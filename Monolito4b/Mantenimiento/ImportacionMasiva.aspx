<%@ Page Title="Importación Masiva" Language="C#" MasterPageFile="~/Mantenimiento/Principal.Master"
    AutoEventWireup="true" CodeBehind="ImportacionMasiva.aspx.cs" Inherits="Monolito4b.Mantenimiento.ImportacionMasiva" %>

<asp:Content ID="headContent" ContentPlaceHolderID="head" runat="server">
<style>
/* ─── Upload zone ──────────────────────────────────────────── */
.upload-zone{
  border:2px dashed rgba(255,107,157,.35);border-radius:12px;
  padding:32px 24px;text-align:center;background:#141427;
  margin-bottom:20px;transition:border-color .2s,background .2s;cursor:pointer;}
.upload-zone:hover{border-color:#ff6b9d;background:rgba(255,107,157,.04);}
.upload-zone .dz-icon{font-size:2.4rem;display:block;margin-bottom:8px;line-height:1;}
.upload-zone .dz-title{color:#ccd0e0;font-weight:600;font-size:.95rem;margin-bottom:4px;}
.upload-zone .dz-hint{color:#8b8fa8;font-size:.78rem;}
.upload-zone input[type=file]{margin:10px auto 0;display:block;color:#8b8fa8;font-size:.8rem;}

/* ─── Botones ──────────────────────────────────────────────── */
.btn-bar{display:flex;gap:10px;align-items:center;flex-wrap:wrap;margin-bottom:6px;}
.btn-confirm{
  background:linear-gradient(135deg,#42d47e,#2ebd68);
  border:none;color:#0d0d1a;padding:9px 22px;border-radius:7px;
  font-size:.85rem;font-weight:700;cursor:pointer;letter-spacing:.02em;
  transition:opacity .18s,transform .12s;box-shadow:0 3px 12px rgba(66,212,126,.25);}
.btn-confirm:hover{opacity:.88;transform:translateY(-1px);}
.btn-confirm:disabled{opacity:.35;cursor:not-allowed;transform:none;box-shadow:none;}

/* ─── Panel preview ────────────────────────────────────────── */
.preview-wrap{
  background:#141427;border:1px solid rgba(255,255,255,.07);
  border-radius:12px;padding:20px 22px;margin-top:22px;}
.preview-hdr{
  display:flex;justify-content:space-between;align-items:center;
  flex-wrap:wrap;gap:10px;margin-bottom:16px;}
.preview-hdr h3{font-size:.95rem;color:#fff;font-weight:700;margin:0;}
.badge-count{
  display:inline-flex;align-items:center;gap:6px;
  background:rgba(255,107,157,.1);border:1px solid rgba(255,107,157,.3);
  color:#ff6b9d;font-size:.78rem;font-weight:600;
  padding:4px 14px;border-radius:20px;}
.badge-count strong{font-size:.92rem;}

/* ─── Tabla mejorada ───────────────────────────────────────── */
.tbl-preview{
  width:100%;border-collapse:collapse;
  font-size:.82rem;color:#ccd0e0;}
.tbl-preview thead tr{
  background:linear-gradient(90deg,#1e1e3a,#252548);}
.tbl-preview thead th{
  padding:11px 14px;text-align:left;font-weight:700;
  color:#8b8fa8;font-size:.73rem;letter-spacing:.06em;text-transform:uppercase;
  border-bottom:2px solid rgba(255,107,157,.2);white-space:nowrap;}
/* columna # */
.tbl-preview thead th.col-num,
.tbl-preview tbody td.col-num{
  text-align:center;width:52px;color:#ff6b9d;}

.tbl-preview tbody tr{border-bottom:1px solid rgba(255,255,255,.04);transition:background .15s;}
.tbl-preview tbody tr:hover{background:rgba(255,107,157,.05);}
.tbl-preview tbody tr:last-child{border-bottom:none;}
.tbl-preview tbody td{padding:9px 14px;vertical-align:middle;}

/* número de fila */
.row-num{
  display:inline-block;width:28px;height:28px;line-height:28px;
  text-align:center;border-radius:50%;font-size:.72rem;font-weight:700;
  background:rgba(255,107,157,.12);color:#ff6b9d;border:1px solid rgba(255,107,157,.2);}
/* badge estado */
.est-a{background:rgba(0,200,100,.12);color:#00c864;padding:2px 9px;border-radius:10px;font-size:.71rem;font-weight:600;}
.est-i{background:rgba(255,255,255,.07);color:#aaa;padding:2px 9px;border-radius:10px;font-size:.71rem;font-weight:600;}
/* path truncado */
.path-cell{max-width:140px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;color:#555;font-size:.72rem;}
.path-cell:hover{color:#8b8fa8;}

/* ─── Pager ────────────────────────────────────────────────── */
.pager-row td{padding:12px 0 2px;text-align:center;}
.pager a,.pager span{
  color:#8b8fa8;padding:5px 11px;
  border:1px solid rgba(255,255,255,.08);
  border-radius:5px;font-size:.78rem;margin:0 2px;text-decoration:none;
  display:inline-block;transition:all .15s;}
.pager a:hover{background:rgba(255,107,157,.1);border-color:#ff6b9d;color:#ff6b9d;}
.pager span{background:rgba(255,107,157,.18);color:#ff6b9d;border-color:#ff6b9d;font-weight:700;}

/* ─── Resultado ────────────────────────────────────────────── */
.result-box{
  background:#141427;border:1px solid rgba(255,255,255,.07);
  border-radius:10px;padding:18px 22px;margin-top:18px;font-size:.85rem;}
</style>
</asp:Content>

<asp:Content ID="bodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

  <div class="page-title">Importación Masiva de Productos</div>

  <!-- ═ Upload ════════════════════════════════════════════════════ -->
  <div class="upload-zone">
    <span class="dz-icon">📂</span>
    <div class="dz-title">Selecciona tu archivo CSV</div>
    <div class="dz-hint">Delimitado por punto y coma (;) — columnas: nombre; cantidad; precio; estado; prov_id; imagen; categoría</div>
    <asp:FileUpload ID="fuCSV" runat="server" />
  </div>

  <div class="btn-bar">
    <asp:Button ID="btnCargar" runat="server" Text="&#128270; Cargar Vista Previa"
        CssClass="btn-primary" OnClick="btnCargar_Click" />
    <asp:Button ID="btnConfirmar" runat="server" Text="&#10003; Confirmar Inserción"
        CssClass="btn-confirm" OnClick="btnConfirmar_Click"
        Enabled="false" OnClientClick="return confirm('¿Insertar todos los registros en la base de datos?');" />
    <asp:Label ID="lblMsg" runat="server" CssClass="msg-ok" />
  </div>

  <!-- ═ Vista Previa ══════════════════════════════════════════════ -->
  <asp:Panel ID="pnlPreview" runat="server" Visible="false">
    <div class="preview-wrap">
      <div class="preview-hdr">
        <h3>Vista Previa — ordenado del último al primero</h3>
        <span class="badge-count">
          <strong><asp:Literal ID="litCount" runat="server" /></strong> fila(s) detectadas
        </span>
      </div>

      <div style="overflow-x:auto;">
        <asp:GridView ID="gvPreview" runat="server"
            CssClass="tbl-preview"
            AutoGenerateColumns="false"
            EmptyDataText="Sin datos válidos."
            AllowPaging="true" PageSize="10"
            OnPageIndexChanging="gvPreview_PageIndexChanging"
            PagerStyle-CssClass="pager"
            GridLines="None"
            ShowHeaderWhenEmpty="true">
          <Columns>

            <%-- Columna # ─────────────────────────────────── --%>
            <asp:TemplateField HeaderText="#">
              <HeaderStyle CssClass="col-num" />
              <ItemStyle   CssClass="col-num" />
              <ItemTemplate>
                <span class="row-num">
                  <%# gvPreview.PageIndex * gvPreview.PageSize + Container.DataItemIndex + 1 %>
                </span>
              </ItemTemplate>
            </asp:TemplateField>

            <%-- Nombre --%>
            <asp:BoundField DataField="pro_nombre"   HeaderText="Nombre"    />

            <%-- Cantidad --%>
            <asp:BoundField DataField="pro_cantidad" HeaderText="Cant."
              ItemStyle-HorizontalAlign="Center" />

            <%-- Precio --%>
            <asp:BoundField DataField="pro_precio"   HeaderText="Precio"
              DataFormatString="{0:C2}"
              ItemStyle-HorizontalAlign="Right" />

            <%-- Estado con badge --%>
            <asp:TemplateField HeaderText="Estado">
              <ItemStyle HorizontalAlign="Center" />
              <ItemTemplate>
                <span class='<%# ((Eval("pro_estado") as string)??"A").Trim().ToUpper()=="A"?"est-a":"est-i" %>'>
                  <%# ((Eval("pro_estado") as string)??"A").Trim().ToUpper()=="A"?"Activo":"Inactivo" %>
                </span>
              </ItemTemplate>
            </asp:TemplateField>

            <%-- Proveedor ID --%>
            <asp:BoundField DataField="prov_id"      HeaderText="Prov."
              ItemStyle-HorizontalAlign="Center"
              NullDisplayText="—" />

            <%-- Imagen path (truncado) --%>
            <asp:TemplateField HeaderText="Imagen">
              <ItemTemplate>
                <span class="path-cell" title='<%# Eval("pro_imagen_path") %>'>
                  <%# string.IsNullOrWhiteSpace(Eval("pro_imagen_path") as string) ? "—" : Eval("pro_imagen_path") %>
                </span>
              </ItemTemplate>
            </asp:TemplateField>

            <%-- Categoría --%>
            <asp:BoundField DataField="pro_categoria" HeaderText="Categoría"
              NullDisplayText="—" />

          </Columns>
        </asp:GridView>
      </div>
    </div>
  </asp:Panel>

  <!-- ═ Resultado ════════════════════════════════════════════════ -->
  <asp:Panel ID="pnlResultado" runat="server" Visible="false">
    <div class="result-box">
      <asp:Literal ID="litResultado" runat="server" />
    </div>
  </asp:Panel>

</asp:Content>
