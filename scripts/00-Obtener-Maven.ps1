$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$raiz = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$tools = Join-Path $raiz '.tools'
$version = '3.9.9'
$carpeta = Join-Path $tools ('apache-maven-' + $version)
$mvn = Join-Path $carpeta 'bin\mvn.cmd'

if (Test-Path -LiteralPath $mvn) {
    Write-Host "Apache Maven $version disponible en $carpeta" -ForegroundColor Green
    exit 0
}

New-Item -ItemType Directory -Path $tools -Force | Out-Null
$zip = Join-Path $tools ('apache-maven-' + $version + '-bin.zip')
$urls = @(
    'https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.9/apache-maven-3.9.9-bin.zip',
    'https://archive.apache.org/dist/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.zip'
)
$correcto = $false
foreach ($url in $urls) {
    try {
        Write-Host "Descargando Apache Maven $version desde $url" -ForegroundColor Cyan
        if (Test-Path -LiteralPath $zip) { Remove-Item -LiteralPath $zip -Force }
        if (Test-Path -LiteralPath $carpeta) { Remove-Item -LiteralPath $carpeta -Recurse -Force }
        Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing -TimeoutSec 180 -ErrorAction Stop
        if ((Get-Item -LiteralPath $zip).Length -lt 8000000) {
            throw 'El archivo descargado es demasiado pequeno para ser Apache Maven.'
        }
        Expand-Archive -LiteralPath $zip -DestinationPath $tools -Force -ErrorAction Stop
        if (-not (Test-Path -LiteralPath $mvn)) {
            throw 'El ZIP descargado no contiene bin\mvn.cmd en la ruta esperada.'
        }
        $correcto = $true
        break
    } catch {
        Write-Warning ('Fallo la descarga o extraccion: ' + $_.Exception.Message)
    }
}
if (-not $correcto) {
    throw 'No se pudo obtener Apache Maven 3.9.9. Comprueba internet o proxy; no es un error de Java ni del proyecto.'
}

try {
    Write-Host 'Comprobando Maven descargado...' -ForegroundColor Cyan
    & $mvn -version
    if ($LASTEXITCODE -ne 0) { throw 'Apache Maven no pudo ejecutarse.' }
} finally {
    if (Test-Path -LiteralPath $zip) { Remove-Item -LiteralPath $zip -Force }
}
Write-Host 'Maven instalado dentro de .tools (sin cambios en PATH de Windows).' -ForegroundColor Green