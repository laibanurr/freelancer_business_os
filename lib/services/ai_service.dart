import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';

class AiService {
  
  final GenerativeModel _model =
      FirebaseAI.googleAI().generativeModel(model: 'gemini-flash-latest');

  
  final GenerativeModel _jsonModel = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-flash-latest',
    generationConfig: GenerationConfig(responseMimeType: 'application/json'),
  );

  
  
  
  Future<Map<String, dynamic>> parseClientInformation(String rawInputText) async {
    if (rawInputText.trim().isEmpty) return {};

    final instructions = '''
    Extract client contact details from the text below.
    Return JSON with exactly these keys: name, company, email, phone.
    Use an empty string for anything not in the text. Never invent values.
    ''';

    final content = [
      Content.multi([
        TextPart(instructions),
        TextPart('Text to analyze: "$rawInputText"'),
      ])
    ];

    final response = await _jsonModel.generateContent(content);
    var text = (response.text ?? '').trim();
    if (text.isEmpty) throw Exception('Gemini returned an empty response.');

    
    text = text
        .replaceAll(RegExp(r'^```(?:json)?\s*'), '')
        .replaceAll(RegExp(r'\s*```\$'), '')
        .trim();

    return jsonDecode(text) as Map<String, dynamic>;
  }

  
  
  
  Future<String> generateProjectScope(
    String roughNotes, {
    String? projectName,
    String? hourlyRate,
  }) async {
    if (roughNotes.trim().isEmpty) return '';

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

    
    
    final content = [
      Content.multi([
        TextPart(instructions),
        TextPart('Project name: ${projectName ?? "not given"}\\nHourly rate: ${hourlyRate ?? "not given"}\\nNotes: $roughNotes'),
      ])
    ];

    final response = await _model.generateContent(content);
    final text = response.text;
    if (text == null || text.trim().isEmpty) {
      throw Exception('Gemini returned an empty scope.');
    }
    return text.trim();
  }

  
  
  
  Future<String> auditInvoiceSummary(String totalHoursBilled, String clientContext) async {
    final instructions = '''
    Write a short, professional description line for a client invoice.
    Maximum 2 sentences, plain text, no markdown. Do not invent work that is not
    mentioned.
    ''';

    final content = [
      Content.multi([
        TextPart(instructions),
        TextPart('Total hours billed: $totalHoursBilled hrs\\nClient / project context: $clientContext'),
      ])
    ];

    final response = await _model.generateContent(content);
    final text = response.text;
    if (text == null || text.trim().isEmpty) {
      throw Exception('Gemini returned an empty invoice summary.');
    }
    return text.trim();
  }

  
  
  
  Future<String> auditDashboardFinancials(String rawMetricsData) async {
    if (rawMetricsData.trim().isEmpty) return '';
    
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
        TextPart(rawMetricsData),
      ])
    ];
    
    final response = await _model.generateContent(content);
    final textOutput = response.text;
    if (textOutput == null) {
      throw Exception('Gemini returned an empty financial diagnostic statement string.');
    }
    return textOutput.trim();
  }
}
