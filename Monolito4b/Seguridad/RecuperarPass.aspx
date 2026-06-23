<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RecuperarPass.aspx.cs" Inherits="Monolito4b.Seguridad.RecuperarPass" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Recuperar contraseña</title>
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
  <style>
    *{margin:0;padding:0;box-sizing:border-box;}
    body{font-family:'Segoe UI',sans-serif;min-height:100vh;display:flex;align-items:center;
      justify-content:center;background:linear-gradient(to bottom,#0a0a1a,#1a1a2e 30%,#2d1f3d 50%,#4a3a5c 65%,#8b6b4a 80%,#1a1a2e);}
    .box{width:100%;max-width:340px;padding:40px 20px;text-align:center;}
    .logo{width:65px;height:65px;border:2px solid rgba(255,255,255,.7);border-radius:50%;
      display:flex;align-items:center;justify-content:center;margin:0 auto 30px;}
    .logo span{font-size:30px;font-weight:300;color:rgba(255,255,255,.9);font-family:Georgia,serif;}
    h1{color:rgba(255,255,255,.9);font-size:18px;font-weight:400;margin-bottom:8px;}
    p.sub{color:rgba(255,255,255,.5);font-size:13px;margin-bottom:22px;}
    form{width:100%;}
    .fg{position:relative;width:100%;margin-bottom:14px;}
    .fg .icon{position:absolute;left:18px;top:50%;transform:translateY(-50%);
      width:18px;height:18px;fill:rgba(255,255,255,.5);pointer-events:none;}
    .fg input,.fg .finput{width:100%;padding:13px 20px 13px 50px;
      background:rgba(30,30,45,.7);border:1px solid rgba(255,255,255,.1);
      border-radius:30px;color:white;font-size:14px;outline:none;}
    .fg input::placeholder,.fg .finput::placeholder{color:rgba(255,255,255,.5);}
    .btn{width:100%;padding:14px;background:linear-gradient(135deg,#ff4081,#ff6b9d);
      border:none;border-radius:30px;color:white;font-size:14px;font-weight:500;
      cursor:pointer;margin-top:6px;transition:all .3s;}
    .btn:hover{transform:translateY(-2px);box-shadow:0 6px 25px rgba(255,64,129,.5);}
    .link{margin-top:20px;font-size:13px;color:rgba(255,255,255,.5);}
    .link a{color:#ff6b9d;text-decoration:none;}
  </style>
</head>
<body>
<div class="box">
  <div class="logo"><span>D</span></div>
  <h1>Recuperar contraseña</h1>
  <p class="sub">Ingresa tu correo y recibirás una clave temporal por WhatsApp y correo.</p>

  <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />

    <asp:Panel ID="pnl_solicitar" runat="server">
      <div class="fg">
        <svg class="icon" viewBox="0 0 24 24"><path d="M20 4H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"/></svg>
        <asp:TextBox ID="txt_correo" runat="server" placeholder="Correo electrónico" CssClass="finput" />
      </div>
      <asp:Button ID="btn_solicitar" runat="server" Text="Enviar clave temporal"
        CssClass="btn" OnClick="btn_solicitar_Click" />
    </asp:Panel>

    <asp:Panel ID="pnl_ok" runat="server" Visible="false">
      <p style="color:#aaa;font-size:14px;line-height:1.6;">
        Se envió una clave temporal a tu correo y WhatsApp.<br/>
        Úsala para ingresar y cámbiala inmediatamente.
      </p>
      <br/>
      <a href="login.aspx" class="btn" style="display:block;text-decoration:none;padding:13px;">
        Ir al login
      </a>
    </asp:Panel>
  </form>

  <p class="link"><a href="login.aspx">← Volver al login</a></p>
</div>
</body>
</html>
