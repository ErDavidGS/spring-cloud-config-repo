$raiz = Split-Path -Parent $PSScriptRoot
$run = Join-Path $raiz '.run'
foreach ($modulo in @('microservicio-pedidos','microservicio-productos','microservicio-usuarios','config-server')) {
    $archivo = Join-Path $run "$modulo.pid"
    if (-not (Test-Path $archivo)) { continue }
    $idProceso = [int](Get-Content $archivo -Raw)
    $p = Get-Process -Id $idProceso -ErrorAction SilentlyContinue
    if ($p -and $p.ProcessName -match '^javaw?$') {
        Stop-Process -Id $idProceso -ErrorAction SilentlyContinue
        Write-Host "Detenido $modulo ($idProceso)"
    } else {
        Write-Host "Proceso registrado de $modulo ya no esta activo (o no es Java)."
    }
    Remove-Item $archivo -Force
}
