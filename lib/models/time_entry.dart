import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
class TimeEntry {
  final String id;
  final String projectId;
  final DateTime startTime;
  final DateTime? endTime;
  const TimeEntry({
    required this.id,
    required this.projectId,
    required this.startTime,
    this.endTime,
  });
  TimeEntry copyWith({
    String? id,
    String? projectId,
    DateTime? startTime,
    DateTime? endTime,
    bool clearEndTime = false,
  }) {
    return TimeEntry(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      startTime: startTime ?? this.startTime,
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
    };
  }
  factory TimeEntry.fromMap(Map<String, dynamic> map) {
    final rawId = map['id'];
    final rawProjectId = map['projectId'];
    DateTime parseDate(dynamic value, {required DateTime fallback}) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value) ?? fallback;
      return fallback;
    }
    return TimeEntry(
      id: (rawId as String?) ?? '',
      projectId: (rawProjectId as String?) ?? '',
      startTime: parseDate(map['startTime'], fallback: DateTime.now()),
      endTime: map['endTime'] != null
          ? parseDate(map['endTime'], fallback: DateTime.now())
          : null, 
    );
  }
  String toJson() => json.encode(toMap());
  factory TimeEntry.fromJson(String source) =>
      TimeEntry.fromMap(json.decode(source) as Map<String, dynamic>);
  @override
  String toString() {
    return 'TimeEntry(id: $id, projectId: $projectId, start: $startTime, end: $endTime)';
  }
  @override
  bool operator ==(covariant TimeEntry other) {
    if (identical(this, other)) return true;
    return other.id == id &&
        other.projectId == projectId &&
        other.startTime == startTime &&
        other.endTime == endTime;
  }
  @override
  int get hashCode {
    return id.hashCode ^
        projectId.hashCode ^
        startTime.hashCode ^
        endTime.hashCode;
  }
}