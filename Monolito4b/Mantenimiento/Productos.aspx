<%@ Page Title="Productos" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Productos.aspx.cs" Inherits="Monolito4b.Mantenimiento.Productos" %>

<asp:Content ID="headContent" ContentPlaceHolderID="HeadContent" runat="server">
  <style>
  /* ─── Tabla / formulario ───────────────────────────────── */
  .search-bar{display:flex;gap:10px;flex-wrap:wrap;align-items:flex-end;margin-bottom:16px;}
  .search-bar label{font-size:.78rem;color:#8b8fa8;display:block;margin-bottom:3px;}
  .search-bar input[type=text],.search-bar select{
    background:#1a1a2e;border:1px solid rgba(255,255,255,.07);
    color:#ccd0e0;padding:8px 10px;border-radius:6px;font-size:.84rem;min-width:180px;}
  .search-bar input[type=text]:focus,.search-bar select:focus{border-color:#ff6b9d;outline:none;}
  .tbl img.prod-thumb{width:46px;height:46px;object-fit:cover;border-radius:5px;background:#1a1a2e;display:block;}
  .form-panel{background:#141427;border:1px solid rgba(255,255,255,.07);border-radius:10px;padding:22px 24px;margin-bottom:24px;}
  .form-panel h3{font-size:1rem;color:#fff;margin-bottom:16px;}
  .f-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(190px,1fr));gap:12px;}
  .f-grid .f-field label{font-size:.78rem;color:#8b8fa8;display:block;margin-bottom:4px;}
  .f-grid .f-field input[type=text],
  .f-grid .f-field input[type=number],
  .f-grid .f-field select{
    width:100%;background:#1a1a2e;border:1px solid rgba(255,255,255,.07);
    color:#ccd0e0;padding:8px 10px;border-radius:6px;font-size:.84rem;}
  .f-grid .f-field input:focus,.f-grid .f-field select:focus{border-color:#ff6b9d;outline:none;}
  .img-preview-box{margin-top:8px;display:none;}
  .img-preview-box img{width:70px;height:70px;object-fit:cover;border-radius:6px;border:1px solid rgba(255,107,157,.3);}
  .pager a,.pager span{color:#8b8fa8;padding:4px 9px;border:1px solid rgba(255,255,255,.07);
    border-radius:4px;font-size:.8rem;margin:0 2px;text-decoration:none;}
  .pager span{background:rgba(255,107,157,.2);color:#ff6b9d;border-color:#ff6b9d;}
  .badge-a{background:rgba(0,200,100,.15);color:#00c864;padding:2px 8px;border-radius:10px;font-size:.72rem;}
  .badge-i{background:rgba(255,255,255,.08);color:#aaa;padding:2px 8px;border-radius:10px;font-size:.72rem;}

  /* ─── Miniaturas en tabla ──────────────────────────────── */
  .thumbs-wrap{display:flex;flex-direction:column;align-items:flex-start;gap:4px;}
  .thumbs-row{display:flex;gap:3px;}
  .thumb-mini{width:34px;height:34px;object-fit:cover;border-radius:4px;
    border:1px solid rgba(255,107,157,.3);display:block;}
  .btn-ver-imgs{
    display:inline-flex;align-items:center;gap:4px;
    font-size:.7rem;padding:3px 9px;border-radius:12px;
    border:1px solid rgba(255,107,157,.45);color:#ff6b9d;
    background:transparent;cursor:pointer;white-space:nowrap;
    transition:all .18s;text-decoration:none;}
  .btn-ver-imgs:hover{background:rgba(255,107,157,.12);}
  .thumb-count-badge{
    font-size:.65rem;background:rgba(255,107,157,.15);
    color:#ff6b9d;padding:1px 6px;border-radius:8px;}

  /* ─── Gallery Viewer Modal (JS) ────────────────────────── */
  #galViewer{
    display:none;position:fixed;inset:0;
    background:rgba(0,0,0,.96);z-index:9999;
    flex-direction:column;align-items:center;justify-content:center;
    padding:16px;}
  #galViewer.open{display:flex;}

  .gv-header{
    width:100%;max-width:960px;
    display:flex;align-items:center;justify-content:space-between;
    margin-bottom:12px;}
  .gv-title{color:#fff;font-size:1rem;font-weight:600;
    white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:70%;}
  .gv-close{
    color:#fff;font-size:2rem;opacity:.7;cursor:pointer;
    background:none;border:none;padding:0;line-height:1;}
  .gv-close:hover{opacity:1;}

  .gv-main{
    position:relative;display:flex;align-items:center;
    width:100%;max-width:960px;flex:1;min-height:0;
    justify-content:center;}
  .gv-img-wrap{
    flex:1;display:flex;align-items:center;justify-content:center;
    min-height:0;overflow:hidden;}
  #galMainImg{
    max-width:100%;max-height:60vh;
    object-fit:contain;border-radius:8px;
    transition:opacity .2s,transform .2s;
    box-shadow:0 8px 40px rgba(0,0,0,.6);}
  #galMainImg.fade{opacity:0;transform:scale(.96);}

  .gv-nav{
    background:rgba(255,255,255,.08);border:none;
    color:#fff;font-size:2rem;line-height:1;
    padding:0 14px;height:56px;border-radius:8px;
    cursor:pointer;transition:background .18s;flex-shrink:0;}
  .gv-nav:hover{background:rgba(255,107,157,.3);}
  .gv-nav:disabled{opacity:.2;cursor:not-allowed;}

  .gv-counter{
    color:#8b8fa8;font-size:.82rem;margin:8px 0;
    text-align:center;letter-spacing:.03em;}
  .gv-counter strong{color:#fff;}

  /* Thumbnails strip */
  .gv-thumbs{
    display:flex;gap:8px;width:100%;max-width:960px;
    overflow-x:auto;padding:4px 0 8px;
    scrollbar-width:thin;scrollbar-color:#333 transparent;}
  .gv-thumbs::-webkit-scrollbar{height:4px;}
  .gv-thumbs::-webkit-scrollbar-thumb{background:#333;border-radius:2px;}
  .gv-thumb{
    flex-shrink:0;width:68px;height:52px;
    object-fit:cover;border-radius:6px;cursor:pointer;
    border:2px solid transparent;transition:border-color .18s,opacity .18s;
    opacity:.6;}
  .gv-thumb:hover{opacity:.9;}
  .gv-thumb.active{border-color:#ff6b9d;opacity:1;}

  /* Responsive */
  @media(max-width:600px){
    .gv-nav{font-size:1.4rem;padding:0 10px;height:44px;}
    #galMainImg{max-height:50vh;}
    .gv-thumb{width:52px;height:40px;}
  }
  </style>
</asp:Content>

<asp:Content ID="bodyContent" ContentPlaceHolderID="MainContent" runat="server">

  <div class="page-title">Gestion de Productos</div>

  <!-- ═ FORMULARIO (fuera del UpdatePanel para que FileUpload funcione) ═══ -->
  <div class="form-panel" id="anclaForm">
    <h3 id="formTitle">Nuevo Producto</h3>

    <%-- Campos del formulario — postback completo --%>
    <asp:HiddenField ID="hfProId"        runat="server" Value="0" />
    <asp:HiddenField ID="hfImagenActual" runat="server" Value="" />

    <div class="f-grid">
      <div class="f-field"><label>Nombre</label>
        <asp:TextBox ID="txtNombre"   runat="server" /></div>
      <div class="f-field"><label>Cantidad</label>
        <asp:TextBox ID="txtCantidad" runat="server" TextMode="Number" /></div>
      <div class="f-field"><label>Precio</label>
        <asp:TextBox ID="txtPrecio"   runat="server" /></div>
      <div class="f-field"><label>Categoria</label>
        <asp:TextBox ID="txtCategoria" runat="server" /></div>
      <div class="f-field"><label>Proveedor</label>
        <asp:DropDownList ID="ddlProveedor" runat="server" AppendDataBoundItems="true">
          <asp:ListItem Value="" Text="— Sin proveedor —" />
        </asp:DropDownList>
      </div>
      <div class="f-field"><label>Estado</label>
        <asp:DropDownList ID="ddlEstado" runat="server">
          <asp:ListItem Value="A" Text="Activo" />
          <asp:ListItem Value="I" Text="Inactivo" />
        </asp:DropDownList>
      </div>
      <div class="f-field" style="grid-column:span 2;">
        <label>Imagen (JPG/PNG/GIF) — dejar en blanco para conservar la actual</label>
        <asp:FileUpload ID="fuImagen" runat="server"
          accept="image/jpeg,image/png,image/gif,image/webp,image/bmp" />
        <div class="img-preview-box" id="previewBox">
          <asp:Image ID="imgPreview" runat="server" CssClass="prod-thumb" />
          <small style="color:#8b8fa8;font-size:.72rem;">Imagen actual</small>
        </div>
      </div>
    </div>

    <div style="margin-top:16px;display:flex;gap:10px;">
      <asp:Button ID="btnGuardar" runat="server" Text="Guardar"
        CssClass="btn-primary" OnClick="btnGuardar_Click" />
      <asp:Button ID="btnCancelar" runat="server" Text="Cancelar"
        CssClass="btn-danger" OnClick="btnCancelar_Click" CausesValidation="false" />
    </div>
    <asp:Label ID="lblMsg" runat="server" CssClass="msg-ok" />
  </div>

  <!-- ═ GRID (dentro del UpdatePanel para búsqueda en tiempo real) ════════ -->
  <div class="card">
    <asp:UpdatePanel ID="upGrid" runat="server" UpdateMode="Conditional">
      <ContentTemplate>

        <%-- Hidden fields para pasar datos de edicion al formulario via JS --%>
        <asp:HiddenField ID="hfEditId"       runat="server" Value="" />
        <asp:HiddenField ID="hfEditNombre"   runat="server" Value="" />
        <asp:HiddenField ID="hfEditCantidad" runat="server" Value="" />
        <asp:HiddenField ID="hfEditPrecio"   runat="server" Value="" />
        <asp:HiddenField ID="hfEditCategoria" runat="server" Value="" />
        <asp:HiddenField ID="hfEditEstado"   runat="server" Value="" />
        <asp:HiddenField ID="hfEditProvId"   runat="server" Value="" />
        <asp:HiddenField ID="hfEditImagen"   runat="server" Value="" />

        <div style="display:flex;justify-content:space-between;align-items:flex-end;flex-wrap:wrap;gap:10px;margin-bottom:10px;">
          <div class="search-bar" style="margin-bottom:0;">
            <div>
              <label>Buscar por nombre</label>
              <asp:TextBox ID="txtBuscar" runat="server" AutoPostBack="true"
                OnTextChanged="FiltroChanged" placeholder="Escriba para filtrar..." />
            </div>
            <div>
              <label>Categoria</label>
              <asp:DropDownList ID="ddlFiltroCategoria" runat="server"
                AutoPostBack="true" OnSelectedIndexChanged="FiltroChanged"
                AppendDataBoundItems="true">
                <asp:ListItem Value="" Text="— Todas —" />
              </asp:DropDownList>
            </div>
          </div>
          <div style="display:flex;gap:8px;">
            <a href="/Mantenimiento/Imagenes.aspx"
               style="padding:8px 14px;border-radius:6px;background:rgba(255,107,157,.15);
                      border:1px solid #ff6b9d;color:#ff6b9d;font-size:.8rem;text-decoration:none;">
              Gestionar imágenes
            </a>
            <a href="/Handlers/ExcelExport.ashx?tabla=productos"
               style="padding:8px 14px;border-radius:6px;background:rgba(66,212,126,.12);
                      border:1px solid #42d47e;color:#42d47e;font-size:.8rem;text-decoration:none;">
              Exportar Excel
            </a>
          </div>
        </div>

        <asp:GridView ID="gvProductos" runat="server" CssClass="tbl"
          AutoGenerateColumns="false" AllowPaging="true" PageSize="5"
          OnPageIndexChanging="gvProductos_PageIndexChanging"
          OnRowCommand="gvProductos_RowCommand"
          PagerStyle-CssClass="pager"
          EmptyDataText="Sin resultados.">
          <Columns>
            <asp:TemplateField HeaderText="Imágenes">
              <ItemTemplate>
                <%# RenderMiniaturas(Eval("pro_id")) %>
              </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="pro_nombre"    HeaderText="Nombre"    />
            <asp:BoundField DataField="pro_categoria" HeaderText="Categoria" />
            <asp:BoundField DataField="pro_cantidad"  HeaderText="Stock"     />
            <asp:BoundField DataField="pro_precio"    HeaderText="Precio"    DataFormatString="{0:C2}" />
            <asp:TemplateField HeaderText="Estado">
              <ItemTemplate>
                <span class='<%# (Eval("pro_estado") as string)?.Trim()=="A"?"badge-a":"badge-i" %>'>
                  <%# (Eval("pro_estado") as string)?.Trim()=="A"?"Activo":"Inactivo" %>
                </span>
              </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Acciones">
              <ItemTemplate>
                <asp:LinkButton runat="server" CommandName="Editar"
                  CommandArgument='<%# Eval("pro_id") %>'
                  CssClass="btn-primary" Text="Editar" />
                &nbsp;
                <asp:LinkButton runat="server" CommandName="Baja"
                  CommandArgument='<%# Eval("pro_id") %>'
                  CssClass="btn-danger" Text="Baja"
                  OnClientClick="return confirm('Confirma la baja logica?');" />
              </ItemTemplate>
            </asp:TemplateField>
          </Columns>
        </asp:GridView>

      </ContentTemplate>
    </asp:UpdatePanel>
  </div>

  <script>
  // ── Búsqueda en tiempo real ──────────────────────────────────────────────
  (function(){
    var timer=null;
    function hook(){
      var tb=document.getElementById('<%=txtBuscar.ClientID%>');
      if(!tb)return;
      tb.setAttribute('autocomplete','off');
      tb.addEventListener('input',function(){
        clearTimeout(timer);
        timer=setTimeout(function(){ __doPostBack('<%=txtBuscar.UniqueID%>',''); },350);
      });
    }
    hook();
    if(typeof Sys!=='undefined')
      Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function(){ hook(); rellenarFormSiHayEdicion(); });
  })();

  // ── Poblar formulario con datos del Editar (vía hidden fields del panel) ─
  function rellenarFormSiHayEdicion(){
    var id=document.getElementById('<%=hfEditId.ClientID%>').value;
    if(!id||id==='')return;

    // Poblar formulario (fuera del UpdatePanel)
    document.getElementById('<%=hfProId.ClientID%>').value        = id;
    document.getElementById('<%=hfImagenActual.ClientID%>').value  = document.getElementById('<%=hfEditImagen.ClientID%>').value;
    document.getElementById('<%=txtNombre.ClientID%>').value       = document.getElementById('<%=hfEditNombre.ClientID%>').value;
    document.getElementById('<%=txtCantidad.ClientID%>').value     = document.getElementById('<%=hfEditCantidad.ClientID%>').value;
    document.getElementById('<%=txtPrecio.ClientID%>').value       = document.getElementById('<%=hfEditPrecio.ClientID%>').value;
    document.getElementById('<%=txtCategoria.ClientID%>').value    = document.getElementById('<%=hfEditCategoria.ClientID%>').value;
    
    var selEst=document.getElementById('<%=ddlEstado.ClientID%>');
    var est=document.getElementById('<%=hfEditEstado.ClientID%>').value;
    for(var i=0;i<selEst.options.length;i++)
      if(selEst.options[i].value===est){ selEst.selectedIndex=i; break; }

    var selProv=document.getElementById('<%=ddlProveedor.ClientID%>');
    var prov=document.getElementById('<%=hfEditProvId.ClientID%>').value;
    for(var j=0;j<selProv.options.length;j++)
      if(selProv.options[j].value===prov){ selProv.selectedIndex=j; break; }

    // Mostrar imagen actual si existe
    var imgPath=document.getElementById('<%=hfEditImagen.ClientID%>').value;
    var previewBox=document.getElementById('previewBox');
    if(imgPath && imgPath!==''){
      document.getElementById('<%=imgPreview.ClientID%>').src=imgPath;
      previewBox.style.display='block';
    }else{
      previewBox.style.display='none';
    }

    document.getElementById('formTitle').innerText='Editar Producto';
    document.getElementById('<%=btnGuardar.ClientID%>').value='Actualizar Producto';

    // Limpiar el trigger para no re-poblar en proximos postbacks
    document.getElementById('<%=hfEditId.ClientID%>').value='';

    // Scroll al formulario
    setTimeout(function(){
      var el=document.getElementById('anclaForm');
      if(el)el.scrollIntoView({behavior:'smooth',block:'start'});
    },80);
  }

  // Ejecutar al cargar (para postback completo tras guardar)
  rellenarFormSiHayEdicion();
  </script>

  <!-- ═══════════════════════════════════════════════════════════
       GALLERY VIEWER MODAL — main image + thumbs + navegación
  ═══════════════════════════════════════════════════════════════ -->
  <div id="galViewer" role="dialog" aria-modal="true" aria-label="Galería de imágenes">
    <div class="gv-header">
      <span class="gv-title" id="galTitle"></span>
      <button class="gv-close" onclick="GV.close()" title="Cerrar (Esc)">&times;</button>
    </div>

    <div class="gv-main">
      <button class="gv-nav" id="galPrev" onclick="GV.prev()" title="Anterior (←)">&#8249;</button>
      <div class="gv-img-wrap">
        <img id="galMainImg" src="" alt="" />
      </div>
      <button class="gv-nav" id="galNext" onclick="GV.next()" title="Siguiente (→)">&#8250;</button>
    </div>

    <div class="gv-counter" id="galCounter"></div>

    <div class="gv-thumbs" id="galThumbs"></div>
  </div>

  <script>
  /* ══ ProductGallery Viewer ══════════════════════════════════
     Carga imágenes vía JSON handler y muestra:
     - Imagen principal grande (con transición)
     - Strip de miniaturas clicables
     - Botones ← →, teclado y swipe táctil
  ═══════════════════════════════════════════════════════════ */
  var GV = (function(){
    var imgs    = [];   // [{id,url,nombre,principal,orden}]
    var cur     = 0;
    var viewer  = null, mainImg = null, thumbsDiv = null,
        counter = null, title = null, prevBtn = null, nextBtn = null;
    var touchX  = null;

    function init(){
      viewer   = document.getElementById('galViewer');
      mainImg  = document.getElementById('galMainImg');
      thumbsDiv= document.getElementById('galThumbs');
      counter  = document.getElementById('galCounter');
      title    = document.getElementById('galTitle');
      prevBtn  = document.getElementById('galPrev');
      nextBtn  = document.getElementById('galNext');
      // Teclado
      document.addEventListener('keydown', onKey);
      // Touch/swipe
      viewer.addEventListener('touchstart', function(e){ touchX = e.touches[0].clientX; }, {passive:true});
      viewer.addEventListener('touchend',   function(e){
        if(touchX===null) return;
        var dx = e.changedTouches[0].clientX - touchX;
        touchX = null;
        if(Math.abs(dx)>50){ dx < 0 ? next() : prev(); }
      });
    }

    /* Abrir galería para un producto */
    function open(proId, proName){
      fetch('/Handlers/ProductImageHandler.ashx?pro_id=' + proId)
        .then(function(r){ return r.json(); })
        .then(function(data){
          imgs = data;
          if(!imgs || imgs.length === 0){
            alert('Este producto aún no tiene imágenes guardadas.');
            return;
          }
          // Empezar por la principal si existe
          cur = 0;
          for(var i=0;i<imgs.length;i++){
            if(imgs[i].principal === 'S'){ cur = i; break; }
          }
          title.textContent = '📷  ' + (proName || 'Producto');
          renderThumbs();
          showImg(cur, false);
          viewer.classList.add('open');
          document.body.style.overflow = 'hidden';
        })
        .catch(function(){
          alert('No se pudieron cargar las imágenes.');
        });
    }

    function close(){
      viewer.classList.remove('open');
      document.body.style.overflow = '';
      mainImg.src = '';
    }

    function goTo(idx, anim){
      if(idx < 0 || idx >= imgs.length) return;
      cur = idx;
      showImg(cur, anim !== false);
    }

    function next(){ goTo(cur + 1); }
    function prev(){ goTo(cur - 1); }

    function showImg(idx, animate){
      if(animate){
        mainImg.classList.add('fade');
        setTimeout(function(){
          setImg(idx);
          mainImg.classList.remove('fade');
        }, 200);
      } else {
        setImg(idx);
      }
      // Actualizar thumbnails
      var ts = thumbsDiv.querySelectorAll('.gv-thumb');
      ts.forEach(function(t,i){ t.classList.toggle('active', i===idx); });
      // Scroll al thumb activo
      if(ts[idx]) ts[idx].scrollIntoView({behavior:'smooth',block:'nearest',inline:'center'});
      // Counter
      counter.innerHTML = '<strong>'+(idx+1)+'</strong> / '+imgs.length;
      // Botones nav
      prevBtn.disabled = idx === 0;
      nextBtn.disabled = idx === imgs.length - 1;
    }

    function setImg(idx){
      var img = imgs[idx];
      mainImg.src = img.url;
      mainImg.alt = img.nombre || '';
    }

    function renderThumbs(){
      thumbsDiv.innerHTML = '';
      imgs.forEach(function(img, i){
        var t  = document.createElement('img');
        t.src  = img.url;
        t.alt  = img.nombre || '';
        t.className = 'gv-thumb' + (i===cur ? ' active' : '');
        t.title = img.nombre || ('Imagen ' + (i+1));
        t.onerror = function(){ this.style.opacity='.15'; };
        t.addEventListener('click', function(){ goTo(i); });
        thumbsDiv.appendChild(t);
      });
    }

    function onKey(e){
      if(!viewer.classList.contains('open')) return;
      if(e.key==='ArrowRight' || e.key==='ArrowDown') next();
      else if(e.key==='ArrowLeft' || e.key==='ArrowUp') prev();
      else if(e.key==='Escape') close();
    }

    // Cerrar al hacer clic en el fondo
    document.addEventListener('click', function(e){
      if(e.target === viewer) close();
    });

    // Init cuando el DOM esté listo
    if(document.readyState === 'loading')
      document.addEventListener('DOMContentLoaded', init);
    else
      init();

    return { open:open, close:close, next:next, prev:prev, goTo:goTo };
  })();
  </script>

</asp:Content>
