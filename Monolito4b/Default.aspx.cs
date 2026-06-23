using System;
using System.Linq;
using System.Web;
using System.Web.UI;
using Capa_Datos;

namespace Monolito4b
{
    public partial class _Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // ── Anti-cache: que el botón "atrás" no muestre la página tras logout
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            Response.Cache.SetExpires(DateTime.UtcNow.AddMinutes(-1));
            Response.AppendHeader("Pragma", "no-cache");

            // ── Verificar sesión
            if (Session["usuario"] == null)
            {
                Response.Redirect("~/Seguridad/login.aspx");
                return;
            }

            int tusu_id = Session["tusu_id"] != null ? (int)Session["tusu_id"] : 1;

            // tusu_id = 2 → Administrador, va directo al panel admin
            if (tusu_id == 2)
            {
                Response.Redirect("~/Mantenimiento/Adm.aspx");
                return;
            }

            // ── Para usuarios normales: cargar info para el landing
            if (!IsPostBack)
            {
                CargarInfoUsuario();
            }
        }

        private void CargarInfoUsuario()
        {
            int usu_id = Session["usu_id"] != null ? (int)Session["usu_id"] : 0;
            string nick = Session["usuario"] != null ? Session["usuario"].ToString() : "Jugador";

            using (var dc = new BasededatosDataContext())
            {
                var u = dc.tbl_usuario.FirstOrDefault(x => x.usu_id == usu_id);
                if (u != null)
                {
                    string nombreCompleto = (u.usu_nombres + " " + u.usu_apellidos).Trim();
                    lbl_nombre.Text = string.IsNullOrWhiteSpace(nombreCompleto) ? nick : nombreCompleto;
                    lbl_rol.Text    = "Usuario  •  @" + nick;
                }
                else
                {
                    lbl_nombre.Text = nick;
                    lbl_rol.Text    = "Usuario";
                }
            }

            // Foto via handler (si no hay, devuelve 1x1 transparente)
            img_foto.ImageUrl = "~/Handlers/FotoHandler.ashx?usu_id=" + usu_id + "&t=" + DateTime.Now.Ticks;
        }

        protected void btn_entrar_juego_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Usuario/Juego.aspx");
        }

        protected void btn_cerrar_sesion_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Cookies.Add(new System.Web.HttpCookie("ASP.NET_SessionId", "") { Expires = DateTime.Now.AddDays(-1) });
            Response.Redirect("~/Seguridad/login.aspx");
        }
    }
}
