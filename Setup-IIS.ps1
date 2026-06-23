# ============================================================
#  Monolito4b - Setup completo en IIS
#  Ejecutar como ADMINISTRADOR:
#    Clic derecho en este archivo → "Ejecutar con PowerShell"
#    O desde PowerShell Admin: .\Setup-IIS.ps1
# ============================================================

$ErrorActionPreference = "Stop"
$proyecto = "C:\Users\Pc\Documents\My Web Sites\Monolito4b\Monolito4b"
$sitio    = "Monolito4b"
$pool     = "Monolito4b_Pool"
$puerto   = 8080
$bd       = "Monolito4am"

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "  SETUP IIS - $sitio" -ForegroundColor Cyan
Write-Host "==========================================`n" -ForegroundColor Cyan

# ----------------------------------------------------------
# 1. Activar IIS y ASP.NET 4.8
# ----------------------------------------------------------
Write-Host "[1/6] Activando IIS y ASP.NET..." -ForegroundColor Yellow

$features = @(
    "IIS-WebServer",
    "IIS-CommonHttpFeatures",
    "IIS-StaticContent",
    "IIS-DefaultDocument",
    "IIS-HttpErrors",
    "IIS-ApplicationDevelopment",
    "IIS-ASPNET45",
    "IIS-NetFxExtensibility45",
    "IIS-ISAPIExtensions",
    "IIS-ISAPIFilter",
    "IIS-ManagementConsole",
    "NetFx4Extended-ASPNET45"
)

foreach ($f in $features) {
    $state = (Get-WindowsOptionalFeature -Online -FeatureName $f -ErrorAction SilentlyContinue).State
    if ($state -ne "Enabled") {
        Write-Host "   Habilitando: $f" -ForegroundColor Gray
        Enable-WindowsOptionalFeature -Online -FeatureName $f -All -NoRestart | Out-Null
    } else {
        Write-Host "   Ya activo:   $f" -ForegroundColor DarkGray
    }
}
Write-Host "   [OK] IIS activado`n" -ForegroundColor Green

# ----------------------------------------------------------
# 2. Registrar ASP.NET 4 en IIS
# ----------------------------------------------------------
Write-Host "[2/6] Registrando ASP.NET 4.0 en IIS..." -ForegroundColor Yellow

$aspnet = "$env:windir\Microsoft.NET\Framework64\v4.0.30319\aspnet_regiis.exe"
if (Test-Path $aspnet) {
    & $aspnet -i | Out-Null
    Write-Host "   [OK] ASP.NET 4.0 registrado`n" -ForegroundColor Green
} else {
    Write-Host "   [!] aspnet_regiis no encontrado - probando Framework32..." -ForegroundColor DarkYellow
    $aspnet32 = "$env:windir\Microsoft.NET\Framework\v4.0.30319\aspnet_regiis.exe"
    if (Test-Path $aspnet32) { & $aspnet32 -i | Out-Null }
    Write-Host ""
}

# ----------------------------------------------------------
# 3. Crear Application Pool
# ----------------------------------------------------------
Write-Host "[3/6] Configurando Application Pool '$pool'..." -ForegroundColor Yellow

Import-Module WebAdministration -ErrorAction Stop

if (Test-Path "IIS:\AppPools\$pool") {
    Write-Host "   Pool ya existe, reconfigurando..." -ForegroundColor DarkGray
    Remove-WebAppPool -Name $pool
}

New-WebAppPool -Name $pool | Out-Null
Set-ItemProperty "IIS:\AppPools\$pool" managedRuntimeVersion "v4.0"
Set-ItemProperty "IIS:\AppPools\$pool" managedPipelineMode   "Integrated"
Set-ItemProperty "IIS:\AppPools\$pool" startMode             "AlwaysRunning"
Set-ItemProperty "IIS:\AppPools\$pool" processModel.idleTimeout "00:00:00"

Write-Host "   [OK] Pool '$pool' creado (.NET 4.0 / Integrado)`n" -ForegroundColor Green

# ----------------------------------------------------------
# 4. Crear el Sitio Web
# ----------------------------------------------------------
Write-Host "[4/6] Creando sitio '$sitio' en puerto $puerto..." -ForegroundColor Yellow

