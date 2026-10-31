import 'package:flutter_test/flutter_test.dart';
void main() {
  group('Anti-Double-Billing Algorithm Tests', () {
    test('Excludes already-billed time entry IDs and only captures unbilled sessions', () {
      final pastInvoicesBilledIds = [
        ['t_entry_1', 't_entry_2'],
        ['t_entry_3'],
      ];
      final alreadyBilledSet = pastInvoicesBilledIds
          .expand((ids) => ids)
          .toSet();
      final candidateEntries = [
        {'id': 't_entry_1', 'isCompleted': true, 'minutes': 60}, 
        {'id': 't_entry_2', 'isCompleted': true, 'minutes': 30}, 
        {'id': 't_entry_4', 'isCompleted': true, 'minutes': 90}, 
        {'id': 't_entry_5', 'isCompleted': false, 'minutes': 15}, 
      ];
      final unbilledSessions = candidateEntries.where((entry) {
        final isCompleted = entry['isCompleted'] as bool;
        final id = entry['id'] as String;
        return isCompleted && !alreadyBilledSet.contains(id);
      }).toList();
      expect(unbilledSessions.length, 1);
      expect(unbilledSessions.first['id'], 't_entry_4');
      final hours = (unbilledSessions.first['minutes'] as int) / 60.0; 
      const rateInCents = 5000;
      final totalCents = (hours * rateInCents).round();
      expect(totalCents, 7500); 
    });
  });
}