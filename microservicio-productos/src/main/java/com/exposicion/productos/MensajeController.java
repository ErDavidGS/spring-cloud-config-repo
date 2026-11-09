package com.exposicion.productos;

import java.util.Map;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RefreshScope
@RestController
public class MensajeController {
    @Value("${demo.mensaje}")
    private String mensaje;

    @Value("${demo.version}")
    private String version;

    @GetMapping("/mensaje")
    public Map<String, Object> mensaje() {
        return Map.of(
            "servicio", "productos",
            "mensaje", mensaje,
            "version", version,
            "origen", "Spring Cloud Config Server + Git"
        );
    }

    @GetMapping("/")
    public Map<String, String> inicio() {
        return Map.of("servicio", "productos", "prueba", "/mensaje", "estado", "activo");
    }
}
