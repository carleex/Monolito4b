<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Adm.aspx.cs" Inherits="Monolito4b.Mantenimiento.Adm" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Panel Administrador</title>
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
  <style>
    *{margin:0;padding:0;box-sizing:border-box;}
    body{font-family:'Segoe UI',sans-serif;background:#0d0d1a;color:white;min-height:100vh;}
    .navbar{background:linear-gradient(135deg,#1a1a2e,#2d1f3d);padding:16px 30px;
      display:flex;justify-content:space-between;align-items:center;
      border-bottom:1px solid rgba(255,255,255,.1);}
    .navbar h2{font-size:20px;font-weight:400;color:#ff6b9d;}
    .navbar .nav-info{color:rgba(255,255,255,.6);font-size:13px;}
    .navbar a.logout{color:#ff6b9d;font-size:13px;text-decoration:none;padding:6px 16px;
      border:1px solid #ff6b9d;border-radius:20px;transition:all .3s;}
    .navbar a.logout:hover{background:#ff6b9d;color:white;}
    .container{max-width:1100px;margin:30px auto;padding:0 20px;}
    h3{font-size:17px;font-weight:400;margin-bottom:18px;color:rgba(255,255,255,.8);}
    .search-bar{display:flex;gap:10px;margin-bottom:20px;}
    .search-bar input{flex:1;padding:10px 18px;background:rgba(30,30,45,.7);
      border:1px solid rgba(255,255,255,.1);border-radius:20px;color:white;font-size:14px;outline:none;}
    .search-bar input::placeholder{color:rgba(255,255,255,.4);}
    .search-bar button{padding:10px 22px;background:#ff4081;border:none;border-radius:20px;
      color:white;font-size:13px;cursor:pointer;transition:all .3s;}
    .search-bar button:hover{background:#ff6b9d;}
    table{width:100%;border-collapse:collapse;font-size:13px;}
    th{background:rgba(255,64,129,.15);color:#ff6b9d;padding:12px 14px;text-align:left;font-weight:500;}
    td{padding:11px 14px;border-bottom:1px solid rgba(255,255,255,.06);color:rgba(255,255,255,.8);}
    tr:hover td{background:rgba(255,255,255,.04);}
    .badge{display:inline-block;padding:3px 10px;border-radius:10px;font-size:11px;font-weight:600;}
    .badge-A{background:rgba(0,200,100,.15);color:#00c864;}
    .badge-B{background:rgba(255,50,50,.15);color:#ff5252;}
    .badge-T{background:rgba(255,200,0,.15);color:#ffc800;}
    .btn-unlock{padding:5px 14px;background:transparent;border:1px solid #ff6b9d;
      border-radius:14px;color:#ff6b9d;font-size:12px;cursor:pointer;transition:all .3s;}
    .btn-unlock:hover{background:#ff6b9d;color:white;}
    .foto-mini{width:36px;height:36px;border-radius:50%;object-fit:cover;border:2px solid #ff6b9d;}
  </style>
</head>
<body>
  <div class="navbar">
    <h2>Panel Administrador</h2>
    <div class="nav-info">
      Sesión: <asp:Literal ID="lbl_nick" runat="server" />
    </div>
    <a href="~/Seguridad/login.aspx" runat="server" class="logout">Cerrar sesión</a>
  </div>

  <div class="container">
    <h3>Gestión de usuarios</h3>

    <form id="form1" runat="server">
      <asp:ScriptManager ID="ScriptManager1" runat="server" />

      <div class="search-bar">
        <asp:TextBox ID="txt_buscar" runat="server" placeholder="Buscar por cédula o nick..." />
        <asp:Button ID="btn_buscar" runat="server" Text="Buscar" OnClick="btn_buscar_Click" />
        <asp:Button ID="btn_todos" runat="server" Text="Ver todos" OnClick="btn_todos_Click" />
      </div>

      <table>
        <thead>
          <tr>
            <th>Foto</th>
            <th>Cédula</th>
            <th>Nombre</th>
            <th>Nick</th>
            <th>Correo</th>
            <th>Estado</th>
            <th>Intentos</th>
            <th>Acción</th>
          </tr>
        </thead>
        <asp:Repeater ID="rpt_usuarios" runat="server" OnItemCommand="rpt_usuarios_ItemCommand">
          <ItemTemplate>
            <tr>
              <td>
                <img class="foto-mini"
                     src='<%# "~/Handlers/FotoHandler.ashx?usu_id=" + Eval("usu_id") %>'
                     onerror="this.src='https://ui-avatars.com/api/?background=2d1f3d&color=ff6b9d&name=<%# Eval("usu_nombres") %>'" />
              </td>
              <td><%# Eval("usu_cedula") %></td>
              <td><%# Eval("usu_nombres") %> <%# Eval("usu_apellidos") %></td>
              <td><%# Eval("usu_nick") %></td>
              <td><%# Eval("usu_correo") %></td>
              <td>
                <span class='badge badge-<%# Eval("usu_estado") %>'>
                  <%# Eval("usu_estado").ToString() == "A" ? "Activo" :
                      Eval("usu_estado").ToString() == "B" ? "Bloqueado" : "Temporal" %>
                </span>
              </td>
              <td><%# Eval("usu_intentos") ?? 0 %></td>
              <td>
                <asp:Button runat="server" CommandName="Desbloquear"
                  CommandArgument='<%# Eval("usu_id") %>'
                  Text="Desbloquear" CssClass="btn-unlock"
                  Visible='<%# Eval("usu_estado").ToString() == "B" || (Eval("usu_intentos") != null && (int)Eval("usu_intentos") > 0) %>' />
              </td>
            </tr>
          </ItemTemplate>
        </asp:Repeater>
      </table>
    </form>
  </div>
</body>
</html>
