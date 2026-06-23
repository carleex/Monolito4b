using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;

namespace Capa_Datos
{
    /// <summary>
    /// Capa de Datos para la tabla tbl_proveedor.
    /// Contiene los métodos que ejecutan SQL directamente contra la base de datos.
    /// Esta clase NO contiene lógica de negocio — solo acceso a datos.
    /// </summary>
    public class CD_tbl_proveedor
    {
        // Cadena de conexión leída desde Web.config (sección connectionStrings)
        // readonly = solo se asigna una vez (en la declaración), no puede cambiar después
        // static = compartida entre todas las instancias de la clase (eficiencia)
        private static readonly string _conn =
            ConfigurationManager.ConnectionStrings[
                "Capa_Datos.Properties.Settings.Monolito4amConnectionString"].ConnectionString;

        // ── LISTAR TODOS LOS PROVEEDORES ──────────────────────────────────────
        public static List<Proveedor> Listar()
        {
            var lista = new List<Proveedor>();

            // Consulta ordenada por nombre para que el DDL aparezca en orden alfabético
            const string sql =
                "SELECT prov_id, prov_nombre, prov_estado " +
                "FROM tbl_proveedor " +
                "ORDER BY prov_nombre";

            // "using" garantiza que la conexión se cierre aunque haya excepción
            // (equivalente a try/finally con cn.Close())
            using (var cn = new SqlConnection(_conn))
            using (var cm = new SqlCommand(sql, cn))
            {
                cn.Open(); // Abrir conexión con el servidor SQL
                using (var rd = cm.ExecuteReader()) // ExecuteReader = consulta que devuelve filas
                    while (rd.Read()) // Leer fila por fila hasta que no haya más
                        lista.Add(new Proveedor
                        {
                            prov_id     = rd.GetInt32(0),    // Columna 0: prov_id (entero)
                            // IsDBNull verifica si el valor en BD es NULL antes de leerlo
                            // Si es NULL, usar string vacío en lugar de lanzar excepción
                            prov_nombre = rd.IsDBNull(1) ? "" : rd.GetString(1),
                            prov_estado = rd.IsDBNull(2) ? "A" : rd.GetString(2).Trim()
                        });
            }
            return lista;
        }

        // ── INSERTAR NUEVO PROVEEDOR ──────────────────────────────────────────
        /// <summary>
        /// Devuelve true si el INSERT fue exitoso.
        /// El parámetro 'out mensaje' devuelve el error si retorna false.
        /// Usar 'out' en lugar de excepciones permite que la UI muestre el error sin try/catch.
        /// </summary>
        public static bool Insertar(Proveedor p, out string mensaje)
        {
            mensaje = "";
            try
            {
                using (var cn = new SqlConnection(_conn))
                using (var cm = new SqlCommand(
                    "INSERT INTO tbl_proveedor (prov_nombre, prov_estado) VALUES (@n, @e)", cn))
                {
                    // AddWithValue agrega el parámetro con detección automática del tipo SQL
                    // El cast (object) permite que ?? DBNull.Value funcione:
                    // si prov_nombre es null en C#, se guarda NULL en la BD
                    cm.Parameters.AddWithValue("@n", (object)p.prov_nombre ?? DBNull.Value);
                    cm.Parameters.AddWithValue("@e", p.prov_estado ?? "A");
                    cn.Open();
                    cm.ExecuteNonQuery(); // ExecuteNonQuery = INSERT/UPDATE/DELETE (sin filas de retorno)
                }
                return true;
            }
            catch (Exception ex)
            {
                mensaje = ex.Message; // Capturar el mensaje del error SQL
                return false;
            }
        }

        // ── ACTUALIZAR PROVEEDOR EXISTENTE ────────────────────────────────────
        public static bool Actualizar(Proveedor p, out string mensaje)
        {
            mensaje = "";
            try
            {
                using (var cn = new SqlConnection(_conn))
                using (var cm = new SqlCommand(
                    "UPDATE tbl_proveedor SET prov_nombre=@n, prov_estado=@e " +
                    "WHERE prov_id=@id", cn))
                {
                    cm.Parameters.AddWithValue("@n",  (object)p.prov_nombre ?? DBNull.Value);
                    cm.Parameters.AddWithValue("@e",  p.prov_estado ?? "A");
                    cm.Parameters.AddWithValue("@id", p.prov_id); // Condición WHERE
                    cn.Open();
                    cm.ExecuteNonQuery();
                }
                return true;
            }
            catch (Exception ex) { mensaje = ex.Message; return false; }
        }

