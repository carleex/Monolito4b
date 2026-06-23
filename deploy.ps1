############################################################
#  DEPLOY.PS1  -  Monolito4b -> Azure App Service
#  .NET Framework 4.8 + Azure SQL
############################################################

$ErrorActionPreference = "Continue"

function Info  { param($m) Write-Host "  >> $m" -ForegroundColor Cyan }
function Ok    { param($m) Write-Host "  OK $m" -ForegroundColor Green }
function Warn  { param($m) Write-Host "  !! $m" -ForegroundColor Yellow }
function Fail  { param($m) Write-Host "[ERROR] $m" -ForegroundColor Red; Read-Host "Presiona Enter para salir"; exit 1 }

Write-Host ""
Write-Host "=================================================" -ForegroundColor Magenta
Write-Host "   DEPLOY  -  Monolito4b  =>  Azure             " -ForegroundColor Magenta
Write-Host "=================================================" -ForegroundColor Magenta
Write-Host ""

$Root     = "C:\Users\Pc\Documents\My Web Sites\Monolito4b"
$WebDir   = Join-Path $Root "Monolito4b"
$SolFile  = Join-Path $Root "Monolito4b.sln"
$PubDir   = Join-Path $Root "_pub"
$ZipFile  = Join-Path $Root "_pub.zip"
$InfoFile = Join-Path $Root "deploy_info.txt"

# ─────────────────────────────────────────────────────────────
# 0. PREREQS
# ─────────────────────────────────────────────────────────────
Info "Verificando Azure CLI..."
if (-not (Get-Command az -ErrorAction SilentlyContinue)) { Fail "Azure CLI no encontrado. Instala desde https://aka.ms/installazurecliwindows" }
Ok "Azure CLI listo."

$msbuild = "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
if (-not (Test-Path $msbuild)) { Fail "MSBuild no encontrado en $msbuild" }
Ok "MSBuild encontrado."

$aspnetc = "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\aspnet_compiler.exe"
if (-not (Test-Path $aspnetc)) { $aspnetc = "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\aspnet_compiler.exe" }
if (-not (Test-Path $aspnetc)) { Fail "aspnet_compiler no encontrado." }
Ok "aspnet_compiler encontrado."

# ─────────────────────────────────────────────────────────────
# 1. LOGIN
# ─────────────────────────────────────────────────────────────
Write-Host ""
Info "Comprobando sesion Azure..."
az account show 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Info "Iniciando sesion..."
    az login
    if ($LASTEXITCODE -ne 0) { Fail "No se pudo iniciar sesion." }
}
$sub = az account show --query "name" -o tsv
Ok "Suscripcion: $sub"

# ─────────────────────────────────────────────────────────────
# 2. CONFIGURACION - leer de archivo o pedir al usuario
# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "---- CONFIGURACION ----" -ForegroundColor DarkGray

# Si ya se desplegó antes, reusar el mismo nombre
$savedApp = ""
if (Test-Path $InfoFile) {
    $lines = Get-Content $InfoFile
    foreach ($line in $lines) {
        if ($line -match "^AppName=(.+)$") { $savedApp = $Matches[1] }
    }
}

if ($savedApp) {
    Write-Host "  Se encontro despliegue anterior: $savedApp" -ForegroundColor DarkCyan
    Write-Host "  Usar el mismo nombre? (s = si, n = nuevo):" -ForegroundColor White
    $useSaved = Read-Host " "
    if ($useSaved -ne "n") { $AppName = $savedApp }
}

if (-not $AppName) {
    $rnd = Get-Random -Minimum 1000 -Maximum 9999
    Write-Host "  Nombre de la aplicacion web (vacio = monolito4b-$rnd):" -ForegroundColor White
    $inp = Read-Host " "
    if ([string]::IsNullOrWhiteSpace($inp)) { $AppName = "monolito4b-$rnd" } else { $AppName = $inp }
}

Write-Host "  Region: eastus, westus, westeurope, brazilsouth" -ForegroundColor DarkGray
Write-Host "  Region de Azure (vacio = eastus):" -ForegroundColor White
$Location = Read-Host " "
if ([string]::IsNullOrWhiteSpace($Location)) { $Location = "eastus" }

Write-Host "  Usuario admin SQL (vacio = monolito_admin):" -ForegroundColor White
$SqlUser = Read-Host " "
if ([string]::IsNullOrWhiteSpace($SqlUser)) { $SqlUser = "monolito_admin" }

