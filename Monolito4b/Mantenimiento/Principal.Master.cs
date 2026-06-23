using System;
using System.Web;
using System.Web.UI;

namespace Monolito4b.Mantenimiento
{
    public partial class Principal : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            Response.Cache.SetExpires(DateTime.UtcNow.AddMinutes(-1));
            Response.AppendHeader("Pragma", "no-cache");

            if (Session["usuario"] == null)
            {
                Response.Redirect("~/Seguridad/login.aspx");
                return;
            }

            int tusu_id = Session["tusu_id"] != null ? (int)Session["tusu_id"] : 0;
            int usu_id  = Session["usu_id"]  != null ? (int)Session["usu_id"]  : 0;

            // Solo administradores (tusu_id == 1) pueden usar las páginas de Mantenimiento
            if (tusu_id != 1)
            {
                Response.Redirect("~/Usuario/Juego.aspx");
                return;
            }

            lbl_nse.Text = "@" + Session["usuario"].ToString();
            lbl_rol.Text = "Administrador";

            pnl_adm.Visible = true;   // siempre admin aquí
            pnl_usu.Visible = false;

            img_avatar.ImageUrl = ResolveUrl(
                "~/Handlers/FotoHandler.ashx?usu_id=" + usu_id + "&t=" + DateTime.Now.Ticks);
        }

        protected void btn_cerrar_Click(object sender, EventArgs e)
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
