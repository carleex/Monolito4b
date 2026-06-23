using System;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using Capa_Datos;

namespace Monolito4b.Mantenimiento
{
    public partial class Adm : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Control de acceso: solo administrador
            if (Session["usuario"] == null)
            {
                Response.Redirect("~/Seguridad/login.aspx");
                return;
            }
            if (Session["tusu_id"] == null || (int)Session["tusu_id"] != 2)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            lbl_nick.Text = Session["usuario"].ToString();

            if (!IsPostBack)
                CargarUsuarios(null);
        }

        private void CargarUsuarios(string filtro)
        {
            using (var dc = new BasededatosDataContext())
            {
                var q = dc.tbl_usuario.AsQueryable();

                if (!string.IsNullOrWhiteSpace(filtro))
                    q = q.Where(u => u.usu_cedula.Contains(filtro) ||
                                     u.usu_nick.Contains(filtro));

                rpt_usuarios.DataSource = q.OrderBy(u => u.usu_nombres).ToList();
                rpt_usuarios.DataBind();
            }
        }

        protected void btn_buscar_Click(object sender, EventArgs e)
        {
            CargarUsuarios(txt_buscar.Text.Trim());
        }

        protected void btn_todos_Click(object sender, EventArgs e)
        {
            txt_buscar.Text = "";
            CargarUsuarios(null);
        }

        protected void rpt_usuarios_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Desbloquear")
            {
                int usu_id = int.Parse(e.CommandArgument.ToString());

                using (var dc = new BasededatosDataContext())
                {
                    tbl_usuario u = dc.tbl_usuario.FirstOrDefault(x => x.usu_id == usu_id);
                    if (u != null)
                    {
                        u.usu_estado               = 'A';
                        u.usu_intentos             = 0;
                        u.usu_fecha_ultimo_intento = null;
                        dc.SubmitChanges();
                    }
                }

                CargarUsuarios(txt_buscar.Text.Trim());

                ScriptManager.RegisterStartupScript(this, GetType(), "SA",
                    "Swal.fire({icon:'success',title:'Desbloqueado',text:'Usuario desbloqueado correctamente.'});",
                    true);
            }
        }
    }
}
