<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="Monolito4b.Dashboard" %>

<asp:Content ID="headContent" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <style>
        .dash-grid { display:grid; grid-template-columns:1fr 1fr; gap:22px; }
        @media(max-width:900px){ .dash-grid { grid-template-columns:1fr; } }

        /* ── Carrusel ── */
        .carousel-wrap {
            position: relative; border-radius: 10px; background: #0d0d1a;
            overflow: hidden; width: 100%;
        }
        .carousel-track {
            display: flex; flex-wrap: nowrap;
            transition: transform .45s ease;
            will-change: transform;
        }
        .carousel-slide {
            flex: 0 0 100%; width: 100%;
            position: relative;
            background: #0d0d1a;
            display: flex; align-items: center; justify-content: center;
            min-height: 300px;
        }
        .carousel-slide img {
            max-width: 100%; max-height: 300px;
            width: auto; height: 300px;
            object-fit: contain;
            display: block;
        }
        .slide-caption {
            position: absolute; bottom: 0; left: 0; right: 0;
            padding: 14px 18px;
            background: linear-gradient(transparent, rgba(0,0,0,.78));
            color: #fff; font-size: .9rem; border-radius: 0 0 10px 10px;
        }
        .slide-caption small { display:block; font-size:.75rem; color:rgba(255,255,255,.6); margin-top:3px; }
        .carousel-btn {
            position: absolute; top: 50%; transform: translateY(-50%);
            background: rgba(0,0,0,.55); border: none; color: #fff;
            font-size: 1.2rem; width: 38px; height: 38px;
            display: flex; align-items: center; justify-content: center;
            cursor: pointer; border-radius: 50%; z-index: 5;
            transition: background .2s;
        }
        .carousel-btn:hover { background: rgba(255,107,157,.6); }
        .carousel-btn.prev { left: 10px; }
        .carousel-btn.next { right: 10px; }
        .no-img-placeholder {
            width: 100%; min-height: 300px;
            display: flex; align-items: center; justify-content: center;
            color: #444760; font-size: .85rem; background: #0d0d1a;
        }

        /* ── Chart ── */
        .chart-wrap { background:#141427; border:1px solid rgba(255,255,255,.07); border-radius:10px; padding:22px; }
        .chart-wrap h3 { font-size:.95rem; color:#fff; margin-bottom:16px; }
        canvas#chartProductos { max-height:320px; }

        /* ── KPI cards ── */
        .kpi-row { display:grid; grid-template-columns:repeat(auto-fill,minmax(150px,1fr)); gap:14px; margin-bottom:22px; }
        .kpi-card { background:#141427; border:1px solid rgba(255,255,255,.07); border-radius:10px; padding:18px 20px; }
        .kpi-card .kpi-val { font-size:1.6rem; font-weight:700; color:#ff6b9d; }
        .kpi-card .kpi-lbl { font-size:.75rem; color:#8b8fa8; margin-top:4px; }
    </style>
</asp:Content>

<asp:Content ID="bodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="page-title">Dashboard</div>

    <!-- ═ KPI row ══════════════════════════════════════════════════════════ -->
    <div class="kpi-row">
        <div class="kpi-card">
            <div class="kpi-val"><asp:Literal ID="litTotalProductos" runat="server" /></div>
            <div class="kpi-lbl">Productos activos</div>
        </div>
        <div class="kpi-card">
            <div class="kpi-val"><asp:Literal ID="litTotalStock"    runat="server" /></div>
            <div class="kpi-lbl">Unidades en stock</div>
        </div>
        <div class="kpi-card">
            <div class="kpi-val"><asp:Literal ID="litTotalProveedores" runat="server" /></div>
            <div class="kpi-lbl">Proveedores activos</div>
        </div>
        <div class="kpi-card">
            <div class="kpi-val"><asp:Literal ID="litCategorias" runat="server" /></div>
            <div class="kpi-lbl">Categorías</div>
        </div>
    </div>

    <!-- ═ Carrusel + Chart ══════════════════════════════════════════════════ -->
    <div class="dash-grid">

        <!-- Carrusel (Repeater) -->
        <div>
            <div class="card" style="padding:0; border-radius:10px;">
                <div class="carousel-wrap" id="carousel">
                    <div class="carousel-track" id="carouselTrack">
                        <asp:Repeater ID="repCarrusel" runat="server">
                            <ItemTemplate>
                                <div class="carousel-slide">
                                    <%# GetImgSrc(Eval("pro_imagen_path")) != ""
                                        ? "<img src=\"" + GetImgSrc(Eval("pro_imagen_path")) + "\" alt=\"" + Eval("pro_nombre") + "\" style=\"width:100%;height:260px;object-fit:cover;border-radius:10px;display:block;\" onerror=\"this.parentNode.innerHTML='<div class=no-img-placeholder>Sin imagen</div>'\" />"
                                        : "<div class=\"no-img-placeholder\">Sin imagen</div>" %>
                                    <div class="slide-caption">
                                        <%# Eval("pro_nombre") %>
                                        <small>Stock: <%# Eval("pro_cantidad") %> &nbsp;|&nbsp; <%# Eval("pro_categoria") %></small>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                    <button class="carousel-btn prev" type="button" onclick="slidePrev()">&#10094;</button>
                    <button class="carousel-btn next" type="button" onclick="slideNext()">&#10095;</button>
                </div>
            </div>
        </div>

        <!-- Chart.js -->
        <div class="chart-wrap">
            <h3>Stock por Producto</h3>
            <canvas id="chartProductos"></canvas>
        </div>

    </div>

    <!-- Chart.js data injection -->
    <script>
        (function () {
            var labels = <%= JsonLabels %>;
            var data   = <%= JsonData %>;
            new Chart(document.getElementById('chartProductos'), {
                type: 'bar',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Cantidad en stock',
                        data: data,
                        backgroundColor: 'rgba(255,107,157,0.65)',
                        borderColor: '#ff6b9d',
                        borderWidth: 1,
                        borderRadius: 5
                    }]
                },
                options: {
                    responsive: true,
                    plugins: { legend: { labels: { color: '#ccd0e0' } } },
                    scales: {
                        x: { ticks: { color: '#8b8fa8' }, grid: { color: 'rgba(255,255,255,.05)' } },
                        y: { ticks: { color: '#8b8fa8' }, grid: { color: 'rgba(255,255,255,.05)' }, beginAtZero: true }
                    }
                }
            });
        })();

        // ── Carrusel ─────────────────────────────────────────────────────
        var _idx = 0;
        var _track = document.getElementById('carouselTrack');
        var _total = _track ? _track.children.length : 0;
        var _auto;

        function goTo(n) {
            if (_total === 0) return;
            _idx = (n + _total) % _total;
            _track.style.transform = 'translateX(-' + (_idx * 100) + '%)';
        }
        function slideNext() { goTo(_idx + 1); }
        function slidePrev() { goTo(_idx - 1); }

        function startAuto() { _auto = setInterval(slideNext, 4000); }
        function stopAuto()  { clearInterval(_auto); }

        // Detener auto-play al pasar el ratón
        var wrap = document.getElementById('carousel');
        if (wrap) {
            wrap.addEventListener('mouseenter', stopAuto);
            wrap.addEventListener('mouseleave', startAuto);
        }
        startAuto();
    </script>

</asp:Content>
