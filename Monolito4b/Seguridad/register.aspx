<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="register.aspx.cs" Inherits="Monolito4b.Seguridad.register" %>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Registro - Divi</title>
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }

    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      min-height: 100vh;
      display: flex; align-items: center; justify-content: center;
      background: linear-gradient(to bottom,
        #0a0a1a 0%, #1a1a2e 30%, #2d1f3d 50%,
        #4a3a5c 65%, #8b6b4a 80%, #c4956a 90%, #1a1a2e 100%);
      position: relative;
    }

    body::before {
      content: '';
      position: absolute; bottom: 0; left: 0; right: 0;
      height: 25%;
      background: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 1440 320'%3E%3Cpath fill='%230d0d15' d='M0,224L48,213.3C96,203,192,181,288,181.3C384,181,480,203,576,218.7C672,235,768,245,864,234.7C960,224,1056,192,1152,181.3C1248,171,1344,181,1392,186.7L1440,192L1440,320L1392,320C1344,320,1248,320,1152,320C1056,320,960,320,864,320C768,320,672,320,576,320C480,320,384,320,288,320C192,320,96,320,48,320L0,320Z'%3E%3C/path%3E%3C/svg%3E") no-repeat bottom;
      background-size: cover;
    }

    .register-container {
      width: 100%; max-width: 360px;
      padding: 35px 20px;
      display: flex; flex-direction: column; align-items: center;
      position: relative; z-index: 1;
    }

    .logo {
      width: 70px; height: 70px;
      border: 2px solid rgba(255,255,255,0.7);
      border-radius: 50%;
      display: flex; align-items: center; justify-content: center;
      margin-bottom: 25px;
    }
    .logo span {
      font-size: 32px; font-weight: 300;
      color: rgba(255,255,255,0.9);
      font-family: Georgia, serif;
    }

    .title {
      color: rgba(255,255,255,0.9);
      font-size: 20px; font-weight: 400;
      margin-bottom: 20px;
    }

    form { width: 100%; }

    .form-group {
      width: 100%; margin-bottom: 12px;
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
    .form-group select,
    .form-group .form-input {
      width: 100%;
      padding: 13px 20px 13px 50px;
      background: rgba(30,30,45,0.7);
      border: 1px solid rgba(255,255,255,0.1);
      border-radius: 30px;
      color: white; font-size: 14px;
      outline: none;
      transition: all 0.3s ease;
    }
    .form-group select {
      padding-left: 20px;
      -webkit-appearance: none;
    }
    .form-group input::placeholder,
    .form-group .form-input::placeholder { color: rgba(255,255,255,0.5); }
    .form-group input:focus,
    .form-group .form-input:focus,
    .form-group select:focus {
      border-color: rgba(255,255,255,0.3);
      background: rgba(30,30,45,0.9);
    }

    /* ── Botón ojo ver/ocultar contraseña ── */
    .eye-btn {
      position: absolute; right: 18px; top: 50%;
      transform: translateY(-50%);
      background: none; border: none; cursor: pointer;
      color: rgba(255,255,255,0.45); padding: 0;
      display: flex; align-items: center; z-index: 2;
      transition: color 0.2s;
    }
    .eye-btn:hover { color: rgba(255,255,255,0.9); }
    .eye-btn svg { width: 18px; height: 18px; }
    /* Deja espacio para el ojo en los campos de contraseña */
    .has-eye .form-input { padding-right: 48px; }

    .submit-btn {
      width: 100%; padding: 14px 20px;
      background: linear-gradient(135deg, #ff4081 0%, #ff6b9d 100%);
      border: none; border-radius: 30px;
      color: white; font-size: 14px; font-weight: 500;
      cursor: pointer; margin-top: 8px;
      transition: all 0.3s ease;
      box-shadow: 0 4px 20px rgba(255,64,129,0.4);
    }
    .submit-btn:hover  { transform: translateY(-2px); box-shadow: 0 6px 25px rgba(255,64,129,0.5); }
    .submit-btn:active { transform: translateY(0); }

    .login-link {
      margin-top: 22px;
      color: rgba(255,255,255,0.5); font-size: 13px;
    }
    .login-link a {
      color: #ff6b9d; text-decoration: none;
      font-weight: 500; transition: color 0.3s;
    }
    .login-link a:hover { color: #ff4081; }
  </style>

  <script>
    /* Solo letras (incl. acentos y ñ) y espacios */
    function soloLetras(e) {
      var c = e.which || e.keyCode;
      return (c >= 65 && c <= 90) || (c >= 97 && c <= 122) ||
             c === 32 || (c >= 192 && c <= 255);
    }
    /* Solo dígitos */
    function soloNumeros(e) {
      var c = e.which || e.keyCode;
      return c >= 48 && c <= 57;
    }
    /* Sin espacios */
    function sinEspacios(e) {
      return (e.which || e.keyCode) !== 32;
    }
    /* Ver / ocultar contraseña */
    function togglePass(btn, id) {
      var inp = document.getElementById(id);
      if (!inp) return;
      var show = inp.type === 'password';
      inp.type = show ? 'text' : 'password';
      btn.querySelector('.eye-open').style.display  = show ? 'none' : '';
      btn.querySelector('.eye-close').style.display = show ? ''     : 'none';
    }
  </script>
</head>
<body>
  <div class="register-container">
    <div class="logo"><span>D</span></div>
    <h1 class="title">Crea tu cuenta</h1>

    <form id="form1" runat="server">
      <asp:ScriptManager ID="ScriptManager1" runat="server" />

      <%-- Foto de perfil (sin JS - previsualización en servidor) --%>
      <div class="form-group" style="text-align:center;">
        <label style="color:rgba(255,255,255,0.7);font-size:13px;display:block;margin-bottom:8px;">
          Foto de perfil (opcional)
        </label>
        <asp:Image ID="img_preview" runat="server" Visible="false"
          style="width:90px;height:90px;border-radius:50%;object-fit:cover;
                 border:3px solid #ff6b9d;display:block;margin:0 auto 10px;" />
        <asp:FileUpload ID="fu_foto" runat="server"
          style="color:rgba(255,255,255,0.6);font-size:13px;" />
        <asp:Button ID="btn_preview" runat="server"
          Text="Previsualizar"
          CssClass="submit-btn"
          style="margin-top:8px;padding:8px 20px;font-size:12px;"
          OnClick="btn_preview_Click" />
      </div>

      <%-- Cédula --%>
      <div class="form-group">
        <svg class="icon" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="M20 4H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm-9 3h2v2h-2V7zm0 4h2v6h-2v-6zM7 7h4v2H7V7zm0 4h4v2H7v-2zm0 4h4v2H7v-2zm10 2h-4v-2h4v2zm0-4h-4v-2h4v2zm0-4h-4V7h4v2z"/>
        </svg>
        <asp:TextBox ID="txt_ced" runat="server"
          placeholder="Cédula (solo números)"
          CssClass="form-input"
          MaxLength="10"
          autocomplete="off"
          onkeypress="return soloNumeros(event)" />
      </div>

      <%-- Nombres --%>
      <div class="form-group">
        <svg class="icon" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
        </svg>
        <asp:TextBox ID="txt_nombres" runat="server"
          placeholder="Nombres"
          CssClass="form-input"
          MaxLength="50"
          autocomplete="given-name"
          onkeypress="return soloLetras(event)" />
      </div>

      <%-- Apellidos --%>
      <div class="form-group">
        <svg class="icon" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
        </svg>
        <asp:TextBox ID="txt_apellidos" runat="server"
          placeholder="Apellidos"
          CssClass="form-input"
          MaxLength="50"
          autocomplete="family-name"
          onkeypress="return soloLetras(event)" />
      </div>

      <%-- Celular --%>
      <div class="form-group">
        <svg class="icon" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="M6.62 10.79a15.05 15.05 0 006.59 6.59l2.2-2.2a1 1 0 011.01-.24c1.12.37 2.33.57 3.58.57a1 1 0 011 1V20a1 1 0 01-1 1C9.61 21 3 14.39 3 6a1 1 0 011-1h3.5a1 1 0 011 1c0 1.25.2 2.46.57 3.58a1 1 0 01-.24 1.01l-2.21 2.2z"/>
        </svg>
        <asp:TextBox ID="txt_celular" runat="server"
          placeholder="Celular (10 dígitos)"
          CssClass="form-input"
          MaxLength="10"
          autocomplete="tel"
          onkeypress="return soloNumeros(event)" />
      </div>

      <%-- Correo --%>
      <div class="form-group">
        <svg class="icon" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="M20 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"/>
        </svg>
        <asp:TextBox ID="txt_correo" runat="server"
          placeholder="Correo electrónico"
          CssClass="form-input"
          MaxLength="100"
          autocomplete="email"
          onkeypress="return sinEspacios(event)" />
      </div>

      <%-- Perfil --%>
      <div class="form-group">
        <asp:DropDownList ID="ddl_perfil" runat="server"
          style="width:100%; padding:13px 20px; background:rgba(30,30,45,0.7); border:1px solid rgba(255,255,255,0.1); border-radius:30px; color:white; font-size:14px; outline:none;">
        </asp:DropDownList>
      </div>

      <%-- Nick --%>
      <div class="form-group">
        <svg class="icon" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 3c1.66 0 3 1.34 3 3s-1.34 3-3 3-3-1.34-3-3 1.34-3 3-3zm0 14.2c-2.5 0-4.71-1.28-6-3.22.03-1.99 4-3.08 6-3.08 1.99 0 5.97 1.09 6 3.08-1.29 1.94-3.5 3.22-6 3.22z"/>
        </svg>
        <asp:TextBox ID="txt_nick" runat="server"
          placeholder="Nombre de usuario (sin espacios)"
          CssClass="form-input"
          MaxLength="50"
          autocomplete="username"
          onkeypress="return sinEspacios(event)" />
      </div>

      <%-- Contraseña --%>
      <div class="form-group has-eye">
        <svg class="icon" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2z"/>
        </svg>
        <asp:TextBox ID="txt_contrasena" runat="server"
          TextMode="Password"
          placeholder="Contraseña"
          CssClass="form-input"
          MaxLength="50"
          autocomplete="new-password" />
        <button type="button" class="eye-btn"
          onclick="togglePass(this,'<%= txt_contrasena.ClientID %>')"
          title="Ver / ocultar contraseña">
          <svg class="eye-open" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
            <circle cx="12" cy="12" r="3"/>
          </svg>
          <svg class="eye-close" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="display:none">
            <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/>
            <line x1="1" y1="1" x2="23" y2="23"/>
          </svg>
        </button>
      </div>

      <%-- Confirmar contraseña --%>
      <div class="form-group has-eye">
        <svg class="icon" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2z"/>
        </svg>
        <asp:TextBox ID="txt_confirmar" runat="server"
          TextMode="Password"
          placeholder="Confirmar contraseña"
          CssClass="form-input"
          MaxLength="50"
          autocomplete="new-password" />
        <button type="button" class="eye-btn"
          onclick="togglePass(this,'<%= txt_confirmar.ClientID %>')"
          title="Ver / ocultar contraseña">
          <svg class="eye-open" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
            <circle cx="12" cy="12" r="3"/>
          </svg>
          <svg class="eye-close" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="display:none">
            <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/>
            <line x1="1" y1="1" x2="23" y2="23"/>
          </svg>
        </button>
      </div>

      <asp:Button ID="btn_registrar" runat="server"
        Text="Registrarse"
        CssClass="submit-btn"
        OnClick="btn_registrar_Click" />
    </form>

    <p class="login-link">
      ¿Ya tienes cuenta? <a href="login.aspx">Iniciar sesión</a>
    </p>
  </div>
</body>
</html>
