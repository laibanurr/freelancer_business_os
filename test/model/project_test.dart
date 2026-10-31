import 'package:flutter_test/flutter_test.dart';
import 'package:freelancer_business_os/models/project.dart';
void main() {
  group('Project Model & Financial Arithmetic Tests', () {
    test('Converts hourly rate in dollars to exact integer cents without rounding decay', () {
      const rateDollars = 50.25;
      final calculatedCents = (rateDollars * 100).round();
      expect(calculatedCents, 5025);
    });
    test('Project copyWith creates a new instance while preserving existing values', () {
      final originalProject = Project(
        id: 'proj_123',
        clientId: 'client_abc',
        projectName: 'Original Contract',
        projectStatus: 'active',
        rateInCents: 5000,
        startDate: DateTime(2026, 1, 1),
      );
      final updatedProject = originalProject.copyWith(
        projectName: 'Updated Contract Name',
        rateInCents: 6000,
      );
      expect(updatedProject.projectName, 'Updated Contract Name');
      expect(updatedProject.rateInCents, 6000);
      expect(updatedProject.id, 'proj_123');
      expect(updatedProject.clientId, 'client_abc');
      expect(updatedProject.projectStatus, 'active');
    });
    test('Project copyWith with clearEndDate explicitly sets endDate to null', () {
      final projectWithEnd = Project(
        id: 'proj_123',
        clientId: 'client_abc',
        projectName: 'Fixed Deadline Contract',
        projectStatus: 'active',
        rateInCents: 5000,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 6, 1),
      );
      final retainerProject = projectWithEnd.copyWith(clearEndDate: true);
      expect(retainerProject.endDate, isNull);
    });
  });
}