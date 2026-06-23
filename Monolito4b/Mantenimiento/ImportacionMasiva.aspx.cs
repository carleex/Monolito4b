using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Web.UI;
using Capa_Datos;
using Capa_Negocio;
using Monolito4b.Infrastructure.Mongo;

namespace Monolito4b.Mantenimiento
{
    public partial class ImportacionMasiva : Page
    {
        // Clave fija para guardar/recuperar el lote CSV en la Session del usuario.
        // Usar una constante evita errores de tipeo si se usa en varios métodos.
        private const string SesionClave = "ImportCSV_Lote";
        private readonly MongoLogService _mongoLog = new MongoLogService();

        // ── Page_Load: se ejecuta en CADA petición (postback o no) ──────────
        protected void Page_Load(object sender, EventArgs e)
        {
            // IsPostBack = false solo la primera vez que se carga la página.
            // Evita reiniciar controles cuando el usuario hace clic en un botón.
            if (!IsPostBack)
            {
                pnlPreview.Visible   = false;  // Ocultar la tabla de vista previa
                pnlResultado.Visible = false;  // Ocultar el panel de resultado
                btnConfirmar.Enabled = false;  // Deshabilitar "Confirmar" hasta cargar CSV
            }
        }

        // ── PASO 1: Cargar y parsear el CSV para mostrar vista previa ────────
        protected void btnCargar_Click(object sender, EventArgs e)
        {
            // Limpiar mensajes y paneles anteriores en cada nueva carga
            lblMsg.Text          = "";
            pnlPreview.Visible   = false;
            pnlResultado.Visible = false;
            btnConfirmar.Enabled = false;

            // Validación 1: verificar que se seleccionó algún archivo
            if (!fuCSV.HasFile)
            {
                TryLog("Importación", "Intento de carga sin archivo CSV", UsuarioActual());
                MostrarMsg("Seleccione un archivo CSV.", false); return;
            }

            // Validación 2: verificar que la extensión sea .csv o .txt
            string ext = Path.GetExtension(fuCSV.FileName).ToLower();
            if (ext != ".csv" && ext != ".txt")
            {
                TryLog("Importación", "Archivo con extensión inválida: " + fuCSV.FileName, UsuarioActual());
                MostrarMsg("Solo se aceptan archivos .csv", false); return;
            }

            // Variables de salida del parser (out = se llenan dentro del método)
            List<Producto> lote;    // Filas válidas parseadas
            List<string>   errores; // Mensajes de filas con errores
            ParsarCSV(fuCSV.FileContent, out lote, out errores);

            // Si no hay ni una fila válida, no tiene sentido continuar
            if (lote.Count == 0)
            {
                TryLog("Importación", "CSV sin filas válidas", UsuarioActual());
                MostrarMsg("El archivo no contiene filas válidas. " +
                    (errores.Any() ? errores[0] : ""), false);
                return;
            }

            // Invertir la lista: el último registro del CSV queda en la posición #1
            // Esto facilita ver los registros más recientes primero (orden descendente)
            lote.Reverse();

            // Guardar el lote en Session del servidor para recuperarlo en el paso 2
            // (el archivo CSV ya no está disponible en la siguiente petición)
            Session[SesionClave] = lote;

            // Configurar el GridView de vista previa
            gvPreview.PageIndex  = 0;        // Siempre empezar en la página 1
            gvPreview.DataSource = lote;     // Asignar la lista como fuente de datos
            gvPreview.DataBind();            // Ejecutar el enlace (sin esto no se muestra)
            litCount.Text = lote.Count.ToString(); // Mostrar el total de filas detectadas

            // Si hubo filas ignoradas, informar cuántas y por qué
            if (errores.Any())
            {
                TryLog("Importación", "Vista previa cargada con " + errores.Count + " fila(s) inválidas", UsuarioActual());
                MostrarMsg($"Se ignoraron {errores.Count} fila(s) con errores de formato.", false);
            }
            else
            {
                TryLog("Importación", "Vista previa cargada correctamente. Registros: " + lote.Count, UsuarioActual());
            }

            // Mostrar el panel de vista previa y habilitar el botón de confirmación
            pnlPreview.Visible   = true;
            btnConfirmar.Enabled = true;
        }

