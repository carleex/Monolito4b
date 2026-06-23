using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;

namespace Capa_Datos
{
    public class CD_tbl_producto
    {
        private static readonly string _conn =
            ConfigurationManager.ConnectionStrings[
                "Capa_Datos.Properties.Settings.Monolito4amConnectionString"].ConnectionString;

        private static Producto MapRow(SqlDataReader rd)
        {
            return new Producto
            {
                pro_id         = rd.GetInt32(0),
                pro_nombre     = rd.IsDBNull(1) ? "" : rd.GetString(1),
                pro_cantidad   = rd.IsDBNull(2) ? 0  : rd.GetInt32(2),
                pro_precio     = rd.IsDBNull(3) ? 0m : rd.GetDecimal(3),
                pro_estado     = rd.IsDBNull(4) ? "A": rd.GetString(4).Trim(),
                prov_id        = rd.IsDBNull(5) ? (int?)null : rd.GetInt32(5),
                pro_imagen_path= rd.IsDBNull(6) ? "" : rd.GetString(6),
                pro_categoria  = rd.IsDBNull(7) ? "" : rd.GetString(7)
            };
        }

        public static List<Producto> Listar(string nombre = "", string categoria = "")
        {
            var lista = new List<Producto>();
            const string sql = @"
                SELECT pro_id, pro_nombre, pro_cantidad, pro_precio, pro_estado,
                       prov_id, pro_imagen_path, pro_categoria
                FROM   tbl_producto
                WHERE  pro_estado = 'A'
                  AND (@nombre = '' OR pro_nombre LIKE '%' + @nombre + '%')
                  AND (@cat    = '' OR pro_categoria = @cat)
                ORDER  BY pro_nombre";

            using (var cn = new SqlConnection(_conn))
            using (var cm = new SqlCommand(sql, cn))
            {
                cm.Parameters.AddWithValue("@nombre", nombre   ?? "");
                cm.Parameters.AddWithValue("@cat",    categoria ?? "");
                cn.Open();
                using (var rd = cm.ExecuteReader())
                    while (rd.Read())
                        lista.Add(MapRow(rd));
            }
            return lista;
        }

        public static List<string> ListarCategorias()
        {
            var lista = new List<string>();
            using (var cn = new SqlConnection(_conn))
            using (var cm = new SqlCommand(
                "SELECT DISTINCT pro_categoria FROM tbl_producto " +
                "WHERE pro_categoria IS NOT NULL AND pro_categoria <> '' ORDER BY pro_categoria", cn))
            {
                cn.Open();
                using (var rd = cm.ExecuteReader())
                    while (rd.Read())
                        lista.Add(rd.GetString(0));
            }
            return lista;
        }

        public static bool Insertar(Producto p, out string mensaje)
        {
            mensaje = "";
            try
            {
                using (var cn = new SqlConnection(_conn))
                using (var cm = new SqlCommand(@"
                    INSERT INTO tbl_producto
                        (pro_nombre, pro_cantidad, pro_precio, pro_estado,
                         prov_id, pro_imagen_path, pro_categoria)
                    VALUES (@n, @c, @pr, @e, @pv, @img, @cat)", cn))
                {
                    SetParams(cm, p);
                    cn.Open();
                    cm.ExecuteNonQuery();
                }
                return true;
            }
            catch (Exception ex) { mensaje = ex.Message; return false; }
        }

        public static bool Actualizar(Producto p, out string mensaje)
        {
            mensaje = "";
            try
            {
                using (var cn = new SqlConnection(_conn))
                using (var cm = new SqlCommand(@"
                    UPDATE tbl_producto
                    SET    pro_nombre=@n, pro_cantidad=@c, pro_precio=@pr, pro_estado=@e,
                           prov_id=@pv, pro_imagen_path=@img, pro_categoria=@cat
                    WHERE  pro_id=@id", cn))
                {
                    SetParams(cm, p);
                    cm.Parameters.AddWithValue("@id", p.pro_id);
                    cn.Open();
                    cm.ExecuteNonQuery();
                }
                return true;
            }
            catch (Exception ex) { mensaje = ex.Message; return false; }
        }

        public static bool BajaLogica(int pro_id, out string mensaje)
        {
            mensaje = "";
            try
            {
                using (var cn = new SqlConnection(_conn))
                using (var cm = new SqlCommand(
                    "UPDATE tbl_producto SET pro_estado='I' WHERE pro_id=@id", cn))
                {
                    cm.Parameters.AddWithValue("@id", pro_id);
                    cn.Open();
                    cm.ExecuteNonQuery();
                }
                return true;
            }
            catch (Exception ex) { mensaje = ex.Message; return false; }
        }

        /// <summary>
        /// Inserción masiva con SqlTransaction.
        /// Si prov_id no existe en tbl_proveedor se pone NULL (no viola FK).
        /// </summary>
        public static bool InsertarMasivo(List<Producto> lista, out string mensaje)
        {
            mensaje = "";
            using (var cn = new SqlConnection(_conn))
            {
                cn.Open();

                // Cargar IDs válidos de proveedores para validar antes de insertar
                var provIdsValidos = new HashSet<int>();
                using (var cm2 = new SqlCommand(
                    "SELECT prov_id FROM tbl_proveedor WHERE prov_estado='A'", cn))
                using (var rd = cm2.ExecuteReader())
                    while (rd.Read()) provIdsValidos.Add(rd.GetInt32(0));

                SqlTransaction tx = cn.BeginTransaction("InsertMasivo");
                try
                {
                    foreach (var p in lista)
                    {
                        // Si prov_id no es válido, enviarlo como NULL
                        if (p.prov_id.HasValue && !provIdsValidos.Contains(p.prov_id.Value))
                            p.prov_id = null;

                        using (var cm = new SqlCommand(@"
                            INSERT INTO tbl_producto
                                (pro_nombre, pro_cantidad, pro_precio, pro_estado,
                                 prov_id, pro_imagen_path, pro_categoria)
                            VALUES (@n, @c, @pr, @e, @pv, @img, @cat)", cn, tx))
                        {
                            SetParams(cm, p);
                            cm.ExecuteNonQuery();
                        }
                    }
                    tx.Commit();
                    mensaje = $"{lista.Count} registro(s) insertados correctamente.";
                    return true;
                }
                catch (Exception ex)
                {
                    tx.Rollback("InsertMasivo");
                    mensaje = $"Lote revertido (Rollback). {ex.Message}";
                    return false;
                }
            }
        }

        private static void SetParams(SqlCommand cm, Producto p)
        {
            cm.Parameters.AddWithValue("@n",   (object)p.pro_nombre     ?? DBNull.Value);
            cm.Parameters.AddWithValue("@c",   p.pro_cantidad);
            cm.Parameters.AddWithValue("@pr",  p.pro_precio);
            cm.Parameters.AddWithValue("@e",   p.pro_estado ?? "A");
            cm.Parameters.AddWithValue("@pv",  (object)p.prov_id        ?? DBNull.Value);
            cm.Parameters.AddWithValue("@img", (object)p.pro_imagen_path ?? DBNull.Value);
            cm.Parameters.AddWithValue("@cat", (object)p.pro_categoria   ?? DBNull.Value);
        }
    }
}
