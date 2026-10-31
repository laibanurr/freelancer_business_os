import 'package:flutter_test/flutter_test.dart';
Map<String, String> parseTextLocally(String input) {
  var email = '';
  var phone = '';
  final emailMatch = RegExp(
    r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
  ).firstMatch(input);
  if (emailMatch != null) {
    email = emailMatch.group(0) ?? '';
  }
  final phoneText = input.replaceAll(RegExp(r'[\s-]'), '');
  final phoneMatch = RegExp(r'\+?[0-9]{7,15}').firstMatch(phoneText);
  if (phoneMatch != null) {
    phone = phoneMatch.group(0) ?? '';
  }
  return {
    'email': email,
    'phone': phone,
  };
}
void main() {
  group('Offline Fallback Regex Parser Tests', () {
    test('Extracts valid email and phone from messy unstructured signature text', () {
      const messyInput = '''
        Hey there, looking forward to working with you!
        Best regards,
        Sarah Connor
        Email: sarah.connor@cyberdyne.org
        Mobile: +1 555-0199
      ''';
      final result = parseTextLocally(messyInput);
      expect(result['email'], 'sarah.connor@cyberdyne.org');
      expect(result['phone'], '+15550199');
    });
    test('Safely returns empty strings when no contact details are found', () {
      const emptyInput = 'Just some random notes with no contact data.';
      final result = parseTextLocally(emptyInput);
      expect(result['email'], '');
      expect(result['phone'], '');
    });
  });
}