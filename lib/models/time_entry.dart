import 'package:cloud_firestore/cloud_firestore.dart';

class TimeEntry {
  final String projectId;
  final String id;
  final DateTime startTime;
  final DateTime? endTime;

  TimeEntry({
    required this.startTime,
    this.endTime,
    required this.id,
    required this.projectId,
  });
  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'id': id,
      'projectId': projectId,
    };
  }

  factory TimeEntry.fromMap(Map<String, dynamic> map) {
    return TimeEntry(
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: map['endTime'] != null ? 
      (map['endTime'] as Timestamp).toDate(): null ,
      id: map['id'] as String,
      projectId: map['projectId'] as String,
    );
  }
}
