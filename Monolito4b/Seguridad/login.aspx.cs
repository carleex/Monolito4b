using System;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using Capa_Datos;
using Capa_Negocio;
using Monolito4b.Infrastructure.Mongo;

namespace Monolito4b.Seguridad
{
    public partial class Login : System.Web.UI.Page
    {
        // Duración de validez del OTP
        private const int OTP_MINUTOS = 10;
        private readonly MongoLogService _mongoLog = new MongoLogService();

        protected void Page_Load(object sender, EventArgs e)
        {
            // Anti-cache para que la página de login no quede en caché del navegador
            Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            Response.Cache.SetExpires(DateTime.UtcNow.AddMinutes(-1));

            if (!IsPostBack)
            {
                BasededatosDataContext dc = new BasededatosDataContext();
                dc.sp_reset_intentos_si_nuevo_dia(null);
            }
        }

        protected void lnk_registar_Click(object sender, EventArgs e)
        {
            Response.Redirect("register.aspx");
        }

        // ── Paso 1: validar credenciales y enviar OTP ────────────────
        protected void btn_inicio_Click1(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txt_ced.Text))
            { Alerta("warning", "Campo vacío", "Ingrese su nick o cédula."); return; }
            if (string.IsNullOrWhiteSpace(txt_pass.Text))
            { Alerta("warning", "Campo vacío", "Ingrese su contraseña."); return; }

            string input = txt_ced.Text.Trim();

