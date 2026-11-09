# Spring Cloud Config Server â€” proyecto completo

Proyecto academico con cuatro aplicaciones Spring Boot: **Config Server** (8888), **Usuarios** (8081), **Productos** (8082) y **Pedidos** (8083).

- Configuracion de los clientes en los YAML **de la raiz** (`application.yml`, `usuarios.yml`, `productos.yml`, `pedidos.yml`).
- El servidor de configuracion obtiene estos archivos del repositorio remoto `https://github.com/ErDavidGS/spring-cloud-config-repo.git` (rama `main`).
- Se puede ejecutar en Windows con JDK 17, Git, PowerShell e internet para descargar Maven/dependencias por primera vez.
- No se usan bases de datos ni Docker.

## Instalacion desde cero en Windows

```powershell
git clone https://github.com/ErDavidGS/spring-cloud-config-repo.git
cd spring-cloud-config-repo
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\01-Preparar.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\02-Iniciar-GitHub.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\03-Verificar.ps1
```

La primera preparacion instala **Maven 3.9.9 dentro de `.tools`**, excluido del repositorio.

## Demostracion de configuracion remota

```powershell
curl.exe http://127.0.0.1:8888/usuarios/default
curl.exe http://127.0.0.1:8081/mensaje
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\04-Cambiar-Mensaje-GitHub.ps1 -NuevoMensaje 'CAMBIO DESDE GITHUB'
curl.exe http://127.0.0.1:8081/mensaje
```

El script de cambio edita `usuarios.yml` en **este repositorio**, crea un commit, ejecuta `git push origin main`, llama `POST /actuator/refresh` con JSON y consulta el nuevo valor sin reiniciar Java. Requiere permisos de escritura en GitHub.

## Respaldo sin GitHub

El script `scripts/02-Iniciar.ps1` apunta a la copia Git local del propio clon. Los endpoints y la demostracion usan los mismos cuatro puertos. `scripts/04-Cambiar-Mensaje.ps1` modifica Git solo localmente.

Para detener los servicios iniciados por los scripts:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\05-Detener.ps1
```

## Documentacion

- `manual/`: guia PDF y notas de evidencias.
- `presentacion/`: diapositivas editables y guion.
- `scripts/`: preparacion, inicio local o GitHub, pruebas, actualizacion y detencion.

Nota: la configuracion centralizada esta en la raiz del repositorio porque Spring Cloud Config busca alli los YAML por defecto. Solo se publica el codigo y los documentos; **no** se versionan los JAR, `target/`, Maven descargado ni logs. No publiques credenciales en los YAML.