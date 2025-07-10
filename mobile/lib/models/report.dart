class Report {
  int? id;
  String date;
  String workerName;
  String area;
  String incidentType;
  String description;
  String? photoPath;
  bool isSynced;

  Report({
    this.id,
    required this.date,
    required this.workerName,
    required this.area,
    required this.incidentType,
    required this.description,
    this.photoPath,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'workerName': workerName,
      'area': area,
      'incidentType': incidentType,
      'description': description,
      'photoPath': photoPath,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'],
      date: map['date'],
      workerName: map['workerName'],
      area: map['area'],
      incidentType: map['incidentType'],
      description: map['description'],
      photoPath: map['photoPath'],
      isSynced: map['isSynced'] == 1,
    );
  }

  // Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'workerName': workerName,
      'area': area,
      'incidentType': incidentType,
      'description': description,
      'photoBase64': photoPath, // This will need to be converted to base64
    };
  }
}
