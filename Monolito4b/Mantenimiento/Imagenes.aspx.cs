using System;
using System.Collections.Generic;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Capa_Datos;
using Capa_Negocio;

namespace Monolito4b.Mantenimiento
{
    public partial class Imagenes : Page
    {
        // Propiedad que devuelve la ruta física de la carpeta de uploads en el servidor
        // Server.MapPath convierte "~/uploads/" a "C:\...\uploads\" según donde esté el sitio
        private string UploadsDir => Server.MapPath("~/uploads/");

        // HashSet de extensiones permitidas — búsqueda O(1), más rápido que array
        // StringComparer.OrdinalIgnoreCase hace la comparación insensible a mayúsculas
        // (acepta .JPG, .jpg, .Jpg de la misma manera)
        private static readonly HashSet<string> _extsOk =
            new HashSet<string>(StringComparer.OrdinalIgnoreCase)
            { ".jpg", ".jpeg", ".png", ".gif", ".webp", ".bmp" };

        // ── CICLO DE VIDA DE LA PÁGINA ────────────────────────────────────────
        protected void Page_Load(object sender, EventArgs e)
        {
            // Sin <asp:FileUpload> en la página, ASP.NET NO agrega enctype="multipart/form-data"
            // al formulario automáticamente. Sin ese atributo los archivos llegan vacíos al servidor.
            // Aquí se fuerza manualmente para que los archivos del <input type="file"> HTML
            // sí se envíen correctamente en la petición POST.
            Page.Form.Enctype = "multipart/form-data";

            // Solo cargar datos en la primera carga (no en postbacks de botones)
            if (!IsPostBack)
            {
                CargarProductos(); // Llenar el DropDownList de selección de producto
                BindGaleria();     // Mostrar todas las imágenes en el Repeater
            }
        }

        // ── CARGA DE DATOS ────────────────────────────────────────────────────

        // Llena el DropDownList con todos los productos activos
        private void CargarProductos()
        {
            ddlProducto.Items.Clear();
            ddlProducto.Items.Add(new ListItem("— Seleccione producto —", ""));
            // Obtener lista de productos desde la capa de negocio
            foreach (var p in CN_tbl_producto.Listar())
                ddlProducto.Items.Add(new ListItem(p.pro_nombre, p.pro_id.ToString()));
        }

        // Enlaza el Repeater con la lista de imágenes (con filtro opcional por nombre)
        private void BindGaleria(string filtro = "")
        {
            var lista = CN_tbl_imagen_producto.ListarTodos(filtro);
            rptImagenes.DataSource = lista;
            rptImagenes.DataBind(); // Ejecutar enlace — sin esto el Repeater queda vacío

            // Mostrar mensaje de estado vacío si no hay imágenes registradas
            litVacio.Text = lista.Count == 0
                ? "<div class='empty-st'><div class='icon'>🖼️</div>" +
                  "<p>Aún no hay imágenes registradas.</p></div>"
                : "";
        }

        // ── GUARDAR IMÁGENES ─────────────────────────────────────────────────
        // Flujo de un solo paso: subir archivo físico → guardar ruta en BD
        // Si el archivo se sube pero la BD falla, el archivo se borra (rollback físico)
        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            // Validar que se seleccionó un producto antes de subir
            if (string.IsNullOrWhiteSpace(ddlProducto.SelectedValue))
            { Msg("Selecciona un producto.", false); return; }

            // Request.Files contiene todos los archivos enviados en el formulario
            var files = Request.Files;

            // Verificar que llegaron archivos y que al menos uno tiene contenido
            if (files.Count == 0 || AllEmpty(files))
            { Msg("No se recibieron archivos. Selecciona al menos una imagen.", false); return; }

            // Crear la carpeta uploads si no existe (primera vez que se usa el sistema)
            if (!Directory.Exists(UploadsDir)) Directory.CreateDirectory(UploadsDir);

            int proId      = int.Parse(ddlProducto.SelectedValue); // ID del producto seleccionado
            int baseOrden  = int.TryParse(txtOrden.Text, out int ord) ? ord : 0; // Orden inicial
            string setPpal = ddlPrincipal.SelectedValue;  // "S" = marcar primera como principal

            int  guardados = 0;          // Contador de imágenes guardadas con éxito
            bool esPrimera = true;        // Flag para saber cuál es la primera imagen del lote
            var  errores   = new List<string>(); // Lista de errores por archivo