            using (BasededatosDataContext dc = new BasededatosDataContext())
            {
                // Buscar por nick O cédula
                tbl_usuario usuario = dc.tbl_usuario
                    .FirstOrDefault(u => u.usu_nick == input || u.usu_cedula == input);

                if (usuario == null)
                {
                    TryLog("Login", "Usuario no registrado", input);
                    Alerta("warning", "Usuario no registrado",
                        "No existe ninguna cuenta con ese usuario o cédula.");
                    return;
                }

                if (usuario.usu_estado == 'B' || usuario.usu_estado == 'I')
                {
                    TryLog("Login", "Acceso bloqueado", usuario.usu_nick);
                    Alerta("error", "Acceso bloqueado",
                        "Tu cuenta está bloqueada. Contacta al administrador.");
                    return;
                }

                // Descifrar contraseña almacenada y comparar
                string passDesc = dc.desencritacion(usuario.usu_contraseña);
                if (passDesc == txt_pass.Text)
                {
                    usuario.usu_intentos             = 0;
                    usuario.usu_fecha_ultimo_intento = null;
                    dc.SubmitChanges();

                    TryLog("Login", "Credenciales correctas, OTP generado", usuario.usu_nick);
                    GenerarYEnviarOTP(usuario);
                    pnl_credenciales.Visible = false;
                    pnl_otp.Visible          = true;
                }
                else
                {
                    int intentos = (usuario.usu_intentos ?? 0) + 1;
                    usuario.usu_intentos             = intentos;
                    usuario.usu_fecha_ultimo_intento = DateTime.Now;

                    if (intentos >= 3)
                    {
                        usuario.usu_estado = 'B';
                        dc.SubmitChanges();
                        TryLog("Login", "Cuenta bloqueada por intentos fallidos", usuario.usu_nick);
                        Alerta("error", "Cuenta bloqueada",
                            "Tu cuenta fue bloqueada por 3 intentos fallidos. Contacta al administrador.");
                    }
                    else
                    {
                        dc.SubmitChanges();
                        TryLog("Login", "Contraseña incorrecta. Intento " + intentos, usuario.usu_nick);
                        Alerta("warning", "Contraseña incorrecta",
                            "Contraseña incorrecta. Intento " + intentos + " de 3.");
                    }
                }
            }
        }

        // ── Genera OTP, guarda expiración en sesión y envía ─────────
        private void GenerarYEnviarOTP(tbl_usuario usuario)
        {
            string otp = new Random().Next(100000, 999999).ToString();

            BasededatosDataContext dc = new BasededatosDataContext();
            tbl_usuario u = dc.tbl_usuario.FirstOrDefault(x => x.usu_id == usuario.usu_id);
            if (u != null)
            {
                u.usu_codigo_OTP = otp;
                dc.SubmitChanges();
            }

            DateTime expira = DateTime.Now.AddMinutes(OTP_MINUTOS);
            Session["otp_usu_id"]   = usuario.usu_id;
            Session["otp_expira"]   = expira;

            Mail mail = new Mail();
            if (!string.IsNullOrEmpty(usuario.usu_correo))
                mail.EnviarOTP(usuario.usu_correo, usuario.usu_nick, otp);
            if (!string.IsNullOrEmpty(usuario.usu_celular))
                mail.EnviarOTPWhatsApp(usuario.usu_celular, usuario.usu_nick, otp);
            TryLog("Login", "OTP enviado por correo/WhatsApp", usuario.usu_nick);
        }

        // ── Reenviar / regenerar OTP ─────────────────────────────────
        protected void btn_reenviar_otp_Click(object sender, EventArgs e)
        {
            int usu_id = (int)(Session["otp_usu_id"] ?? 0);
            if (usu_id == 0)
            {
                TryLog("Login", "Solicitud de reenvío OTP con sesión expirada", "");
                Alerta("warning", "Sesión expirada", "Vuelva a iniciar sesión.");
                pnl_otp.Visible = false;
                pnl_credenciales.Visible = true;
                return;
            }

            BasededatosDataContext dc = new BasededatosDataContext();
            tbl_usuario usuario = dc.tbl_usuario.FirstOrDefault(u => u.usu_id == usu_id);
            if (usuario == null)
            {
                TryLog("Login", "Reenvío OTP - usuario no encontrado", "");
                Alerta("error", "Error", "Usuario no encontrado.");
                return;
            }

            GenerarYEnviarOTP(usuario);
            txt_otp.Text = "";
            Alerta("success", "Nuevo código enviado",
                "Se envió un nuevo código a tu correo y WhatsApp. Válido por " + OTP_MINUTOS + " minutos.");
        }

        // ── Verificar OTP (manual o desde escaneo QR) ────────────────
        protected void btn_verificar_otp_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txt_otp.Text))
            { Alerta("warning", "Vacío", "Ingrese el código OTP o escanee el QR."); return; }

            int usu_id = (int)(Session["otp_usu_id"] ?? 0);
            DateTime expira = (DateTime)(Session["otp_expira"] ?? DateTime.MinValue);

            if (usu_id == 0)
            { TryLog("Login", "Verificación OTP con sesión expirada", ""); Alerta("warning", "Sesión expirada", "Vuelva a iniciar sesión."); return; }

            if (DateTime.Now > expira)
            {
                TryLog("Login", "OTP expirado", usu_id.ToString());
                Alerta("warning", "Código expirado",
                    "El código OTP expiró. Presiona \"Reenviar código\" para generar uno nuevo.");
                return;
            }

            BasededatosDataContext dc = new BasededatosDataContext();
            tbl_usuario usuario = dc.tbl_usuario.FirstOrDefault(u => u.usu_id == usu_id);

            if (usuario != null && usuario.usu_codigo_OTP == txt_otp.Text.Trim())
            {
                // Guardar variables de sesión completas
                Session["usuario"]      = usuario.usu_nick;
                Session["usu_id"]       = usuario.usu_id;
                Session["tusu_id"]      = usuario.tusu_id;
                Session["usu_nombres"]  = usuario.usu_nombres;  // sidebar Site.Master

                usuario.usu_codigo_OTP = null;
                dc.SubmitChanges();

                Session.Remove("otp_usu_id");
                Session.Remove("otp_expira");
                TryLog("Login", "Inicio de sesión exitoso con OTP", usuario.usu_nick);

                // tusu_id == 1  → Administrador → Dashboard
                // tusu_id == 2  → Usuario       → Home del usuario
                int tipo = usuario.tusu_id ?? 0;
                if (tipo == 1)
                    Response.Redirect("~/Dashboard.aspx");
                else if (tipo == 2)
                    Response.Redirect("~/Usuario/Home.aspx");
                else
                    Response.Redirect("~/Usuario/Home.aspx");
            }
            else
            {
                TryLog("Login", "OTP incorrecto", usu_id.ToString());
                Alerta("error", "Código incorrecto", "El código OTP no es válido.");
            }
        }

        protected void lnk_volver_Click(object sender, EventArgs e)
        {
            pnl_otp.Visible          = false;
            pnl_credenciales.Visible = true;
            Session.Remove("otp_usu_id");
            Session.Remove("otp_expira");
        }

        private void Alerta(string icono, string titulo, string texto)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "SA",
                "Swal.fire({icon:'" + icono + "',title:'" + titulo + "',text:'" + texto.Replace("'", "\\'") + "'});", true);
        }

        private void TryLog(string modulo, string mensaje, string usuario)
        {
            try
            {
                _mongoLog.Registrar(modulo, mensaje, usuario);
            }
            catch
            {
            }
        }
    }
}
