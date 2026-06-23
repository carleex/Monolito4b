using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Capa_Datos;
using Capa_Negocio;

namespace Monolito4b.Mantenimiento
{
    public partial class Productos : Page
    {
        // ── CICLO DE VIDA DE LA PÁGINA ────────────────────────────────────────
        protected void Page_Load(object sender, EventArgs e)
        {
            // IsPostBack es false solo en la primera carga de la página.
            // En postbacks (clic de botones, paginación, filtros) NO se entra aquí,
            // evitando recargar los dropdowns y el grid innecesariamente.
            if (!IsPostBack)
            {
                CargarProveedores();      // Llenar DDL del formulario
                CargarCategoriasFiltro(); // Llenar DDL del filtro de búsqueda
                BindGrid();               // Mostrar la tabla de productos
            }
        }

        // ── CARGA DE LISTAS PARA LOS CONTROLES ────────────────────────────────

        // Rellena el DropDownList de proveedores en el formulario
        private void CargarProveedores()
        {
            ddlProveedor.Items.Clear();
            // Item vacío por defecto para el caso "sin proveedor"
            ddlProveedor.Items.Add(new ListItem("— Sin proveedor —", ""));
            // Agregar un item por cada proveedor activo en la BD
            foreach (var p in CN_tbl_proveedor.Listar())
                ddlProveedor.Items.Add(new ListItem(p.prov_nombre, p.prov_id.ToString()));
        }

        // Rellena el DropDownList de filtro de categorías (encima de la tabla)
        private void CargarCategoriasFiltro()
        {
            ddlFiltroCategoria.Items.Clear();
            ddlFiltroCategoria.Items.Add(new ListItem("— Todas —", ""));
            // ListarCategorias devuelve los valores DISTINCT de pro_categoria en la BD
            foreach (var c in CN_tbl_producto.ListarCategorias())
                ddlFiltroCategoria.Items.Add(new ListItem(c, c));
        }

        // Enlaza el GridView con los productos filtrados según los controles actuales
        private void BindGrid()
        {
            // Pasar los filtros actuales a la consulta de BD
            var lista = CN_tbl_producto.Listar(
                txtBuscar.Text.Trim(),               // Filtro por nombre (puede ser vacío)
                ddlFiltroCategoria.SelectedValue);    // Filtro por categoría (puede ser vacío)
            gvProductos.DataSource = lista;
            gvProductos.DataBind(); // Ejecutar el enlace — sin esto la tabla no se actualiza
        }

        // ── RENDERIZADO DE MINIATURAS EN LA TABLA ────────────────────────────
        /// <summary>
        /// Método llamado desde el ASPX con <%# RenderMiniaturas(Eval("pro_id")) %>
        /// Devuelve HTML con miniaturas de las imágenes del producto y botón del viewer.
        /// Se ejecuta una vez por cada fila del GridView durante el DataBind.
        /// </summary>
        protected string RenderMiniaturas(object proIdObj)
        {
            int proId;
            // Intentar convertir el valor de la celda a entero
            // El operador ?. evita NullReferenceException si proIdObj es null
            if (!int.TryParse(proIdObj?.ToString(), out proId)) return "";

            // Obtener las imágenes del producto desde la capa de negocio
            var imgs = CN_tbl_imagen_producto.ListarPorProducto(proId);

            // Si no hay imágenes en tbl_imagen_producto, buscar la imagen legacy
            // (campo pro_imagen_path de tbl_producto, de versiones anteriores del sistema)
            if (imgs.Count == 0)
            {
                var prod = CN_tbl_producto.Listar().FirstOrDefault(x => x.pro_id == proId);
                if (prod != null && !string.IsNullOrWhiteSpace(prod.pro_imagen_path))
                    imgs.Add(new ImagenProducto
                    {
                        img_id        = -1,              // -1 indica imagen legacy
                        img_path      = prod.pro_imagen_path,
                        img_principal = "S",
                        img_nombre    = ""
                    });
            }

            // Si no hay ninguna imagen, mostrar ícono vacío
            if (imgs.Count == 0)
                return "<div class='thumbs-wrap'>" +
                       "<span style='color:#333;font-size:1.3rem;'>🖼️</span>" +
                       "</div>";

            // Obtener el nombre del producto para el título del viewer
            var p0 = CN_tbl_producto.Listar().FirstOrDefault(x => x.pro_id == proId);
            // JavaScriptStringEncode escapa el nombre para usarlo seguro dentro de onclick="..."
            string prodNom = HttpUtility.JavaScriptStringEncode(p0?.pro_nombre ?? "");

            var sb = new StringBuilder("<div class='thumbs-wrap'><div class='thumbs-row'>");

            // Mostrar hasta 3 miniaturas para no ocupar demasiado espacio en la fila
            int show = Math.Min(imgs.Count, 3);
            for (int i = 0; i < show; i++)
            {
                // ResolveUrl convierte "~/uploads/foto.jpg" a "/uploads/foto.jpg"
                string url = ResolveUrl((imgs[i].img_path ?? "").Trim());
                sb.AppendFormat(
                    "<img class='thumb-mini' src='{0}' alt='' loading='lazy' " +
                    // Al hacer clic en la miniatura, llamar al Gallery Viewer con el ID del producto
                    "onclick=\"GV.open({1},'{2}')\" " +
                    // Si la imagen no carga (URL rota), atenuar visualmente en lugar de mostrar el ícono roto
                    "onerror=\"this.style.opacity='.15'\" />",
                    url, proId, prodNom);
            }

            sb.Append("</div>");

            // Botón que muestra el total de imágenes y abre el Gallery Viewer
            string label = imgs.Count == 1 ? "1 imagen" : imgs.Count + " imágenes";
            sb.AppendFormat(
                "<button type='button' class='btn-ver-imgs' onclick=\"GV.open({0},'{1}')\">" +
                "📷 {2}</button>",
                proId, prodNom, label);

            sb.Append("</div>");
            return sb.ToString();
        }

