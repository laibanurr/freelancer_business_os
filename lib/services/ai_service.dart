import 'dart:async';
import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
class AiService {
  final GenerativeModel _model;
  final GenerativeModel _jsonModel;
  static const Duration _requestTimeout = Duration(seconds: 15);
  AiService({
    GenerativeModel? model,
    GenerativeModel? jsonModel,
  })  : _model = model ??
            FirebaseAI.googleAI().generativeModel(
              model: 'gemini-flash-latest',
            ),
        _jsonModel = jsonModel ??
            FirebaseAI.googleAI().generativeModel(
              model: 'gemini-flash-latest',
              generationConfig: GenerationConfig(
                responseMimeType: 'application/json',
                responseSchema: Schema.object(
                  properties: {
                    'name': Schema.string(),
                    'company': Schema.string(),
                    'email': Schema.string(),
                    'phone': Schema.string(),
                  },
                ),
              ),
            );
  Future<Map<String, dynamic>> parseClientInformation(String rawInputText) async {
    final trimmedInput = rawInputText.trim();
    if (trimmedInput.isEmpty) return {};
    final instructions = '''
Extract client contact details from the text below.
Return JSON with exactly these keys: name, company, email, phone.
Use an empty string for anything not in the text. Never invent values.
''';
    final content = [
      Content.multi([
        TextPart(instructions),
        TextPart('Text to analyze: "$trimmedInput"'),
      ])
    ];
    try {
      final response = await _jsonModel
          .generateContent(content)
          .timeout(_requestTimeout);
      var text = (response.text ?? '').trim();
      if (text.isEmpty) {
        throw const FormatException('Gemini returned an empty response.');
      }
      text = text
          .replaceAll(RegExp(r'^```(?:json)?\s*'), '')
          .replaceAll(RegExp(r'\s*```$'), '') 
          .trim();
      final decoded = jsonDecode(text);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {};
    } on TimeoutException {
      throw Exception('AI request timed out. Please check your internet connection.');
    } catch (e) {
      rethrow;
    }
  }
  Future<String> generateProjectScope(
    String roughNotes, {
    String? projectName,
    String? hourlyRate,
  }) async {
    final trimmedNotes = roughNotes.trim();
    if (trimmedNotes.isEmpty) return '';
    final instructions = '''
You are helping a freelancer write a short scope of work to send to a client.
Use ONLY the information in the notes below. Do not invent technologies,
features, deadlines or prices that are not mentioned.
If something important is missing, list it under "To confirm with client".
Write plain text (no markdown, no # or * symbols), under 150 words,
with exactly these headings:
Summary
What's included
To confirm with client
Payment
''';
    final contextInfo = 'Project name: ${projectName ?? "not given"}\n'
        'Hourly rate: ${hourlyRate ?? "not given"}\n'
        'Notes: $trimmedNotes';
    final content = [
      Content.multi([
        TextPart(instructions),
        TextPart(contextInfo),
      ])
    ];
    final response = await _model
        .generateContent(content)
        .timeout(_requestTimeout);
    final text = response.text;
    if (text == null || text.trim().isEmpty) {
      throw Exception('Gemini returned an empty scope.');
    }
    return text.trim();
  }
  Future<String> auditInvoiceSummary(
    String totalHoursBilled,
    String clientContext,
  ) async {
    final instructions = '''
Write a short, professional description line for a client invoice.
Maximum 2 sentences, plain text, no markdown. Do not invent work that is not
mentioned.
''';
    final content = [
      Content.multi([
        TextPart(instructions),
        TextPart(
          'Total hours billed: $totalHoursBilled hrs\nClient / project context: $clientContext',
        ),
      ])
    ];
    final response = await _model
        .generateContent(content)
        .timeout(_requestTimeout);
    final text = response.text;
    if (text == null || text.trim().isEmpty) {
      throw Exception('Gemini returned an empty invoice summary.');
    }
    return text.trim();
  }
  Future<String> auditDashboardFinancials(String rawMetricsData) async {
    final trimmedMetrics = rawMetricsData.trim();
    if (trimmedMetrics.isEmpty) return '';
    final instructions = '''
You are an elite corporate financial operations intelligence analyst advisor and business companion.
Analyze the instructions, inquiries, or raw metrics provided below and assist the user conversationally.
CRITICAL QUALITY CONTROL RULES: 
- Answer cleanly, warmly, and to the point.
- Do NOT write or wrap the text blocks in Markdown ticks code structures (like ```).
- Provide raw text output layout formats natively.
''';
    final content = [
      Content.multi([
        TextPart(instructions),
        TextPart(trimmedMetrics),
      ])
    ];
    final response = await _model
        .generateContent(content)
        .timeout(_requestTimeout);
    final textOutput = response.text;
    if (textOutput == null || textOutput.trim().isEmpty) {
      throw Exception('Gemini returned an empty financial diagnostic statement string.');
    }
    return textOutput.trim();
  }
}