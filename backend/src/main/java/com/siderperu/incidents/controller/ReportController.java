package com.siderperu.incidents.controller;

import com.siderperu.incidents.model.Report;
import com.siderperu.incidents.service.ReportService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.mail.MessagingException;
import javax.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/api/reportes")
@RequiredArgsConstructor
@Tag(name = "Reportes", description = "API para gestión de reportes de incidentes")
@CrossOrigin(origins = "*")
public class ReportController {

    private final ReportService reportService;

    @PostMapping
    @Operation(summary = "Crear nuevo reporte", description = "Crea un nuevo reporte de incidente")
    @ApiResponse(responseCode = "201", description = "Reporte creado exitosamente")
    public ResponseEntity<Report> createReport(@Valid @RequestBody Report report) {
        Report savedReport = reportService.saveReport(report);
        return new ResponseEntity<>(savedReport, HttpStatus.CREATED);
    }

    @GetMapping
    @Operation(summary = "Obtener todos los reportes", description = "Obtiene la lista de todos los reportes")
    @ApiResponse(responseCode = "200", description = "Lista de reportes obtenida exitosamente")
    public ResponseEntity<List<Report>> getAllReports() {
        List<Report> reports = reportService.getAllReports();
        return ResponseEntity.ok(reports);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtener reporte por ID", description = "Obtiene un reporte específico por su ID")
    @ApiResponse(responseCode = "200", description = "Reporte encontrado")
    @ApiResponse(responseCode = "404", description = "Reporte no encontrado")
    public ResponseEntity<Report> getReportById(@PathVariable Long id) {
        return reportService.getReportById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Eliminar reporte", description = "Elimina un reporte por su ID")
    @ApiResponse(responseCode = "204", description = "Reporte eliminado exitosamente")
    public ResponseEntity<Void> deleteReport(@PathVariable Long id) {
        reportService.deleteReport(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/send-email")
    @Operation(summary = "Enviar reportes por correo", description = "Envía todos los reportes por correo electrónico")
    @ApiResponse(responseCode = "200", description = "Correo enviado exitosamente")
    @ApiResponse(responseCode = "500", description = "Error al enviar el correo")
    public ResponseEntity<String> sendReportsEmail() {
        try {
            reportService.sendReportsEmail();
            return ResponseEntity.ok("Reportes enviados por correo exitosamente");
        } catch (MessagingException e) {
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error al enviar el correo: " + e.getMessage());
        }
    }

    @GetMapping("/area/{area}")
    @Operation(summary = "Obtener reportes por área", description = "Obtiene la lista de reportes de un área específica")
    @ApiResponse(responseCode = "200", description = "Lista de reportes obtenida exitosamente")
    public ResponseEntity<List<Report>> getReportsByArea(@PathVariable String area) {
        List<Report> reports = reportService.getReportsByArea(area);
        return ResponseEntity.ok(reports);
    }
}
