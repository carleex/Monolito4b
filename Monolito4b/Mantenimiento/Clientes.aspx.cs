using System;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using Capa_Negocio;

namespace Monolito4b.Mantenimiento
{
    public partial class Clientes : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) BindGrid();
        }

        private void BindGrid()
        {
            // Solo usuarios con tusu_id == 2 (jugadores/clientes)
            var lista = CN_tbl_usuarios.Buscar(txtBuscarCli.Text)
                        .Where(u => u.tusu_id == 2).ToList();
            gvClientes.DataSource = lista;
            gvClientes.DataBind();
        }

        protected void Buscar_Changed(object sender, EventArgs e)
        {
            gvClientes.PageIndex = 0;
            BindGrid();
        }

        protected void gvClientes_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvClientes.PageIndex = e.NewPageIndex;
            BindGrid();
        }

        protected void gvClientes_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);
            string msg;

            if (e.CommandName == "Baja")
            {
                if (CN_tbl_usuarios.BajaLogica(id, out msg))
                    Msg("Cliente dado de baja.", true);
                else
                    Msg(msg, false);
            }
            else if (e.CommandName == "Activar")
            {
                if (CN_tbl_usuarios.Desbloquear(id, out msg))
                    Msg("Cliente activado.", true);
                else
                    Msg(msg, false);
            }

            BindGrid();
        }

        private void Msg(string txt, bool ok)
        {
            lblMsgCli.Text     = txt;
            lblMsgCli.CssClass = ok ? "msg-ok" : "msg-err";
        }
    }
}
