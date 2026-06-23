using System;

namespace Capa_Datos
{
    public class Proveedor
    {
        public int prov_id { get; set; }
        public string prov_nombre { get; set; }
        public string prov_estado { get; set; }
    }

    public class Producto
    {
        public int pro_id { get; set; }
        public string pro_nombre { get; set; }
        public int pro_cantidad { get; set; }
        public decimal pro_precio { get; set; }
        public string pro_estado { get; set; }
        public int? prov_id { get; set; }
        public string pro_imagen_path { get; set; }
        public string pro_categoria { get; set; }
    }

    /// <summary>Imagen adicional asociada a un producto (relación 1:N).</summary>
    public class ImagenProducto
    {
        public int img_id { get; set; }
        public int pro_id { get; set; }
        public string img_path { get; set; }
        public string img_nombre { get; set; }
        public int img_orden { get; set; }
        public string img_principal { get; set; }  // 'S' / 'N'
        public DateTime img_fecha { get; set; }
        // Desnormalizado para listados
        public string pro_nombre { get; set; }
    }
}
