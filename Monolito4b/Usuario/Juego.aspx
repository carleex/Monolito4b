<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Juego.aspx.cs" Inherits="Monolito4b.Usuario.Juego" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Trivia Matemática</title>
  <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
  <meta http-equiv="Pragma" content="no-cache" />
  <meta http-equiv="Expires" content="0" />
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
  <style>
    *{margin:0;padding:0;box-sizing:border-box;}
    body{font-family:'Segoe UI',sans-serif;background:#0d0d1a;color:white;min-height:100vh;
      display:flex;flex-direction:column;}
    .navbar{background:linear-gradient(135deg,#1a1a2e,#2d1f3d);padding:14px 28px;
      display:flex;justify-content:space-between;align-items:center;
      border-bottom:1px solid rgba(255,255,255,.1);}
    .navbar h2{color:#ff6b9d;font-size:19px;font-weight:400;}
    .navbar a{color:rgba(255,255,255,.5);font-size:13px;text-decoration:none;
      padding:5px 14px;border:1px solid rgba(255,255,255,.2);border-radius:20px;}
    .navbar a:hover{border-color:#ff6b9d;color:#ff6b9d;}
    .game-wrap{flex:1;display:flex;align-items:center;justify-content:center;padding:20px;}
    .card{background:linear-gradient(145deg,#1a1a2e,#2d1f3d);border:1px solid rgba(255,255,255,.08);
      border-radius:20px;padding:35px 30px;max-width:520px;width:100%;text-align:center;
      box-shadow:0 20px 60px rgba(0,0,0,.5);}

    /* ── Inicio ── */
    .start-icon{font-size:56px;margin-bottom:16px;}
    .card h1{font-size:24px;font-weight:600;color:#ff6b9d;margin-bottom:8px;}
    .card .desc{color:rgba(255,255,255,.5);font-size:14px;line-height:1.7;margin-bottom:24px;}
    .btn-start{padding:14px 36px;background:linear-gradient(135deg,#ff4081,#ff6b9d);
      border:none;border-radius:30px;color:white;font-size:15px;font-weight:600;
      cursor:pointer;transition:all .3s;box-shadow:0 4px 20px rgba(255,64,129,.4);}
    .btn-start:hover{transform:translateY(-2px);box-shadow:0 6px 28px rgba(255,64,129,.6);}

    /* ── Juego ── */
    .prog{display:flex;justify-content:space-between;margin-bottom:18px;font-size:13px;
      color:rgba(255,255,255,.5);}
    .prog-bar{height:5px;background:rgba(255,255,255,.1);border-radius:3px;margin-bottom:20px;}
    .prog-fill{height:100%;background:linear-gradient(90deg,#ff4081,#ff6b9d);
      border-radius:3px;transition:width .4s ease;}
    .timer{font-size:42px;font-weight:700;color:#ff6b9d;margin-bottom:6px;
      transition:color .3s;}
    .timer.warn{color:#ffc800;}
    .timer.danger{color:#ff5252;animation:pulse .5s infinite alternate;}
    @keyframes pulse{from{transform:scale(1);}to{transform:scale(1.08);}}
    .pregunta{font-size:22px;font-weight:600;margin:16px 0 24px;
      color:rgba(255,255,255,.9);line-height:1.4;}
    .opciones{display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:20px;}
    .opc-btn{padding:14px 10px;background:rgba(255,255,255,.05);
      border:1px solid rgba(255,255,255,.12);border-radius:12px;
      color:rgba(255,255,255,.85);font-size:15px;cursor:pointer;
      transition:all .25s;}
    .opc-btn:hover{background:rgba(255,64,129,.2);border-color:#ff4081;color:white;}
    .opc-btn:disabled{cursor:not-allowed;opacity:.6;}
    .opc-btn.correcto{background:rgba(0,200,100,.2);border-color:#00c864;color:#00c864;}
    .opc-btn.incorrecto{background:rgba(255,50,50,.2);border-color:#ff5252;color:#ff5252;}

    /* ── Resultado ── */
    .score-ring{width:110px;height:110px;border-radius:50%;
      border:5px solid #ff6b9d;display:flex;align-items:center;justify-content:center;
      margin:10px auto 20px;font-size:30px;font-weight:700;color:#ff6b9d;}
    .score-msg{font-size:17px;margin-bottom:20px;color:rgba(255,255,255,.7);}
    .feedback{font-size:14px;color:rgba(255,255,255,.5);margin-bottom:24px;line-height:1.6;}
  </style>
</head>
<body>
  <div class="navbar">
    <h2>Trivia Matemática</h2>
    <div style="display:flex;gap:10px;align-items:center;">
      <button type="button" id="btnMute" onclick="toggleMute()"
        style="background:transparent;border:1px solid rgba(255,255,255,.2);color:rgba(255,255,255,.6);
        border-radius:50%;width:36px;height:36px;cursor:pointer;font-size:16px;"
        title="Silenciar / Activar sonido">🔊</button>
      <a href="../Usuario/Home.aspx">&#8592; Inicio</a>
    </div>
  </div>

  <div class="game-wrap">
    <form id="form1" runat="server">
      <asp:ScriptManager ID="ScriptManager1" runat="server" />

      <%-- ── Pantalla de inicio ──────────────────────────────────── --%>
      <asp:Panel ID="pnl_inicio" runat="server" CssClass="card">
        <div class="start-icon">🧮</div>
        <h1>Trivia Matemática</h1>
        <p class="desc">
          10 preguntas de aritmética.<br/>
          Tienes <strong>15 segundos</strong> por pregunta.<br/>
          Toda la lógica corre en el servidor C#.
        </p>
        <asp:Button ID="btn_iniciar" runat="server"
          Text="¡Jugar!"
          CssClass="btn-start"
          OnClick="btn_iniciar_Click" />
      </asp:Panel>

      <%-- ── Pantalla de pregunta ────────────────────────────────── --%>
      <asp:Panel ID="pnl_juego" runat="server" Visible="false" CssClass="card">
        <div class="prog">
          <span>Pregunta <asp:Literal ID="lbl_num" runat="server" /> de 10</span>
          <span>Puntaje: <asp:Literal ID="lbl_score" runat="server" /></span>
        </div>
        <div class="prog-bar">
          <div class="prog-fill" id="progFill" style="width:0%"></div>
        </div>
        <div class="timer" id="timerDisplay">15</div>
        <div class="pregunta">
          <asp:Literal ID="lbl_pregunta" runat="server" />
        </div>
        <div class="opciones">
          <asp:Button ID="btn_opc0" runat="server" CssClass="opc-btn" CommandArgument="0" OnClick="btn_respuesta_Click" />
          <asp:Button ID="btn_opc1" runat="server" CssClass="opc-btn" CommandArgument="1" OnClick="btn_respuesta_Click" />
          <asp:Button ID="btn_opc2" runat="server" CssClass="opc-btn" CommandArgument="2" OnClick="btn_respuesta_Click" />
          <asp:Button ID="btn_opc3" runat="server" CssClass="opc-btn" CommandArgument="3" OnClick="btn_respuesta_Click" />
        </div>
        <%-- Hidden field para saber si el tiempo se agotó (JS → server) --%>
        <asp:HiddenField ID="hf_timeout" runat="server" Value="0" />
        <asp:Button ID="btn_tiempo_agotado" runat="server" style="display:none"
          OnClick="btn_tiempo_agotado_Click" />
      </asp:Panel>

      <%-- ── Pantalla de resultados ──────────────────────────────── --%>
      <asp:Panel ID="pnl_resultado" runat="server" Visible="false" CssClass="card">
        <div class="score-ring">
          <asp:Literal ID="lbl_score_final" runat="server" />
        </div>
        <h1>Resultado</h1>
        <p class="score-msg"><asp:Literal ID="lbl_califica" runat="server" /></p>
        <p class="feedback"><asp:Literal ID="lbl_feedback" runat="server" /></p>
        <asp:Button ID="btn_reiniciar" runat="server"
          Text="Jugar de nuevo"
          CssClass="btn-start"
          OnClick="btn_reiniciar_Click" />
      </asp:Panel>
    </form>
  </div>

  <script>
    // ══════════════════════════════════════════════════════════
    //  MOTOR DE SONIDOS (Web Audio API + samples graciosos)
    // ══════════════════════════════════════════════════════════
    var SFX = (function () {
      var ctx = null;
      var muted = (localStorage.getItem('sfx_mute') === '1');
      function getCtx() {
        if (!ctx) {
          var AC = window.AudioContext || window.webkitAudioContext;
          if (AC) ctx = new AC();
        }
        if (ctx && ctx.state === 'suspended') ctx.resume();
        return ctx;
      }
      // tone(freq, duration, type, gain, attack, when)
      function tone(f, d, type, g, atk, when) {
        if (muted) return;
        var c = getCtx(); if (!c) return;
        var t0 = (when || 0) + c.currentTime;
        var o  = c.createOscillator();
        var v  = c.createGain();
        o.type = type || 'sine';
        o.frequency.setValueAtTime(f, t0);
        v.gain.setValueAtTime(0.0001, t0);
        v.gain.exponentialRampToValueAtTime(g || 0.18, t0 + (atk || 0.01));
        v.gain.exponentialRampToValueAtTime(0.0001, t0 + d);
        o.connect(v); v.connect(c.destination);
        o.start(t0); o.stop(t0 + d + 0.05);
      }
      // slide(freq1, freq2, duration)
      function slide(f1, f2, d, type, g) {
        if (muted) return;
        var c = getCtx(); if (!c) return;
        var t0 = c.currentTime;
        var o = c.createOscillator(), v = c.createGain();
        o.type = type || 'sawtooth';
        o.frequency.setValueAtTime(f1, t0);
        o.frequency.exponentialRampToValueAtTime(f2, t0 + d);
        v.gain.setValueAtTime(0.0001, t0);
        v.gain.exponentialRampToValueAtTime(g || 0.2, t0 + 0.02);
        v.gain.exponentialRampToValueAtTime(0.0001, t0 + d);
        o.connect(v); v.connect(c.destination);
        o.start(t0); o.stop(t0 + d + 0.05);
      }
      function noiseBurst(d, g) {
        if (muted) return;
        var c = getCtx(); if (!c) return;
        var bufSize = c.sampleRate * d;
        var buffer = c.createBuffer(1, bufSize, c.sampleRate);
        var data   = buffer.getChannelData(0);
        for (var i = 0; i < bufSize; i++) data[i] = Math.random() * 2 - 1;
        var src = c.createBufferSource(); src.buffer = buffer;
        var v = c.createGain();
        v.gain.setValueAtTime(g || 0.2, c.currentTime);
        v.gain.exponentialRampToValueAtTime(0.0001, c.currentTime + d);
        src.connect(v); v.connect(c.destination);
        src.start(); src.stop(c.currentTime + d);
      }

      return {
        click:    function () { tone(880, 0.05, 'square', 0.1); },
        // 🔔 ¡correcto!  campanita ascendente C-E-G
        correct:  function () {
          tone(523.25, 0.12, 'triangle', 0.2);
          tone(659.25, 0.12, 'triangle', 0.2, 0.01, 0.10);
          tone(783.99, 0.25, 'triangle', 0.22, 0.01, 0.20);
        },
        // 😩 incorrecto: trompetín triste "wah-wah"
        wrong:    function () {
          slide(440, 220, 0.45, 'sawtooth', 0.22);
          setTimeout(function(){ slide(330, 165, 0.55, 'sawtooth', 0.22); }, 250);
        },
        // ⏰ tiempo agotado: bocina molesta
        timeout:  function () {
          slide(800, 200, 0.7, 'square', 0.25);
        },
        // ⏱ tic-tac (últimos segundos)
        tick:     function () { tone(1200, 0.04, 'square', 0.08); },
        // 🚀 al iniciar
        start:    function () {
          tone(523, 0.10, 'sine', 0.18);
          tone(659, 0.10, 'sine', 0.18, 0.01, 0.10);
          tone(880, 0.18, 'sine', 0.20, 0.01, 0.20);
        },
        // 🏆 ¡juego perfecto!  fanfarria
        win:      function () {
          var notas = [523, 659, 783, 1046];
          notas.forEach(function (f, i) {
            tone(f, 0.18, 'triangle', 0.22, 0.01, i * 0.13);
          });
          tone(1318, 0.40, 'triangle', 0.25, 0.01, 0.55);
        },
        // 😅 derrota suave
        lose:     function () {
          var notas = [523, 466, 392, 311];
          notas.forEach(function (f, i) {
            tone(f, 0.22, 'sine', 0.20, 0.01, i * 0.18);
          });
        },
        // 💖 aprobado normal
        ok:       function () {
          tone(659, 0.15, 'triangle', 0.22);
          tone(880, 0.20, 'triangle', 0.22, 0.01, 0.15);
        },
        // 🎺 graciosos: pequeñas frases divertidas (sintetizadas)
        // Risa "ji ji ji"
        risa:     function () {
          for (var i = 0; i < 4; i++) {
            tone(900 + Math.random()*200, 0.06, 'square', 0.12, 0.005, i*0.10);
          }
        },
        // "Boing"
        boing:    function () {
          slide(180, 600, 0.18, 'sine', 0.22);
          slide(600, 200, 0.20, 'sine', 0.18);
        },

        toggleMute: function () {
          muted = !muted;
          localStorage.setItem('sfx_mute', muted ? '1' : '0');
          return muted;
        },
        isMuted:  function () { return muted; }
      };
    })();

    function toggleMute() {
      var m = SFX.toggleMute();
      var btn = document.getElementById('btnMute');
      if (btn) btn.textContent = m ? '🔇' : '🔊';
    }
    // Inicializar ícono según preferencia guardada
    (function(){
      var btn = document.getElementById('btnMute');
      if (btn && SFX.isMuted()) btn.textContent = '🔇';
    })();

    // Reproducir clic suave en cada botón de opción
    document.addEventListener('click', function (e) {
      if (e.target && e.target.classList && e.target.classList.contains('opc-btn'))
        SFX.click();
    });

    // ══════════════════════════════════════════════════════════
    //  Bloqueo del botón atrás del navegador
    // ══════════════════════════════════════════════════════════
    history.pushState(null, '', location.href);
    window.addEventListener('popstate', function () {
      history.pushState(null, '', location.href);
    });
    window.addEventListener('pageshow', function (e) {
      if (e.persisted) { window.location.reload(); }
    });

    // ══════════════════════════════════════════════════════════
    //  TIMER (con tic-tac al final)
    // ══════════════════════════════════════════════════════════
    var segundos = 15;
    var timer;

    function iniciarTimer() {
      segundos = 15;
      var d = document.getElementById('timerDisplay');
      if (d) { d.textContent = segundos; d.className = 'timer'; }
      clearInterval(timer);
      timer = setInterval(function () {
        segundos--;
        var el = document.getElementById('timerDisplay');
        if (!el) { clearInterval(timer); return; }
        el.textContent = segundos;
        if (segundos <= 5)      { el.className = 'timer danger'; SFX.tick(); }
        else if (segundos <= 8) { el.className = 'timer warn'; }

        if (segundos <= 0) {
          clearInterval(timer);
          SFX.timeout();
          document.getElementById('<%= hf_timeout.ClientID %>').value = '1';
          document.getElementById('<%= btn_tiempo_agotado.ClientID %>').click();
        }
      }, 1000);
    }

    function setProgress(n) {
      var fill = document.getElementById('progFill');
      if (fill) fill.style.width = (n * 10) + '%';
    }

    window.onload = function () {
      var panel = document.getElementById('<%= pnl_juego.ClientID %>');
      if (panel && panel.style.display !== 'none' && panel.offsetParent !== null) {
        iniciarTimer();
      }
    };

    function detenerTimer() { clearInterval(timer); }
  </script>
</body>
</html>
