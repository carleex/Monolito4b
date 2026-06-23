using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Monolito4b.Usuario
{
    // ══════════════════════════════════════════════════════════════
    // Clase que representa una pregunta del juego
    // Toda la lógica se genera y valida en C# (backend)
    // ══════════════════════════════════════════════════════════════
    [Serializable]
    public class Pregunta
    {
        public string Enunciado  { get; set; }
        public int    Respuesta  { get; set; }          // índice 0-3 de la opción correcta
        public string[] Opciones { get; set; }          // 4 opciones
    }

    public partial class Juego : System.Web.UI.Page
    {
        // ── Constantes del juego ─────────────────────────────────
        private const int TOTAL_PREGUNTAS = 10;

        // ── Acceso a estado del juego (ViewState) ────────────────
        private List<Pregunta> Preguntas
        {
            get { return ViewState["Preguntas"] as List<Pregunta>; }
            set { ViewState["Preguntas"] = value; }
        }
        private int Indice
        {
            get { return (int)(ViewState["Indice"] ?? 0); }
            set { ViewState["Indice"] = value; }
        }
        private int Puntaje
        {
            get { return (int)(ViewState["Puntaje"] ?? 0); }
            set { ViewState["Puntaje"] = value; }
        }

        // ════════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            // Anti-cache: el botón atrás del navegador no podrá mostrar la página tras logout
            Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            Response.Cache.SetExpires(DateTime.UtcNow.AddMinutes(-1));
            Response.AppendHeader("Pragma", "no-cache");

            if (Session["usuario"] == null)
            {
                Response.Redirect("~/Seguridad/login.aspx");
                return;
            }

            // Solo usuarios tipo 2 pueden acceder al juego
            int tipo = Convert.ToInt32(Session["tusu_id"] ?? 0);
            if (tipo != 2)
            {
                Response.Redirect("~/Dashboard.aspx");
                return;
            }
        }

        // ── Iniciar juego ─────────────────────────────────────────
        protected void btn_iniciar_Click(object sender, EventArgs e)
        {
            Preguntas = GenerarPreguntas();
            Indice    = 0;
            Puntaje   = 0;

            pnl_inicio.Visible    = false;
            pnl_juego.Visible     = true;
            pnl_resultado.Visible = false;

            MostrarPregunta();
            // Reiniciar timer JS + sonido de inicio
            ScriptManager.RegisterStartupScript(this, GetType(), "timer",
                "SFX.start();iniciarTimer();setProgress(0);", true);
        }

        // ── Respuesta seleccionada ────────────────────────────────
        protected void btn_respuesta_Click(object sender, EventArgs e)
        {
            hf_timeout.Value = "0";
            Button btn = (Button)sender;
            int seleccion = int.Parse(btn.CommandArgument);
            ProcesarRespuesta(seleccion);
        }

        // ── Tiempo agotado (JS notificó) ─────────────────────────
        protected void btn_tiempo_agotado_Click(object sender, EventArgs e)
        {
            if (hf_timeout.Value == "1")
                ProcesarRespuesta(-1);   // -1 = no contestó
        }

        // ── Reiniciar juego ───────────────────────────────────────
        protected void btn_reiniciar_Click(object sender, EventArgs e)
        {
            Preguntas = null;
            Indice    = 0;
            Puntaje   = 0;

            pnl_inicio.Visible    = true;
            pnl_juego.Visible     = false;
            pnl_resultado.Visible = false;
        }

        // ════════════════════════════════════════════════════════
        // LÓGICA DE NEGOCIO DEL JUEGO (100% C# backend)
        // ════════════════════════════════════════════════════════

        /// <summary>Genera 10 preguntas únicas con operaciones variadas.</summary>
        private List<Pregunta> GenerarPreguntas()
        {
            Random rnd = new Random(DateTime.Now.Millisecond);
            var lista  = new List<Pregunta>();
            var usados = new HashSet<string>();

            string[] operaciones = { "+", "-", "×", "÷" };

            while (lista.Count < TOTAL_PREGUNTAS)
            {
                string op = operaciones[rnd.Next(operaciones.Length)];
                int a, b, correcta;

                switch (op)
                {
                    case "+":
                        a = rnd.Next(10, 100);
                        b = rnd.Next(10, 100);
                        correcta = a + b;
                        break;
                    case "-":
                        a = rnd.Next(20, 100);
                        b = rnd.Next(5, a);
                        correcta = a - b;
                        break;
                    case "×":
                        a = rnd.Next(2, 13);
                        b = rnd.Next(2, 13);
                        correcta = a * b;
                        break;
                    default: // ÷
                        b = rnd.Next(2, 13);
                        correcta = rnd.Next(2, 13);
                        a = b * correcta;   // garantiza división exacta
                        break;
                }

                string clave = op + a + b;
                if (usados.Contains(clave)) continue;
                usados.Add(clave);

                // Generar 4 opciones únicas (sin repetición)
                var opcs   = new List<int> { correcta };
                var usadosOpc = new HashSet<int> { correcta };

                while (opcs.Count < 4)
                {
                    int delta  = rnd.Next(1, 12) * (rnd.Next(2) == 0 ? 1 : -1);
                    int distractor = correcta + delta;
                    if (distractor > 0 && !usadosOpc.Contains(distractor))
                    {
                        opcs.Add(distractor);
                        usadosOpc.Add(distractor);
                    }
                }

                // Mezclar opciones (Fisher-Yates)
                for (int i = opcs.Count - 1; i > 0; i--)
                {
                    int j    = rnd.Next(i + 1);
                    int temp = opcs[i]; opcs[i] = opcs[j]; opcs[j] = temp;
                }

                int idxCorrecta = opcs.IndexOf(correcta);

                lista.Add(new Pregunta
                {
                    Enunciado = "¿Cuánto es  " + a + " " + op + " " + b + " ?",
                    Respuesta = idxCorrecta,
                    Opciones  = new[] { opcs[0].ToString(), opcs[1].ToString(),
                                        opcs[2].ToString(), opcs[3].ToString() }
                });
            }
            return lista;
        }

        /// <summary>Muestra la pregunta actual en los controles.</summary>
        private void MostrarPregunta()
        {
            Pregunta p  = Preguntas[Indice];
            lbl_num.Text      = (Indice + 1).ToString();
            lbl_score.Text    = Puntaje.ToString();
            lbl_pregunta.Text = p.Enunciado;

            btn_opc0.Text = p.Opciones[0];
            btn_opc1.Text = p.Opciones[1];
            btn_opc2.Text = p.Opciones[2];
            btn_opc3.Text = p.Opciones[3];

            // Habilitar todos los botones
            btn_opc0.Enabled = btn_opc1.Enabled = btn_opc2.Enabled = btn_opc3.Enabled = true;
        }

        /// <summary>Valida la respuesta y avanza (o termina el juego).</summary>
        private void ProcesarRespuesta(int seleccion)
        {
            Pregunta p     = Preguntas[Indice];
            bool esCorrecto = seleccion == p.Respuesta;

            if (esCorrecto)
            {
                Puntaje++;
                string respTexto = p.Opciones[p.Respuesta];
                ScriptManager.RegisterStartupScript(this, GetType(), "fb",
                    "SFX.correct();Swal.fire({icon:'success',title:'¡Correcto!',text:'La respuesta era " + respTexto + "',timer:1200,showConfirmButton:false});",
                    true);
            }
            else if (seleccion == -1)
            {
                string respTexto = p.Opciones[p.Respuesta];
                ScriptManager.RegisterStartupScript(this, GetType(), "fb",
                    "SFX.boing();Swal.fire({icon:'info',title:'¡Se acabó el tiempo!',text:'La respuesta era " + respTexto + "',timer:1500,showConfirmButton:false});",
                    true);
            }
            else
            {
                string respTexto = p.Opciones[p.Respuesta];
                ScriptManager.RegisterStartupScript(this, GetType(), "fb",
                    "SFX.wrong();Swal.fire({icon:'error',title:'¡Casi!',text:'La respuesta era " + respTexto + "',timer:1500,showConfirmButton:false});",
                    true);
            }

            Indice++;

            if (Indice >= TOTAL_PREGUNTAS)
            {
                MostrarResultado();
            }
            else
            {
                MostrarPregunta();
                int idx = Indice;
                ScriptManager.RegisterStartupScript(this, GetType(), "timerR",
                    "setTimeout(function(){iniciarTimer();setProgress(" + idx + ");},1600);", true);
            }
        }

        /// <summary>Muestra la pantalla de resultado con calificación del C#.</summary>
        private void MostrarResultado()
        {
            pnl_juego.Visible     = false;
            pnl_resultado.Visible = true;

            lbl_score_final.Text = Puntaje + "/10";

            // Calificación generada por C# (no JS)
            string califica, feedback;
            if (Puntaje == 10)
            {
                califica = "¡Perfecto! 🏆";
                feedback = "Respondiste todas las preguntas correctamente. ¡Eres un genio de las matemáticas!";
            }
            else if (Puntaje >= 8)
            {
                califica = "¡Excelente! ⭐";
                feedback = "Muy buen desempeño. Solo " + (10 - Puntaje) + " respuesta(s) fallaron.";
            }
            else if (Puntaje >= 6)
            {
                califica = "Bien 👍";
                feedback = "Aprobado. Puedes mejorar practicando más operaciones.";
            }
            else if (Puntaje >= 4)
            {
                califica = "Regular 📚";
                feedback = "Necesitas repasar. Solo acertaste " + Puntaje + " de 10.";
            }
            else
            {
                califica = "Sigue practicando 💪";
                feedback = "No te rindas. Repasa las operaciones básicas e inténtalo de nuevo.";
            }

            lbl_califica.Text = califica;
            lbl_feedback.Text = feedback;

            // Sonido final acorde al puntaje
            string sfx;
            if      (Puntaje == 10) sfx = "setTimeout(function(){SFX.win();},400);";
            else if (Puntaje >= 6 ) sfx = "setTimeout(function(){SFX.ok();},400);";
            else if (Puntaje >= 4 ) sfx = "setTimeout(function(){SFX.lose();},400);";
            else                    sfx = "setTimeout(function(){SFX.lose();SFX.risa();},400);";

            ScriptManager.RegisterStartupScript(this, GetType(), "sfx_final", sfx, true);
        }
    }
}
