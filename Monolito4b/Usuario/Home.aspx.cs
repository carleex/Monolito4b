using System;
using System.Web.UI;

namespace Monolito4b.Usuario
{
    public partial class Home : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["usuario"] == null)
            {
                Response.Redirect("~/Seguridad/login.aspx");
                return;
            }
            litNombre.Text = Session["usu_nombres"] != null
                ? Session["usu_nombres"].ToString()
                : Session["usuario"].ToString();
        }
    }
}
