param([string]$NuevoMensaje = 'Mensaje ACTUALIZADO desde Git durante la exposicion')
$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent $PSScriptRoot
$repo = if (Test-Path -LiteralPath (Join-Path $raiz 'config-repo')) { (Resolve-Path (Join-Path $raiz 'config-repo')).Path } else { $raiz }
$archivo = Join-Path $repo 'usuarios.yml'
if (-not (Test-Path (Join-Path $repo '.git'))) { throw 'Primero ejecuta 01-Preparar.ps1' }
if ($NuevoMensaje -match '[\r\n]') { throw 'El mensaje no puede contener saltos de linea.' }
# ConvertTo-Json garantiza el escape de comillas dentro del valor YAML.
$cadenaYaml = ConvertTo-Json -InputObject $NuevoMensaje -Compress
$actual = Get-Content -LiteralPath $archivo -Raw -Encoding UTF8
$actualizado = [regex]::Replace($actual, '(?m)^  mensaje:.*$', ('  mensaje: ' + $cadenaYaml))
if ($actual -eq $actualizado) { throw 'No se encontro la propiedad demo.mensaje o el contenido no cambio.' }
[System.IO.File]::WriteAllText($archivo, $actualizado, [System.Text.UTF8Encoding]::new($false))
& git -C $repo add usuarios.yml
if ($LASTEXITCODE -ne 0) { throw 'Fallo git add.' }
& git -C $repo -c 'user.name=Equipo Spring Cloud Config' -c 'user.email=equipo@localhost.invalid' commit -m 'Actualizar mensaje del servicio usuarios'
if ($LASTEXITCODE -ne 0) { throw 'Fallo git commit.' }
Write-Host 'Se creo un commit nuevo en el repositorio Git.' -ForegroundColor Green
Write-Host 'Actualizando el servicio de usuarios con /actuator/refresh...' -ForegroundColor Cyan
$changes = Invoke-RestMethod -Method Post -Uri 'http://127.0.0.1:8081/actuator/refresh' -ContentType 'application/json' -Body '{}' -TimeoutSec 25
Write-Host ('Propiedades refrescadas: ' + ($changes -join ', '))
$data = Invoke-RestMethod -Uri 'http://localhost:8081/mensaje'
$data | ConvertTo-Json
