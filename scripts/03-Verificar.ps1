$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent $PSScriptRoot
$repo = if (Test-Path -LiteralPath (Join-Path $raiz 'config-repo')) { (Resolve-Path (Join-Path $raiz 'config-repo')).Path } else { $raiz }
Write-Host '=== Configuracion centralizada desde Git ===' -ForegroundColor Cyan
$config = Invoke-RestMethod -Uri 'http://127.0.0.1:8888/usuarios/default' -TimeoutSec 15
$rama = ((& git -C $repo branch --show-current) | Out-String).Trim()
Write-Host "Servicio: $($config.name) | rama Git local: $rama | commit servido: $($config.version)"
foreach ($item in @(
    @{Nombre='Usuarios'; URL='http://127.0.0.1:8081/mensaje'},
    @{Nombre='Productos'; URL='http://127.0.0.1:8082/mensaje'},
    @{Nombre='Pedidos'; URL='http://127.0.0.1:8083/mensaje'}
)) {
    $data = Invoke-RestMethod -Uri $item.URL -TimeoutSec 15
    Write-Host "$($item.Nombre): $($data.mensaje) | version $($data.version)" -ForegroundColor Green
}