# Eliminar si ya existe
if (Get-Website -Name $sitio -ErrorAction SilentlyContinue) {
    Remove-Website -Name $sitio
    Write-Host "   Sitio anterior eliminado." -ForegroundColor DarkGray
}

# Verificar que la carpeta existe
if (-not (Test-Path $proyecto)) {
    Write-Host "   [ERROR] La carpeta del proyecto no existe:" -ForegroundColor Red
    Write-Host "   $proyecto" -ForegroundColor Red
    Write-Host "   Verifica la ruta y vuelve a ejecutar." -ForegroundColor Red
    Read-Host "`nPresiona Enter para salir"
    exit 1
}

New-Website -Name $sitio `
            -PhysicalPath $proyecto `
            -ApplicationPool $pool `
            -Port $puerto | Out-Null

# Página de inicio predeterminada
$cfgPath = "IIS:\Sites\$sitio"
Add-WebConfiguration "//defaultDocument/files" -PSPath $cfgPath `
    -Value @{value="Seguridad/login.aspx"} -ErrorAction SilentlyContinue

Write-Host "   [OK] Sitio creado en http://localhost:$puerto`n" -ForegroundColor Green

# ----------------------------------------------------------
# 5. Permisos de carpeta para el pool
# ----------------------------------------------------------
Write-Host "[5/6] Asignando permisos de carpeta al pool..." -ForegroundColor Yellow

$acl      = Get-Acl $proyecto
$identity = "IIS APPPOOL\$pool"
$rule     = New-Object System.Security.AccessControl.FileSystemAccessRule(
                $identity, "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
$acl.SetAccessRule($rule)
Set-Acl -Path $proyecto -AclObject $acl

Write-Host "   [OK] Permisos asignados a '$identity'`n" -ForegroundColor Green

# ----------------------------------------------------------
# 6. Crear login SQL Server para el pool (Seguridad integrada)
# ----------------------------------------------------------
Write-Host "[6/6] Configurando permisos en SQL Server..." -ForegroundColor Yellow

$sqlLogin = "IIS APPPOOL\$pool"
$sqlCmd   = @"
USE [master];
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'$sqlLogin')
BEGIN
    CREATE LOGIN [$sqlLogin] FROM WINDOWS WITH DEFAULT_DATABASE=[$bd];
    PRINT 'Login creado: $sqlLogin';
END
ELSE
    PRINT 'Login ya existe: $sqlLogin';

USE [$bd];
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'$sqlLogin')
BEGIN
    CREATE USER [$sqlLogin] FOR LOGIN [$sqlLogin];
    PRINT 'Usuario BD creado.';
END
EXEC sp_addrolemember 'db_owner', [$sqlLogin];
PRINT 'Rol db_owner asignado.';
"@

try {
    sqlcmd -S "." -Q $sqlCmd -E 2>&1 | ForEach-Object { Write-Host "   $_" -ForegroundColor DarkGray }
    Write-Host "   [OK] Permisos SQL configurados`n" -ForegroundColor Green
} catch {
    Write-Host "   [!] No se pudo configurar SQL automaticamente." -ForegroundColor DarkYellow
    Write-Host "   Ejecuta manualmente en SSMS:`n" -ForegroundColor DarkYellow
    Write-Host $sqlCmd -ForegroundColor DarkGray
    Write-Host ""
}

# ----------------------------------------------------------
# Iniciar el sitio
# ----------------------------------------------------------
Start-Website -Name $sitio
Start-WebAppPool -Name $pool

# ----------------------------------------------------------
# Resumen
# ----------------------------------------------------------
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  SETUP COMPLETADO" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  URL:      http://localhost:$puerto/Seguridad/login.aspx" -ForegroundColor White
Write-Host "  Carpeta:  $proyecto" -ForegroundColor White
Write-Host "  Pool:     $pool (.NET 4.0)" -ForegroundColor White
Write-Host "  BD:       $bd" -ForegroundColor White
Write-Host ""
Write-Host "  Abriendo el navegador..." -ForegroundColor Yellow
Start-Process "http://localhost:$puerto/Seguridad/login.aspx"

Read-Host "`nPresiona Enter para salir"
