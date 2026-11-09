# Actualizacion dinamica via GitHub: commit local -> push origin/main -> POST /actuator/refresh
param([string]$NuevoMensaje = 'Mensaje ACTUALIZADO desde Git durante la exposicion')
$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent $PSScriptRoot
$repo = if (Test-Path -LiteralPath (Join-Path $raiz 'config-repo')) { (Resolve-Path (Join-Path $raiz 'config-repo')).Path } else { $raiz }
$archivo = Join-Path $repo 'usuarios.yml'
if (-not (Test-Path (Join-Path $repo '.git'))) { throw 'Primero ejecuta 01-Preparar.ps1' }
if ($NuevoMensaje -match '[\r\n]') { throw 'El mensaje no puede contener saltos de linea.' }
$cadenaYaml = ConvertTo-Json -InputObject $NuevoMensaje -Compress
$actual = Get-Content -LiteralPath $archivo -Raw -Encoding UTF8
$actualizado = [regex]::Replace($actual, '(?m)^  mensaje:.*$', ('  mensaje: ' + $cadenaYaml))
if ($actual -eq $actualizado) { throw 'No se encontro demo.mensaje o el mensaje no cambio.' }
[System.IO.File]::WriteAllText($archivo, $actualizado, [System.Text.UTF8Encoding]::new($false))
& git -C $repo add usuarios.yml
if ($LASTEXITCODE -ne 0) { throw 'Fallo git add.' }
& git -C $repo -c 'user.name=Equipo Spring Cloud Config' -c 'user.email=equipo@localhost.invalid' commit -m 'Actualizar mensaje del servicio usuarios'
if ($LASTEXITCODE -ne 0) { throw 'Fallo git commit.' }
Write-Host 'Nuevo commit Git creado.' -ForegroundColor Green
Write-Host 'Publicando nuevo commit en GitHub (origin/main)...' -ForegroundColor Cyan
& git -C $repo push origin main
if ($LASTEXITCODE -ne 0) { throw 'Fallo git push: no se intentara el refresh hasta publicar el commit en GitHub.' }
Write-Host 'Commit publicado en GitHub.' -ForegroundColor Green
Write-Host 'Refrescando el microservicio usuarios...' -ForegroundColor Cyan
$changes = Invoke-RestMethod -Method Post -Uri 'http://127.0.0.1:8081/actuator/refresh' -ContentType 'application/json' -Body '{}' -TimeoutSec 30
Write-Host ('Propiedades refrescadas: ' + ($changes -join ', '))
$data = Invoke-RestMethod -Uri 'http://127.0.0.1:8081/mensaje' -TimeoutSec 10
$data | ConvertTo-Json
