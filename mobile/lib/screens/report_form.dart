import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/report.dart';
import '../services/database_service.dart';

class ReportForm extends StatefulWidget {
  const ReportForm({Key? key}) : super(key: key);

  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  final _formKey = GlobalKey<FormState>();
  final _dbService = DatabaseService.instance;
  final _imagePicker = ImagePicker();
  
  DateTime _selectedDate = DateTime.now();
  String? _photoPath;
  final TextEditingController _workerNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedArea = 'Planta';
  String _selectedType = 'Acto inseguro';

  final List<String> _areas = ['Planta', 'Taller', 'Oficina', 'Almacén'];
  final List<String> _types = [
    'Acto inseguro',
    'Condición insegura',
    'Incidente leve',
    'Incidente grave'
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _photoPath = image.path;
      });
    }
  }

  Future<void> _pickPhoto() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _photoPath = image.path;
      });
    }
  }

  Future<void> _saveReport() async {
    if (_formKey.currentState!.validate()) {
      try {
        final report = Report(
          date: _selectedDate.toIso8601String().split('T')[0],
          workerName: _workerNameController.text,
          area: _selectedArea,
          incidentType: _selectedType,
          description: _descriptionController.text,
          photoPath: _photoPath,
        );

        await _dbService.createReport(report);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte guardado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar el reporte'),
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
        title: const Text('Nuevo Reporte'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date Selection
              ListTile(
                title: Text(
                  'Fecha: ${_selectedDate.toIso8601String().split('T')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),

              // Worker Name
              TextFormField(
                controller: _workerNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Trabajador',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Area Dropdown
              DropdownButtonFormField<String>(
                value: _selectedArea,
                decoration: const InputDecoration(
                  labelText: 'Zona',
                  border: OutlineInputBorder(),
                ),
                items: _areas.map((String area) {
                  return DropdownMenuItem(
                    value: area,
                    child: Text(area),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedArea = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Incident Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items: _types.map((String type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Photo Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Tomar Foto'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galería'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Photo Preview
              if (_photoPath != null) ...[
                Image.file(
                  File(_photoPath!),
                  height: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 16),
              ],

              // Save Button
              ElevatedButton(
                onPressed: _saveReport,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  'Guardar Reporte',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _workerNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
