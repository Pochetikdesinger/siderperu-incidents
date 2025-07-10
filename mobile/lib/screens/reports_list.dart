import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/report.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';

class ReportsList extends StatefulWidget {
  const ReportsList({Key? key}) : super(key: key);

  @override
  State<ReportsList> createState() => _ReportsListState();
}

class _ReportsListState extends State<ReportsList> {
  final DatabaseService _dbService = DatabaseService.instance;
  final ApiService _apiService = ApiService();

  Future<void> _deleteReport(int id) async {
    try {
      await _dbService.deleteReport(id);
      setState(() {}); // Refresh the list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reporte eliminado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar el reporte'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendEmail() async {
    try {
      final success = await _apiService.sendReportsEmail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Reportes enviados por correo exitosamente'
                  : 'Error al enviar reportes por correo',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al enviar reportes por correo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes Guardados'),
        actions: [
          IconButton(
            icon: const Icon(Icons.email),
            onPressed: _sendEmail,
            tooltip: 'Enviar por correo',
          ),
        ],
      ),
      body: FutureBuilder<List<Report>>(
        future: _dbService.getAllReports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final reports = snapshot.data ?? [];

          if (reports.isEmpty) {
            return const Center(
              child: Text('No hay reportes guardados'),
            );
          }

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ExpansionTile(
                  title: Text(
                    'Reporte ${report.id} - ${report.workerName}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${report.date} - ${report.area}'),
                  leading: Icon(
                    report.isSynced ? Icons.cloud_done : Icons.cloud_off,
                    color: report.isSynced ? Colors.green : Colors.grey,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tipo: ${report.incidentType}'),
                          const SizedBox(height: 8),
                          Text('Descripción: ${report.description}'),
                          if (report.photoPath != null) ...[
                            const SizedBox(height: 8),
                            Image.file(
                              File(report.photoPath!),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.delete),
                                label: const Text('Eliminar'),
                                onPressed: () => _deleteReport(report.id!),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