        /// <summary>
        /// Método de compatibilidad para código antiguo que use pro_imagen_path directamente.
        /// Genera el HTML de una imagen simple (sin galería).
        /// </summary>
        protected string RenderImagen(string path)
        {
            if (string.IsNullOrWhiteSpace(path))
                // Placeholder cuando no hay imagen asignada
                return "<div style='width:46px;height:46px;background:#1a1a2e;border-radius:5px;" +
                       "display:flex;align-items:center;justify-content:center;color:#444;font-size:18px;'>&#128247;</div>";
            string url = ResolveUrl(path.Trim());
            return "<img class='prod-thumb' src='" + url + "' alt='producto' />";
        }

        // ── FILTROS EN TIEMPO REAL (dentro del UpdatePanel) ───────────────────
        // Se ejecuta cuando el usuario escribe en el TextBox (AutoPostBack=true) 
        // o cambia la categoría. El UpdatePanel hace que solo se actualice la tabla,
        // no la página completa.
        protected void FiltroChanged(object sender, EventArgs e)
        {
            gvProductos.PageIndex = 0; // Volver a la primera página al cambiar el filtro
            BindGrid();
        }

        // Se ejecuta cuando el usuario hace clic en un número de página del GridView
        protected void gvProductos_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            // e.NewPageIndex = índice de la página seleccionada (base 0)
            gvProductos.PageIndex = e.NewPageIndex;
            BindGrid(); // Recargar con la nueva página
        }

