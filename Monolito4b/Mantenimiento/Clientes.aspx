<%@ Page Title="Clientes" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Clientes.aspx.cs" Inherits="Monolito4b.Mantenimiento.Clientes" %>

<asp:Content ID="hc" ContentPlaceHolderID="HeadContent" runat="server">
  <style>
    .search-bar{margin-bottom:14px;}
    .search-bar input{width:100%;max-width:340px;padding:8px 16px;
      background:#1a1a2e;border:1px solid rgba(255,255,255,.07);
      border-radius:20px;color:#ccd0e0;font-size:.84rem;outline:none;}
    .search-bar input:focus{border-color:#ff6b9d;}
    .badge-A{background:rgba(50,200,100,.15);color:#42d47e;border-radius:4px;padding:2px 8px;font-size:.75rem;}
    .badge-I{background:rgba(220,80,80,.15);color:#e05050;border-radius:4px;padding:2px 8px;font-size:.75rem;}
    .badge-B{background:rgba(255,255,255,.08);color:#aaa;border-radius:4px;padding:2px 8px;font-size:.75rem;}
    .btn-sm{padding:4px 12px;border-radius:14px;font-size:.73rem;cursor:pointer;border:1px solid;background:transparent;transition:all .2s;margin-right:4px;}
    .btn-unlock{border-color:#42d47e;color:#42d47e;} .btn-unlock:hover{background:#42d47e;color:white;}
    .btn-del{border-color:#e05050;color:#e05050;}    .btn-del:hover{background:#e05050;color:white;}
  </style>
</asp:Content>

<asp:Content ID="mc" ContentPlaceHolderID="MainContent" runat="server">

  <h2 class="page-title">Clientes / Jugadores</h2>
  <p style="color:#8b8fa8;font-size:.82rem;margin-bottom:18px;">
    Listado de usuarios con perfil <strong style="color:#ff6b9d;">Usuario</strong> (tusu_id = 2).
  </p>

  <div class="card">
    <asp:UpdatePanel ID="upClientes" runat="server" UpdateMode="Conditional">
      <ContentTemplate>

        <div class="search-bar">
          <asp:TextBox ID="txtBuscarCli" runat="server"
            placeholder="Buscar por cédula, nick o nombre..."
            AutoPostBack="true" OnTextChanged="Buscar_Changed" />
        </div>

        <asp:Label ID="lblMsgCli" runat="server" style="display:block;margin-bottom:10px;" />

        <asp:GridView ID="gvClientes" runat="server"
          CssClass="tbl" AutoGenerateColumns="false"
          AllowPaging="true" PageSize="8"
          OnPageIndexChanging="gvClientes_PageIndexChanging"
          OnRowCommand="gvClientes_RowCommand"
          EmptyDataText="Sin clientes registrados.">
          <Columns>
            <asp:BoundField DataField="usu_cedula"    HeaderText="Cédula"    />
            <asp:BoundField DataField="usu_nombres"   HeaderText="Nombres"   />
            <asp:BoundField DataField="usu_apellidos" HeaderText="Apellidos" />
            <asp:BoundField DataField="usu_nick"      HeaderText="Nick"      />
            <asp:BoundField DataField="usu_correo"    HeaderText="Correo"    />
            <asp:BoundField DataField="usu_celular"   HeaderText="Celular"   />
            <asp:TemplateField HeaderText="Estado">
              <ItemTemplate>
                <span class='<%# "badge-" + Eval("usu_estado") %>'>
                  <%# Eval("usu_estado").ToString() == "A" ? "Activo"
                      : Eval("usu_estado").ToString() == "B" ? "Bloqueado" : "Inactivo" %>
                </span>
              </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Acciones">
              <ItemTemplate>
                <asp:LinkButton runat="server" CommandName="Baja"
                  CommandArgument='<%# Eval("usu_id") %>'
                  CssClass="btn-sm btn-del" Text="Baja"
                  Visible='<%# Eval("usu_estado").ToString() == "A" %>'
                  OnClientClick="return confirm('¿Dar de baja al cliente?');" />
                <asp:LinkButton runat="server" CommandName="Activar"
                  CommandArgument='<%# Eval("usu_id") %>'
                  CssClass="btn-sm btn-unlock" Text="Activar"
                  Visible='<%# Eval("usu_estado").ToString() != "A" %>' />
              </ItemTemplate>
            </asp:TemplateField>
          </Columns>
        </asp:GridView>

      </ContentTemplate>
      <Triggers>
        <asp:AsyncPostBackTrigger ControlID="txtBuscarCli" EventName="TextChanged" />
      </Triggers>
    </asp:UpdatePanel>
  </div>

</asp:Content>
