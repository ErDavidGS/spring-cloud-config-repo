# Guion de exposición (8 diapositivas)

> Duración orientativa: 6-8 minutos de explicación y 4-6 minutos de demostración. Ajustar al tiempo real asignado por el docente.

## 1. Portada
"Mostraremos cómo administrar los parámetros de tres microservicios con una única fuente de configuración, utilizando Spring Cloud Config Server y Git. No emplearemos una base de datos: queremos demostrar exclusivamente el concepto de configuración centralizada."

## 2. Problema
"Si cada servicio almacena su propia configuración, los cambios son repetitivos y puede haber diferencias entre los ambientes. Al versionar las propiedades fuera del código Java, reducimos el riesgo de inconsistencias."

## 3. Arquitectura
"Git almacena tres archivos YAML. Config Server trabaja como intermediario y expone un endpoint HTTP. Cada microservicio obtiene la configuración correspondiente a su nombre y mantiene una API REST para demostrar el resultado."

## 4. Conceptos
"El Config Client usa `spring.config.import`. Los archivos se buscan por nombre y perfil. Con `@RefreshScope` y un POST a `/actuator/refresh`, actualizamos las propiedades de un servicio sin tener que editar ni recompilar el código."

## 5. Herramientas
"Usamos Java 17, Spring Boot 3.5 y Spring Cloud 2025.0, Git y Maven Wrapper. Cada aplicación usa un puerto: Config Server en 8888; usuarios en 8081; productos en 8082 y pedidos en 8083."

## 6. Implementación
"En cada cliente solo indicamos su nombre y dónde está Config Server. En Git definimos su puerto, su mensaje y su versión. Esto separa las responsabilidades: la lógica pertenece al código, los parámetros al repositorio."

## 7. Demostración en vivo
"Primero levantamos Config Server y luego los clientes. Comprobamos las cuatro URLs. Editamos `usuarios.yml`, creamos un commit, invocamos el endpoint de refresco y repetimos GET /mensaje. El mensaje debe cambiar sin recompilar Java."

## 8. Conclusión
"El objetivo es la centralización y trazabilidad mediante Git. La práctica usa servicios muy simples deliberadamente. En producción habría que asegurar el endpoint de refresco, gestionar secretos y usar infraestructura remota confiable."

## Comandos para quien realiza la demostración

Ejecutar desde la carpeta raíz del ZIP ya extraído, en una computadora con Java JDK y Git:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\01-Preparar.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\02-Iniciar.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\03-Verificar.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\04-Cambiar-Mensaje.ps1 -NuevoMensaje "Cambio visible en vivo"
```

Al terminar:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\05-Detener.ps1
```

**Nota:** no afirmar que la demo funcionó hasta ensayarla en Windows y ver las respuestas reales.
