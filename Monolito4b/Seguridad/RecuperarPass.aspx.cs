using System;
using System.Linq;
using System.Web.UI;
using Capa_Datos;
using Capa_Negocio;

namespace Monolito4b.Seguridad
{
    public partial class RecuperarPass : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        protected void btn_solicitar_Click(object sender, EventArgs e)
        {
            string correo = txt_correo.Text.Trim();
            if (string.IsNullOrEmpty(correo))
            {
                Alerta("warning", "Campo vacío", "Ingrese su correo electrónico.");
                return;
            }

            using (BasededatosDataContext dc = new BasededatosDataContext())
            {
                tbl_usuario usuario = dc.tbl_usuario
                    .FirstOrDefault(u => u.usu_correo == correo && u.usu_estado != 'B');

                if (usuario == null)
                {
                    Alerta("error", "No encontrado", "No existe ninguna cuenta activa con ese correo.");
                    return;
                }

                // Generar clave temporal alfanumérica de 8 caracteres
                string chars    = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
                Random rnd      = new Random();
                string claveTemp = "";
                for (int i = 0; i < 8; i++)
                    claveTemp += chars[rnd.Next(chars.Length)];

                // Guardar en tbl_recuperacion
                tbl_recuperacion rec = new tbl_recuperacion
                {
                    usu_id     = usuario.usu_id,
                    rec_token  = claveTemp,
                    rec_expira = DateTime.Now.AddMinutes(30),
                    rec_usado  = 'N'
                };
                dc.tbl_recuperacion.InsertOnSubmit(rec);

                // Actualizar contraseña en BD con la clave temporal
                usuario.usu_contraseña = dc.encriptacion(claveTemp);
                usuario.usu_estado     = 'T';   // Estado 'T' = contraseña temporal

                dc.SubmitChanges();

                // Enviar por correo y WhatsApp
                Mail mail = new Mail();
                mail.EnviarRecuperacion(usuario.usu_correo, usuario.usu_nick, claveTemp);

                if (!string.IsNullOrEmpty(usuario.usu_celular))
                    mail.EnviarRecuperacionWhatsApp(usuario.usu_celular, usuario.usu_nick, claveTemp);

                pnl_solicitar.Visible = false;
                pnl_ok.Visible        = true;
            }
        }

        private void Alerta(string icono, string titulo, string texto)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "SA",
                "Swal.fire({icon:'" + icono + "',title:'" + titulo + "',text:'" + texto + "'});", true);
        }
    }
}
