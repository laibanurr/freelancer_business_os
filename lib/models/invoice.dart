import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
enum InvoiceStatus { draft, sent, paid, overdue }
class Invoice {
  final String id;
  final String projectId;
  final List<String> timeEntryIds;
  final InvoiceStatus status;
  final DateTime createdDate;
  final int totalAmountInCents;
  final String? invoiceDescription;
  const Invoice({
    required this.id,
    required this.projectId,
    required this.status,
    required this.timeEntryIds,
    required this.createdDate,
    required this.totalAmountInCents,
    this.invoiceDescription,
  });
  Invoice copyWith({
    String? id,
    String? projectId,
    List<String>? timeEntryIds,
    InvoiceStatus? status,
    DateTime? createdDate,
    int? totalAmountInCents,
    String? invoiceDescription,
    bool clearDescription = false,
  }) {
    return Invoice(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      timeEntryIds: timeEntryIds ?? this.timeEntryIds,
      status: status ?? this.status,
      createdDate: createdDate ?? this.createdDate,
      totalAmountInCents: totalAmountInCents ?? this.totalAmountInCents,
      invoiceDescription: clearDescription
          ? null
          : (invoiceDescription ?? this.invoiceDescription),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'timeEntryIds': timeEntryIds,
      'invoiceStatus': status.name,
      'totalAmountInCents': totalAmountInCents,
      'createdDate': Timestamp.fromDate(createdDate),
      'invoiceDescription': invoiceDescription,
    };
  }
  factory Invoice.fromMap(Map<String, dynamic> map) {
    final statusString = map['invoiceStatus'] as String? ?? 'draft';
    final parsedStatus = InvoiceStatus.values.firstWhere(
      (e) => e.name == statusString,
      orElse: () => InvoiceStatus.draft,
    );
    final dateRaw = map['createdDate'];
    DateTime parsedDate;
    if (dateRaw is Timestamp) {
      parsedDate = dateRaw.toDate();
    } else if (dateRaw is DateTime) {
      parsedDate = dateRaw;
    } else if (dateRaw is String) {
      parsedDate = DateTime.tryParse(dateRaw) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }
    final rawIds = map['timeEntryIds'];
    List<String> parsedEntryIds = [];
    if (rawIds is List) {
      parsedEntryIds = rawIds.map((e) => e.toString()).toList();
    }
    return Invoice(
      id: map['id'] as String? ?? '',
      projectId: map['projectId'] as String? ?? '',
      status: parsedStatus,
      timeEntryIds: parsedEntryIds,
      totalAmountInCents: (map['totalAmountInCents'] as num?)?.toInt() ?? 0,
      createdDate: parsedDate,
      invoiceDescription: map['invoiceDescription'] as String?,
    );
  }
  String toJson() => json.encode(toMap());
  factory Invoice.fromJson(String source) =>
      Invoice.fromMap(json.decode(source) as Map<String, dynamic>);
  @override
  String toString() {
    return 'Invoice(id: $id, project: $projectId, status: ${status.name}, totalCents: $totalAmountInCents, items: ${timeEntryIds.length})';
  }
  @override
  bool operator ==(covariant Invoice other) {
    if (identical(this, other)) return true;
    return other.id == id &&
        other.projectId == projectId &&
        other.status == status &&
        other.createdDate == createdDate &&
        other.totalAmountInCents == totalAmountInCents &&
        other.invoiceDescription == invoiceDescription &&
        listEquals(other.timeEntryIds, timeEntryIds); 
  }
  @override
  int get hashCode {
    return id.hashCode ^
        projectId.hashCode ^
        status.hashCode ^
        createdDate.hashCode ^
        totalAmountInCents.hashCode ^
        invoiceDescription.hashCode ^
        Object.hashAll(timeEntryIds);
  }
}