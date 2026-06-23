using System;
using System.Linq;
using System.Text;
using System.Web.UI;
using Capa_Datos;
using Capa_Negocio;

namespace Monolito4b
{
    public partial class Dashboard : Page
    {
        protected string JsonLabels { get; private set; }
        protected string JsonData   { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Solo administradores (tusu_id = 1)
            if (Session["usuario"] == null)
            {
                Response.Redirect("~/Seguridad/login.aspx"); return;
            }
            int tipo = Convert.ToInt32(Session["tusu_id"] ?? 0);
            if (tipo != 1)
            {
                Response.Redirect("~/Usuario/Juego.aspx"); return;
            }

            if (!IsPostBack)
            {
                CargarKPIs();
                CargarCarrusel();
                CargarChart();
            }
        }

        private void CargarKPIs()
        {
            var productos   = CN_tbl_producto.Listar();
            var proveedores = CN_tbl_proveedor.Listar()
                              .Where(p => p.prov_estado?.Trim() == "A").ToList();
            var categorias  = CN_tbl_producto.ListarCategorias();

            litTotalProductos.Text  = productos.Count.ToString();
            litTotalStock.Text      = productos.Sum(p => p.pro_cantidad).ToString();
            litTotalProveedores.Text = proveedores.Count.ToString();
            litCategorias.Text      = categorias.Count.ToString();
        }

        private void CargarCarrusel()
        {
            var lista = CN_tbl_producto.Listar();
            repCarrusel.DataSource = lista;
            repCarrusel.DataBind();
        }

        /// <summary>
        /// Resuelve el path de imagen para usarse en databinding del Repeater.
        /// Retorna "" si no hay imagen (el template mostrará el placeholder).
        /// </summary>
        protected string GetImgSrc(object rawPath)
        {
            string path = rawPath as string;
            if (string.IsNullOrWhiteSpace(path)) return "";
            return ResolveUrl(path.Trim());
        }

        private void CargarChart()
        {
            var productos = CN_tbl_producto.Listar();

            var sbLabels = new StringBuilder("[");
            var sbData   = new StringBuilder("[");

            for (int i = 0; i < productos.Count; i++)
            {
                var p = productos[i];
                string nombre = p.pro_nombre?.Replace("\"", "\\\"") ?? "";
                sbLabels.Append($"\"{nombre}\"");
                sbData.Append(p.pro_cantidad);
                if (i < productos.Count - 1)
                {
                    sbLabels.Append(",");
                    sbData.Append(",");
                }
            }

            sbLabels.Append("]");
            sbData.Append("]");

            JsonLabels = sbLabels.ToString();
            JsonData   = sbData.ToString();
        }
    }
}
