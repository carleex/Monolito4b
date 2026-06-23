using System.Collections.Generic;
using Capa_Datos;

namespace Capa_Negocio
{
    public class CN_tbl_proveedor
    {
        public static List<Proveedor> Listar()
            => CD_tbl_proveedor.Listar();

        public static bool Insertar(Proveedor p, out string mensaje)
            => CD_tbl_proveedor.Insertar(p, out mensaje);

        public static bool Actualizar(Proveedor p, out string mensaje)
            => CD_tbl_proveedor.Actualizar(p, out mensaje);

        public static bool BajaLogica(int prov_id, out string mensaje)
            => CD_tbl_proveedor.BajaLogica(prov_id, out mensaje);

        public static bool RestaurarProveedor(int prov_id, out string mensaje)
            => CD_tbl_proveedor.RestaurarProveedor(prov_id, out mensaje);
    }
}
