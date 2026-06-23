using System;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using Capa_Datos;
using Capa_Negocio;

namespace Monolito4b.Mantenimiento
{
    public partial class Usu : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CargarTipos();
                BindGrid();
            }
        }

        // ── Cargar dropdown de tipos desde BD ────────────────────────────────
        private void CargarTipos()
        {
            ddlTipo.Items.Clear();
            ddlTipo.Items.Add(new ListItem("Administrador", "1"));
            ddlTipo.Items.Add(new ListItem("Usuario", "2"));
        }

        // ── Grid ─────────────────────────────────────────────────────────────
        private void BindGrid()
        {
            gvUsuarios.DataSource = CN_tbl_usuarios.Buscar(txtBuscarUsu.Text);
            gvUsuarios.DataBind();
        }

        protected void FiltroUsu_Changed(object sender, EventArgs e)
        {
            gvUsuarios.PageIndex = 0;
            BindGrid();
        }

        protected void gvUsuarios_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvUsuarios.PageIndex = e.NewPageIndex;
            BindGrid();
        }

        protected void gvUsuarios_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);
            string msg;

            if (e.CommandName == "Baja")
            {
                if (CN_tbl_usuarios.BajaLogica(id, out msg))
                    Msg("Baja logica aplicada.", true);
                else
                    Msg(msg, false);
                BindGrid();
                return;
            }

            if (e.CommandName == "Desbloquear")
            {
                if (CN_tbl_usuarios.Desbloquear(id, out msg))
                    Msg("Usuario activado correctamente.", true);
                else
                    Msg(msg, false);
                BindGrid();
                return;
            }

            if (e.CommandName == "Editar")
            {
                var u = CN_tbl_usuarios.ObtenerPorId(id);
                if (u == null) return;

                // Cargar tipos si aun no estan
                if (ddlTipo.Items.Count == 0) CargarTipos();

                // Llenar campos de solo lectura
                litRoCedula.Text    = u.usu_cedula    ?? "";
                litRoNombres.Text   = u.usu_nombres   ?? "";
                litRoApellidos.Text = u.usu_apellidos ?? "";
                litRoNick.Text      = u.usu_nick      ?? "";
                litRoCorreo.Text    = u.usu_correo    ?? "";
                litRoCelular.Text   = u.usu_celular   ?? "";

                // Llenar campos editables
                txtDireccion.Text = u.usu_direccion ?? "";
                hfUserId.Value    = u.usu_id.ToString();

                // Seleccionar tipo
                var tipoItem = ddlTipo.Items.FindByValue(
                    u.tusu_id.HasValue ? u.tusu_id.Value.ToString() : "2");
                if (tipoItem != null) ddlTipo.SelectedValue = tipoItem.Value;

                // Seleccionar estado
                var estadoItem = ddlEstadoUsu.Items.FindByValue(
                    u.usu_estado.HasValue ? u.usu_estado.Value.ToString() : "A");
                if (estadoItem != null) ddlEstadoUsu.SelectedValue = estadoItem.Value;

                // Cambiar modo visual
                pnlCamposCreacion.Visible = false;
                pnlInfoReadonly.Visible   = true;
                pnlAvisoEdicion.Visible   = true;
                litTituloForm.Text        = "Editar Usuario";
                btnGuardarUsu.Text        = "Actualizar Usuario";
                lblMsgUsu.Text            = "";

                // Scroll al formulario
                ScriptManager.RegisterStartupScript(this, GetType(), "scrollForm",
                    "setTimeout(function(){var el=document.getElementById('anclaForm');" +
                    "if(el)el.scrollIntoView({behavior:'smooth',block:'start'});},80);", true);
            }
        }

        // ── Guardar (insert / update) ─────────────────────────────────────────
        protected void btnGuardarUsu_Click(object sender, EventArgs e)
        {
            int id = Convert.ToInt32(hfUserId.Value);
            string msg;
            bool ok;

            if (id == 0)
            {
                // ── CREAR ────────────────────────────────────────────────────
                if (string.IsNullOrWhiteSpace(txtNick.Text))
                { Msg("El campo Nick es obligatorio.", false); return; }
                if (string.IsNullOrWhiteSpace(txtPassword.Text))
                { Msg("La contrasena es obligatoria al crear un usuario.", false); return; }
                if (CN_tbl_usuarios.ExisteNick(txtNick.Text.Trim(), 0))
                { Msg("El nick ya esta en uso.", false); return; }
                if (!string.IsNullOrWhiteSpace(txtCorreo.Text) &&
                    CN_tbl_usuarios.ExisteCorreo(txtCorreo.Text.Trim(), 0))
                { Msg("El correo ya esta registrado.", false); return; }

                var u = new tbl_usuario
                {
                    usu_cedula    = txtCedula.Text.Trim(),
                    usu_nombres   = txtNombres.Text.Trim(),
                    usu_apellidos = txtApellidos.Text.Trim(),
                    usu_direccion = txtDireccion.Text.Trim(),
                    usu_celular   = txtCelular.Text.Trim(),
                    usu_correo    = txtCorreo.Text.Trim(),
                    usu_nick      = txtNick.Text.Trim(),
                    tusu_id       = int.Parse(ddlTipo.SelectedValue),
                    usu_estado    = ddlEstadoUsu.SelectedValue[0]
                };
                ok = CN_tbl_usuarios.Insertar(u, txtPassword.Text, out msg);
                if (ok) Msg("Usuario creado correctamente.", true);
                else    Msg(msg, false);
            }
            else
            {
                // ── EDITAR (solo direccion, tipo, estado) ─────────────────────
                ok = CN_tbl_usuarios.ActualizarRestringido(
                    id,
                    txtDireccion.Text.Trim(),
                    int.Parse(ddlTipo.SelectedValue),
                    ddlEstadoUsu.SelectedValue[0],
                    out msg);
                if (ok) Msg("Usuario actualizado correctamente.", true);
                else    Msg(msg, false);
            }

            if (ok)
            {
                LimpiarForm();
                BindGrid();
            }
        }

        protected void btnCancelarUsu_Click(object sender, EventArgs e) => LimpiarForm();

        // ── Utilidades ────────────────────────────────────────────────────────
        private void LimpiarForm()
        {
            hfUserId.Value    = "0";
            txtCedula.Text    = "";
            txtNombres.Text   = "";
            txtApellidos.Text = "";
            txtDireccion.Text = "";
            txtCelular.Text   = "";
            txtCorreo.Text    = "";
            txtNick.Text      = "";
            txtPassword.Text  = "";

            litRoCedula.Text    = "";
            litRoNombres.Text   = "";
            litRoApellidos.Text = "";
            litRoNick.Text      = "";
            litRoCorreo.Text    = "";
            litRoCelular.Text   = "";

            if (ddlTipo.Items.Count > 1) ddlTipo.SelectedValue = "2";
            ddlEstadoUsu.SelectedValue = "A";

            pnlCamposCreacion.Visible = true;
            pnlInfoReadonly.Visible   = false;
            pnlAvisoEdicion.Visible   = false;
            litTituloForm.Text        = "Nuevo Usuario";
            btnGuardarUsu.Text        = "Guardar";
            lblMsgUsu.Text            = "";
        }

        private void Msg(string texto, bool ok)
        {
            lblMsgUsu.Text     = texto;
            lblMsgUsu.CssClass = ok ? "msg-ok" : "msg-err";
        }
    }
}
