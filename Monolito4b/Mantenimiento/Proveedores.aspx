<%@ Page Title="Proveedores" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Proveedores.aspx.cs" Inherits="Monolito4b.Mantenimiento.Proveedores" %>

<asp:Content ID="hc" ContentPlaceHolderID="HeadContent" runat="server">
  <style>
    .f-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:14px;margin-bottom:18px;}
    .f-field label{display:block;font-size:.78rem;color:#8b8fa8;margin-bottom:4px;}
    .f-field input,.f-field select{
      width:100%;padding:9px 12px;background:#1a1a2e;
      border:1px solid rgba(255,255,255,.07);border-radius:6px;
      color:#ccd0e0;font-size:.84rem;outline:none;}
    .f-field input:focus,.f-field select:focus{border-color:#ff6b9d;}
    .btn-row{display:flex;gap:10px;flex-wrap:wrap;margin-top:6px;}
    .search-bar{margin-bottom:14px;}
    .search-bar input{width:100%;max-width:340px;padding:8px 16px;
      background:#1a1a2e;border:1px solid rgba(255,255,255,.07);
      border-radius:20px;color:#ccd0e0;font-size:.84rem;outline:none;}
    .search-bar input:focus{border-color:#ff6b9d;}
    .badge-A{background:rgba(50,200,100,.15);color:#42d47e;border-radius:4px;padding:2px 8px;font-size:.75rem;}
    .badge-I{background:rgba(220,80,80,.15);color:#e05050;border-radius:4px;padding:2px 8px;font-size:.75rem;}
    .btn-sm{padding:4px 12px;border-radius:14px;font-size:.73rem;cursor:pointer;border:1px solid;background:transparent;transition:all .2s;margin-right:4px;}
    .btn-edit{border-color:#ff6b9d;color:#ff6b9d;} .btn-edit:hover{background:#ff6b9d;color:white;}
    .btn-del{border-color:#e05050;color:#e05050;}  .btn-del:hover{background:#e05050;color:white;}
    .btn-res{border-color:#42d47e;color:#42d47e;}  .btn-res:hover{background:#42d47e;color:white;}
  </style>
</asp:Content>

<asp:Content ID="mc" ContentPlaceHolderID="MainContent" runat="server">

  <h2 class="page-title">Gestión de Proveedores</h2>

  <!-- ══ FORMULARIO ══ -->
  <div class="card">
    <b style="color:#ccd0e0;font-size:.9rem"><asp:Literal ID="litTitulo" runat="server" Text="Nuevo Proveedor" /></b>
    <asp:HiddenField ID="hfProvId" runat="server" Value="0" />
    <div class="f-grid" style="margin-top:14px;">
      <div class="f-field">
        <label>Nombre del Proveedor</label>
        <asp:TextBox ID="txtNombre" runat="server" MaxLength="50" placeholder="Ej: Proveedor S.A." />
      </div>
      <div class="f-field">
        <label>Estado</label>
        <asp:DropDownList ID="ddlEstado" runat="server">
          <asp:ListItem Value="A" Text="Activo" />
          <asp:ListItem Value="I" Text="Inactivo" />
        </asp:DropDownList>
      </div>
    </div>
    <div class="btn-row">
      <asp:Button ID="btnGuardar" runat="server" Text="Guardar"
        CssClass="btn-primary" OnClick="btnGuardar_Click" />
      <asp:Button ID="btnCancelar" runat="server" Text="Cancelar"
        CssClass="btn-danger" OnClick="btnCancelar_Click" CausesValidation="false" />
    </div>
    <asp:Label ID="lblMsg" runat="server" style="display:block;margin-top:10px;" />
  </div>

  <!-- ══ GRID ══ -->
  <div class="card">
    <asp:UpdatePanel ID="upProv" runat="server" UpdateMode="Conditional">
      <ContentTemplate>
        <div class="search-bar" style="display:flex;justify-content:space-between;align-items:center;">
          <asp:TextBox ID="txtBuscar" runat="server"
            placeholder="Buscar por nombre..."
            AutoPostBack="true" OnTextChanged="Buscar_Changed" />
          <a href="/Handlers/ExcelExport.ashx?tabla=proveedores"
             style="padding:8px 14px;border-radius:6px;background:rgba(66,212,126,.12);
                    border:1px solid #42d47e;color:#42d47e;font-size:.8rem;text-decoration:none;white-space:nowrap;">
            Exportar Excel
          </a>
        </div>

        <asp:GridView ID="gvProveedores" runat="server"
          CssClass="tbl" AutoGenerateColumns="false"
          AllowPaging="true" PageSize="8"
          OnPageIndexChanging="gvProveedores_PageIndexChanging"
          OnRowCommand="gvProveedores_RowCommand"
          EmptyDataText="Sin resultados.">
          <Columns>
            <asp:BoundField DataField="prov_id"     HeaderText="ID"     ItemStyle-Width="50px" />
            <asp:BoundField DataField="prov_nombre" HeaderText="Nombre" />
            <asp:TemplateField HeaderText="Estado">
              <ItemTemplate>
                <span class='<%# "badge-" + Eval("prov_estado") %>'>
                  <%# Eval("prov_estado").ToString() == "A" ? "Activo" : "Inactivo" %>
                </span>
              </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Acciones">
              <ItemTemplate>
                <asp:LinkButton runat="server" CommandName="Editar"
                  CommandArgument='<%# Eval("prov_id") %>'
                  CssClass="btn-sm btn-edit" Text="Editar" />
                <asp:LinkButton runat="server" CommandName="Baja"
                  CommandArgument='<%# Eval("prov_id") %>'
                  CssClass="btn-sm btn-del" Text="Baja"
                  Visible='<%# Eval("prov_estado").ToString() == "A" %>'
                  OnClientClick="return confirm('¿Dar de baja al proveedor y sus productos?');" />
                <asp:LinkButton runat="server" CommandName="Restaurar"
                  CommandArgument='<%# Eval("prov_id") %>'
                  CssClass="btn-sm btn-res" Text="Restaurar"
                  Visible='<%# Eval("prov_estado").ToString() == "I" %>'
                  OnClientClick="return confirm('¿Restaurar proveedor y sus productos?');" />
              </ItemTemplate>
            </asp:TemplateField>
          </Columns>
        </asp:GridView>
      </ContentTemplate>
      <Triggers>
        <asp:AsyncPostBackTrigger ControlID="txtBuscar" EventName="TextChanged" />
      </Triggers>
    </asp:UpdatePanel>
  </div>

</asp:Content>
