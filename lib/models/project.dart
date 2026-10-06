import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String projectName;
  final String projectStatus;
  final int rateInCents;
  final DateTime startDate;
  final DateTime endDate;
  final String clientId;
  final String id;
 final String? projectDescription; 
  Project({
    required this.clientId,
    required this.endDate,
    required this.projectName,
    required this.projectStatus,
    required this.rateInCents,
    required this.startDate,
    required this.id,
    required this.projectDescription
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'rateInCents': rateInCents,
      'endDate': endDate,
      'startDate': startDate,
      'projectStatus': projectStatus,
      'projectName': projectName,
      'projectDescription' : projectDescription
    };
  }


  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      clientId: map['clientId'] as String,
      endDate: (map['endDate'] as Timestamp).toDate(),
      projectName: map['projectName'] as String,
      projectStatus: map['projectStatus'] as String,
      rateInCents: map['rateInCents'] as int,
      startDate: (map['startDate'] as Timestamp).toDate(),
      id: map['id'] as String,
      projectDescription: map['projectDescription'] != null ? map['projectDescription'] as String : 'Standard freelance project contract initialized.',

    );
  }
}
