package com.siderperu.incidents.service;

import com.siderperu.incidents.model.Report;
import com.siderperu.incidents.repository.ReportRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.mail.MessagingException;
import javax.mail.internet.MimeMessage;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ReportService {

    private final ReportRepository reportRepository;
    private final JavaMailSender mailSender;
    private static final String SAFETY_EMAIL = "seguridad@siderperu.com.pe";

    @Transactional(readOnly = true)
    public List<Report> getAllReports() {
        return reportRepository.findAll();
    }

    @Transactional(readOnly = true)
    public Optional<Report> getReportById(Long id) {
        return reportRepository.findById(id);
    }

    @Transactional
    public Report saveReport(Report report) {
        return reportRepository.save(report);
    }

    @Transactional
    public void deleteReport(Long id) {
        reportRepository.deleteById(id);
    }

    @Transactional(readOnly = true)
    public List<Report> getReportsByDate(LocalDate date) {
        return reportRepository.findByDate(date);
    }

    @Transactional(readOnly = true)
    public List<Report> getReportsByArea(String area) {
        return reportRepository.findByArea(area);
    }

    @Transactional
    public void sendReportsEmail() throws MessagingException {
        List<Report> reports = reportRepository.findAll();
        if (reports.isEmpty()) {
            return;
        }

        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

        helper.setTo(SAFETY_EMAIL);
        helper.setSubject("Reporte de Incidentes SIDERPERU - " + LocalDate.now());

        StringBuilder htmlContent = new StringBuilder();
        htmlContent.append("<html><body>");
        htmlContent.append("<h2>Reporte de Incidentes SIDERPERU</h2>");
        htmlContent.append("<table border='1' style='border-collapse: collapse;'>");
        htmlContent.append("<tr><th>Fecha</th><th>Trabajador</th><th>Zona</th><th>Tipo</th><th>Descripción</th></tr>");

        for (Report report : reports) {
            htmlContent.append("<tr>");
            htmlContent.append("<td>").append(report.getDate()).append("</td>");
            htmlContent.append("<td>").append(report.getWorkerName()).append("</td>");
            htmlContent.append("<td>").append(report.getArea()).append("</td>");
            htmlContent.append("<td>").append(report.getIncidentType()).append("</td>");
            htmlContent.append("<td>").append(report.getDescription()).append("</td>");
            htmlContent.append("</tr>");
        }

        htmlContent.append("</table>");
        htmlContent.append("</body></html>");

        helper.setText(htmlContent.toString(), true);
        mailSender.send(message);
    }
}
