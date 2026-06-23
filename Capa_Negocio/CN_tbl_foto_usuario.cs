using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Capa_Datos;

namespace Capa_Negocio
{
    public class CN_tbl_foto_usuario
    {
        /// Guarda una nueva foto; si es la primera del usuario la marca como principal.</summary>
        public static void GuardarFoto(int usu_id, byte[] imagen, string nombre, string tipo)
        {
            using (BasededatosDataContext dc = new BasededatosDataContext())
            {
                bool esPrimera = !dc.tbl_foto_usuario.Any(f => f.usu_id == usu_id);

                tbl_foto_usuario foto = new tbl_foto_usuario
                {
                    usu_id         = usu_id,
                    foto_imagen    = imagen,
                    foto_nombre    = nombre,
                    foto_tipo      = tipo,
                    foto_fecha     = DateTime.Now,
                    foto_principal = esPrimera ? 'S' : 'N'
                };
                dc.tbl_foto_usuario.InsertOnSubmit(foto);
                dc.SubmitChanges();
            }
        }

        /// Retorna la foto principal del usuario, o null si no tiene.
        public static tbl_foto_usuario ObtenerFotoPrincipal(int usu_id)
        {
            using (BasededatosDataContext dc = new BasededatosDataContext())
            {
                return dc.tbl_foto_usuario
                    .Where(f => f.usu_id == usu_id && f.foto_principal == 'S')
                    .FirstOrDefault();
            }
        }

        /// Reemplaza la foto principal del usuario: elimina todas las anteriores
        /// e inserta la nueva como principal. Ideal para actualizar el avatar.
        public static void ReemplazarFoto(int usu_id, byte[] imagen, string nombre, string tipo)
        {
            using (BasededatosDataContext dc = new BasededatosDataContext())
            {
                // Borrar todas las fotos anteriores del usuario
                var anteriores = dc.tbl_foto_usuario.Where(f => f.usu_id == usu_id);
                dc.tbl_foto_usuario.DeleteAllOnSubmit(anteriores);
                dc.SubmitChanges();

                // Insertar la nueva como principal
                tbl_foto_usuario foto = new tbl_foto_usuario
                {
                    usu_id         = usu_id,
                    foto_imagen    = imagen,
                    foto_nombre    = nombre,
                    foto_tipo      = tipo,
                    foto_fecha     = DateTime.Now,
                    foto_principal = 'S'
                };
                dc.tbl_foto_usuario.InsertOnSubmit(foto);
                dc.SubmitChanges();
            }
        }

        /// <summary>Retorna todas las fotos del usuario.</summary>
        public static List<tbl_foto_usuario> ObtenerFotos(int usu_id)
        {
            using (BasededatosDataContext dc = new BasededatosDataContext())
            {
                return dc.tbl_foto_usuario
                    .Where(f => f.usu_id == usu_id)
                    .OrderByDescending(f => f.foto_fecha)
                    .ToList();
            }
        }
    }
}
