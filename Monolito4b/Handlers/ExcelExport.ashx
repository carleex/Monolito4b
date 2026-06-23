<%@ WebHandler Language="C#" Class="ExcelExport" %>

using System;
using System.Collections.Generic;
using System.Text;
using System.Web;
using Capa_Negocio;
using Capa_Datos;

/// <summary>
/// Handler HTTP que genera y descarga un archivo Excel (.xls) sin librerías externas.
/// Usa formato HTML-table con MIME application/vnd.ms-excel — Excel lo abre sin advertencias.
/// Uso desde el navegador: /Handlers/ExcelExport.ashx?tabla=proveedores | productos | imagenes
/// </summary>
public class ExcelExport : IHttpHandler
{
    // ── Punto de entrada del handler ─────────────────────────────────────────
    // Se ejecuta cada vez que el navegador solicita este archivo .ashx
    public void ProcessRequest(HttpContext ctx)
    {
        // Leer el parámetro ?tabla= de la URL y normalizarlo a minúsculas
        string tabla = (ctx.Request.QueryString["tabla"] ?? "").ToLower().Trim();

        string nombre; // Nombre base del archivo descargado
        string xml;    // Contenido HTML que se enviará como Excel

        // Decidir qué tabla exportar según el parámetro recibido
        switch (tabla)
        {
            case "proveedores":
                nombre = "Proveedores";
                xml    = BuildProveedores(); // Construye la tabla de proveedores
                break;
            case "productos":
                nombre = "Productos";
                xml    = BuildProductos();   // Construye la tabla de productos
                break;
            case "imagenes":
                nombre = "Imagenes_Productos";
                xml    = BuildImagenes();    // Construye la tabla de imágenes
                break;
            default:
                // Si el parámetro no es válido, devolver error 400 (Bad Request)
                ctx.Response.StatusCode = 400;
                ctx.Response.Write("Parámetro 'tabla' inválido. Use: proveedores, productos o imagenes.");
                return;
        }

        // ── Configurar la respuesta HTTP para forzar descarga ────────────────
        ctx.Response.Clear();

        // MIME type: le dice al navegador que es un archivo Excel
        ctx.Response.ContentType     = "application/vnd.ms-excel";
        ctx.Response.ContentEncoding = Encoding.UTF8;
        ctx.Response.Charset         = "UTF-8";

        // Content-Disposition: attachment = forzar descarga (no abrir en el navegador)
        // Se agrega la fecha al nombre para evitar duplicados en la carpeta de descargas
        ctx.Response.AddHeader("Content-Disposition",
            $"attachment; filename={nombre}_{DateTime.Now:yyyyMMdd}.xls");

        // Escribir el contenido HTML y terminar la respuesta
        ctx.Response.Write(xml);
        ctx.Response.End();
    }

    // ── Construir tabla de PROVEEDORES ───────────────────────────────────────
    private string BuildProveedores()
    {
        // Obtener todos los proveedores desde la capa de negocio
        var lista = CN_tbl_proveedor.Listar();
        var sb    = StartDoc(); // Iniciar el documento HTML

        // Encabezados de columna (isHeader=true → se renderizan como <th>)
        Row(sb, true, "ID", "Nombre", "Estado");

        // Una fila por proveedor (isHeader=false → <td>)
        foreach (var p in lista)
            Row(sb, false,
                p.prov_id.ToString(),
                p.prov_nombre ?? "",
                // Mostrar texto legible en lugar del código 'A'/'I'
                p.prov_estado?.Trim() == "A" ? "Activo" : "Inactivo");

        return EndDoc(sb); // Cerrar el documento y devolver como string
    }

