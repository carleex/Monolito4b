<%@ Page Title="Mi Perfil" Language="C#" MasterPageFile="~/Usuario/Usuario.Master"
    AutoEventWireup="true" CodeBehind="Perfil.aspx.cs" Inherits="Monolito4b.Usuario.Perfil" %>

<asp:Content ID="headContent" ContentPlaceHolderID="head" runat="server">
  <style>
    .perfil-wrap{max-width:700px;margin:36px auto;padding:0 20px;}
    .perfil-card{background:#141427;border:1px solid rgba(255,255,255,.07);border-radius:16px;padding:32px 36px;}
    .avatar-section{display:flex;align-items:center;gap:28px;margin-bottom:30px;padding-bottom:26px;border-bottom:1px solid rgba(255,255,255,.07);}
    .avatar-big{width:96px;height:96px;border-radius:50%;object-fit:cover;border:3px solid #ff6b9d;background:#0d0d1a;display:block;}
    .avatar-placeholder{width:96px;height:96px;border-radius:50%;border:3px solid rgba(255,107,157,.3);background:#1a1a2e;display:flex;align-items:center;justify-content:center;color:#444760;font-size:2.2rem;}
    .avatar-info h2{font-size:1.1rem;color:#fff;font-weight:500;margin-bottom:4px;}
    .avatar-info span{font-size:.8rem;color:#8b8fa8;}
    .section-title{font-size:.82rem;color:#ff6b9d;text-transform:uppercase;letter-spacing:.06em;margin-bottom:14px;}
    .info-grid{display:grid;grid-template-columns:1fr 1fr;gap:14px;margin-bottom:26px;}
    .info-field label{font-size:.73rem;color:#8b8fa8;display:block;margin-bottom:4px;}
    .info-field .val{font-size:.88rem;color:#ccd0e0;background:#1a1a2e;padding:8px 12px;border-radius:6px;border:1px solid rgba(255,255,255,.06);}
    .upload-label{display:block;font-size:.73rem;color:#8b8fa8;margin-bottom:6px;}
    .file-row{display:flex;align-items:center;gap:12px;flex-wrap:wrap;}
    .btn-save{padding:9px 26px;background:#ff4081;border:none;border-radius:20px;color:white;font-size:.84rem;cursor:pointer;transition:all .2s;}
    .btn-save:hover{background:#ff6b9d;}
    .msg-ok{color:#00c864;font-size:.82rem;margin-top:10px;display:block;}
    .msg-err{color:#ff5252;font-size:.82rem;margin-top:10px;display:block;}
    .preview-new{width:72px;height:72px;border-radius:50%;object-fit:cover;border:2px solid #ff6b9d;display:none;}
    .section-sep{border:none;border-top:1px solid rgba(255,255,255,.07);margin:24px 0;}
    .pwd-grid{display:grid;grid-template-columns:1fr 1fr;gap:14px;}
    .pwd-grid input{width:100%;background:#1a1a2e;border:1px solid rgba(255,255,255,.07);color:#ccd0e0;padding:8px 12px;border-radius:6px;font-size:.84rem;}
    .pwd-grid input:focus{border-color:#ff6b9d;outline:none;}
  </style>
</asp:Content>

<asp:Content ID="bodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
  <div class="perfil-wrap">
    <div class="perfil-card">

      <!-- ── Avatar actual ───────────────────────────────────────────── -->
      <div class="avatar-section">
        <asp:Image ID="imgAvatarGrande" runat="server" CssClass="avatar-big" Visible="false" />
        <div id="avatarPlaceholder" class="avatar-placeholder">&#128100;</div>
        <div class="avatar-info">
          <h2><asp:Literal ID="litNombreCompleto" runat="server" /></h2>
          <span><asp:Literal ID="litNick" runat="server" /></span>
        </div>
      </div>

      <!-- ── Info (solo lectura) ─────────────────────────────────────── -->
      <div class="section-title">Informacion de la cuenta</div>
      <div class="info-grid">
        <div class="info-field"><label>Cedula</label>
          <div class="val"><asp:Literal ID="litCedula"    runat="server" /></div></div>
        <div class="info-field"><label>Correo</label>
          <div class="val"><asp:Literal ID="litCorreo"    runat="server" /></div></div>
        <div class="info-field"><label>Celular</label>
          <div class="val"><asp:Literal ID="litCelular"   runat="server" /></div></div>
        <div class="info-field"><label>Direccion</label>
          <div class="val"><asp:Literal ID="litDireccion" runat="server" /></div></div>
      </div>

      <hr class="section-sep" />

      <!-- ── Cambiar foto ────────────────────────────────────────────── -->
      <div class="section-title">Cambiar foto de perfil</div>
      <div class="file-row">
        <asp:FileUpload ID="fuFoto" runat="server" />
        <img id="previewNueva" class="preview-new" alt="preview" />
      </div>
      <div style="margin-top:14px;">
        <asp:Button ID="btnGuardarFoto" runat="server" Text="Guardar foto"
          CssClass="btn-save" OnClick="btnGuardarFoto_Click" />
      </div>
      <asp:Label ID="lblMsgFoto" runat="server" />

      <hr class="section-sep" />

      <!-- ── Cambiar contraseña ──────────────────────────────────────── -->
      <div class="section-title">Cambiar contrasena</div>
      <div class="pwd-grid">
        <div>
          <label class="upload-label">Nueva contrasena</label>
          <asp:TextBox ID="txtNuevaPwd" runat="server" TextMode="Password" placeholder="Nueva contrasena" />
        </div>
        <div>
          <label class="upload-label">Confirmar contrasena</label>
          <asp:TextBox ID="txtConfPwd" runat="server" TextMode="Password" placeholder="Repetir contrasena" />
        </div>
      </div>
      <div style="margin-top:14px;">
        <asp:Button ID="btnCambiarPwd" runat="server" Text="Cambiar contrasena"
          CssClass="btn-save" OnClick="btnCambiarPwd_Click" />
      </div>
      <asp:Label ID="lblMsgPwd" runat="server" />

    </div>
  </div>

  <script>
    // Preview de la imagen antes de subir
    document.getElementById('<%= fuFoto.ClientID %>').addEventListener('change', function () {
      var file = this.files[0];
      if (!file) return;
      var reader = new FileReader();
      reader.onload = function (e) {
        var img = document.getElementById('previewNueva');
        img.src = e.target.result;
        img.style.display = 'block';
      };
      reader.readAsDataURL(file);
    });
  </script>
</asp:Content>
