import 'package:cloud_firestore/cloud_firestore.dart';

class Invoice {
  final String id;
  final String projectId;
  final List<String> timeEntryIds;
  final InvoiceStatus status;
  final DateTime createdDate;
  final int totalAmountInCents;
  Invoice({
    required this.id,
    required this.projectId,
    required this.status,
    required this.timeEntryIds,
    required this.createdDate,
    required this.totalAmountInCents
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'timeEntryIds': timeEntryIds,
      'invoiceStatus': status.name,
      'totalAmountInCents' : totalAmountInCents,
      'createdDate' : createdDate,
    };
    
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      status: InvoiceStatus.values.byName(map['invoiceStatus'] as String),
      timeEntryIds: List<String>.from(map['timeEntryIds']),
      totalAmountInCents:  map['totalAmountInCents'] as int,
       createdDate:  (map['createdDate'] as Timestamp).toDate(),
    );
  }
}

enum InvoiceStatus { draft, sent, paid, overdue }
