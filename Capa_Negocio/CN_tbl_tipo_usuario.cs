using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Capa_Datos;
using System.Data.Linq;
using System.Data;

namespace Capa_Negocio
{
    public class CN_tbl_tipo_usuario
    {
        private static BasededatosDataContext dc = new BasededatosDataContext();

        public static List<tbl_tipo_usuario> traer_tipos_usuarios()
        {
            var lista = dc.tbl_tipo_usuario.Where(x => x.tusu_estado == 'A').ToList();
            return lista;
        }
    }
}
