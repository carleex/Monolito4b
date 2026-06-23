<%@ Page Title="Inicio" Language="C#" MasterPageFile="~/Usuario/Usuario.Master"
    AutoEventWireup="true" CodeBehind="Home.aspx.cs" Inherits="Monolito4b.Usuario.Home" %>

<asp:Content ID="headContent" ContentPlaceHolderID="head" runat="server">
  <style>
    .hero{padding:48px 32px 32px;text-align:center;}
    .hero h1{font-size:1.7rem;font-weight:500;color:#fff;margin-bottom:8px;}
    .hero p{color:rgba(255,255,255,.45);font-size:.9rem;}
    .cards{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));
      gap:20px;padding:0 32px 40px;}
    .card-item{background:linear-gradient(145deg,#1a1a2e,#2d1f3d);
      border:1px solid rgba(255,255,255,.08);border-radius:16px;
      padding:30px 24px;text-align:center;text-decoration:none;
      transition:transform .2s,box-shadow .2s;display:block;}
    .card-item:hover{transform:translateY(-4px);box-shadow:0 12px 40px rgba(255,64,129,.2);border-color:rgba(255,107,157,.3);}
    .card-icon{font-size:2.4rem;margin-bottom:14px;}
    .card-title{font-size:1rem;font-weight:600;color:#fff;margin-bottom:6px;}
    .card-desc{font-size:.78rem;color:rgba(255,255,255,.4);line-height:1.5;}
    .welcome-chip{display:inline-block;background:rgba(255,107,157,.1);
      border:1px solid rgba(255,107,157,.25);border-radius:20px;
      padding:5px 16px;font-size:.8rem;color:#ff6b9d;margin-bottom:18px;}
  </style>
</asp:Content>

<asp:Content ID="bodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
  <div class="hero">
    <div class="welcome-chip">Bienvenido, <asp:Literal ID="litNombre" runat="server" /></div>
    <h1>Panel de Usuario</h1>
    <p>Explora los productos disponibles, gestiona tus pedidos o diviertete con el juego.</p>
  </div>

  <div class="cards">
    <a class="card-item" href="~/Usuario/MisProductos.aspx" runat="server">
      <div class="card-icon">&#128722;</div>
      <div class="card-title">Productos</div>
      <div class="card-desc">Explora el catalogo completo de productos disponibles.</div>
    </a>
    <a class="card-item" href="~/Usuario/MisPedidos.aspx" runat="server">
      <div class="card-icon">&#128203;</div>
      <div class="card-title">Mis Pedidos</div>
      <div class="card-desc">Revisa el historial y estado de tus pedidos.</div>
    </a>
    <a class="card-item" href="~/Usuario/Juego.aspx" runat="server">
      <div class="card-icon">&#127918;</div>
      <div class="card-title">Juego</div>
      <div class="card-desc">Pon a prueba tus conocimientos en la Trivia Matematica.</div>
    </a>
  </div>
</asp:Content>
