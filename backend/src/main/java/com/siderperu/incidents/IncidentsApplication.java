package com.siderperu.incidents;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.info.Info;

@SpringBootApplication
@OpenAPIDefinition(
    info = @Info(
        title = "SIDERPERU Incidents API",
        version = "1.0",
        description = "API para gestión de incidentes de seguridad de SIDERPERU"
    )
)
public class IncidentsApplication {
    public static void main(String[] args) {
        SpringApplication.run(IncidentsApplication.class, args);
    }
}