            // Procesar cada archivo recibido
            for (int i = 0; i < files.Count; i++)
            {
                var f = files[i];

                // Saltar archivos vacíos (ContentLength = 0)
                if (f.ContentLength == 0) continue;

                // Validar la extensión del archivo (segunda línea de defensa tras la del cliente)
                string ext = Path.GetExtension(f.FileName ?? "").ToLower();
                if (!_extsOk.Contains(ext))
                { errores.Add(f.FileName + " (formato no permitido)"); continue; }

                // ► PASO 1: Guardar el archivo físico en el servidor
                // Guid.NewGuid().ToString("N") = identificador único de 32 caracteres sin guiones
                // Esto evita colisiones de nombres (dos usuarios subiendo "foto.jpg" a la vez)
                string newName = Guid.NewGuid().ToString("N") + ext;
                string newPath = Path.Combine(UploadsDir, newName);

                try { f.SaveAs(newPath); } // Guardar en disco
                catch (Exception ex) { errores.Add(f.FileName + ": " + ex.Message); continue; }

                // ► PASO 2: Registrar la ruta en la base de datos
                // SOLO se hace si el archivo se guardó físicamente con éxito
                string nombreSinExt = Path.GetFileNameWithoutExtension(f.FileName ?? newName);

                // img_nombre es VARCHAR(100) en la BD — truncar si el nombre es muy largo
                // Se usa 95 como límite para dejar espacio a los "..." (3 caracteres extra)
                if (nombreSinExt.Length > 95) nombreSinExt = nombreSinExt.Substring(0, 95) + "...";

                // Crear el objeto con los datos de la imagen a insertar
                var img = new ImagenProducto
                {
                    pro_id        = proId,
                    img_path      = "~/uploads/" + newName,  // Ruta relativa (no absoluta)
                    img_nombre    = nombreSinExt,
                    img_orden     = baseOrden + guardados,    // Incrementar orden por cada imagen
                    // Solo la primera imagen del lote se marca como principal (si el usuario lo pidió)
                    img_principal = (esPrimera && setPpal == "S") ? "S" : "N"
                };

                string msgBD;
                if (CN_tbl_imagen_producto.Insertar(img, out msgBD))
                {
                    guardados++;       // Incrementar contador de éxito
                    esPrimera = false; // Las siguientes ya no son la primera
                }
                else
                {
                    // ROLLBACK FÍSICO: si la BD falló, eliminar el archivo que ya se subió
                    // para evitar archivos huérfanos en disco sin registro en la BD
                    try { if (File.Exists(newPath)) File.Delete(newPath); } catch { }
                    errores.Add(f.FileName + " (BD): " + msgBD);
                }
            }

            // Actualizar la galería y el UpdatePanel con los nuevos datos
            BindGaleria(txtFiltro.Text.Trim());
            upGaleria.Update();

            // Mostrar mensaje según el resultado del proceso
            if (errores.Count == 0 && guardados > 0)
            {
                // Éxito total: mensaje limpio en verde
                string plural = guardados == 1 ? "imagen guardada" : "imágenes guardadas";
                Msg("✔ " + guardados + " " + plural + " correctamente.", true);
            }
            else if (guardados > 0 && errores.Count > 0)
            {
                // Éxito parcial: algunas se guardaron, otras fallaron
                Msg("✔ " + guardados + " guardada(s). ⚠ No se pudo guardar: " +
                    string.Join("; ", errores), false);
            }
            else
            {
                // Fallo total: ninguna imagen se guardó
                Msg("⚠ No se guardó ninguna imagen. " + string.Join("; ", errores), false);
            }
        }

        // ── FILTRO DE GALERÍA ─────────────────────────────────────────────────
        // Se ejecuta cuando el usuario escribe en el campo de búsqueda (AutoPostBack=true)
        protected void Filtro_Changed(object sender, EventArgs e)
            => BindGaleria(txtFiltro.Text.Trim());

