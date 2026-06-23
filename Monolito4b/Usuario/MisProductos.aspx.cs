using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using Capa_Datos;
using Capa_Negocio;

namespace Monolito4b.Usuario
{
    public partial class MisProductos : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CargarCategorias();
                BindProductos();
            }
        }

        private void CargarCategorias()
        {
            ddlCategoria.Items.Clear();
            ddlCategoria.Items.Add(new ListItem("Todas las categorias", ""));
            var cats = CD_tbl_producto.ListarCategorias();
            foreach (var c in cats)
                ddlCategoria.Items.Add(new ListItem(c, c));
        }

        private void BindProductos()
        {
            var lista = CD_tbl_producto.Listar(
                txtBuscar.Text.Trim(),
                ddlCategoria.SelectedValue);

            rptProductos.DataSource = lista;
            rptProductos.DataBind();
            lblVacio.Visible = (lista.Count == 0);
        }

        protected void Filtro_Changed(object sender, EventArgs e)
        {
            BindProductos();
        }
    }
}
