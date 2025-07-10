import 'package:flutter/material.dart';
import 'report_form.dart';
import 'reports_list.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';

class HomePage extends StatelessWidget {
  final DatabaseService _dbService = DatabaseService.instance;
  final ApiService _apiService = ApiService();

  HomePage({Key? key}) : super(key: key);

  Future<void> _syncReports(BuildContext context) async {
    try {
      final reports = await _dbService.getUnsyncedReports();
      int successCount = 0;

      for (var report in reports) {
        final success = await _apiService.syncReport(report);
        if (success) {
          await _dbService.markAsSynced(report.id!);
          successCount++;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sincronizados $successCount de ${reports.length} reportes'),
          backgroundColor: successCount > 0 ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al sincronizar reportes'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SIDERPERU Incidentes'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildButton(
              context,
              'Nuevo Reporte',
              Icons.add_circle_outline,
              Colors.blue,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportForm()),
              ),
            ),
            const SizedBox(height: 16),
            _buildButton(
              context,
              'Ver Reportes',
              Icons.list_alt,
              Colors.green,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportsList()),
              ),
            ),
            const SizedBox(height: 16),
            _buildButton(
              context,
              'Sincronizar con Servidor',
              Icons.sync,
              Colors.orange,
              () => _syncReports(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, IconData icon,
      Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
