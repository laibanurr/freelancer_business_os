import 'package:cloud_firestore/cloud_firestore.dart';

enum InvoiceStatus { draft, sent, paid, overdue }

class Invoice {
  final String id;
  final String projectId;
  final List<String> timeEntryIds;
  final InvoiceStatus status;
  final DateTime createdDate;
  final int totalAmountInCents;
  final String? invoiceDescription;

  Invoice({
    required this.id,
    required this.projectId,
    required this.status,
    required this.timeEntryIds,
    required this.createdDate,
    required this.totalAmountInCents,
    this.invoiceDescription,
  });

  // 1. Serializes model variables down into standard JSON structures for Cloud Firestore storage rows
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'timeEntryIds': timeEntryIds,
      'invoiceStatus': status.name,
      'totalAmountInCents': totalAmountInCents,
      // 🌟 FIXED: Convert raw DateTime down into an official cloud Timestamp object before upload!
      'createdDate': Timestamp.fromDate(createdDate), 
      'invoiceDescription': invoiceDescription, 
    };
  }

  // 2. Safely reconstructs incoming server map collections right back into Dart classes cleanly
  factory Invoice.fromMap(Map<String, dynamic> map) {
    // Fallback status checker prevents unmapped options from crashing the parsing engine
    final statusString = map['invoiceStatus'] as String? ?? 'draft';
    final parsedStatus = InvoiceStatus.values.firstWhere(
      (e) => e.name == statusString,
      orElse: () => InvoiceStatus.draft,
    );

    // Safely capture and unwrap Firestore Timestamps with a robust runtime calendar fallback
    final dateRaw = map['createdDate'];
    final parsedDate = dateRaw is Timestamp 
        ? dateRaw.toDate() 
        : DateTime.now();

    return Invoice(
      id: map['id'] as String? ?? '',
      projectId: map['projectId'] as String? ?? '',
      status: parsedStatus,
      timeEntryIds: List<String>.from(map['timeEntryIds'] ?? []),
      totalAmountInCents: map['totalAmountInCents'] as int? ?? 0,
      createdDate: parsedDate,
      //  THE BALANCED DATA SLOT: Cast as an optional String? to safely accept null records
      invoiceDescription: map['invoiceDescription'] as String?, 
    );
  }
}
