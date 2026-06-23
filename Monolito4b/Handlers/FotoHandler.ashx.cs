using System;
using System.Linq;
using System.Web;
using Capa_Datos;
using Capa_Negocio;

namespace Monolito4b.Handlers
{
    /// <summary>
    /// Sirve fotos de perfil almacenadas en la BD.
    /// Uso: FotoHandler.ashx?usu_id=5  (foto principal)
    ///      FotoHandler.ashx?foto_id=12 (foto específica)
    /// </summary>
    public class FotoHandler : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            byte[] bytes = null;
            string tipo  = "image/jpeg";

            // Por foto_id específico
            if (!string.IsNullOrEmpty(context.Request.QueryString["foto_id"]))
            {
                int fotoId = int.Parse(context.Request.QueryString["foto_id"]);
                using (var dc = new BasededatosDataContext())
                {
                    var foto = dc.tbl_foto_usuario.FirstOrDefault(f => f.foto_id == fotoId);
                    if (foto?.foto_imagen != null)
                    {
                        bytes = foto.foto_imagen.ToArray();
                        tipo  = foto.foto_tipo ?? "image/jpeg";
                    }
                }
            }
            // Por usu_id → foto principal
            else if (!string.IsNullOrEmpty(context.Request.QueryString["usu_id"]))
            {
                int usuId = int.Parse(context.Request.QueryString["usu_id"]);
                var foto  = CN_tbl_foto_usuario.ObtenerFotoPrincipal(usuId);
                if (foto?.foto_imagen != null)
                {
                    bytes = foto.foto_imagen.ToArray();
                    tipo  = foto.foto_tipo ?? "image/jpeg";
                }
            }

            if (bytes != null)
            {
                context.Response.ContentType = tipo;
                context.Response.Cache.SetCacheability(HttpCacheability.Public);
                context.Response.Cache.SetMaxAge(TimeSpan.FromMinutes(10));
                context.Response.BinaryWrite(bytes);
            }
            else
            {
                // Imagen placeholder transparente 1x1 PNG
                byte[] png1x1 = Convert.FromBase64String(
                    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==");
                context.Response.ContentType = "image/png";
                context.Response.BinaryWrite(png1x1);
            }
        }

        public bool IsReusable => false;
    }
}