        // ── COMANDOS DEL GRIDVIEW (Editar / Baja) ─────────────────────────────
        // Se ejecuta cuando el usuario hace clic en "Editar" o "Baja" en cualquier fila
        // e.CommandName = nombre del comando ("Editar" o "Baja")
        // e.CommandArgument = valor de CommandArgument (pro_id del producto)
        protected void gvProductos_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "Baja")
            {
                // Baja lógica: cambia pro_estado a 'I' sin borrar el registro
                string msg;
                if (CN_tbl_producto.BajaLogica(id, out msg))
                    MostrarMsg("Baja logica aplicada.", true);
                else
                    MostrarMsg(msg, false);
                BindGrid(); // Actualizar tabla para reflejar el cambio
                return;
            }

            if (e.CommandName == "Editar")
            {
                // Buscar el producto por ID en la lista
                var lista = CN_tbl_producto.Listar();
                var p = lista.FirstOrDefault(x => x.pro_id == id);
                if (p == null) return; // Producto no encontrado (raro, pero seguro)

                // Guardar los datos del producto en HiddenFields DENTRO del UpdatePanel.
                // El formulario está FUERA del UpdatePanel (necesario para FileUpload).
                // El JavaScript en 'endRequest' los leerá y poblará el formulario
                // sin que el usuario tenga que recargar la página.
                hfEditId.Value        = p.pro_id.ToString();
                hfEditNombre.Value    = p.pro_nombre    ?? "";
                hfEditCantidad.Value  = p.pro_cantidad.ToString();
                hfEditPrecio.Value    = p.pro_precio.ToString("F2"); // "F2" = 2 decimales fijos
                hfEditCategoria.Value = p.pro_categoria ?? "";
                hfEditEstado.Value    = (p.pro_estado   ?? "A").Trim();
                hfEditProvId.Value    = p.prov_id.HasValue ? p.prov_id.Value.ToString() : "";
                // Resolver URL de imagen para mostrar la preview actual en el formulario
                hfEditImagen.Value    = string.IsNullOrWhiteSpace(p.pro_imagen_path)
                    ? ""
                    : ResolveUrl(p.pro_imagen_path.Trim());

                // Actualizar solo el UpdatePanel (no toda la página)
                upGrid.Update();
            }
        }

        // ── GUARDAR PRODUCTO (INSERT o UPDATE) ────────────────────────────────
        // Este evento hace un postback COMPLETO (no pasa por el UpdatePanel)
        // porque necesita procesar el FileUpload — los controles FileUpload
        // no funcionan dentro de UpdatePanel en ASP.NET WebForms.
        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            // Construir el objeto Producto con los valores del formulario
            var p = new Producto
            {
                // hfProId.Value = "0" si es nuevo, o el ID real si es edición
                pro_id        = Convert.ToInt32(hfProId.Value),
                pro_nombre    = txtNombre.Text.Trim(),
                // TryParse con valor por defecto: si el texto no es número, usar 0
                pro_cantidad  = int.TryParse(txtCantidad.Text, out int qty) ? qty : 0,
                // Reemplazar coma por punto para manejar locales que usan coma decimal
                pro_precio    = decimal.TryParse(txtPrecio.Text.Replace(",", "."),
                                    System.Globalization.NumberStyles.Any,
                                    System.Globalization.CultureInfo.InvariantCulture, out decimal pr)
                                ? pr : 0m,
                pro_estado    = ddlEstado.SelectedValue,     // "A" o "I"
                pro_categoria = txtCategoria.Text.Trim(),
                // Si el DDL tiene "" seleccionado, guardar null en la BD (nullable int)
                prov_id       = string.IsNullOrWhiteSpace(ddlProveedor.SelectedValue)
                                ? (int?)null
                                : int.Parse(ddlProveedor.SelectedValue)
            };

            // ── Procesar imagen si se subió una nueva ────────────────────────
            if (fuImagen.HasFile)
            {
                // Validar formato en el servidor (segunda línea de defensa tras el 'accept' del input)
                string ext = Path.GetExtension(fuImagen.FileName).ToLower();
                if (ext != ".jpg" && ext != ".jpeg" && ext != ".png" &&
                    ext != ".gif" && ext != ".webp" && ext != ".bmp")
                { MostrarMsg("Formato no permitido. Use JPG, PNG, GIF, WEBP o BMP.", false); return; }

                // Crear la carpeta uploads si no existe (primera vez del sistema)
                string folder = Server.MapPath("~/uploads/");
                if (!Directory.Exists(folder)) Directory.CreateDirectory(folder);

                // Nombre único con GUID para evitar colisiones entre usuarios
                string fileName = Guid.NewGuid().ToString("N") + ext;
                string fullPath = Path.Combine(folder, fileName);
                fuImagen.SaveAs(fullPath); // Guardar físicamente en el servidor
                p.pro_imagen_path = "~/uploads/" + fileName; // Guardar ruta relativa en BD
            }
            else
            {
                // Si no se subió imagen nueva, conservar la que ya tenía el producto
                if (p.pro_id > 0)
                {
                    // Recuperar la ruta original de la BD (no la URL resuelta que está en hfImagenActual)
                    var existente = CN_tbl_producto.Listar().FirstOrDefault(x => x.pro_id == p.pro_id);
                    p.pro_imagen_path = existente?.pro_imagen_path ?? "";
                }
            }

            // Llamar al método correcto según si es nuevo (pro_id=0) o edición (pro_id>0)
            string msg;
            bool ok = p.pro_id == 0
                ? CN_tbl_producto.Insertar(p, out msg)   // INSERT
                : CN_tbl_producto.Actualizar(p, out msg); // UPDATE

            if (ok)
            {
                MostrarMsg(p.pro_id == 0 ? "Producto creado." : "Producto actualizado.", true);
                LimpiarForm();               // Resetear formulario
                CargarCategoriasFiltro();    // Actualizar categorías (puede haber una nueva)
                BindGrid();                  // Refrescar tabla
            }
            else
            {
                MostrarMsg(msg, false); // Mostrar el error devuelto por la capa de datos
            }
        }

        // Cancelar edición: resetear el formulario sin guardar cambios
        protected void btnCancelar_Click(object sender, EventArgs e) => LimpiarForm();

        // ── UTILIDADES PRIVADAS ───────────────────────────────────────────────

        // Deja el formulario en estado "nuevo producto" (campos vacíos, ID=0)
        private void LimpiarForm()
        {
            hfProId.Value        = "0"; // "0" indica que el siguiente guardado será un INSERT
            hfImagenActual.Value = "";
            // Limpiar todos los TextBox en una sola línea con asignación múltiple
            txtNombre.Text = txtCantidad.Text = txtPrecio.Text = txtCategoria.Text = "";
            ddlEstado.SelectedValue    = "A"; // Estado por defecto: Activo
            ddlProveedor.SelectedIndex = 0;   // Selección por defecto: sin proveedor
            imgPreview.ImageUrl        = "";
            lblMsg.Text                = "";
        }

        // Muestra un mensaje de retroalimentación con color según resultado
        private void MostrarMsg(string texto, bool ok)
        {
            lblMsg.Text     = texto;
            lblMsg.CssClass = ok ? "msg-ok" : "msg-err"; // Verde o rojo según CSS del Site.Master
        }
    }
}
