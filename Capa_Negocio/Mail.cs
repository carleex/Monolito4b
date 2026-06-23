using System;
using System.IO;
using System.Net;
using System.Net.Mail;
using System.Configuration;
using System.Text;

namespace Capa_Negocio
{
    /// <summary>
    /// Servicio de correo y WhatsApp (Cloud API de Meta).
    /// Configurar en Web.config appSettings:
    ///   SMTP:   SmtpHost, SmtpPort, SmtpUser, SmtpPass, SmtpFrom
    ///   WA:     WaCloudToken, WaCloudPhoneId, WaCloudTemplate, WaCloudLang
    /// </summary>
    public class Mail
    {
        // ── SMTP ──
        private static string Host    = ConfigurationManager.AppSettings["SmtpHost"] ?? "smtp.gmail.com";
        private static int    Puerto  = int.Parse(ConfigurationManager.AppSettings["SmtpPort"] ?? "587");
        private static string Usuario = ConfigurationManager.AppSettings["SmtpUser"] ?? "csoporte020@gmail.com";
        private static string Clave   = ConfigurationManager.AppSettings["SmtpPass"] ?? "password";
        private static string Remit   = ConfigurationManager.AppSettings["SmtpFrom"] ?? "csoporte020@gmail.com";

        // ── WhatsApp Cloud API (Meta) ──
        private static string WaToken      = ConfigurationManager.AppSettings["WaCloudToken"]    ?? "";
        private static string WaPhoneId    = ConfigurationManager.AppSettings["WaCloudPhoneId"]  ?? "";
        private static string WaTemplate   = ConfigurationManager.AppSettings["WaCloudTemplate"] ?? "";
        private static string WaLang       = ConfigurationManager.AppSettings["WaCloudLang"]     ?? "es";
        private static string WaApiVersion = ConfigurationManager.AppSettings["WaCloudVersion"]  ?? "v21.0";

        static Mail()
        {
            // TLS 1.2 obligatorio para llamar al Graph API
            try { ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12; }
            catch { }
        }

        // ════════════════════════════════════════════════════════════
        //  EMAIL
        // ════════════════════════════════════════════════════════════
        public bool envia_correo(string to, string msj)
        {
            return EnviarCorreo(to, "Recuperacion de contrasena", msj);
        }

        public bool EnviarCorreo(string para, string asunto, string cuerpoHtml)
        {
            try
            {
                using (var client = new SmtpClient(Host, Puerto))
                {
                    client.EnableSsl = true;
                    client.Credentials = new NetworkCredential(Usuario, Clave);
                    client.DeliveryMethod = SmtpDeliveryMethod.Network;

                    var msg = new MailMessage(Remit, para)
                    {
                        Subject    = asunto,
                        Body       = cuerpoHtml,
                        IsBodyHtml = true
                    };
                    client.Send(msg);
                }
                return true;
            }
            catch { return false; }
        }

        public bool EnviarOTP(string para, string nick, string codigoOTP)
        {
            string qrUrl = "https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=" + codigoOTP;

            string html = "<div style='font-family:Arial,sans-serif;max-width:480px;margin:auto;'>"
                + "<div style='background:#1a1a2e;padding:25px;border-radius:12px;text-align:center;'>"
                + "<h2 style='color:#ff6b9d;margin-bottom:5px;'>Codigo OTP</h2>"
                + "<p style='color:#ccc;'>Hola <strong>" + nick + "</strong>, escanea el QR o ingresa el codigo:</p>"
                + "<img src='" + qrUrl + "' alt='QR OTP' style='display:block;margin:20px auto;border:4px solid #ff6b9d;border-radius:8px;'/>"
                + "<div style='background:#2d1f3d;border-radius:8px;padding:16px;margin-top:10px;'>"
                + "<span style='font-size:36px;font-weight:bold;letter-spacing:8px;color:#fff;'>" + codigoOTP + "</span>"
                + "</div>"
                + "<p style='color:#888;font-size:12px;margin-top:16px;'>Este codigo expira en 10 minutos.</p>"
                + "</div></div>";

            return EnviarCorreo(para, "Tu codigo OTP de acceso", html);
        }

        public bool EnviarRecuperacion(string para, string nick, string claveTemp)
        {
            string html = "<div style='font-family:Arial,sans-serif;max-width:480px;margin:auto;'>"
                + "<div style='background:#1a1a2e;padding:25px;border-radius:12px;text-align:center;'>"
                + "<h2 style='color:#ff6b9d;'>Recuperacion de contrasena</h2>"
                + "<p style='color:#ccc;'>Hola <strong>" + nick + "</strong>, tu contrasena temporal es:</p>"
                + "<div style='background:#2d1f3d;border-radius:8px;padding:16px;margin:16px 0;'>"
                + "<span style='font-size:28px;font-weight:bold;letter-spacing:4px;color:#fff;'>" + claveTemp + "</span>"
                + "</div>"
                + "<p style='color:#888;font-size:12px;'>Valida por 30 minutos. Cambiala despues de ingresar.</p>"
                + "</div></div>";

            return EnviarCorreo(para, "Recuperacion de contrasena", html);
        }

        // ════════════════════════════════════════════════════════════
        //  WHATSAPP CLOUD API (Meta)
        // ════════════════════════════════════════════════════════════

