using System;
using System.Web.UI;

namespace Monolito4b.Usuario
{
    public partial class MisPedidos : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["usuario"] == null)
                Response.Redirect("~/Seguridad/login.aspx");
        }
    }
}
