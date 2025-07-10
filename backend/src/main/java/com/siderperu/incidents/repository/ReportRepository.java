package com.siderperu.incidents.repository;

import com.siderperu.incidents.model.Report;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;

@Repository
public interface ReportRepository extends JpaRepository<Report, Long> {
    
    // Find reports by date
    List<Report> findByDate(LocalDate date);
    
    // Find reports by area
    List<Report> findByArea(String area);
    
    // Find reports by incident type
    List<Report> findByIncidentType(String incidentType);
    
    // Find reports by worker name containing
    List<Report> findByWorkerNameContainingIgnoreCase(String workerName);
    
    // Find reports between dates
    List<Report> findByDateBetween(LocalDate startDate, LocalDate endDate);
}
