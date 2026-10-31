import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
class Project {
  final String id;
  final String clientId;
  final String projectName;
  final String projectStatus;
  final int rateInCents;
  final DateTime startDate;
  final DateTime? endDate;
  final String? projectDescription;
  const Project({
    required this.id,
    required this.clientId,
    required this.projectName,
    required this.projectStatus,
    required this.rateInCents,
    required this.startDate,
    this.endDate,
    this.projectDescription,
  });
  Project copyWith({
    String? id,
    String? clientId,
    String? projectName,
    String? projectStatus,
    int? rateInCents,
    DateTime? startDate,
    DateTime? endDate,
    String? projectDescription,
    bool clearEndDate = false,
    bool clearProjectDescription = false,
  }) {
    return Project(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      projectName: projectName ?? this.projectName,
      projectStatus: projectStatus ?? this.projectStatus,
      rateInCents: rateInCents ?? this.rateInCents,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      projectDescription: clearProjectDescription
          ? null
          : (projectDescription ?? this.projectDescription),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'projectName': projectName,
      'projectStatus': projectStatus,
      'rateInCents': rateInCents,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'projectDescription': projectDescription,
    };
  }
  factory Project.fromMap(Map<String, dynamic> map) {
    final rawId = map['id'];
    if (rawId is! String || rawId.trim().isEmpty) {
      throw const FormatException('Project data is missing a valid ID.');
    }
    final rawClientId = map['clientId'];
    if (rawClientId is! String || rawClientId.trim().isEmpty) {
      throw const FormatException('Project data is missing a valid clientId.');
    }
    String readString(String key, {String fallback = ''}) {
      final value = map[key];
      return value is String ? value : fallback;
    }
    DateTime parseDate(dynamic value, {required DateTime fallback}) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value) ?? fallback;
      return fallback;
    }
    final name = readString('projectName').trim();
    final rawRate = map['rateInCents'];
    final rate = rawRate is num ? rawRate.toInt() : 0;
    final rawDescription = map['projectDescription'];
    return Project(
      id: rawId,
      clientId: rawClientId,
      projectName: name.isEmpty ? 'Untitled Project' : name,
      projectStatus: readString('projectStatus', fallback: 'active'),
      rateInCents: rate,
      startDate: parseDate(map['startDate'], fallback: DateTime.now()),
      endDate: map['endDate'] != null
          ? parseDate(map['endDate'], fallback: DateTime.now())
          : null,
      projectDescription: rawDescription is String ? rawDescription : null,
    );
  }
  String toJson() => json.encode(toMap());
  factory Project.fromJson(String source) =>
      Project.fromMap(json.decode(source) as Map<String, dynamic>);
  @override
  String toString() {
    return 'Project(id: $id, clientId: $clientId, projectName: $projectName, projectStatus: $projectStatus, rateInCents: $rateInCents, startDate: $startDate, endDate: $endDate, projectDescription: $projectDescription)';
  }
  @override
  bool operator ==(covariant Project other) {
    if (identical(this, other)) return true;
    return other.id == id &&
        other.clientId == clientId &&
        other.projectName == projectName &&
        other.projectStatus == projectStatus &&
        other.rateInCents == rateInCents &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.projectDescription == projectDescription;
  }
  @override
  int get hashCode {
    return id.hashCode ^
        clientId.hashCode ^
        projectName.hashCode ^
        projectStatus.hashCode ^
        rateInCents.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        projectDescription.hashCode;
  }
}