        /// <summary>
        /// Normaliza el numero a formato internacional sin "+", espacios ni guiones.
        /// </summary>
        private static string Normalizar(string telefono)
        {
            if (string.IsNullOrWhiteSpace(telefono)) return "";
            return telefono.Trim().Replace("+", "").Replace(" ", "").Replace("-", "").Replace("(", "").Replace(")", "");
        }

        private static string Esc(string s)
        {
            if (s == null) return "";
            var sb = new StringBuilder(s.Length + 8);
            foreach (char c in s)
            {
                switch (c)
                {
                    case '\\': sb.Append("\\\\"); break;
                    case '"':  sb.Append("\\\""); break;
                    case '\n': sb.Append("\\n");  break;
                    case '\r': sb.Append("\\r");  break;
                    case '\t': sb.Append("\\t");  break;
                    default:
                        if (c < 0x20) sb.AppendFormat("\\u{0:x4}", (int)c);
                        else sb.Append(c);
                        break;
                }
            }
            return sb.ToString();
        }

        /// <summary>
        /// Envia una solicitud POST JSON al Graph API. Devuelve true si HTTP 200/2xx.
        /// </summary>
        private bool PostGraph(string json)
        {
            if (string.IsNullOrWhiteSpace(WaToken) || string.IsNullOrWhiteSpace(WaPhoneId))
                return false;

            try
            {
                string url = "https://graph.facebook.com/" + WaApiVersion + "/" + WaPhoneId + "/messages";
                var req = (HttpWebRequest)WebRequest.Create(url);
                req.Method      = "POST";
                req.ContentType = "application/json";
                req.Headers["Authorization"] = "Bearer " + WaToken;

                byte[] body = Encoding.UTF8.GetBytes(json);
                req.ContentLength = body.Length;
                using (var s = req.GetRequestStream())
                    s.Write(body, 0, body.Length);

                using (var resp = (HttpWebResponse)req.GetResponse())
                {
                    int code = (int)resp.StatusCode;
                    return code >= 200 && code < 300;
                }
            }
            catch (WebException ex)
            {
                // Log opcional para depurar
                try
                {
                    if (ex.Response != null)
                        using (var sr = new StreamReader(ex.Response.GetResponseStream()))
                            System.Diagnostics.Debug.WriteLine("WA Cloud error: " + sr.ReadToEnd());
                }
                catch { }
                return false;
            }
            catch { return false; }
        }

        /// <summary>
        /// Envia mensaje de texto libre. Solo funciona si el destinatario
        /// envió un mensaje al numero de negocio en las ultimas 24h.
        /// </summary>
        public bool EnviarWhatsApp(string telefono, string mensaje)
        {
            string tel = Normalizar(telefono);
            if (string.IsNullOrEmpty(tel)) return false;

            string json = "{"
                + "\"messaging_product\":\"whatsapp\","
                + "\"recipient_type\":\"individual\","
                + "\"to\":\"" + Esc(tel) + "\","
                + "\"type\":\"text\","
                + "\"text\":{\"preview_url\":false,\"body\":\"" + Esc(mensaje) + "\"}"
                + "}";
            return PostGraph(json);
        }

        /// <summary>
        /// Envia un mensaje usando una plantilla aprobada por Meta.
        /// Pasa los parametros como string[] (en orden {{1}},{{2}}…).
        /// </summary>
        public bool EnviarWhatsAppTemplate(string telefono, string template, string lang, params string[] parametros)
        {
            string tel = Normalizar(telefono);
            if (string.IsNullOrEmpty(tel) || string.IsNullOrEmpty(template)) return false;

            var sbParams = new StringBuilder();
            if (parametros != null && parametros.Length > 0)
            {
                sbParams.Append(",\"components\":[{\"type\":\"body\",\"parameters\":[");
                for (int i = 0; i < parametros.Length; i++)
                {
                    if (i > 0) sbParams.Append(",");
                    sbParams.Append("{\"type\":\"text\",\"text\":\"").Append(Esc(parametros[i])).Append("\"}");
                }
                sbParams.Append("]}]");
            }

            string json = "{"
                + "\"messaging_product\":\"whatsapp\","
                + "\"to\":\"" + Esc(tel) + "\","
                + "\"type\":\"template\","
                + "\"template\":{"
                +   "\"name\":\""     + Esc(template) + "\","
                +   "\"language\":{\"code\":\"" + Esc(string.IsNullOrEmpty(lang) ? WaLang : lang) + "\"}"
                +   sbParams
                + "}"
                + "}";
            return PostGraph(json);
        }

        // ── OTP por WhatsApp ─────────────────────────────────────────
        // Si hay plantilla configurada (WaCloudTemplate) la usa con el codigo;
        // si no, intenta texto libre (24h window).
        public bool EnviarOTPWhatsApp(string telefono, string nick, string codigoOTP)
        {
            if (!string.IsNullOrWhiteSpace(WaTemplate))
            {
                // Plantilla con un solo parametro = el codigo OTP
                if (EnviarWhatsAppTemplate(telefono, WaTemplate, WaLang, codigoOTP))
                    return true;
            }

            string msg = "Hola " + nick + ", tu codigo OTP es: " + codigoOTP
                       + ". Valido por 10 minutos. No lo compartas.";
            return EnviarWhatsApp(telefono, msg);
        }

        public bool EnviarRecuperacionWhatsApp(string telefono, string nick, string claveTemp)
        {
            string msg = "Hola " + nick + ", tu contrasena temporal es: " + claveTemp
                       + ". Valida por 30 minutos.";
            return EnviarWhatsApp(telefono, msg);
        }
    }
}