$SqlPass = ""
while ($SqlPass.Length -lt 12) {
    Write-Host "  Contrasena SQL (min 12 chars, Mayus+minus+numero+especial):" -ForegroundColor White
    $sp = Read-Host " " -AsSecureString
    $SqlPass = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($sp))
    if ($SqlPass.Length -lt 12) { Warn "Muy corta, intenta de nuevo." }
}

$RG     = "rg-$AppName"
$Plan   = "plan-$AppName"
$SqlSrv = "$AppName-sql"
$SqlDb  = "Monolito4am"

Write-Host ""
Write-Host "  App:    $AppName"  -ForegroundColor DarkCyan
Write-Host "  RG:     $RG"      -ForegroundColor DarkCyan
Write-Host "  SQL:    $SqlSrv"  -ForegroundColor DarkCyan
Write-Host "  Region: $Location" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "  Continuar? escribe s y Enter, n para cancelar:" -ForegroundColor White
$ok = Read-Host " "
if ($ok -ne "s") { Write-Host "Cancelado."; exit 0 }

# ─────────────────────────────────────────────────────────────
# 3. COMPILAR
# ─────────────────────────────────────────────────────────────
Write-Host ""
Info "Compilando solucion..."

if (Test-Path $PubDir)  { Remove-Item $PubDir  -Recurse -Force }
if (Test-Path $ZipFile) { Remove-Item $ZipFile -Force }
New-Item -ItemType Directory -Path $PubDir | Out-Null

# Compilar DLLs
& "$msbuild" "$SolFile" /p:Configuration=Release /t:Build /verbosity:minimal /nologo
if ($LASTEXITCODE -ne 0) { Fail "Error de compilacion." }
Ok "Compilacion exitosa."

# Limpiar obj para que aspnet_compiler no falle con XDT
$objDir = Join-Path $WebDir "obj"
if (Test-Path $objDir) { Remove-Item $objDir -Recurse -Force; Ok "Carpeta obj limpiada." }

# Precompilar
Info "Precompilando web app..."
& "$aspnetc" -v "/" -p "$WebDir" -f "$PubDir" -fixednames 2>&1
if ($LASTEXITCODE -ne 0) { Fail "Error en aspnet_compiler." }
Ok "Precompilacion exitosa."

# ZIP
Info "Creando paquete ZIP..."
Add-Type -AssemblyName System.IO.Compression.FileSystem
[IO.Compression.ZipFile]::CreateFromDirectory($PubDir, $ZipFile)
$mb = [math]::Round((Get-Item $ZipFile).Length/1MB, 1)
Ok "Paquete: $mb MB"

# ─────────────────────────────────────────────────────────────
# 4. CREAR RECURSOS AZURE (skip si ya existen)
# ─────────────────────────────────────────────────────────────
Write-Host ""

# Resource Group
Info "Verificando Resource Group..."
$rgExists = az group show --name $RG --query "name" -o tsv 2>&1
if ($LASTEXITCODE -ne 0) {
    Info "Creando Resource Group $RG..."
    az group create --name $RG --location $Location
    if ($LASTEXITCODE -ne 0) { Fail "No se pudo crear el Resource Group." }
}
Ok "Resource Group: $RG"

# App Service Plan
Info "Verificando App Service Plan..."
$planExists = az appservice plan show --name $Plan --resource-group $RG --query "name" -o tsv 2>&1
if ($LASTEXITCODE -ne 0) {
    Info "Creando App Service Plan (F1 Free)..."
    az appservice plan create --name $Plan --resource-group $RG --sku F1 --is-linux false
    if ($LASTEXITCODE -ne 0) { Fail "No se pudo crear el App Service Plan." }
}
Ok "Plan: $Plan"

# Web App
Info "Verificando Web App..."
$appExists = az webapp show --name $AppName --resource-group $RG --query "name" -o tsv 2>&1
if ($LASTEXITCODE -ne 0) {
    Info "Creando Web App $AppName..."
    az webapp create --name $AppName --resource-group $RG --plan $Plan
    if ($LASTEXITCODE -ne 0) { Fail "No se pudo crear la Web App. El nombre puede estar ocupado, intenta con otro nombre." }
    az webapp config set --name $AppName --resource-group $RG --net-framework-version "v4.8" --use-32bit-worker-process false
}
Ok "Web App: $AppName"