        // ── COMANDOS DEL REPEATER ─────────────────────────────────────────────
        // El Repeater llama este método cuando se hace clic en un botón de cada tarjeta
        // e.CommandName identifica qué botón fue ("Del" o "Ppal")
        // e.CommandArgument contiene el ID o datos del registro afectado
        protected void rptImagenes_ItemCommand(object src, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Del")
            {
                // Eliminar imagen: primero de la BD, luego del disco
                string msgBD, pathBD;
                if (CN_tbl_imagen_producto.Eliminar(
                        Convert.ToInt32(e.CommandArgument), out msgBD, out pathBD))
                {
                    BorrarFisico(pathBD); // Borrar el archivo físico del servidor
                    Msg("✔ Imagen eliminada.", true);
                }
                else Msg("Error: " + msgBD, false);
            }
            else if (e.CommandName == "Ppal")
            {
                // Marcar como principal: CommandArgument tiene formato "imgId|proId"
                var parts = e.CommandArgument.ToString().Split('|');
                string msgBD;
                if (CN_tbl_imagen_producto.MarcarPrincipal(
                        int.Parse(parts[0]), int.Parse(parts[1]), out msgBD))
                    Msg("✔ Imagen marcada como principal.", true);
                else
                    Msg("Error: " + msgBD, false);
            }

            // Refrescar la galería después de cualquier comando
            BindGaleria(txtFiltro.Text.Trim());
            upGaleria.Update();
        }

        // ── HELPERS DE RENDERIZADO PARA EL REPEATER ──────────────────────────

        // Genera el HTML de la imagen con enlace al lightbox
        // idx = índice único de la imagen para el ID del lightbox
        protected string BuildThumbLink(int idx, string path)
        {
            if (string.IsNullOrWhiteSpace(path))
                // Si no hay imagen, mostrar un placeholder con ícono
                return "<div style='width:100%;height:145px;background:#0d0d1a;" +
                       "display:flex;align-items:center;justify-content:center;" +
                       "color:#333;font-size:2.5rem;'>🖼️</div>";

            // ResolveUrl convierte "~/uploads/foto.jpg" a "/uploads/foto.jpg"
            // (o "/miapp/uploads/foto.jpg" si el sitio está en una subcarpeta)
            string url = ResolveUrl(path.Trim());
            return string.Format(
                "<a href='#lb-{0}' class='lb-open'></a>" +  // Enlace que activa el lightbox
                "<img src='{1}' alt='' loading='lazy' " +    // loading=lazy = carga diferida
                "style='width:100%;height:145px;object-fit:cover;display:block;' " +
                "onerror=\"this.style.opacity='.15'\" />",   // Si la imagen no carga, atenuar
                idx, url);
        }

        // Genera el HTML del lightbox (modal de imagen ampliada)
        protected string BuildLightbox(int idx, string path, string caption)
        {
            if (string.IsNullOrWhiteSpace(path)) return "";
            string url = ResolveUrl(path.Trim());
            return string.Format(
                // El id="lb-{idx}" coincide con el href="#lb-{idx}" del link de arriba
                // Usando CSS :target, cuando la URL tiene #lb-1 ese div se hace visible
                "<div id='lb-{0}' class='lb-overlay'>" +
                  "<a href='#' class='lb-close'>&times;</a>" +  // Botón X para cerrar
                  "<img class='lb-img' src='{1}' alt='{2}' />" +
                  "<div class='lb-caption'>{2}</div>" +         // Nombre de la imagen
                "</div>",
                idx, url, HttpUtility.HtmlAttributeEncode(caption ?? ""));
            // HtmlAttributeEncode escapa caracteres especiales para que no rompan el HTML
        }

        // ── UTILIDADES PRIVADAS ───────────────────────────────────────────────

        // Verifica si TODOS los archivos en la colección están vacíos (ContentLength = 0)
        // Retorna true si no hay ningún archivo con contenido real
        private bool AllEmpty(HttpFileCollection files)
        {
            for (int i = 0; i < files.Count; i++)
                if (files[i].ContentLength > 0) return false; // Encontró uno con contenido
            return true; // Todos estaban vacíos
        }

        // Elimina un archivo físico del servidor de forma segura
        // appPath = ruta relativa como "~/uploads/abc123.jpg"
        private void BorrarFisico(string appPath)
        {
            if (string.IsNullOrWhiteSpace(appPath)) return;
            try
            {
                // Server.MapPath convierte la ruta relativa a ruta absoluta del sistema de archivos
                string f = Server.MapPath(appPath.Trim());
                if (File.Exists(f)) File.Delete(f); // Solo borrar si el archivo existe
            }
            catch { } // Silenciar errores de sistema de archivos (permisos, archivo en uso)
        }

        // Muestra un mensaje de retroalimentación al usuario con color según resultado
        private void Msg(string texto, bool ok)
        {
            lblMsg.Text     = texto;
            lblMsg.CssClass = ok ? "msg-ok" : "msg-err"; // CSS verde o rojo
        }
    }
}