    // ── Construir tabla de PRODUCTOS ─────────────────────────────────────────
    private string BuildProductos()
    {
        var lista = CN_tbl_producto.Listar();
        var sb    = StartDoc();

        Row(sb, true, "ID", "Nombre", "Categoria", "Cantidad", "Precio", "Estado", "Proveedor ID", "Imagen");

        foreach (var p in lista)
            Row(sb, false,
                p.pro_id.ToString(),
                p.pro_nombre    ?? "",
                p.pro_categoria ?? "",
                p.pro_cantidad.ToString(),
                // "F2" = formato fijo con 2 decimales (ej: 15.00)
                p.pro_precio.ToString("F2"),
                p.pro_estado?.Trim() == "A" ? "Activo" : "Inactivo",
                // HasValue verifica que prov_id no sea NULL en la BD antes de convertir
                p.prov_id.HasValue ? p.prov_id.Value.ToString() : "",
                p.pro_imagen_path ?? "");

        return EndDoc(sb);
    }

    // ── Construir tabla de IMÁGENES ──────────────────────────────────────────
    private string BuildImagenes()
    {
        var lista = CN_tbl_imagen_producto.ListarTodos();
        var sb    = StartDoc();

        Row(sb, true, "ID Imagen", "Producto", "Archivo", "Ruta", "Orden", "Principal", "Fecha");

        foreach (var i in lista)
            Row(sb, false,
                i.img_id.ToString(),
                i.pro_nombre  ?? "",
                i.img_nombre  ?? "",
                i.img_path    ?? "",
                i.img_orden.ToString(),
                i.img_principal?.Trim() == "S" ? "Sí" : "No",
                // Formato fecha legible: 2025-06-01 14:30
                i.img_fecha.ToString("yyyy-MM-dd HH:mm"));

        return EndDoc(sb);
    }

    // ── Helper: iniciar documento HTML ───────────────────────────────────────
    // Crea el encabezado HTML con estilos básicos para que se vea bien en Excel
    private static StringBuilder StartDoc()
    {
        var sb = new StringBuilder();
        sb.AppendLine("<!DOCTYPE html><html><head>");
        sb.AppendLine("<meta charset=\"UTF-8\">");
        sb.AppendLine("<style>");
        // Colapsar bordes de la tabla para que no haya espacios entre celdas
        sb.AppendLine("table{border-collapse:collapse;font-family:Arial,sans-serif;font-size:11pt;}");
        // Encabezados con fondo azul oscuro y texto blanco
        sb.AppendLine("th{background:#1a1a6e;color:#fff;padding:6px 10px;border:1px solid #aaa;font-weight:bold;}");
        sb.AppendLine("td{padding:5px 10px;border:1px solid #ccc;}");
        // Filas alternadas con fondo gris claro para mejor lectura
        sb.AppendLine("tr:nth-child(even) td{background:#f2f2f2;}");
        sb.AppendLine("</style></head><body><table>");
        return sb;
    }

    // ── Helper: agregar una fila a la tabla ──────────────────────────────────
    // params string[] cells = acepta cualquier cantidad de celdas como argumentos
    private static void Row(StringBuilder sb, bool isHeader, params string[] cells)
    {
        sb.Append("<tr>");
        // Si es encabezado usa <th>, si es dato usa <td>
        string tag = isHeader ? "th" : "td";
        foreach (var c in cells)
        {
            // HtmlEncode escapa caracteres especiales como <, >, & para evitar
            // que rompan la estructura HTML del archivo
            string v = System.Web.HttpUtility.HtmlEncode(c ?? "");
            sb.Append($"<{tag}>{v}</{tag}>");
        }
        sb.AppendLine("</tr>");
    }

    // ── Helper: cerrar el documento HTML ────────────────────────────────────
    private static string EndDoc(StringBuilder sb)
    {
        sb.AppendLine("</table></body></html>");
        return sb.ToString(); // Devuelve todo el contenido como un string
    }

    // IsReusable = false: el handler NO se reutiliza entre peticiones
    // (importante si tuviera estado interno; aquí es buena práctica mantenerlo en false)
    public bool IsReusable => false;
}