        // ── BAJA LÓGICA CON TRANSACCIÓN ───────────────────────────────────────
        /// <summary>
        /// Inactiva el proveedor (prov_estado='I') Y sus productos hijos (pro_estado='I')
        /// dentro de una TRANSACCIÓN SQL.
        ///
        /// Qué es una transacción:
        ///   Un bloque de operaciones que se tratan como una sola unidad atómica.
        ///   Si CUALQUIER paso falla, se hace Rollback: TODAS las operaciones se revierten
        ///   como si nunca hubieran ocurrido.
        ///   Si TODOS los pasos tienen éxito, se hace Commit: los cambios se guardan definitivamente.
        ///
        /// Por qué se necesita aquí:
        ///   Sin transacción, si el paso 1 (inactivar proveedor) tiene éxito pero el paso 2
        ///   (inactivar productos) falla, quedarían datos inconsistentes:
        ///   proveedor inactivo pero productos activos — estado contradictorio en la BD.
        /// </summary>
        public static bool BajaLogica(int prov_id, out string mensaje)
        {
            mensaje = "";
            using (var cn = new SqlConnection(_conn))
            {
                cn.Open();

                // BeginTransaction abre la transacción con un nombre descriptivo
                // (el nombre sirve para rollbacks parciales en transacciones anidadas)
                SqlTransaction tx = cn.BeginTransaction("BajaProveedor");
                try
                {
                    // ── PASO 1: Inactivar el proveedor padre ─────────────────
                    using (var cm = new SqlCommand(
                        "UPDATE tbl_proveedor SET prov_estado='I' " +
                        "WHERE prov_id=@id", cn, tx)) // tx vincula este comando a la transacción
                    {
                        cm.Parameters.AddWithValue("@id", prov_id);
                        int filas = cm.ExecuteNonQuery(); // Retorna cuántas filas se afectaron

                        // Si no se afectó ninguna fila, el proveedor no existe o ya está inactivo
                        if (filas == 0)
                            throw new Exception("Proveedor no encontrado o ya está inactivo.");
                    }

                    // ── PASO 2: Inactivar todos los productos hijos activos ───
                    // La condición AND pro_estado='A' evita tocar productos ya inactivos
                    using (var cm = new SqlCommand(
                        "UPDATE tbl_producto SET pro_estado='I' " +
                        "WHERE prov_id=@id AND pro_estado='A'", cn, tx))
                    {
                        cm.Parameters.AddWithValue("@id", prov_id);
                        cm.ExecuteNonQuery(); // Puede afectar 0 filas si no tiene productos — está bien
                    }

                    // Ambos pasos exitosos: confirmar y guardar los cambios en la BD
                    tx.Commit();
                    return true;
                }
                catch (Exception ex)
                {
                    // Algún paso falló: revertir AMBAS operaciones al estado anterior
                    tx.Rollback("BajaProveedor");
                    mensaje = $"Operación revertida (Rollback). {ex.Message}";
                    return false;
                }
            }
        }

        // ── RESTAURAR PROVEEDOR Y SUS PRODUCTOS ───────────────────────────────
        /// <summary>
        /// Reactiva el proveedor (prov_estado='A') Y sus productos inactivos.
        /// También usa SqlTransaction por la misma razón que BajaLogica:
        /// garantizar consistencia entre las dos tablas.
        /// </summary>
        public static bool RestaurarProveedor(int prov_id, out string mensaje)
        {
            mensaje = "";
            using (var cn = new SqlConnection(_conn))
            {
                cn.Open();
                SqlTransaction tx = cn.BeginTransaction("RestaurarProveedor");
                try
                {
                    // ── PASO 1: Reactivar el proveedor ───────────────────────
                    using (var cm = new SqlCommand(
                        "UPDATE tbl_proveedor SET prov_estado='A' WHERE prov_id=@id", cn, tx))
                    {
                        cm.Parameters.AddWithValue("@id", prov_id);
                        cm.ExecuteNonQuery();
                    }

                    // ── PASO 2: Reactivar productos que estaban inactivos ────
                    // Solo los que tenían pro_estado='I' (posiblemente por esta misma baja)
                    using (var cm = new SqlCommand(
                        "UPDATE tbl_producto SET pro_estado='A' " +
                        "WHERE prov_id=@id AND pro_estado='I'", cn, tx))
                    {
                        cm.Parameters.AddWithValue("@id", prov_id);
                        cm.ExecuteNonQuery();
                    }

                    tx.Commit(); // Confirmar ambos cambios
                    return true;
                }
                catch (Exception ex)
                {
                    tx.Rollback("RestaurarProveedor"); // Revertir si algo falla
                    mensaje = $"Restauración revertida (Rollback). {ex.Message}";
                    return false;
                }
            }
        }
    }
}
