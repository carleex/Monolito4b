using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;

namespace Capa_Datos
{
    /// <summary>
    /// CRUD para tbl_imagen_producto (N imágenes por producto).
    /// El archivo físico se sube PRIMERO al servidor; este método solo
    /// guarda la ruta una vez confirmada la subida.
    /// </summary>
    public class CD_tbl_imagen_producto
    {
        private static readonly string _conn =
            ConfigurationManager.ConnectionStrings[
                "Capa_Datos.Properties.Settings.Monolito4amConnectionString"].ConnectionString;

        private static ImagenProducto MapRow(SqlDataReader rd) => new ImagenProducto
        {
            img_id       = rd.GetInt32(0),
            pro_id       = rd.GetInt32(1),
            img_path     = rd.IsDBNull(2) ? "" : rd.GetString(2),
            img_nombre   = rd.IsDBNull(3) ? "" : rd.GetString(3),
            img_orden    = rd.IsDBNull(4) ? 0  : rd.GetInt32(4),
            img_principal= rd.IsDBNull(5) ? "N": rd.GetString(5).Trim(),
            img_fecha    = rd.IsDBNull(6) ? DateTime.Now : rd.GetDateTime(6),
            pro_nombre   = rd.FieldCount > 7 && !rd.IsDBNull(7) ? rd.GetString(7) : ""
        };

        /// <summary>Obtiene todas las imágenes de un producto.</summary>
        public static List<ImagenProducto> ListarPorProducto(int pro_id)
        {
            var lista = new List<ImagenProducto>();
            const string sql = @"
                SELECT i.img_id, i.pro_id, i.img_path, i.img_nombre,
                       i.img_orden, i.img_principal, i.img_fecha, p.pro_nombre
                FROM   tbl_imagen_producto i
                INNER JOIN tbl_producto p ON p.pro_id = i.pro_id
                WHERE  i.pro_id = @pid
                ORDER  BY i.img_principal DESC, i.img_orden, i.img_fecha";
            using (var cn = new SqlConnection(_conn))
            using (var cm = new SqlCommand(sql, cn))
            {
                cm.Parameters.AddWithValue("@pid", pro_id);
                cn.Open();
                using (var rd = cm.ExecuteReader())
                    while (rd.Read()) lista.Add(MapRow(rd));
            }
            return lista;
        }

        /// <summary>Lista todas las imágenes (para exportar o administrar).</summary>
        public static List<ImagenProducto> ListarTodos(string nombreProducto = "")
        {
            var lista = new List<ImagenProducto>();
            const string sql = @"
                SELECT i.img_id, i.pro_id, i.img_path, i.img_nombre,
                       i.img_orden, i.img_principal, i.img_fecha, p.pro_nombre
                FROM   tbl_imagen_producto i
                INNER JOIN tbl_producto p ON p.pro_id = i.pro_id
                WHERE  (@nom = '' OR p.pro_nombre LIKE '%' + @nom + '%')
                ORDER  BY p.pro_nombre, i.img_principal DESC, i.img_orden";
            using (var cn = new SqlConnection(_conn))
            using (var cm = new SqlCommand(sql, cn))
            {
                cm.Parameters.AddWithValue("@nom", nombreProducto ?? "");
                cn.Open();
                using (var rd = cm.ExecuteReader())
                    while (rd.Read()) lista.Add(MapRow(rd));
            }
            return lista;
        }

        /// <summary>
        /// Guarda la ruta en BD DESPUÉS de que el archivo ya fue subido físicamente.
        /// Si img_principal='S', desmarca el resto de imágenes del producto.
        /// </summary>
        public static bool Insertar(ImagenProducto img, out string mensaje)
        {
            mensaje = "";
            using (var cn = new SqlConnection(_conn))
            {
                cn.Open();
                var tx = cn.BeginTransaction("InsertImagen");
                try
                {
                    if (img.img_principal == "S")
                    {
                        using (var cm = new SqlCommand(
                            "UPDATE tbl_imagen_producto SET img_principal='N' WHERE pro_id=@pid", cn, tx))
                        {
                            cm.Parameters.AddWithValue("@pid", img.pro_id);
                            cm.ExecuteNonQuery();
                        }
                    }

                    using (var cm = new SqlCommand(@"
                        INSERT INTO tbl_imagen_producto
                            (pro_id, img_path, img_nombre, img_orden, img_principal)
                        VALUES (@pid, @path, @nom, @ord, @ppal)", cn, tx))
                    {
                        cm.Parameters.AddWithValue("@pid",  img.pro_id);
                        cm.Parameters.AddWithValue("@path", (object)img.img_path   ?? DBNull.Value);
                        cm.Parameters.AddWithValue("@nom",  (object)img.img_nombre ?? DBNull.Value);
                        cm.Parameters.AddWithValue("@ord",  img.img_orden);
                        cm.Parameters.AddWithValue("@ppal", img.img_principal ?? "N");
                        cm.ExecuteNonQuery();
                    }
                    tx.Commit();
                    return true;
                }
                catch (Exception ex)
                {
                    tx.Rollback("InsertImagen");
                    mensaje = ex.Message;
                    return false;
                }
            }
        }

        /// <summary>Elimina el registro de BD (el archivo físico lo borra el caller).</summary>
        public static bool Eliminar(int img_id, out string mensaje, out string pathEliminado)
        {
            mensaje = ""; pathEliminado = "";
            try
            {
                using (var cn = new SqlConnection(_conn))
                {
                    cn.Open();
                    // Obtener el path antes de eliminar para poder borrar el archivo
                    using (var cm = new SqlCommand(
                        "SELECT img_path FROM tbl_imagen_producto WHERE img_id=@id", cn))
                    {
                        cm.Parameters.AddWithValue("@id", img_id);
                        var r = cm.ExecuteScalar();
                        pathEliminado = r == null ? "" : r.ToString();
                    }
                    using (var cm = new SqlCommand(
                        "DELETE FROM tbl_imagen_producto WHERE img_id=@id", cn))
                    {
                        cm.Parameters.AddWithValue("@id", img_id);
                        cm.ExecuteNonQuery();
                    }
                }
                return true;
            }
            catch (Exception ex) { mensaje = ex.Message; return false; }
        }

        /// <summary>Marca una imagen como principal del producto (desmarca las demás).</summary>
        public static bool MarcarPrincipal(int img_id, int pro_id, out string mensaje)
        {
            mensaje = "";
            using (var cn = new SqlConnection(_conn))
            {
                cn.Open();
                var tx = cn.BeginTransaction("MarcaPrincipal");
                try
                {
                    using (var cm = new SqlCommand(
                        "UPDATE tbl_imagen_producto SET img_principal='N' WHERE pro_id=@pid", cn, tx))
                    {
                        cm.Parameters.AddWithValue("@pid", pro_id);
                        cm.ExecuteNonQuery();
                    }
                    using (var cm = new SqlCommand(
                        "UPDATE tbl_imagen_producto SET img_principal='S' WHERE img_id=@id", cn, tx))
                    {
                        cm.Parameters.AddWithValue("@id", img_id);
                        cm.ExecuteNonQuery();
                    }
                    tx.Commit();
                    return true;
                }
                catch (Exception ex)
                {
                    tx.Rollback("MarcaPrincipal");
                    mensaje = ex.Message;
                    return false;
                }
            }
        }
    }
}
