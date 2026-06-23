using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Capa_Datos;
using Capa_Negocio;
using Monolito4b.Infrastructure.Mongo;

namespace Monolito4b.Seguridad
{
    public partial class register : System.Web.UI.Page
    {
        private readonly MongoLogService _mongoLog = new MongoLogService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                cargar_perfil();
            }
            // Restaurar preview si ya se subió foto en este postback
            if (ViewState["foto_bytes"] != null)
            {
                byte[] bytes = (byte[])ViewState["foto_bytes"];
                string tipo  = ViewState["foto_tipo"] as string ?? "image/jpeg";
                img_preview.ImageUrl = "data:" + tipo + ";base64," + Convert.ToBase64String(bytes);
                img_preview.Visible  = true;
            }
        }

        private void cargar_perfil()
        {
            List<tbl_tipo_usuario> listu = CN_tbl_tipo_usuario.traer_tipos_usuarios();
            ddl_perfil.DataSource     = listu;
            ddl_perfil.DataTextField  = "tusu_nombre";
            ddl_perfil.DataValueField = "tusu_id";
            ddl_perfil.DataBind();
        }

        // ── Previsualizar foto (server-side, sin JS) ─────────────────
        protected void btn_preview_Click(object sender, EventArgs e)
        {
            if (!fu_foto.HasFile)
            {
                TryLog("Registro", "Intento de preview sin archivo", "");
                Alerta("warning", "Sin archivo", "Seleccione una imagen primero.");
                return;
            }

            string ext  = Path.GetExtension(fu_foto.FileName).ToLower();
            string tipo = fu_foto.PostedFile.ContentType;

            if (ext != ".jpg" && ext != ".jpeg" && ext != ".png" && ext != ".gif")
            {
                TryLog("Registro", "Preview con formato inválido", fu_foto.FileName);
                Alerta("warning", "Formato inválido", "Use JPG, PNG o GIF.");
                return;
            }

            byte[] bytes = fu_foto.FileBytes;
            ViewState["foto_bytes"]  = bytes;
            ViewState["foto_tipo"]   = tipo;
            ViewState["foto_nombre"] = fu_foto.FileName;

            img_preview.ImageUrl = "data:" + tipo + ";base64," + Convert.ToBase64String(bytes);
            img_preview.Visible  = true;
            TryLog("Registro", "Preview de foto generada", txt_nick.Text.Trim());
        }

        // ── Registrar usuario ─────────────────────────────────────────
        protected void btn_registrar_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txt_ced.Text))     { Alerta("warning", "Cédula requerida",    "Ingrese su número de cédula."); return; }
            if (string.IsNullOrWhiteSpace(txt_nombres.Text)) { Alerta("warning", "Nombres requeridos",  "Ingrese sus nombres."); return; }
            if (string.IsNullOrWhiteSpace(txt_apellidos.Text)){ Alerta("warning", "Apellidos requeridos","Ingrese sus apellidos."); return; }
            if (string.IsNullOrWhiteSpace(txt_correo.Text))  { Alerta("warning", "Correo requerido",    "Ingrese su correo."); return; }
            if (string.IsNullOrWhiteSpace(txt_nick.Text))    { Alerta("warning", "Usuario requerido",   "Ingrese un nombre de usuario."); return; }
            if (string.IsNullOrWhiteSpace(txt_contrasena.Text)){ Alerta("warning","Contraseña requerida","Ingrese una contraseña."); return; }
            if (txt_contrasena.Text != txt_confirmar.Text)   { Alerta("warning", "No coinciden",        "Las contraseñas no son iguales."); return; }

            // Verificar cédula única
            if (CN_tbl_usuarios.traerced(txt_ced.Text.Trim()) != null)
            {
                TryLog("Registro", "Cédula duplicada", txt_ced.Text.Trim());
                Alerta("error", "Cédula ya registrada", "Esa cédula ya tiene una cuenta.");
                return;
            }

            // Verificar correo único
            if (CN_tbl_usuarios.ExisteCorreo(txt_correo.Text.Trim()))
            {
                TryLog("Registro", "Correo duplicado", txt_correo.Text.Trim());
                Alerta("error", "Correo ya registrado", "Ese correo ya está en uso por otra cuenta.");
                return;
            }

            // Verificar nick único
            if (CN_tbl_usuarios.ExisteNick(txt_nick.Text.Trim()))
            {
                TryLog("Registro", "Nick duplicado", txt_nick.Text.Trim());
                Alerta("error", "Usuario ya existe", "Ese nombre de usuario ya está tomado, elige otro.");
                return;
            }

            // Guardar usuario
            BasededatosDataContext dc = new BasededatosDataContext();

            tbl_usuario nuevo = new tbl_usuario
            {
                usu_cedula          = txt_ced.Text.Trim(),
                usu_nombres         = txt_nombres.Text.Trim(),
                usu_apellidos       = txt_apellidos.Text.Trim(),
                usu_correo          = txt_correo.Text.Trim(),
                usu_nick            = txt_nick.Text.Trim(),
                usu_contraseña      = dc.encriptacion(txt_contrasena.Text),
                usu_celular         = txt_celular.Text.Trim(),
                tusu_id             = int.Parse(ddl_perfil.SelectedValue),
                usu_fecha_creacion  = DateTime.Now,
                usu_estado          = 'A',
                usu_intentos        = 0
            };
            dc.tbl_usuario.InsertOnSubmit(nuevo);
            dc.SubmitChanges();

            // Guardar foto si se subió
            if (ViewState["foto_bytes"] != null)
            {
                byte[] bytes  = (byte[])ViewState["foto_bytes"];
                string tipo   = ViewState["foto_tipo"]   as string ?? "image/jpeg";
                string nombre = ViewState["foto_nombre"] as string ?? "foto.jpg";
                CN_tbl_foto_usuario.GuardarFoto(nuevo.usu_id, bytes, nombre, tipo);
            }

            TryLog("Registro", "Usuario registrado correctamente", nuevo.usu_nick);

            ScriptManager.RegisterStartupScript(this, GetType(), "SA",
                "Swal.fire({icon:'success',title:'Registro exitoso',text:'Tu cuenta ha sido creada.'}).then(()=>window.location='login.aspx');",
                true);
        }

        private void Alerta(string icono, string titulo, string texto)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "SA",
                "Swal.fire({icon:'" + icono + "',title:'" + titulo + "',text:'" + texto + "'});", true);
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