        // ── PASO 2: Confirmar e insertar en la base de datos ─────────────────
        protected void btnConfirmar_Click(object sender, EventArgs e)
        {
            // Recuperar el lote guardado en Session
            // "as List<Producto>" hace el cast sin lanzar excepción (devuelve null si falla)
            var lote = Session[SesionClave] as List<Producto>;

            // Verificar que aún existen datos en Session (podría expirar por inactividad)
            if (lote == null || lote.Count == 0)
            {
                TryLog("Importación", "Confirmación sin lote en sesión", UsuarioActual());
                MostrarMsg("No hay datos para insertar. Cargue el archivo nuevamente.", false); return;
            }

            string msg; // Mensaje que devuelve la capa de negocio con el resultado

            // InsertarMasivo usa SqlTransaction internamente:
            // si algún registro falla, hace Rollback de TODO el lote
            bool ok = CN_tbl_producto.InsertarMasivo(lote, out msg);
            TryLog("Importación", ok ? "Inserción masiva exitosa: " + msg : "Error en inserción masiva: " + msg, UsuarioActual());

            // Mostrar el resultado con color según éxito o error
            litResultado.Text = ok
                ? $"<span style='color:#42d47e;'>&#10003; {msg}</span>"   // ✓ verde
                : $"<span style='color:#e05050;'>&#10007; {msg}</span>";  // ✗ rojo

            pnlResultado.Visible = true;
            btnConfirmar.Enabled = false; // Evitar doble confirmación

            // Limpiar Session para liberar memoria del servidor
            Session.Remove(SesionClave);

            if (ok)
            {
                // Si fue exitoso, ocultar la vista previa (ya se insertó todo)
                pnlPreview.Visible = false;
                lblMsg.Text = "";
            }
        }

        // ── Paginación de la vista previa ────────────────────────────────────
        // Se ejecuta cuando el usuario hace clic en un número de página del GridView
        protected void gvPreview_PageIndexChanging(object sender, System.Web.UI.WebControls.GridViewPageEventArgs e)
        {
            // Recuperar el lote de Session (no releer el archivo CSV)
            var lote = Session[SesionClave] as List<Producto>;
            if (lote == null) return; // Si Session expiró, no hacer nada

            // e.NewPageIndex = índice de la página que el usuario seleccionó
            gvPreview.PageIndex  = e.NewPageIndex;
            gvPreview.DataSource = lote;
            gvPreview.DataBind(); // Volver a enlazar para mostrar la nueva página
        }

