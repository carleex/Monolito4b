<%@ Page Title="Usuarios" Language="C#" MasterPageFile="~/Mantenimiento/Principal.Master"
    AutoEventWireup="true" CodeBehind="Usu.aspx.cs" Inherits="Monolito4b.Mantenimiento.Usu" %>

<asp:Content ID="headContent" ContentPlaceHolderID="head" runat="server">
  <style>
    .page-header{padding:28px 28px 0;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px;}
    .page-header h2{font-size:1.15rem;font-weight:500;color:#fff;}
    .page-body{padding:20px 28px;}
    .form-card{background:#141427;border:1px solid rgba(255,255,255,.07);border-radius:10px;padding:22px 24px;margin-bottom:24px;}
    .form-card h3{font-size:.95rem;color:#ccd0e0;margin-bottom:18px;}
    .f-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(185px,1fr));gap:12px;}
    .f-field label{display:block;font-size:.75rem;color:#8b8fa8;margin-bottom:4px;}
    .f-field input,.f-field select{width:100%;padding:9px 12px;background:#1a1a2e;border:1px solid rgba(255,255,255,.07);border-radius:6px;color:#ccd0e0;font-size:.84rem;outline:none;}
    .f-field input:focus,.f-field select:focus{border-color:#ff6b9d;}
    .f-field input[readonly]{background:#111120;color:#666;cursor:default;border-color:rgba(255,255,255,.04);}
    .f-field small{display:block;color:#8b8fa8;font-size:.7rem;margin-top:3px;}
    .info-tag{font-size:.78rem;color:#ccd0e0;padding:9px 12px;background:#1a1a2e;border:1px solid rgba(255,255,255,.07);border-radius:6px;width:100%;box-sizing:border-box;display:block;}
    .edit-notice{background:rgba(255,107,157,.07);border:1px solid rgba(255,107,157,.2);border-radius:8px;padding:10px 14px;font-size:.78rem;color:#ff6b9d;margin-bottom:16px;}
    .btn-row{display:flex;gap:10px;margin-top:18px;flex-wrap:wrap;}
    .btn-primary{padding:8px 22px;background:#ff4081;border:none;border-radius:20px;color:white;font-size:.82rem;cursor:pointer;transition:all .2s;}
    .btn-primary:hover{background:#ff6b9d;}
    .btn-secondary{padding:8px 22px;background:transparent;border:1px solid rgba(255,255,255,.15);border-radius:20px;color:#ccd0e0;font-size:.82rem;cursor:pointer;transition:all .2s;}
    .btn-secondary:hover{border-color:#ff6b9d;color:#ff6b9d;}
    .msg-ok{color:#00c864;font-size:.82rem;margin-top:8px;display:block;}
    .msg-err{color:#ff5252;font-size:.82rem;margin-top:8px;display:block;}
    .search-bar{display:flex;gap:10px;margin-bottom:16px;flex-wrap:wrap;}
    .search-bar input{flex:1;min-width:200px;padding:9px 16px;background:#1a1a2e;border:1px solid rgba(255,255,255,.07);border-radius:20px;color:#ccd0e0;font-size:.84rem;outline:none;}
    .search-bar input:focus{border-color:#ff6b9d;}
    .tbl{width:100%;border-collapse:collapse;font-size:.82rem;}
    .tbl th{background:rgba(255,64,129,.12);color:#ff6b9d;padding:10px 12px;text-align:left;font-weight:500;}
    .tbl td{padding:10px 12px;border-bottom:1px solid rgba(255,255,255,.05);color:rgba(255,255,255,.8);vertical-align:middle;}
    .tbl tr:hover td{background:rgba(255,255,255,.03);}
    .badge{display:inline-block;padding:2px 9px;border-radius:10px;font-size:.72rem;font-weight:600;}
    .badge-A{background:rgba(0,200,100,.15);color:#00c864;}
    .badge-I{background:rgba(255,255,255,.08);color:#aaa;}
    .badge-B{background:rgba(255,50,50,.15);color:#ff5252;}
    .tbl-act{display:flex;gap:6px;flex-wrap:wrap;}
    .btn-sm{padding:4px 12px;border-radius:14px;font-size:.73rem;cursor:pointer;border:1px solid;transition:all .2s;background:transparent;}
    .btn-edit{border-color:#ff6b9d;color:#ff6b9d;} .btn-edit:hover{background:#ff6b9d;color:white;}
    .btn-del{border-color:#ff5252;color:#ff5252;}   .btn-del:hover{background:#ff5252;color:white;}
    .btn-unlock{border-color:#00c864;color:#00c864;}.btn-unlock:hover{background:#00c864;color:white;}
    .pager a,.pager span{color:#8b8fa8;padding:3px 8px;border:1px solid rgba(255,255,255,.07);border-radius:4px;font-size:.75rem;margin:0 2px;text-decoration:none;}
    .pager span{background:rgba(255,107,157,.2);color:#ff6b9d;border-color:#ff6b9d;}
    .card{background:#141427;border:1px solid rgba(255,255,255,.07);border-radius:10px;padding:20px 22px;}
  </style>
</asp:Content>

<asp:Content ID="bodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
  <div class="page-header"><h2>Gestión de Usuarios</h2></div>
  <div class="page-body">

    <asp:UpdatePanel ID="upTodo" runat="server" UpdateMode="Always">
      <ContentTemplate>

        <!-- ══ FORMULARIO ══ -->
        <div class="form-card" id="anclaForm">
          <h3><asp:Literal ID="litTituloForm" runat="server" Text="Nuevo Usuario" /></h3>
          <asp:HiddenField ID="hfUserId" runat="server" Value="0" />

          <%-- Aviso de modo edición restringida --%>
          <asp:Panel ID="pnlAvisoEdicion" runat="server" Visible="false">
            <div class="edit-notice">
              Solo puedes cambiar: Tipo de usuario, Direccion y Estado. Los demas datos los gestiona el propio usuario.
            </div>
          </asp:Panel>

          <%-- Campos de solo lectura (visibles al editar) --%>
          <asp:Panel ID="pnlInfoReadonly" runat="server" Visible="false">
            <div class="f-grid" style="margin-bottom:14px;">
              <div class="f-field"><label>Cedula</label>
                <span class="info-tag"><asp:Literal ID="litRoCedula" runat="server" /></span></div>
              <div class="f-field"><label>Nombres</label>
                <span class="info-tag"><asp:Literal ID="litRoNombres" runat="server" /></span></div>
              <div class="f-field"><label>Apellidos</label>
                <span class="info-tag"><asp:Literal ID="litRoApellidos" runat="server" /></span></div>
              <div class="f-field"><label>Nick</label>
                <span class="info-tag"><asp:Literal ID="litRoNick" runat="server" /></span></div>
              <div class="f-field"><label>Correo</label>
                <span class="info-tag"><asp:Literal ID="litRoCorreo" runat="server" /></span></div>
              <div class="f-field"><label>Celular</label>
                <span class="info-tag"><asp:Literal ID="litRoCelular" runat="server" /></span></div>
            </div>
          </asp:Panel>

          <%-- Campos completos (visibles al CREAR) --%>
          <asp:Panel ID="pnlCamposCreacion" runat="server" Visible="true">
            <div class="f-grid">
              <div class="f-field"><label>Cedula</label>
                <asp:TextBox ID="txtCedula"    runat="server" MaxLength="10" placeholder="0000000000" /></div>
              <div class="f-field"><label>Nombres</label>
                <asp:TextBox ID="txtNombres"   runat="server" MaxLength="50" /></div>
              <div class="f-field"><label>Apellidos</label>
                <asp:TextBox ID="txtApellidos" runat="server" MaxLength="50" /></div>
              <div class="f-field"><label>Celular</label>
                <asp:TextBox ID="txtCelular"   runat="server" MaxLength="10" placeholder="0900000000" /></div>
              <div class="f-field"><label>Correo</label>
                <asp:TextBox ID="txtCorreo"    runat="server" MaxLength="150" /></div>
              <div class="f-field"><label>Nick (usuario)</label>
                <asp:TextBox ID="txtNick"      runat="server" MaxLength="50" /></div>
              <div class="f-field"><label>Contrasena</label>
                <asp:TextBox ID="txtPassword"  runat="server" TextMode="Password" MaxLength="50" /></div>
            </div>
          </asp:Panel>

          <%-- Campos editables (siempre visibles) --%>
          <div class="f-grid" style="margin-top:12px;">
            <div class="f-field"><label>Direccion</label>
              <asp:TextBox ID="txtDireccion" runat="server" MaxLength="50" /></div>
            <div class="f-field"><label>Tipo de usuario</label>
              <asp:DropDownList ID="ddlTipo" runat="server" /></div>
            <div class="f-field"><label>Estado</label>
              <asp:DropDownList ID="ddlEstadoUsu" runat="server">
                <asp:ListItem Value="A" Text="Activo" />
                <asp:ListItem Value="I" Text="Inactivo" />
                <asp:ListItem Value="B" Text="Bloqueado" />
              </asp:DropDownList></div>
          </div>

          <div class="btn-row">
            <asp:Button ID="btnGuardarUsu" runat="server" Text="Guardar"
              CssClass="btn-primary" OnClick="btnGuardarUsu_Click" />
            <asp:Button ID="btnCancelarUsu" runat="server" Text="Cancelar"
              CssClass="btn-secondary" OnClick="btnCancelarUsu_Click"
              CausesValidation="false" />
          </div>
          <asp:Label ID="lblMsgUsu" runat="server" />
        </div>

        <!-- ══ BUSCADOR + GRID ══ -->
        <div class="card">
          <div class="search-bar">
            <asp:TextBox ID="txtBuscarUsu" runat="server"
              placeholder="Buscar por cedula, nick o nombre..."
              AutoPostBack="true" OnTextChanged="FiltroUsu_Changed" />
          </div>

          <asp:GridView ID="gvUsuarios" runat="server"
            CssClass="tbl" AutoGenerateColumns="false"
            AllowPaging="true" PageSize="8"
            OnPageIndexChanging="gvUsuarios_PageIndexChanging"
            OnRowCommand="gvUsuarios_RowCommand"
            PagerStyle-CssClass="pager"
            EmptyDataText="Sin resultados.">
            <Columns>
              <asp:BoundField DataField="usu_cedula"    HeaderText="Cedula"    />
              <asp:BoundField DataField="usu_nombres"   HeaderText="Nombres"   />
              <asp:BoundField DataField="usu_apellidos" HeaderText="Apellidos" />
              <asp:BoundField DataField="usu_nick"      HeaderText="Nick"      />
              <asp:BoundField DataField="usu_correo"    HeaderText="Correo"    />
              <asp:TemplateField HeaderText="Estado">
                <ItemTemplate>
                  <span class='<%# "badge badge-" + Eval("usu_estado") %>'>
                    <%# Eval("usu_estado").ToString()=="A" ? "Activo"
                        : Eval("usu_estado").ToString()=="B" ? "Bloqueado" : "Inactivo" %>
                  </span>
                </ItemTemplate>
              </asp:TemplateField>
              <asp:TemplateField HeaderText="Acciones">
                <ItemTemplate>
                  <div class="tbl-act">
                    <asp:LinkButton runat="server" CommandName="Editar"
                      CommandArgument='<%# Eval("usu_id") %>'
                      CssClass="btn-sm btn-edit" Text="Editar" />
                    <asp:LinkButton runat="server" CommandName="Baja"
                      CommandArgument='<%# Eval("usu_id") %>'
                      CssClass="btn-sm btn-del" Text="Baja"
                      OnClientClick="return confirm('Dar de baja al usuario?');" />
                    <asp:LinkButton runat="server" CommandName="Desbloquear"
                      CommandArgument='<%# Eval("usu_id") %>'
                      CssClass="btn-sm btn-unlock" Text="Activar"
                      Visible='<%# Eval("usu_estado").ToString() != "A" %>' />
                  </div>
                </ItemTemplate>
              </asp:TemplateField>
            </Columns>
          </asp:GridView>
        </div>

      </ContentTemplate>
    </asp:UpdatePanel>

  </div>
</asp:Content>
