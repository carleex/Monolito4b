<%@ Page Title="Mis Pedidos" Language="C#" MasterPageFile="~/Usuario/Usuario.Master"
    AutoEventWireup="true" CodeBehind="MisPedidos.aspx.cs" Inherits="Monolito4b.Usuario.MisPedidos" %>

<asp:Content ID="headContent" ContentPlaceHolderID="head" runat="server">
  <style>
    .page-body{padding:28px 32px;}
    .page-title{font-size:1.1rem;color:#fff;font-weight:500;margin-bottom:24px;}
    .empty-state{text-align:center;padding:60px 20px;}
    .empty-icon{font-size:3.5rem;margin-bottom:16px;opacity:.4;}
    .empty-state h3{font-size:1rem;color:rgba(255,255,255,.4);font-weight:400;}
    .empty-state p{font-size:.8rem;color:rgba(255,255,255,.25);margin-top:8px;}
    .btn-shop{display:inline-block;margin-top:20px;padding:10px 26px;
      background:#ff4081;border-radius:20px;color:white;text-decoration:none;font-size:.84rem;transition:all .2s;}
    .btn-shop:hover{background:#ff6b9d;}
  </style>
</asp:Content>

<asp:Content ID="bodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
  <div class="page-body">
    <div class="page-title">Mis Pedidos</div>
    <div class="empty-state">
      <div class="empty-icon">&#128203;</div>
      <h3>Aun no tienes pedidos</h3>
      <p>Cuando realices un pedido, aparecera aqui.</p>
      <a class="btn-shop" href="~/Usuario/MisProductos.aspx" runat="server">Ver Productos</a>
    </div>
  </div>
</asp:Content>
