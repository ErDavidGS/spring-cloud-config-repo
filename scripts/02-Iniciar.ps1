# Spring Cloud Config: arranque idempotente en Windows (PowerShell 5.1 / 7).
# Ejecucion: powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\02-Iniciar.ps1
$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent $PSScriptRoot
$repo = if (Test-Path -LiteralPath (Join-Path $raiz 'config-repo')) { (Resolve-Path (Join-Path $raiz 'config-repo')).Path } else { $raiz }
if (-not (Test-Path (Join-Path $repo '.git'))) {
    throw 'Falta inicializar el repositorio Git. Ejecuta scripts\01-Preparar.ps1.'
}
$env:CONFIG_GIT_URI = 'file:///' + ($repo -replace '\\', '/')
$logs = Join-Path $raiz 'logs'
$run = Join-Path $raiz '.run'
New-Item -ItemType Directory -Force -Path $logs, $run | Out-Null

$servicios = @(
    @{ Modulo = 'config-server'; Puerto = 8888 },
    @{ Modulo = 'microservicio-usuarios'; Puerto = 8081 },
    @{ Modulo = 'microservicio-productos'; Puerto = 8082 },
    @{ Modulo = 'microservicio-pedidos'; Puerto = 8083 }
)

function Test-Health {
    param([int]$Puerto)
    try {
        $respuesta = Invoke-RestMethod -Method Get -Uri "http://127.0.0.1:$Puerto/actuator/health" -TimeoutSec 4
        return ($null -ne $respuesta -and $respuesta.status -eq 'UP')
    } catch {
        return $false
    }
}

foreach ($svc in $servicios) {
    $modulo = $svc.Modulo
    $puerto = [int]$svc.Puerto
    $escuchando = @(Get-NetTCPConnection -LocalPort $puerto -State Listen -ErrorAction SilentlyContinue)

    if ($escuchando.Count -gt 0) {
        if (Test-Health -Puerto $puerto) {
            Write-Host "$modulo (puerto $puerto): ya se encuentra operativo." -ForegroundColor Green
            continue
        }
        throw "El puerto $puerto esta ocupado, pero su /actuator/health no devuelve UP. Revisa el proceso que utiliza ese puerto."
    }

    $target = Join-Path (Join-Path $raiz $modulo) 'target'
    if (-not (Test-Path $target)) { throw "No existe $target. Ejecuta primero scripts\01-Preparar.ps1." }
    $jar = Get-ChildItem -Path $target -File -Filter '*.jar' |
        Where-Object { $_.Name -notmatch '\.original$' -and $_.Name -notmatch 'sources|javadoc' } |
        Select-Object -First 1
    if (-not $jar) { throw "No se encontro el JAR ejecutable de $modulo. Ejecuta scripts\01-Preparar.ps1." }

    $out = Join-Path $logs "$modulo.out.log"
    $err = Join-Path $logs "$modulo.err.log"
    Write-Host "Iniciando $modulo en puerto $puerto..." -ForegroundColor Cyan
    $proceso = Start-Process -FilePath 'java' -ArgumentList @('-jar', ('"' + $jar.FullName + '"')) `
        -WorkingDirectory (Join-Path $raiz $modulo) -PassThru -WindowStyle Hidden `
        -RedirectStandardOutput $out -RedirectStandardError $err
    $proceso.Id | Set-Content (Join-Path $run "$modulo.pid")

    $activo = $false
    for ($intento = 1; $intento -le 60; $intento++) {
        if (Test-Health -Puerto $puerto) { $activo = $true; break }
        $proceso.Refresh()
        if ($proceso.HasExited) { break }
        Start-Sleep -Seconds 2
    }

    if (-not $activo) {
        Write-Host "No se pudo comprobar el arranque de $modulo. Ultimas lineas del log:" -ForegroundColor Yellow
        if (Test-Path $out) { Get-Content $out -Tail 35 }
        if ((Test-Path $err) -and (Get-Item $err).Length -gt 0) {
            Write-Host 'Errores:' -ForegroundColor Yellow
            Get-Content $err -Tail 35
        }
        throw "No se inicio $modulo en el puerto $puerto. Consulta los archivos de logs/."
    }
    Write-Host "$modulo (puerto $puerto): OK" -ForegroundColor Green
}
Write-Host 'SISTEMA ACTIVO: 8888, 8081, 8082, 8083' -ForegroundColor Green
Write-Host 'Verifica los mensajes con scripts\03-Verificar.ps1.'
