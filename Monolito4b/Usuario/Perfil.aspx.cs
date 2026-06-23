using System;
using System.IO;
using System.Linq;
using System.Web.UI;
using Capa_Datos;
using Capa_Negocio;

namespace Monolito4b.Usuario
{
    public partial class Perfil : Page
    {
        private int UsuId => Session["usu_id"] != null ? (int)Session["usu_id"] : 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["usuario"] == null) { Response.Redirect("~/Seguridad/login.aspx"); return; }
            if (!IsPostBack) CargarDatos();
        }

        private void CargarDatos()
        {
            int id = UsuId;
            using (var dc = new BasededatosDataContext())
            {
                var u = dc.tbl_usuario.FirstOrDefault(x => x.usu_id == id);
                if (u == null) return;

                string nombre = (u.usu_nombres ?? "") + " " + (u.usu_apellidos ?? "");
                litNombreCompleto.Text = nombre.Trim();
                litNick.Text           = "@" + (u.usu_nick ?? "");
                litCedula.Text         = u.usu_cedula    ?? "";
                litCorreo.Text         = u.usu_correo    ?? "";
                litCelular.Text        = u.usu_celular   ?? "";
                litDireccion.Text      = u.usu_direccion ?? "";
            }

            // Avatar
            var foto = CN_tbl_foto_usuario.ObtenerFotoPrincipal(id);
            if (foto != null)
            {
                imgAvatarGrande.ImageUrl = "~/Handlers/FotoHandler.ashx?usu_id=" + id + "&t=" + DateTime.Now.Ticks;
                imgAvatarGrande.Visible  = true;
                Page.ClientScript.RegisterStartupScript(GetType(), "hideHolder",
                    "document.getElementById('avatarPlaceholder').style.display='none';", true);
            }
        }

        protected void btnGuardarFoto_Click(object sender, EventArgs e)
        {
            if (!fuFoto.HasFile)
            { Msg(lblMsgFoto, "Seleccione una imagen.", false); return; }

            string ext = Path.GetExtension(fuFoto.FileName).ToLower();
            if (ext != ".jpg" && ext != ".jpeg" && ext != ".png" && ext != ".gif" && ext != ".webp")
            { Msg(lblMsgFoto, "Formato no permitido. Use JPG, PNG, GIF o WEBP.", false); return; }

            if (fuFoto.PostedFile.ContentLength > 5 * 1024 * 1024)
            { Msg(lblMsgFoto, "La imagen no puede superar 5 MB.", false); return; }

            try
            {
                byte[] bytes;
                using (var ms = new MemoryStream())
                {
                    fuFoto.PostedFile.InputStream.CopyTo(ms);
                    bytes = ms.ToArray();
                }

                CN_tbl_foto_usuario.ReemplazarFoto(
                    UsuId, bytes,
                    fuFoto.FileName,
                    fuFoto.PostedFile.ContentType);

                Msg(lblMsgFoto, "Foto actualizada correctamente.", true);
                CargarDatos();
            }
            catch (Exception ex)
            {
                Msg(lblMsgFoto, "Error: " + ex.Message, false);
            }
        }

        protected void btnCambiarPwd_Click(object sender, EventArgs e)
        {
            string nueva = txtNuevaPwd.Text;
            string conf  = txtConfPwd.Text;

            if (string.IsNullOrWhiteSpace(nueva))
            { Msg(lblMsgPwd, "Ingrese la nueva contrasena.", false); return; }
            if (nueva.Length < 6)
            { Msg(lblMsgPwd, "La contrasena debe tener al menos 6 caracteres.", false); return; }
            if (nueva != conf)
            { Msg(lblMsgPwd, "Las contrasenas no coinciden.", false); return; }

            try
            {
                using (var dc = new BasededatosDataContext())
                {
                    var u = dc.tbl_usuario.FirstOrDefault(x => x.usu_id == UsuId);
                    if (u == null) { Msg(lblMsgPwd, "Usuario no encontrado.", false); return; }
                    u.usu_contraseña = System.Text.Encoding.UTF8.GetBytes(nueva);
                    dc.SubmitChanges();
                }
                txtNuevaPwd.Text = "";
                txtConfPwd.Text  = "";
                Msg(lblMsgPwd, "Contrasena actualizada.", true);
            }
            catch (Exception ex)
            {
                Msg(lblMsgPwd, "Error: " + ex.Message, false);
            }
        }

        private void Msg(System.Web.UI.WebControls.Label lbl, string texto, bool ok)
        {
            lbl.Text     = texto;
            lbl.CssClass = ok ? "msg-ok" : "msg-err";
        }
    }
}
