using System;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using Capa_Datos;
using Capa_Negocio;

namespace Monolito4b.Mantenimiento
{
    public partial class Proveedores : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) BindGrid();
        }

        private void BindGrid()
        {
            var lista = CN_tbl_proveedor.Listar();
            string q = txtBuscar.Text.Trim().ToLower();
            if (!string.IsNullOrEmpty(q))
                lista = lista.Where(p => p.prov_nombre != null &&
                    p.prov_nombre.ToLower().Contains(q)).ToList();
            gvProveedores.DataSource = lista;
            gvProveedores.DataBind();
        }

        protected void Buscar_Changed(object sender, EventArgs e)
        {
            gvProveedores.PageIndex = 0;
            BindGrid();
        }

        protected void gvProveedores_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvProveedores.PageIndex = e.NewPageIndex;
            BindGrid();
        }

        protected void gvProveedores_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);
            string msg;

            if (e.CommandName == "Baja")
            {
                if (CN_tbl_proveedor.BajaLogica(id, out msg))
                    Msg("Baja lógica aplicada al proveedor y sus productos.", true);
                else
                    Msg(msg, false);
                BindGrid(); return;
            }

            if (e.CommandName == "Restaurar")
            {
                if (CN_tbl_proveedor.RestaurarProveedor(id, out msg))
                    Msg("Proveedor y productos restaurados.", true);
                else
                    Msg(msg, false);
                BindGrid(); return;
            }

            if (e.CommandName == "Editar")
            {
                var lista = CN_tbl_proveedor.Listar();
                var p = lista.Find(x => x.prov_id == id);
                if (p == null) return;

                hfProvId.Value        = p.prov_id.ToString();
                txtNombre.Text        = p.prov_nombre ?? "";
                ddlEstado.SelectedValue = p.prov_estado ?? "A";
                litTitulo.Text        = "Editar Proveedor";
                lblMsg.Text           = "";

                ScriptManager.RegisterStartupScript(this, GetType(), "scrollForm",
                    "setTimeout(function(){var el=document.querySelector('.form-card');if(el)el.scrollIntoView({behavior:'smooth',block:'start'});},80);",
                    true);
            }
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtNombre.Text))
            { Msg("El nombre es obligatorio.", false); return; }

            int id = Convert.ToInt32(hfProvId.Value);
            var p  = new Proveedor
            {
                prov_id     = id,
                prov_nombre = txtNombre.Text.Trim(),
                prov_estado = ddlEstado.SelectedValue
            };

            string msg;
            bool ok = id == 0
                ? CN_tbl_proveedor.Insertar(p, out msg)
                : CN_tbl_proveedor.Actualizar(p, out msg);

            if (ok)
            {
                Msg(id == 0 ? "Proveedor creado." : "Proveedor actualizado.", true);
                LimpiarForm();
                BindGrid();
            }
            else Msg(msg, false);
        }

        protected void btnCancelar_Click(object sender, EventArgs e) => LimpiarForm();

        private void LimpiarForm()
        {
            hfProvId.Value          = "0";
            txtNombre.Text          = "";
            ddlEstado.SelectedValue = "A";
            litTitulo.Text          = "Nuevo Proveedor";
            lblMsg.Text             = "";
        }

        private void Msg(string txt, bool ok)
        {
            lblMsg.Text     = txt;
            lblMsg.CssClass = ok ? "msg-ok" : "msg-err";
        }
    }
}
