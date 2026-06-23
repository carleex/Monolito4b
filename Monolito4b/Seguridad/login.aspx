<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="login.aspx.cs" Inherits="Monolito4b.Seguridad.Login" %>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Login - Divi</title>
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
  <script src="https://unpkg.com/html5-qrcode" type="text/javascript"></script>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }

    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      background: linear-gradient(to bottom,
        #0a0a1a 0%, #1a1a2e 30%, #2d1f3d 50%,
        #4a3a5c 65%, #8b6b4a 80%, #c4956a 90%, #1a1a2e 100%);
      position: relative;
    }

    body::before {
      content: '';
      position: absolute;
      bottom: 0; left: 0; right: 0;
      height: 25%;
      background: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 1440 320'%3E%3Cpath fill='%230d0d15' d='M0,224L48,213.3C96,203,192,181,288,181.3C384,181,480,203,576,218.7C672,235,768,245,864,234.7C960,224,1056,192,1152,181.3C1248,171,1344,181,1392,186.7L1440,192L1440,320L1392,320C1344,320,1248,320,1152,320C1056,320,960,320,864,320C768,320,672,320,576,320C480,320,384,320,288,320C192,320,96,320,48,320L0,320Z'%3E%3C/path%3E%3C/svg%3E") no-repeat bottom;
      background-size: cover;
    }

    .login-container {
      width: 100%; max-width: 320px;
      padding: 40px 20px;
      display: flex; flex-direction: column; align-items: center;
      position: relative; z-index: 1;
    }

    .logo {
      width: 70px; height: 70px;
      border: 2px solid rgba(255,255,255,0.7);
      border-radius: 50%;
      display: flex; align-items: center; justify-content: center;
      margin-bottom: 40px;
    }
    .logo span {
      font-size: 32px; font-weight: 300;
      color: rgba(255,255,255,0.9);
      font-family: Georgia, serif;
    }

    .title {
      color: rgba(255,255,255,0.9);
      font-size: 20px; font-weight: 400;
      margin-bottom: 25px;
    }

    form { width: 100%; }

    .form-group {
      width: 100%; margin-bottom: 15px;
      position: relative;
    }
    .form-group .icon {
      position: absolute; left: 18px; top: 50%;
      transform: translateY(-50%);
      width: 18px; height: 18px;
      fill: rgba(255,255,255,0.5);
      pointer-events: none;
    }
    .form-group input,
    .form-group .form-input {
      width: 100%;
      padding: 14px 20px 14px 50px;
      background: rgba(30,30,45,0.7);
      border: 1px solid rgba(255,255,255,0.1);
      border-radius: 30px;
      color: white; font-size: 14px;
      outline: none;
      transition: all 0.3s ease;
    }
    .form-group input::placeholder,
    .form-group .form-input::placeholder {
      color: rgba(255,255,255,0.5);
    }
    .form-group input:focus,
    .form-group .form-input:focus {
      border-color: rgba(255,255,255,0.3);
      background: rgba(30,30,45,0.9);
    }

    .submit-btn {
      width: 100%; padding: 14px 20px;
      background: linear-gradient(135deg, #ff4081 0%, #ff6b9d 100%);
      border: none; border-radius: 30px;
      color: white; font-size: 14px; font-weight: 500;
      cursor: pointer; margin-top: 10px;
      transition: all 0.3s ease;
      box-shadow: 0 4px 20px rgba(255,64,129,0.4);
    }
    .submit-btn:hover  { transform: translateY(-2px); box-shadow: 0 6px 25px rgba(255,64,129,0.5); }
    .submit-btn:active { transform: translateY(0); }

    .otp-info {
      color: rgba(255,255,255,0.7);
      font-size: 13px; text-align: center;
      margin-bottom: 18px; line-height: 1.5;
    }
    .back-link {
      display: block; margin-top: 14px;
      color: rgba(255,255,255,0.5);
      font-size: 13px; text-align: center;
      text-decoration: none; cursor: pointer;
      background: none; border: none;
      transition: color 0.3s;
    }
    .back-link:hover { color: #ff6b9d; }

    .forgot-password {
      margin-top: 20px;
      color: rgba(255,255,255,0.5);
      font-size: 12px; text-decoration: none;
      transition: color 0.3s ease;
    }
    .forgot-password:hover { color: rgba(255,255,255,0.8); }

    .divider {
      display: flex; align-items: center;
      width: 100%; margin: 25px 0;
      color: rgba(255,255,255,0.4); font-size: 12px;
    }
    .divider::before, .divider::after {
      content: ''; flex: 1;
      height: 1px; background: rgba(255,255,255,0.2);
    }
    .divider span { padding: 0 15px; }

    .social-icons { display: flex; gap: 15px; justify-content: center; }
    .social-icon {
      width: 45px; height: 45px; border-radius: 50%;
      background: rgba(30,30,45,0.7);
      border: 1px solid rgba(255,255,255,0.1);
      display: flex; align-items: center; justify-content: center;
      cursor: pointer; transition: all 0.3s ease; text-decoration: none;
    }
    .social-icon:hover {
      background: rgba(50,50,70,0.9);
      border-color: rgba(255,255,255,0.3);
      transform: translateY(-3px);
    }
    .social-icon svg { width: 20px; height: 20px; fill: rgba(255,255,255,0.7); }
    .social-icon:hover svg { fill: white; }

    .register-link {
      margin-top: 25px;
      color: rgba(255,255,255,0.5); font-size: 13px;
    }
    .register-link a {
      color: #ff6b9d; text-decoration: none;
      font-weight: 500; transition: color 0.3s;
    }
    .register-link a:hover { color: #ff4081; }

    .otp-tabs { display:flex; gap:6px; margin-bottom:14px; }
    .otp-tab {
      flex:1; padding:10px; border-radius:20px; cursor:pointer;
      background:rgba(30,30,45,0.7); border:1px solid rgba(255,255,255,0.1);
      color:rgba(255,255,255,0.6); font-size:12px; transition:all 0.3s;
    }
    .otp-tab:hover { color:#fff; }
    .otp-tab.active {
      background:linear-gradient(135deg,#ff4081 0%,#ff6b9d 100%);
      color:#fff; border-color:transparent;
    }
    /* ── Botón ojo ver/ocultar contraseña ── */
    .eye-btn {
      position: absolute; right: 16px; top: 50%;
      transform: translateY(-50%);
      background: none; border: none; cursor: pointer;
      color: rgba(255,255,255,0.45); padding: 0;
      display: flex; align-items: center; z-index: 2;
      transition: color 0.2s;
    }
    .eye-btn:hover { color: rgba(255,255,255,0.9); }
    .eye-btn svg { width: 19px; height: 19px; }
    /* Padding derecho extra para que el texto no quede bajo el ojo */
    .has-eye .form-input { padding-right: 48px; }
  </style>
</head>
<body>
  <div class="login-container">
    <div class="logo"><span>D</span></div>
    <h1 class="title">Inicia Sesión</h1>

    <form id="form1" runat="server">
      <asp:ScriptManager ID="ScriptManager1" runat="server" />

      <%-- Panel 1: Credenciales --%>
      <asp:Panel ID="pnl_credenciales" runat="server">
        <div class="form-group">
          <svg class="icon" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
          </svg>
          <asp:TextBox ID="txt_ced" runat="server"
            placeholder="Usuario"
            CssClass="form-input"
            autocomplete="username"
            MaxLength="50" />
        </div>

        <div class="form-group has-eye">
          <svg class="icon" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2z"/>
          </svg>
          <asp:TextBox ID="txt_pass" runat="server"
            TextMode="Password"
            placeholder="Contraseña"
            CssClass="form-input"
            autocomplete="current-password"
            MaxLength="50" />
          <button type="button" class="eye-btn"
            onclick="togglePass(this,'<%= txt_pass.ClientID %>')"
            title="Ver / ocultar contraseña">
            <%-- Ojo abierto (contraseña oculta) --%>
            <svg class="eye-open" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
              <circle cx="12" cy="12" r="3"/>
            </svg>
            <%-- Ojo tachado (contraseña visible) --%>
            <svg class="eye-close" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="display:none">
              <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/>
              <line x1="1" y1="1" x2="23" y2="23"/>
            </svg>
          </button>
        </div>

        <asp:Button ID="btn_inicio" runat="server"
          Text="Ingresar"
          CssClass="submit-btn"
          OnClick="btn_inicio_Click1" />
      </asp:Panel>

      <%-- Panel 2: OTP --%>
      <asp:Panel ID="pnl_otp" runat="server" Visible="false">
        <p class="otp-info">
          Credenciales válidas. Te enviamos un código a tu<br/>correo y WhatsApp. Válido por 10 minutos.
        </p>

        <div class="otp-tabs">
          <button type="button" class="otp-tab active" id="tab_manual" onclick="modoOTP('manual')">Código manual</button>
          <button type="button" class="otp-tab"        id="tab_qr"     onclick="modoOTP('qr')">Escanear QR</button>
        </div>

        <%-- Modo manual --%>
        <div id="box_manual">
          <div class="form-group">
            <svg class="icon" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4zm0 4l5 2.18V11c0 3.5-2.33 6.79-5 7.93-2.67-1.14-5-4.43-5-7.93V7.18L12 5z"/>
            </svg>
            <asp:TextBox ID="txt_otp" runat="server"
              placeholder="Código OTP de 6 dígitos"
              CssClass="form-input"
              MaxLength="10"
              onkeypress="return event.charCode>=48 &amp;&amp; event.charCode<=57" />
          </div>
        </div>

        <%-- Modo QR --%>
        <div id="box_qr" style="display:none;">
          <div id="qr_reader" style="width:100%;border-radius:12px;overflow:hidden;margin-bottom:10px;"></div>
          <p class="otp-info" id="qr_status" style="margin:0 0 12px;">Apunta la cámara al QR del correo.</p>
        </div>

        <asp:Button ID="btn_verificar_otp" runat="server"
          Text="Verificar"
          CssClass="submit-btn"
          OnClick="btn_verificar_otp_Click" />

        <asp:LinkButton ID="btn_reenviar_otp" runat="server"
          CssClass="back-link"
          OnClick="btn_reenviar_otp_Click">↻ Reenviar código</asp:LinkButton>

        <asp:LinkButton ID="lnk_volver" runat="server"
          CssClass="back-link"
          OnClick="lnk_volver_Click">← Volver</asp:LinkButton>
      </asp:Panel>
    </form>

    <a href="RecuperarPass.aspx" class="forgot-password">¿Olvidaste tu contraseña?</a>

    <div class="divider"><span>o continúa con</span></div>

    <div class="social-icons">
      <a href="#" class="social-icon" title="Facebook">
        <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
        </svg>
      </a>
      <a href="#" class="social-icon" title="Google">
        <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
          <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
          <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
          <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
        </svg>
      </a>
      <a href="#" class="social-icon" title="Twitter/X">
        <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>
        </svg>
      </a>
      <a href="#" class="social-icon" title="GitHub">
        <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
        </svg>
      </a>
    </div>

    <p class="register-link">
      ¿No tienes una cuenta? <a href="register.aspx">Registrarse</a>
    </p>
  </div>

  <script>
    /* ── Toggle ver/ocultar contraseña ── */
    function togglePass(btn, id) {
      var inp = document.getElementById(id);
      if (!inp) return;
      var show = inp.type === 'password';
      inp.type = show ? 'text' : 'password';
      btn.querySelector('.eye-open').style.display  = show ? 'none' : '';
      btn.querySelector('.eye-close').style.display = show ? ''     : 'none';
    }

    var qrInstance = null;
    function modoOTP(modo) {
      var tM = document.getElementById('tab_manual');
      var tQ = document.getElementById('tab_qr');
      var bM = document.getElementById('box_manual');
      var bQ = document.getElementById('box_qr');
      if (!tM || !tQ || !bM || !bQ) return;

      if (modo === 'qr') {
        tQ.classList.add('active'); tM.classList.remove('active');
        bM.style.display = 'none';   bQ.style.display = 'block';
        iniciarLectorQR();
      } else {
        tM.classList.add('active'); tQ.classList.remove('active');
        bM.style.display = 'block'; bQ.style.display = 'none';
        detenerLectorQR();
      }
    }
    function iniciarLectorQR() {
      if (qrInstance) return;
      try {
        qrInstance = new Html5Qrcode("qr_reader");
        qrInstance.start(
          { facingMode: "environment" },
          { fps: 10, qrbox: 200 },
          function (decodedText) {
            var input = document.getElementById('<%= txt_otp.ClientID %>');
            if (input) input.value = decodedText.trim();
            document.getElementById('qr_status').innerText = '✓ Código leído: ' + decodedText;
            detenerLectorQR();
            // Auto-enviar verificación
            document.getElementById('<%= btn_verificar_otp.ClientID %>').click();
          },
          function () {}
        ).catch(function (err) {
          document.getElementById('qr_status').innerText = 'No se pudo acceder a la cámara: ' + err;
        });
      } catch (e) {
        document.getElementById('qr_status').innerText = 'Error al iniciar el escáner.';
      }
    }
    function detenerLectorQR() {
      if (qrInstance) {
        qrInstance.stop().then(function () { qrInstance.clear(); qrInstance = null; })
                         .catch(function () { qrInstance = null; });
      }
    }
  </script>
</body>
</html>
