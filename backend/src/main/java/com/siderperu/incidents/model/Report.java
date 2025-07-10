package com.siderperu.incidents.model;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import javax.persistence.*;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "reports")
public class Report {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull(message = "La fecha es requerida")
    private LocalDate date;

    @NotBlank(message = "El nombre del trabajador es requerido")
    @Column(name = "worker_name")
    private String workerName;

    @NotBlank(message = "La zona es requerida")
    private String area;

    @NotBlank(message = "El tipo de incidente es requerido")
    @Column(name = "incident_type")
    private String incidentType;

    @NotBlank(message = "La descripción es requerida")
    private String description;

    @Column(name = "photo_data")
    @Lob
    private String photoBase64;

    @Column(name = "created_at")
    private LocalDate createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDate.now();
    }
}