        // ── Parser CSV: convierte el archivo en lista de objetos Producto ─────
        /// <summary>
        /// Lee el stream del archivo CSV línea por línea.
        /// Detecta automáticamente encoding UTF-8 o Latin-1 (con BOM).
        /// Columnas esperadas (separadas por ;):
        ///   pro_nombre ; pro_cantidad ; pro_precio ; pro_estado ; prov_id ; pro_imagen_path ; pro_categoria
        /// </summary>
        private static void ParsarCSV(Stream stream, out List<Producto> lote, out List<string> errores)
        {
            lote    = new List<Producto>();
            errores = new List<string>();

            // StreamReader con detección automática de BOM (marca de orden de bytes)
            // Maneja archivos guardados desde Excel en Windows (Latin-1) o editores (UTF-8)
            using (var sr = new StreamReader(stream, Encoding.UTF8, detectEncodingFromByteOrderMarks: true))
            {
                int lineNum = 0;
                string line;

                // Leer el archivo línea por línea hasta el final (ReadLine devuelve null al terminar)
                while ((line = sr.ReadLine()) != null)
                {
                    lineNum++;
                    line = line.Trim(); // Quitar espacios y saltos de línea extra

                    // Ignorar líneas completamente vacías
                    if (string.IsNullOrWhiteSpace(line)) continue;

                    // Detectar y saltar la fila de encabezado si contiene "pro_nombre"
                    // (cuando el CSV fue generado con encabezados descriptivos)
                    if (lineNum == 1 && !char.IsDigit(line[0]) &&
                        line.IndexOf("pro_nombre", StringComparison.OrdinalIgnoreCase) >= 0)
                        continue;

                    // Dividir la línea por el separador ';'
                    var cols = line.Split(';');
                    if (cols.Length < 1) { errores.Add($"Línea {lineNum}: vacía."); continue; }

                    try
                    {
                        // Crear el objeto Producto con los valores de cada columna
                        // Los helpers Trim/ParseInt/ParseDecimal/ParseNullableInt manejan
                        // columnas faltantes o con formato incorrecto sin lanzar excepción
                        var p = new Producto
                        {
                            pro_nombre      = Trim(cols, 0),            // Columna 0: nombre
                            pro_cantidad    = ParseInt(cols, 1),         // Columna 1: cantidad
                            pro_precio      = ParseDecimal(cols, 2),     // Columna 2: precio
                            // Si estado está vacío, por defecto 'A' (Activo)
                            pro_estado      = string.IsNullOrWhiteSpace(Trim(cols, 3)) ? "A" : Trim(cols, 3).ToUpper(),
                            prov_id         = ParseNullableInt(cols, 4), // Columna 4: puede ser null
                            pro_imagen_path = Trim(cols, 5),             // Columna 5: ruta imagen
                            pro_categoria   = Trim(cols, 6)              // Columna 6: categoría
                        };

                        // El nombre es obligatorio — sin nombre el producto no tiene sentido
                        if (string.IsNullOrWhiteSpace(p.pro_nombre))
                        { errores.Add($"Línea {lineNum}: pro_nombre vacío."); continue; }

                        lote.Add(p); // Agregar a la lista de productos válidos
                    }
                    catch (Exception ex)
                    {
                        // Capturar cualquier error de parseo y registrarlo sin detener el proceso
                        errores.Add($"Línea {lineNum}: {ex.Message}");
                    }
                }
            }
        }

        // ── Helpers de parseo ─────────────────────────────────────────────────

        // Obtiene una columna por índice y le quita espacios; devuelve "" si no existe
        private static string Trim(string[] cols, int i)
            => i < cols.Length ? cols[i].Trim() : "";

        // Convierte a entero; devuelve 0 si el valor es vacío o no es número
        private static int ParseInt(string[] cols, int i)
        {
            int v;
            return int.TryParse(Trim(cols, i), out v) ? v : 0;
        }

        // Convierte a decimal manejando tanto punto como coma decimal (15.50 o 15,50)
        private static decimal ParseDecimal(string[] cols, int i)
        {
            decimal v;
            // Reemplazar coma por punto para que InvariantCulture lo procese correctamente
            string s = Trim(cols, i).Replace(",", ".");
            return decimal.TryParse(s, System.Globalization.NumberStyles.Any,
                System.Globalization.CultureInfo.InvariantCulture, out v) ? v : 0m;
        }

        // Convierte a entero nullable: si está vacío devuelve null (para prov_id opcional)
        private static int? ParseNullableInt(string[] cols, int i)
        {
            string s = Trim(cols, i);
            int v;
            return int.TryParse(s, out v) ? v : (int?)null;
        }

        // ── Helper de mensajes de usuario ─────────────────────────────────────
        // ok=true → clase CSS verde; ok=false → clase CSS roja
        private void MostrarMsg(string texto, bool ok)
        {
            lblMsg.Text     = texto;
            lblMsg.CssClass = ok ? "msg-ok" : "msg-err";
        }

        private void TryLog(string modulo, string mensaje, string usuario)
        {
            try
            {
                _mongoLog.Registrar(modulo, mensaje, usuario);
            }
            catch
            {
            }
        }

        private string UsuarioActual()
        {
            return Convert.ToString(Session["usuario"] ?? Session["usu_nombres"] ?? "");
        }
    }
}
