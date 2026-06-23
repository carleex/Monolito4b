<%@ Page Title="Productos" Language="C#" MasterPageFile="~/Usuario/Usuario.Master"
    AutoEventWireup="true" CodeBehind="MisProductos.aspx.cs" Inherits="Monolito4b.Usuario.MisProductos" %>

<asp:Content ID="headContent" ContentPlaceHolderID="head" runat="server">
  <style>
    .page-body{padding:28px 32px;}
    .page-title{font-size:1.1rem;color:#fff;font-weight:500;margin-bottom:20px;}
    .filters{display:flex;gap:12px;margin-bottom:22px;flex-wrap:wrap;}
    .filters input,.filters select{padding:9px 16px;background:#1a1a2e;
      border:1px solid rgba(255,255,255,.07);border-radius:20px;
      color:#ccd0e0;font-size:.84rem;outline:none;}
    .filters input{flex:1;min-width:180px;}
    .filters input:focus,.filters select:focus{border-color:#ff6b9d;}
    .prod-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:18px;}
    .prod-card{background:#141427;border:1px solid rgba(255,255,255,.07);border-radius:12px;
      overflow:hidden;transition:transform .2s,box-shadow .2s;}
    .prod-card:hover{transform:translateY(-3px);box-shadow:0 8px 28px rgba(0,0,0,.4);}
    .prod-img{width:100%;height:140px;object-fit:cover;background:#1a1a2e;display:block;}
    .prod-img-placeholder{width:100%;height:140px;background:#1a1a2e;
      display:flex;align-items:center;justify-content:center;color:rgba(255,255,255,.15);font-size:2rem;}
    .prod-body{padding:14px;}
    .prod-name{font-size:.88rem;font-weight:600;color:#fff;margin-bottom:4px;}
    .prod-cat{font-size:.72rem;color:#ff6b9d;margin-bottom:8px;}
    .prod-price{font-size:1rem;font-weight:700;color:#42d47e;}
    .prod-stock{font-size:.72rem;color:rgba(255,255,255,.35);margin-top:3px;}
    .empty-msg{color:rgba(255,255,255,.3);text-align:center;padding:40px;font-size:.88rem;}
  </style>
</asp:Content>

<asp:Content ID="bodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
  <div class="page-body">
    <div class="page-title">Catalogo de Productos</div>

    <asp:UpdatePanel ID="upFiltros" runat="server" UpdateMode="Conditional">
      <ContentTemplate>
        <div class="filters">
          <asp:TextBox ID="txtBuscar" runat="server" placeholder="Buscar producto..."
            AutoPostBack="true" OnTextChanged="Filtro_Changed" />
          <asp:DropDownList ID="ddlCategoria" runat="server"
            AutoPostBack="true" OnSelectedIndexChanged="Filtro_Changed" />
        </div>

        <asp:Panel ID="pnlGrid" runat="server">
          <div class="prod-grid">
            <asp:Repeater ID="rptProductos" runat="server">
              <ItemTemplate>
                <div class="prod-card">
                  <%# !string.IsNullOrWhiteSpace(Eval("pro_imagen_path") as string)
                      ? "<img class=\"prod-img\" src=\"" + ResolveUrl(Eval("pro_imagen_path").ToString()) + "\" alt=\"" + Eval("pro_nombre") + "\" />"
                      : "<div class=\"prod-img-placeholder\">&#128247;</div>" %>
                  <div class="prod-body">
                    <div class="prod-name"><%# Eval("pro_nombre") %></div>
                    <div class="prod-cat"><%# Eval("pro_categoria") %></div>
                    <div class="prod-price">$<%# string.Format("{0:N2}", Eval("pro_precio")) %></div>
                    <div class="prod-stock">Stock: <%# Eval("pro_cantidad") %></div>
                  </div>
                </div>
              </ItemTemplate>
            </asp:Repeater>
          </div>
          <asp:Label ID="lblVacio" runat="server" Visible="false"
            CssClass="empty-msg" Text="No se encontraron productos." />
        </asp:Panel>
      </ContentTemplate>
    </asp:UpdatePanel>
  </div>
</asp:Content>
