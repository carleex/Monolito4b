using System.Collections.Generic;
using Capa_Datos;

namespace Capa_Negocio
{
    public class CN_tbl_producto
    {
        public static List<Producto> Listar(string nombre = "", string categoria = "")
            => CD_tbl_producto.Listar(nombre, categoria);

        public static List<string> ListarCategorias()
            => CD_tbl_producto.ListarCategorias();

        public static bool Insertar(Producto p, out string mensaje)
            => CD_tbl_producto.Insertar(p, out mensaje);

        public static bool Actualizar(Producto p, out string mensaje)
            => CD_tbl_producto.Actualizar(p, out mensaje);

        public static bool BajaLogica(int pro_id, out string mensaje)
            => CD_tbl_producto.BajaLogica(pro_id, out mensaje);

        public static bool InsertarMasivo(List<Producto> lista, out string mensaje)
            => CD_tbl_producto.InsertarMasivo(lista, out mensaje);
    }
}
