// lib/models/report_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportType { fire, flood, earthquake, landslide, medical, other }
enum ReportStatus { newReport, acknowledged, inProgress, resolved, rejected }

class ReportModel {
  final String id; // uuid or firestore doc id
  final String reporterName;
  final String reporterPhone;
  final ReportType type;
  final String description;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final int severity; // 1-5
  final List<String> imageUrls; // uploaded to storage, store urls
  final ReportStatus status;
  final String assignedTo; // volunteer id or null
  final Map<String, dynamic>? sensorData; // optional IoT readings

  ReportModel({
    required this.id,
    required this.reporterName,
    required this.reporterPhone,
    required this.type,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.severity = 3,
    List<String>? imageUrls,
    this.status = ReportStatus.newReport,
    this.assignedTo = '',
    this.sensorData,
  }) : imageUrls = imageUrls ?? [];

  // convenience getters
  String get latLngString => '$latitude,$longitude';

  // Convert enum <-> string
  static String _typeToString(ReportType t) => t.toString().split('.').last;
  static ReportType _typeFromString(String s) =>
      ReportType.values.firstWhere((e) => e.toString().split('.').last == s,
          orElse: () => ReportType.other);

  static String _statusToString(ReportStatus s) => s.toString().split('.').last;
  static ReportStatus _statusFromString(String s) =>
      ReportStatus.values.firstWhere((e) => e.toString().split('.').last == s,
          orElse: () => ReportStatus.newReport);

  // JSON serialization (for local storage or sending to REST)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporterName': reporterName,
      'reporterPhone': reporterPhone,
      'type': _typeToString(type),
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'severity': severity,
      'imageUrls': imageUrls,
      'status': _statusToString(status),
      'assignedTo': assignedTo,
      'sensorData': sensorData,
    };
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: (json['id'] ?? '') as String,
      reporterName: (json['reporterName'] ?? '') as String,
      reporterPhone: (json['reporterPhone'] ?? '') as String,
      type: _typeFromString((json['type'] ?? 'other') as String),
      description: (json['description'] ?? '') as String,
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
        timestamp: (json['timestamp'] is String)
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      severity: (json['severity'] ?? 3) as int,
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      status: _statusFromString((json['status'] ?? 'newReport') as String),
      assignedTo: (json['assignedTo'] ?? '') as String,
      sensorData: (json['sensorData'] as Map<String, dynamic>?),
    );
  }

  // Firestore helpers
  Map<String, dynamic> toFirestore() {
    return {
      'reporterName': reporterName,
      'reporterPhone': reporterPhone,
      'type': _typeToString(type),
      'description': description,
      'location': GeoPoint(latitude, longitude),
      'timestamp': Timestamp.fromDate(timestamp),
      'severity': severity,
      'imageUrls': imageUrls,
      'status': _statusToString(status),
      'assignedTo': assignedTo,
      'sensorData': sensorData ?? {},
    };
  }

  factory ReportModel.fromFirestore(String id, Map<String, dynamic> data) {
    final geo = data['location'] as GeoPoint?;
    return ReportModel(
      id: id,
      reporterName: (data['reporterName'] ?? '') as String,
      reporterPhone: (data['reporterPhone'] ?? '') as String,
      type: _typeFromString((data['type'] ?? 'other') as String),
      description: (data['description'] ?? '') as String,
      latitude: (geo?.latitude ?? 0.0),
      longitude: (geo?.longitude ?? 0.0),
        timestamp: (data['timestamp'] is Timestamp)
          ? (data['timestamp'] as Timestamp).toDate()
          : (data['timestamp'] is String
            ? (DateTime.tryParse(data['timestamp'] as String) ?? DateTime.now())
            : DateTime.now()),
      severity: (data['severity'] ?? 3) as int,
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      status: _statusFromString((data['status'] ?? 'newReport') as String),
      assignedTo: (data['assignedTo'] ?? '') as String,
      sensorData: (data['sensorData'] as Map<String, dynamic>?),
    );
  }

  // simple validation
  List<String> validate() {
    final errors = <String>[];
    if (reporterName.trim().isEmpty) errors.add('Reporter name is required.');
    if (reporterPhone.trim().isEmpty) errors.add('Reporter phone is required.');
    if (description.trim().length < 10) errors.add('Description should be at least 10 characters.');
    if (latitude == 0 && longitude == 0) errors.add('Valid location is required.');
    if (severity < 1 || severity > 5) errors.add('Severity must be between 1 and 5.');
    return errors;
  }

  ReportModel copyWith({
    String? id,
    String? reporterName,
    String? reporterPhone,
    ReportType? type,
    String? description,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    int? severity,
    List<String>? imageUrls,
    ReportStatus? status,
    String? assignedTo,
    Map<String, dynamic>? sensorData,
  }) {
    return ReportModel(
      id: id ?? this.id,
      reporterName: reporterName ?? this.reporterName,
      reporterPhone: reporterPhone ?? this.reporterPhone,
      type: type ?? this.type,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      severity: severity ?? this.severity,
      imageUrls: imageUrls ?? this.imageUrls,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      sensorData: sensorData ?? this.sensorData,
    );
  }
}
