<%@ WebHandler Language="C#" Class="ProductImageHandler" %>

using System;
using System.Text;
using System.Web;
using Capa_Negocio;

/// <summary>
/// Handler HTTP que devuelve las imágenes de un producto en formato JSON.
/// No genera HTML — solo datos en JSON para que el JavaScript del Gallery Viewer
/// los consuma con fetch() sin recargar la página.
///
/// Uso:    GET /Handlers/ProductImageHandler.ashx?pro_id=5
/// Respuesta ejemplo:
///   [
///     {"id":1,"url":"/uploads/abc.jpg","nombre":"foto1","principal":"S","orden":0},
///     {"id":2,"url":"/uploads/xyz.png","nombre":"foto2","principal":"N","orden":1}
///   ]
/// </summary>
public class ProductImageHandler : IHttpHandler
{
    // ── Punto de entrada — se ejecuta con cada petición al handler ───────────
    public void ProcessRequest(HttpContext ctx)
    {
        // Decirle al navegador que la respuesta es JSON en UTF-8
        ctx.Response.ContentType     = "application/json";
        ctx.Response.ContentEncoding = Encoding.UTF8;

        // Deshabilitar caché para que el Gallery Viewer siempre obtenga datos frescos
        // (si se agrega o elimina una imagen, el viewer debe reflejarlos inmediatamente)
        ctx.Response.Cache.SetCacheability(HttpCacheability.NoCache);

        // Leer el parámetro ?pro_id= de la URL
        // int.TryParse devuelve false si el valor es vacío, texto o negativo
        int proId;
        if (!int.TryParse(ctx.Request.QueryString["pro_id"], out proId))
        {
            // Si el ID no es válido, devolver array vacío (no lanzar excepción)
            ctx.Response.Write("[]");
            return;
        }

        // Obtener la lista de imágenes del producto desde la capa de negocio
        var imgs = CN_tbl_imagen_producto.ListarPorProducto(proId);

        // ── Construir el JSON manualmente con StringBuilder ───────────────────
        // No se usa JavaScriptSerializer para evitar dependencias adicionales
        var sb = new StringBuilder("["); // Iniciar array JSON

        for (int i = 0; i < imgs.Count; i++)
        {
            var    img    = imgs[i];
            string rawPath = (img.img_path ?? "").Trim();

            // Convertir ruta relativa "~/uploads/foto.jpg"  a URL usable en el navegador
            // Request.ApplicationPath = "/" si está en la raíz, o "/miapp" si en subcarpeta
            // Esto garantiza que las URLs funcionen en cualquier hosting sin hardcodear rutas
            string url = rawPath.StartsWith("~/")
                ? ctx.Request.ApplicationPath.TrimEnd('/') + "/" + rawPath.Substring(2)
                : rawPath; // Si no empieza con ~/, usar la ruta tal cual

            string nombre = JsonEsc(img.img_nombre ?? "");
            // Normalizar principal: solo "S" es principal, cualquier otro valor es "N"
            string ppal = ((img.img_principal ?? "N").Trim() == "S") ? "S" : "N";

            // Agregar coma entre objetos del array (no antes del primero)
            if (i > 0) sb.Append(",");

            // Construir el objeto JSON de esta imagen
            sb.AppendFormat(
                "{{\"id\":{0},\"url\":\"{1}\",\"nombre\":\"{2}\"," +
                "\"principal\":\"{3}\",\"orden\":{4}}}",
                img.img_id,   // ID del registro en tbl_imagen_producto
                JsonEsc(url), // URL ya resuelta para el navegador
                nombre,       // Nombre del archivo (sin extensión, truncado)
                ppal,         // "S" o "N"
                img.img_orden // Posición de ordenamiento
            );
        }

        sb.Append("]"); // Cerrar array JSON

        // Escribir la respuesta y terminar
        ctx.Response.Write(sb.ToString());
    }

    // ── Helper: escapar caracteres especiales para JSON ─────────────────────
    // JSON tiene caracteres reservados que deben escaparse para no romper la estructura:
    //   \  → \\    (barra invertida)
    //   "  → \"    (comillas dobles)
    //   \n → \\n   (salto de línea)
    //   \r → \\r   (retorno de carro)
    private static string JsonEsc(string s)
        => (s ?? "")
            .Replace("\\", "\\\\")  // Escapar barra invertida PRIMERO (evita doble escape)
            .Replace("\"", "\\\"")  // Escapar comillas dobles
            .Replace("\n", "\\n")   // Escapar salto de línea
            .Replace("\r", "\\r");  // Escapar retorno de carro

    // IsReusable = false: el handler no se reutiliza entre peticiones.
    // Se recomienda false cuando el handler podría tener estado o recursos no compartibles.
    public bool IsReusable => false;
}
