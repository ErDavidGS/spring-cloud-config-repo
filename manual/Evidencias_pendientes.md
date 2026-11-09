# Evidencias recomendadas para anexar tras la prueba

Las capturas deben obtenerse del proyecto ejecutado realmente en Windows.

1. Config Server: GET `http://localhost:8888/usuarios/default` en Postman.
2. Usuarios: GET `http://localhost:8081/mensaje`.
3. Productos: GET `http://localhost:8082/mensaje`.
4. Pedidos: GET `http://localhost:8083/mensaje`.
5. Git: `git -C .\config-repo log --oneline -3` antes/después.
6. Refresco: POST `http://localhost:8081/actuator/refresh`.
7. Usuarios después de refresh: GET `http://localhost:8081/mensaje` con nuevo texto.

No se han incluido capturas simuladas ni resultados de código que no se haya ejecutado.