# SQL Server
Info "Verificando SQL Server..."
$sqlExists = az sql server show --name $SqlSrv --resource-group $RG --query "name" -o tsv 2>&1
if ($LASTEXITCODE -ne 0) {
    Info "Creando SQL Server (puede tardar 2-3 min)..."
    az sql server create --name $SqlSrv --resource-group $RG --location $Location --admin-user $SqlUser --admin-password $SqlPass
    if ($LASTEXITCODE -ne 0) { Fail "No se pudo crear el SQL Server." }
}
Ok "SQL Server: $SqlSrv"

# Firewall
Info "Configurando firewall SQL..."
az sql server firewall-rule create --resource-group $RG --server $SqlSrv --name AllowAzure --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0 2>&1 | Out-Null
$myip = (Invoke-RestMethod "https://api.ipify.org" -ErrorAction SilentlyContinue)
if ($myip) {
    az sql server firewall-rule create --resource-group $RG --server $SqlSrv --name MyIP --start-ip-address $myip --end-ip-address $myip 2>&1 | Out-Null
}
Ok "Firewall OK."

# Base de datos
Info "Verificando base de datos..."
$dbExists = az sql db show --resource-group $RG --server $SqlSrv --name $SqlDb --query "name" -o tsv 2>&1
if ($LASTEXITCODE -ne 0) {
    Info "Creando base de datos $SqlDb..."
    az sql db create --resource-group $RG --server $SqlSrv --name $SqlDb --edition Basic --capacity 5
    if ($LASTEXITCODE -ne 0) { Fail "No se pudo crear la base de datos." }
}
Ok "DB: $SqlDb"

# ─────────────────────────────────────────────────────────────
# 5. ESQUEMA SQL (con reintentos por si el server aun no esta listo)
# ─────────────────────────────────────────────────────────────
Write-Host ""
Info "Ejecutando esquema SQL..."

$sqlcmdObj = Get-Command sqlcmd -ErrorAction SilentlyContinue
$sqlcmd = if ($sqlcmdObj) { $sqlcmdObj.Source } else { $null }
if (-not $sqlcmd) {
    $sqlcmd = Get-ChildItem "C:\Program Files\Microsoft SQL Server\*\Tools\Binn\sqlcmd.exe" -ErrorAction SilentlyContinue |
              Sort-Object | Select-Object -Last 1 -ExpandProperty FullName
}

if ($sqlcmd) {
    $schema = @'
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='tbl_tipo_usuario')
    CREATE TABLE tbl_tipo_usuario (tusu_id INT IDENTITY(1,1) PRIMARY KEY, tusu_nombre VARCHAR(50));
GO
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='tbl_usuario')
    CREATE TABLE tbl_usuario (
        usu_id INT IDENTITY(1,1) PRIMARY KEY,
        usu_cedula VARCHAR(10), usu_nombres VARCHAR(50), usu_apellidos VARCHAR(50),
        usu_direccion VARCHAR(50), usu_celular VARCHAR(10), usu_correo VARCHAR(150),
        usu_nick VARCHAR(50), usu_contrasena VARBINARY(MAX), usu_estado CHAR(1),
        tusu_id INT REFERENCES tbl_tipo_usuario(tusu_id),
        usu_intentos_fallidos INT DEFAULT 0);
GO
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='tbl_proveedor')
    CREATE TABLE tbl_proveedor (prov_id INT IDENTITY(1,1) PRIMARY KEY, prov_nombre VARCHAR(50), prov_estado CHAR(1));
GO
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='tbl_producto')
    CREATE TABLE tbl_producto (
        pro_id INT IDENTITY(1,1) PRIMARY KEY, pro_nombre VARCHAR(50),
        pro_cantidad INT, pro_precio DECIMAL(18,2), pro_estado CHAR(1),
        prov_id INT REFERENCES tbl_proveedor(prov_id),
        pro_imagen_path VARCHAR(255), pro_categoria VARCHAR(50));
GO
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='tbl_foto_usuario')
    CREATE TABLE tbl_foto_usuario (
        foto_id INT IDENTITY(1,1) PRIMARY KEY, usu_id INT REFERENCES tbl_usuario(usu_id),
        foto_imagen VARBINARY(MAX), foto_nombre VARCHAR(100), foto_tipo VARCHAR(50),
        foto_fecha DATETIME DEFAULT GETDATE(), foto_principal CHAR(1) DEFAULT 'N');
