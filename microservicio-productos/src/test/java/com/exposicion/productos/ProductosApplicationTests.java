package com.exposicion.productos;

import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;
import static org.junit.jupiter.api.Assertions.assertEquals;

class ProductosApplicationTests {
    @Test
    void mensajeIncluyeConfiguracionRecibida() {
        MensajeController controller = new MensajeController();
        ReflectionTestUtils.setField(controller, "mensaje", "Valor desde Git");
        ReflectionTestUtils.setField(controller, "version", "2.0");
        assertEquals("Valor desde Git", controller.mensaje().get("mensaje"));
        assertEquals("2.0", controller.mensaje().get("version"));
        assertEquals("productos", controller.mensaje().get("servicio"));
    }
}
