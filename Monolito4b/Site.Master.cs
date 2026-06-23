using System;
using System.Web;
using System.Web.UI;

namespace Monolito4b
{
    public partial class SiteMaster : MasterPage
    {
        protected string NombreUsuario
        {
            get
            {
                var nombre = Session["usu_nombres"] as string;
                return string.IsNullOrWhiteSpace(nombre) ? "Abel OS" : nombre;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Todas las páginas que usan Site.Master son exclusivas de administrador
            if (Session["usuario"] == null)
            {
                Response.Redirect("~/Seguridad/login.aspx");
                return;
            }

            int tusu_id = Session["tusu_id"] != null ? (int)Session["tusu_id"] : 0;
            if (tusu_id != 1)
            {
                // Usuarios normales solo acceden a Juego
                Response.Redirect("~/Usuario/Juego.aspx");
                return;
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Cookies.Add(new HttpCookie("ASP.NET_SessionId", "")
            {
                Expires = DateTime.Now.AddDays(-1)
            });
            Response.Redirect("~/Seguridad/login.aspx");
        }
    }
}