GO
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name='tbl_recuperacion')
    CREATE TABLE tbl_recuperacion (
        rec_id INT IDENTITY(1,1) PRIMARY KEY, usu_id INT REFERENCES tbl_usuario(usu_id),
        rec_token VARCHAR(20), rec_expira DATETIME, rec_usado CHAR(1) DEFAULT 'N');
GO
IF NOT EXISTS (SELECT 1 FROM tbl_tipo_usuario WHERE tusu_id=1) BEGIN
    SET IDENTITY_INSERT tbl_tipo_usuario ON;
    INSERT INTO tbl_tipo_usuario(tusu_id,tusu_nombre) VALUES(1,'Administrador');
    SET IDENTITY_INSERT tbl_tipo_usuario OFF;
END
GO
IF NOT EXISTS (SELECT 1 FROM tbl_tipo_usuario WHERE tusu_id=2) BEGIN
    SET IDENTITY_INSERT tbl_tipo_usuario ON;
    INSERT INTO tbl_tipo_usuario(tusu_id,tusu_nombre) VALUES(2,'Usuario');
    SET IDENTITY_INSERT tbl_tipo_usuario OFF;
END
GO
'@
    $tmpSql = "$env:TEMP\schema_az.sql"
    $schema | Out-File $tmpSql -Encoding UTF8

    $svr = "$SqlSrv.database.windows.net,1433"
    $maxRetry = 5; $retry = 0; $success = $false
    while ($retry -lt $maxRetry -and -not $success) {
        $retry++
        Info "Intento $retry/$maxRetry conectando al SQL Server..."
        $out = & "$sqlcmd" -S $svr -d $SqlDb -U $SqlUser -P $SqlPass -i $tmpSql -l 30 2>&1
        if ($LASTEXITCODE -eq 0) {
            $success = $true
            Ok "Esquema SQL aplicado."
        } else {
            Warn "No se pudo conectar. Esperando 30 segundos..."
            Write-Host ($out | Out-String)
            Start-Sleep -Seconds 30
        }
    }
    if (-not $success) { Warn "No se pudo ejecutar el esquema. Ejecutalo manualmente en SSMS." }
    Remove-Item $tmpSql -ErrorAction SilentlyContinue
} else {
    Warn "sqlcmd no encontrado. Ejecuta el esquema manualmente en SSMS conectando a: $SqlSrv.database.windows.net"
}

# ─────────────────────────────────────────────────────────────
# 6. CONNECTION STRING
# ─────────────────────────────────────────────────────────────
Write-Host ""
Info "Configurando connection string..."
$cs = "Server=tcp:$SqlSrv.database.windows.net,1433;Initial Catalog=$SqlDb;User ID=$SqlUser;Password=$SqlPass;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
az webapp config connection-string set --name $AppName --resource-group $RG --connection-string-type SQLAzure --settings "Capa_Datos.Properties.Settings.Monolito4amConnectionString=$cs"
if ($LASTEXITCODE -ne 0) { Warn "No se pudo configurar el connection string automaticamente." }
else { Ok "Connection string configurado." }

# ─────────────────────────────────────────────────────────────
# 7. DESPLEGAR
# ─────────────────────────────────────────────────────────────
Write-Host ""
Info "Desplegando ZIP en Azure..."
az webapp deploy --name $AppName --resource-group $RG --src-path $ZipFile --type zip
if ($LASTEXITCODE -ne 0) { Fail "Error en el despliegue." }
Ok "Despliegue completado."

# ─────────────────────────────────────────────────────────────
# 8. GUARDAR INFO Y ABRIR URL
# ─────────────────────────────────────────────────────────────
Remove-Item $PubDir  -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item $ZipFile -Force -ErrorAction SilentlyContinue

$url = "https://$AppName.azurewebsites.net"

$infoContent = "AppName=$AppName`nRG=$RG`nSqlSrv=$SqlSrv`nSqlDb=$SqlDb`nSqlUser=$SqlUser`nURL=$url`nFecha=$(Get-Date)"
$infoContent | Out-File $InfoFile -Encoding UTF8

Write-Host ""
Write-Host "=================================================" -ForegroundColor Green
Write-Host "   DESPLIEGUE COMPLETADO                        " -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  URL:  $url" -ForegroundColor Cyan
Write-Host "  SQL:  $SqlSrv.database.windows.net" -ForegroundColor Cyan
Write-Host "  Info guardada en: deploy_info.txt" -ForegroundColor DarkGray
Write-Host ""

Start-Process $url
