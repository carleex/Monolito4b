<%@ Page Title="Inicio" Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="Monolito4b._Default" %>
<!DOCTYPE html>
<html lang="es">
<head runat="server">
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Inicio</title>
  <%-- Anti-cache para que el botón atrás no muestre la página después de cerrar sesión --%>
  <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
  <meta http-equiv="Pragma" content="no-cache" />
  <meta http-equiv="Expires" content="0" />
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
  <style>
    * { margin:0; padding:0; box-sizing:border-box; font-family:'Segoe UI',sans-serif; }
    html, body { height:100%; }
    body {
      background: radial-gradient(ellipse at top, #2d1f3d 0%, #0d0d1a 100%);
      color: #fff; min-height:100vh;
      display:flex; align-items:center; justify-content:center; padding:20px;
    }
    .card {
      background: linear-gradient(145deg,#1a1a2e,#2d1f3d);
      border:1px solid rgba(255,255,255,.08);
      border-radius:24px;
      padding:40px 35px;
      max-width:420px;
      width:100%;
      text-align:center;
      box-shadow:0 25px 70px rgba(0,0,0,.6);
    }
    .avatar-wrap {
      width:130px; height:130px; margin:0 auto 18px;
      border-radius:50%;
      padding:4px;
      background: linear-gradient(135deg,#ff4081,#ff6b9d);
      box-shadow:0 8px 30px rgba(255,64,129,.4);
    }
    .avatar {
      width:100%; height:100%; border-radius:50%;
      background:#0d0d1a center/cover no-repeat;
      border:3px solid #1a1a2e;
      object-fit:cover;
      display:block;
    }
    .saludo { color: rgba(255,255,255,.5); font-size:13px; margin-bottom:4px; letter-spacing:1px; }
    .nombre { color:#ff6b9d; font-size:26px; font-weight:600; margin-bottom:6px; }
    .rol    { color:rgba(255,255,255,.5); font-size:13px; margin-bottom:30px; }
    .btn {
      display:block; width:100%; padding:14px;
      border:none; border-radius:30px;
      font-size:15px; font-weight:600;
      cursor:pointer;
      transition: all .3s;
      margin-bottom:12px;
    }
    .btn-jugar {
      background: linear-gradient(135deg,#ff4081,#ff6b9d);
      color:#fff;
      box-shadow:0 4px 20px rgba(255,64,129,.4);
    }
    .btn-jugar:hover { transform:translateY(-2px); box-shadow:0 6px 28px rgba(255,64,129,.6); }
    .btn-salir {
      background: transparent;
      color: rgba(255,255,255,.6);
      border:1px solid rgba(255,255,255,.15);
    }
    .btn-salir:hover { color:#fff; border-color:#ff5252; background:rgba(255,82,82,.1); }
  </style>
</head>
<body>
  <form id="form1" runat="server">
    <div class="card">
      <div class="avatar-wrap">
        <asp:Image ID="img_foto" runat="server" CssClass="avatar" />
      </div>
      <p class="saludo">BIENVENIDO</p>
      <h1 class="nombre"><asp:Literal ID="lbl_nombre" runat="server" /></h1>
      <p class="rol"><asp:Literal ID="lbl_rol" runat="server" /></p>

      <asp:Button ID="btn_entrar_juego" runat="server"
        Text="🎮  Entrar al juego"
        CssClass="btn btn-jugar"
        OnClick="btn_entrar_juego_Click" />

      <asp:Button ID="btn_cerrar_sesion" runat="server"
        Text="Cerrar sesión"
        CssClass="btn btn-salir"
        OnClick="btn_cerrar_sesion_Click"
        OnClientClick="confirmarSalir(event); return false;" />
    </div>
  </form>

  <script>
    // ── Bloqueo del botón atrás/adelante ───────────────────────────
    history.pushState(null, '', location.href);
    window.addEventListener('popstate', function () {
      history.pushState(null, '', location.href);
    });
    // Si la página se carga desde el bfcache (atrás/adelante), recargar
    // para que el servidor verifique sesión y redireccione si fue cerrada.
    window.addEventListener('pageshow', function (e) {
      if (e.persisted) { window.location.reload(); }
    });

    // ── Confirmación de logout (corregido) ─────────────────────────
    var __logoutConfirmado = false;
    function confirmarSalir(ev) {
      if (__logoutConfirmado) return true;
      if (ev && ev.preventDefault) ev.preventDefault();
      Swal.fire({
        title: '¿Cerrar sesión?',
        text: 'Tendrás que iniciar sesión nuevamente.',
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#ff4081',
        cancelButtonColor: '#666',
        confirmButtonText: 'Sí, salir',
        cancelButtonText: 'Cancelar'
      }).then(function (r) {
        if (r.isConfirmed) {
          __logoutConfirmado = true;
          __doPostBack('<%= btn_cerrar_sesion.UniqueID %>', '');
        }
      });
      return false;
    }
  </script>
</body>
</html>
