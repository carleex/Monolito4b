using System.Collections.Generic;
using Capa_Datos;

namespace Capa_Negocio
{
    public class CN_tbl_imagen_producto
    {
        public static List<ImagenProducto> ListarPorProducto(int pro_id)
            => CD_tbl_imagen_producto.ListarPorProducto(pro_id);

        public static List<ImagenProducto> ListarTodos(string nombreProducto = "")
            => CD_tbl_imagen_producto.ListarTodos(nombreProducto);

        public static bool Insertar(ImagenProducto img, out string mensaje)
            => CD_tbl_imagen_producto.Insertar(img, out mensaje);

        public static bool Eliminar(int img_id, out string mensaje, out string pathEliminado)
            => CD_tbl_imagen_producto.Eliminar(img_id, out mensaje, out pathEliminado);

        public static bool MarcarPrincipal(int img_id, int pro_id, out string mensaje)
            => CD_tbl_imagen_producto.MarcarPrincipal(img_id, pro_id, out mensaje);
    }
}
