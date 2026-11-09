$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent $PSScriptRoot
$repo = if (Test-Path -LiteralPath (Join-Path $raiz 'config-repo')) { (Resolve-Path (Join-Path $raiz 'config-repo')).Path } else { $raiz }
Write-Host '=== 1/3 Comprobando Java y Git ===' -ForegroundColor Cyan
java -version
if ($LASTEXITCODE -ne 0) { throw 'Java no disponible en PATH.' }
javac -version
if ($LASTEXITCODE -ne 0) { throw 'Se necesita un JDK (javac), no solo JRE.' }
git --version
if ($LASTEXITCODE -ne 0) { throw 'Git no disponible en PATH.' }

Write-Host '=== 2/3 Inicializando el repositorio Git ===' -ForegroundColor Cyan
if (-not (Test-Path (Join-Path $repo '.git'))) {
    & git -C $repo init -b main
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo inicializar Git.' }
    & git -C $repo add .
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo agregar los archivos.' }
    & git -C $repo -c 'user.name=Equipo Spring Cloud Config' -c 'user.email=equipo@localhost.invalid' commit -m 'Configuraciones iniciales'
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo crear el commit inicial.' }
} else {
    Write-Host 'Repositorio Git ya inicializado.' -ForegroundColor Green
}

Write-Host '=== 3/3 Compilando los cuatro modulos (primera vez requiere internet) ===' -ForegroundColor Cyan
Write-Host 'Preparando Apache Maven 3.9.9 local...' -ForegroundColor Cyan
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot '00-Obtener-Maven.ps1')
if ($LASTEXITCODE -ne 0) { throw 'Fallo al descargar o preparar Maven. Revisa el mensaje anterior.' }
foreach ($modulo in @('config-server','microservicio-usuarios','microservicio-productos','microservicio-pedidos')) {
    Write-Host "Compilando $modulo..." -ForegroundColor Yellow
    Push-Location (Join-Path $raiz $modulo)
    try {
        & .\mvnw.cmd -B -ntp clean package
        if ($LASTEXITCODE -ne 0) { throw "Fallo Maven en $modulo. Revisa el error." }
    } finally { Pop-Location }
}
Write-Host 'PREPARACION COMPLETA. Sigue con scripts\02-Iniciar.ps1' -ForegroundColor Green
