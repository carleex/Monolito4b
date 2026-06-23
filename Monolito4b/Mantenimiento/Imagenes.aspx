<%@ Page Title="Imágenes" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Imagenes.aspx.cs" Inherits="Monolito4b.Mantenimiento.Imagenes" %>

<asp:Content ID="hc" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ═══ Variables / reset ═══════════════════════════════════════ */
:root{
  --clr-bg:      #0d0d1a;
  --clr-card:    #141427;
  --clr-card2:   #1a1a2e;
  --clr-border:  rgba(255,255,255,.07);
  --clr-pink:    #ff6b9d;
  --clr-green:   #42d47e;
  --clr-text:    #ccd0e0;
  --clr-muted:   #8b8fa8;
  --radius:      10px;
}

/* ═══ Layout ══════════════════════════════════════════════════ */
.pg-title{font-size:1.5rem;font-weight:700;color:#fff;margin-bottom:6px;}
.pg-sub  {font-size:.85rem;color:var(--clr-muted);margin-bottom:22px;}

.card{
  background:var(--clr-card);
  border:1px solid var(--clr-border);
  border-radius:var(--radius);
  padding:24px;
  margin-bottom:22px;}

.sec-title{
  font-size:.82rem;font-weight:700;letter-spacing:.06em;
  color:var(--clr-muted);text-transform:uppercase;margin-bottom:16px;}

/* ═══ Formulario de campos ════════════════════════════════════ */
.f-row{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:14px;margin-bottom:18px;}
.f-field label{display:block;font-size:.76rem;color:var(--clr-muted);margin-bottom:5px;}
.f-field select,
.f-field input[type="number"]{
  width:100%;padding:10px 12px;
  background:var(--clr-card2);
  border:1px solid var(--clr-border);
  border-radius:7px;color:var(--clr-text);font-size:.84rem;
  outline:none;transition:border-color .2s;}
.f-field select:focus,
.f-field input[type="number"]:focus{border-color:var(--clr-pink);}

/* ═══ Dropzone ════════════════════════════════════════════════ */
.dropzone{
  position:relative;
  border:2px dashed rgba(255,107,157,.35);
  border-radius:12px;padding:38px 24px;
  text-align:center;cursor:pointer;
  transition:all .2s;
  background:rgba(255,107,157,.03);}
.dropzone:hover,.dropzone.active{
  border-color:var(--clr-pink);
  background:rgba(255,107,157,.07);}
.dropzone input[type=file]{
  position:absolute;inset:0;opacity:0;cursor:pointer;width:100%;height:100%;}
.dz-icon{font-size:2.8rem;display:block;margin-bottom:10px;line-height:1;}
.dz-title{color:var(--clr-text);font-weight:600;font-size:.95rem;margin-bottom:4px;}
.dz-hint{color:var(--clr-muted);font-size:.78rem;}

/* ═══ Preview gallery ═════════════════════════════════════════ */
#previewSection{display:none;margin-top:22px;}
.preview-header{
  display:flex;align-items:center;justify-content:space-between;
  margin-bottom:14px;flex-wrap:wrap;gap:10px;}
.preview-counter{
  font-size:.83rem;color:var(--clr-muted);}
.preview-counter strong{color:var(--clr-pink);font-size:1rem;}
.btn-clear-all{
  font-size:.75rem;padding:5px 12px;border-radius:20px;
  background:transparent;border:1px solid #555;
  color:var(--clr-muted);cursor:pointer;transition:all .18s;}
.btn-clear-all:hover{border-color:#e05050;color:#e05050;}

#previewGrid{
  display:grid;
  grid-template-columns:repeat(auto-fill,minmax(150px,1fr));
  gap:14px;}

.prev-card{
  position:relative;
  background:var(--clr-card2);
  border-radius:10px;overflow:hidden;
  border:2px solid transparent;
  transition:border-color .2s,transform .2s,box-shadow .2s;
  animation:cardIn .25s ease;}
.prev-card:hover{
  border-color:var(--clr-pink);
  transform:translateY(-3px);
  box-shadow:0 6px 20px rgba(0,0,0,.4);}

@keyframes cardIn{
  from{opacity:0;transform:scale(.88) translateY(8px)}
  to  {opacity:1;transform:scale(1)  translateY(0)}}

.prev-card-img{
  position:relative;overflow:hidden;}
.prev-card-img img{
  width:100%;height:140px;
  object-fit:cover;display:block;
  transition:transform .3s;}
.prev-card:hover .prev-card-img img{transform:scale(1.06);}

/* Tamaño responsive: en móvil más pequeñas */
@media(max-width:480px){
  #previewGrid{grid-template-columns:repeat(auto-fill,minmax(110px,1fr));}
  .prev-card-img img{height:100px;}
}

/* Botón ❌ */
.btn-remove-img{
  position:absolute;top:6px;right:6px;
  width:26px;height:26px;
  background:rgba(20,20,40,.85);
  border:1px solid rgba(224,80,80,.6);
  border-radius:50%;
  color:#e05050;font-size:15px;line-height:1;
  cursor:pointer;display:flex;
  align-items:center;justify-content:center;
  transition:all .18s;backdrop-filter:blur(4px);}
.btn-remove-img:hover{
  background:#e05050;color:#fff;border-color:#e05050;
  transform:scale(1.15);}

.prev-card-info{padding:8px 10px 10px;}
.prev-card-name{
  font-size:.72rem;color:var(--clr-muted);
  white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.prev-card-size{font-size:.66rem;color:#555;margin-top:2px;}

/* ═══ Barra de acciones ════════════════════════════════════════ */
.action-bar{
  display:flex;align-items:center;gap:12px;flex-wrap:wrap;
  margin-top:18px;padding:14px 18px;
  background:rgba(255,107,157,.04);
  border:1px solid rgba(255,107,157,.12);
  border-radius:10px;}
.action-bar .badge{
  padding:4px 14px;border-radius:20px;
  background:rgba(255,107,157,.15);
  color:var(--clr-pink);font-size:.8rem;font-weight:600;}

/* ═══ Mensajes ════════════════════════════════════════════════ */
.msg-ok {color:var(--clr-green);font-size:.84rem;margin-top:10px;display:block;}
.msg-err{color:#e05050;font-size:.84rem;margin-top:10px;display:block;}

/* ═══ Galería inferior ════════════════════════════════════════ */
.gal-toolbar{
  display:flex;gap:12px;align-items:flex-end;
  flex-wrap:wrap;margin-bottom:18px;}
.gal-toolbar label{
  font-size:.76rem;color:var(--clr-muted);display:block;margin-bottom:4px;}
.gal-toolbar input{
  padding:9px 12px;background:var(--clr-card2);
  border:1px solid var(--clr-border);border-radius:7px;
  color:var(--clr-text);font-size:.84rem;min-width:220px;outline:none;}
.gal-toolbar input:focus{border-color:var(--clr-pink);}

.gal-grid{
  display:grid;
  grid-template-columns:repeat(auto-fill,minmax(175px,1fr));
  gap:16px;}
@media(max-width:540px){
  .gal-grid{grid-template-columns:repeat(auto-fill,minmax(130px,1fr));}
}

.gal-card{
  background:var(--clr-card2);border-radius:var(--radius);
  overflow:hidden;border:1px solid var(--clr-border);
  transition:transform .18s,box-shadow .18s;position:relative;}
.gal-card:hover{transform:translateY(-3px);box-shadow:0 8px 24px rgba(0,0,0,.45);}

.gal-thumb{
  position:relative;overflow:hidden;border-radius:var(--radius) var(--radius) 0 0;}
.gal-thumb img{
  width:100%;height:145px;object-fit:cover;display:block;
  transition:transform .3s;}
.gal-card:hover .gal-thumb img{transform:scale(1.06);}
.gal-ppal-badge{
  position:absolute;top:7px;left:7px;
  background:rgba(255,107,157,.9);color:#fff;
  font-size:.6rem;font-weight:700;padding:2px 7px;
  border-radius:8px;letter-spacing:.4px;text-transform:uppercase;}

.gal-body{padding:10px 12px;}
.gal-prod{font-size:.8rem;color:var(--clr-text);font-weight:600;
  white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.gal-meta{font-size:.7rem;color:#555;margin-top:2px;}

.gal-actions{display:flex;gap:6px;padding:0 12px 12px;}
.btn-gal{
  flex:1;padding:5px 0;border-radius:6px;
  font-size:.72rem;cursor:pointer;
  border:1px solid;background:transparent;transition:all .18s;text-align:center;}
.btn-ppal{border-color:var(--clr-green);color:var(--clr-green);}
.btn-ppal:hover{background:var(--clr-green);color:#000;}
.btn-del{border-color:#e05050;color:#e05050;}
.btn-del:hover{background:#e05050;color:#fff;}

/* ═══ Lightbox :target ════════════════════════════════════════ */
.lb-overlay{
  display:none;position:fixed;inset:0;
  background:rgba(0,0,0,.94);z-index:9999;
  align-items:center;justify-content:center;
  flex-direction:column;gap:12px;padding:16px;}
.lb-overlay:target{display:flex;}
.lb-close{
  position:absolute;top:14px;right:18px;
  color:#fff;font-size:2.4rem;
  text-decoration:none;line-height:1;opacity:.7;}
.lb-close:hover{opacity:1;}
.lb-img{
  max-width:92vw;max-height:78vh;
  object-fit:contain;border-radius:8px;
  box-shadow:0 8px 40px rgba(0,0,0,.7);}
.lb-caption{color:#aaa;font-size:.82rem;}
.lb-open{
  display:block;position:absolute;
  inset:0;opacity:0;cursor:zoom-in;}

/* ═══ Empty state ═════════════════════════════════════════════ */
.empty-st{text-align:center;padding:52px 20px;}
.empty-st .icon{font-size:3.2rem;margin-bottom:12px;opacity:.4;}
.empty-st p{color:#555;font-size:.88rem;}
</style>
</asp:Content>

<asp:Content ID="mc" ContentPlaceHolderID="MainContent" runat="server">

<div class="pg-title">Imágenes de Productos</div>
<div class="pg-sub">Sube imágenes ilimitadas para cada producto y gestiona tu galería.</div>

<!-- ══════════════════════════════════════════════════════════════
     FORMULARIO DE CARGA — un solo paso
══════════════════════════════════════════════════════════════════ -->
<div class="card">
  <div class="sec-title">Cargar imágenes a un producto</div>

  <!-- Campos del formulario -->
  <div class="f-row">
    <div class="f-field">
      <label>Producto *</label>
      <asp:DropDownList ID="ddlProducto" runat="server" AppendDataBoundItems="true">
        <asp:ListItem Value="" Text="— Seleccione producto —" />
      </asp:DropDownList>
    </div>
    <div class="f-field">
      <label>Número de orden inicial</label>
      <asp:TextBox ID="txtOrden" runat="server" Text="0" TextMode="Number" />
    </div>
    <div class="f-field">
      <label>Primera imagen como principal</label>
      <asp:DropDownList ID="ddlPrincipal" runat="server">
        <asp:ListItem Value="N" Text="No — mantener principal actual" />
        <asp:ListItem Value="S" Text="Sí — marcar la primera como principal" />
      </asp:DropDownList>
    </div>
  </div>

  <!-- Dropzone — el input file real está embebido para permitir el drag & drop -->
  <div class="dropzone" id="dropzone">
    <input type="file" id="filePicker" name="filePicker" multiple
           accept="image/jpeg,image/png,image/gif,image/webp,image/bmp"
           onchange="IMG.add(this.files); this.value='';" />
    <span class="dz-icon">📁</span>
    <div class="dz-title">Haz clic o arrastra aquí tus imágenes</div>
    <div class="dz-hint">Puedes seleccionar <strong>cuantas quieras</strong> — JPG, PNG, GIF, WEBP</div>
  </div>
  <div id="dzError" style="display:none;color:#e05050;font-size:.82rem;margin-top:8px;padding:6px 10px;
       background:rgba(224,80,80,.08);border-radius:6px;border:1px solid rgba(224,80,80,.25);"></div>

  <!-- Preview gallery (JS la llena) -->
  <div id="previewSection">
    <div class="preview-header">
      <div class="preview-counter">
        <strong id="imgCount">0</strong> imagen(es) seleccionada(s)
      </div>
      <button type="button" class="btn-clear-all" onclick="IMG.clearAll()">
        Quitar todas
      </button>
    </div>
    <div id="previewGrid"></div>

    <!-- Barra de acción -->
    <div class="action-bar">
      <span class="badge" id="actionBadge">0 imágenes listas</span>
      <asp:Button ID="btnGuardar" runat="server" Text="💾 Guardar imágenes"
        CssClass="btn-primary" OnClick="btnGuardar_Click"
        OnClientClick="return IMG.preparar();" CausesValidation="false" />
    </div>
  </div>

  <asp:Label ID="lblMsg" runat="server" />
</div>

<!-- ══════════════════════════════════════════════════════════════
     GALERÍA — imágenes ya guardadas
══════════════════════════════════════════════════════════════════ -->
<div class="card">
  <div class="sec-title">Galería guardada</div>

  <div class="gal-toolbar">
    <div>
      <label>Buscar por producto</label>
      <asp:UpdatePanel ID="upFiltro" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
          <asp:TextBox ID="txtFiltro" runat="server"
            placeholder="Escribe el nombre del producto..."
            AutoPostBack="true" OnTextChanged="Filtro_Changed" />
        </ContentTemplate>
      </asp:UpdatePanel>
    </div>
    <div style="padding-bottom:1px;">
      <a href="/Handlers/ExcelExport.ashx?tabla=imagenes"
         style="display:inline-block;padding:9px 18px;border-radius:7px;
                background:rgba(66,212,126,.1);border:1px solid var(--clr-green);
                color:var(--clr-green);font-size:.8rem;text-decoration:none;">
        ⬇ Exportar Excel
      </a>
    </div>
  </div>

  <asp:UpdatePanel ID="upGaleria" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
      <asp:Repeater ID="rptImagenes" runat="server"
        OnItemCommand="rptImagenes_ItemCommand">
        <HeaderTemplate><div class="gal-grid"></HeaderTemplate>
        <ItemTemplate>
          <div class="gal-card">
            <div class="gal-thumb">
              <%# BuildThumbLink(Container.ItemIndex, Eval("img_path") as string) %>
              <%# (Eval("img_principal") as string)?.Trim()=="S"
                    ? "<span class='gal-ppal-badge'>Principal</span>" : "" %>
            </div>
            <div class="gal-body">
              <div class="gal-prod"><%# Eval("pro_nombre") %></div>
              <div class="gal-meta">
                Orden <%# Eval("img_orden") %> &nbsp;·&nbsp;
                <%# Eval("img_fecha","{0:dd/MM/yy}") %>
              </div>
            </div>
            <div class="gal-actions">
              <asp:LinkButton runat="server" CommandName="Ppal"
                CommandArgument='<%# Eval("img_id") + "|" + Eval("pro_id") %>'
                CssClass="btn-gal btn-ppal" Text="⭐ Principal" />
              <asp:LinkButton runat="server" CommandName="Del"
                CommandArgument='<%# Eval("img_id") %>'
                CssClass="btn-gal btn-del" Text="❌ Eliminar"
                OnClientClick="return confirm('¿Eliminar imagen?');" />
            </div>
          </div>
          <%# BuildLightbox(Container.ItemIndex,
                            Eval("img_path") as string,
                            Eval("pro_nombre") as string) %>
        </ItemTemplate>
        <FooterTemplate></div></FooterTemplate>
      </asp:Repeater>
      <asp:Literal ID="litVacio" runat="server" />
    </ContentTemplate>
    <Triggers>
      <asp:AsyncPostBackTrigger ControlID="txtFiltro" EventName="TextChanged" />
    </Triggers>
  </asp:UpdatePanel>
</div>

<!-- ══════════════════════════════════════════════════════════════
     JAVASCRIPT — gestión de archivos en cliente
══════════════════════════════════════════════════════════════════ -->
<script>
const IMG = (function(){
  let files = [];  // Array<File> — lista manejada por JS

  // Formatos permitidos
  const ALLOWED_TYPES = ['image/jpeg','image/png','image/gif','image/webp','image/bmp'];
  const ALLOWED_EXTS  = ['.jpg','.jpeg','.png','.gif','.webp','.bmp'];

  function extOf(name){
    var dot = name.lastIndexOf('.');
    return dot < 0 ? '' : name.substring(dot).toLowerCase();
  }
  function tipoOk(f){
    return ALLOWED_TYPES.indexOf(f.type) >= 0 || ALLOWED_EXTS.indexOf(extOf(f.name)) >= 0;
  }

  /* ─── Mostrar/ocultar mensaje de error en dropzone ───────────── */
  function setDzError(msg){
    var el = document.getElementById('dzError');
    if(!el) return;
    el.textContent = msg;
    el.style.display = msg ? 'block' : 'none';
  }

  /* ─── Agregar nuevos archivos (acumulados) ────────────────────── */
  function add(fileList){
    var rechazados = [];
    Array.from(fileList).forEach(function(f){
      if(!tipoOk(f)){
        rechazados.push(f.name);
        return;
      }
      // Evitar duplicados exactos (nombre + tamaño)
      if(!files.some(function(x){ return x.name===f.name && x.size===f.size; })){
        files.push(f);
      }
    });
    if(rechazados.length > 0){
      setDzError('Formato no permitido: ' + rechazados.join(', ') +
                 '  —  Solo se aceptan JPG, PNG, GIF, WEBP, BMP.');
    } else {
      setDzError('');
    }
    render();
  }

  /* ─── Quitar un archivo por índice ───────────────────────────── */
  function remove(idx){
    var cards = document.querySelectorAll('.prev-card');
    if(cards[idx]){
      cards[idx].style.transition = 'all .2s';
      cards[idx].style.opacity    = '0';
      cards[idx].style.transform  = 'scale(.8)';
    }
    setTimeout(function(){
      files.splice(idx, 1);
      render();
    }, 200);
  }

  /* ─── Quitar todos ────────────────────────────────────────────── */
  function clearAll(){
    files = [];
    setDzError('');
    render();
  }

  /* ─── Renderizar preview grid ─────────────────────────────────── */
  function render(){
    var section = document.getElementById('previewSection');
    var grid    = document.getElementById('previewGrid');
    var counter = document.getElementById('imgCount');
    var badge   = document.getElementById('actionBadge');

    section.style.display = files.length > 0 ? 'block' : 'none';
    counter.textContent   = files.length;
    badge.textContent     = files.length + (files.length===1 ? ' imagen lista' : ' imágenes listas');

    grid.innerHTML = '';

    files.forEach(function(f, i){
      var card = document.createElement('div');
      card.className = 'prev-card';

      var url  = URL.createObjectURL(f);
      var kb   = f.size < 1024*1024
                   ? Math.round(f.size/1024) + ' KB'
                   : (f.size/1024/1024).toFixed(1) + ' MB';

      card.innerHTML =
        '<div class="prev-card-img">' +
          '<img src="'+url+'" alt="" loading="lazy" '+
               'onload="URL.revokeObjectURL(this.src)" '+
               'onerror="this.src=\'\';this.style.opacity=\'.2\'" />' +
          '<button type="button" class="btn-remove-img" '+
                  'onclick="IMG.remove('+i+')" title="Quitar imagen">&#10005;</button>' +
        '</div>' +
        '<div class="prev-card-info">' +
          '<div class="prev-card-name" title="'+escHtml(f.name)+'">'+escHtml(f.name)+'</div>'+
          '<div class="prev-card-size">'+kb+'</div>'+
        '</div>';

      grid.appendChild(card);
    });
  }

  /* ─── Preparar para submit: inyectar FileList en el input ──────── */
  function preparar(){
    if(files.length === 0){
      alert('Selecciona al menos una imagen antes de guardar.');
      return false;
    }
    try{
      var dt = new DataTransfer();
      files.forEach(function(f){ dt.items.add(f); });
      document.getElementById('filePicker').files = dt.files;
    }catch(e){
      // Fallback: navegadores sin DataTransfer
    }
    return true;
  }

  function escHtml(s){
    return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
  }

  /* ─── Drag & drop en el dropzone ─────────────────────────────── */
  (function initDrop(){
    var dz = document.getElementById('dropzone');
    if(!dz) return;
    dz.addEventListener('dragover', function(e){
      e.preventDefault();
      dz.classList.add('active');
    });
    dz.addEventListener('dragleave', function(){ dz.classList.remove('active'); });
    dz.addEventListener('drop', function(e){
      e.preventDefault();
      dz.classList.remove('active');
      if(e.dataTransfer && e.dataTransfer.files) add(e.dataTransfer.files);
    });
  })();

  return { add:add, remove:remove, clearAll:clearAll, preparar:preparar };
})();
</script>
</asp:Content>
