import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
class AiService {
  final GenerativeModel _model =
      FirebaseAI.googleAI().generativeModel(model: 'gemini-flash-latest');
  Future<Map<String, dynamic>> parseClientInformation(String rawInputText) async {
    if (rawInputText.trim().isEmpty) return {};
    final instructions = '''
    You are an elite database formatting assistant. 
    Analyze the raw unscripted text input provided below and extract four specific data variables:
    1. Client Name (Person's name)
    2. Company Name (If not explicitly found, use 'Independent Freelancer')
    3. Email Address
    4. Phone Number (Include international country codes like + if present)
    CRITICAL RULE: You must respond ONLY with a clean, raw, valid JSON object match. Do not wrap the JSON in Markdown ticks or write any conversational text blocks.
    Follow this JSON keys structure exactly:
    {
      "name": "extracted name or empty string",
      "company": "extracted company or Independent Freelancer",
      "email": "extracted email or empty string",
      "phone": "extracted phone number or empty string"
    }
    ''';
    final content = [
      Content.multi([
        TextPart(instructions),
        TextPart('Raw Input Text to analyze: "\$rawInputText"'),
      ])
    ];
    final response = await _model.generateContent(content);
    final cleanTextResult = response.text;
    if (cleanTextResult == null) {
      throw Exception('Gemini returned an empty response.');
    }
    return jsonDecode(cleanTextResult.trim()) as Map<String, dynamic>;
  }
  Future<String> generateProjectScope(String roughRequirements) async {
    if (roughRequirements.trim().isEmpty) return '';
    final instructions = '''
    You are an elite corporate project operations advisor. 
    Analyze the rough, brief freelancer requirements notes provided below and draft a polished, premium, professional Project Scope and Proposal summary statement text outline.
    Structure your response text cleanly with these explicit textual section layout items:
    1. OBJECTIVE SUMMARY (A polished corporate executive description overview)
    2. TECHNICAL INFRASTRUCTURE (List out the frameworks, databases, or tools items discovered)
    3. TARGET DELIVERABLES (A punchy bullet point list tracking milestones safely)
    CRITICAL QUALITY CONTROL RULES: 
    - Maintain a highly elite, professional, corporate enterprise tone.
    - Do NOT write or wrap the text blocks in Markdown ticks code structures (like ```).
    - Provide raw, formatted text strings using clear new line spaces directly.
    ''';
    final content = [
      Content.multi([
        TextPart(instructions),
        TextPart('Rough project requirements notes to expand: "\$roughRequirements"'),
      ])
    ];
    final response = await _model.generateContent(content);
    final textOutput = response.text;
    if (textOutput == null) {
      throw Exception('Gemini returned an empty text string scope response.');
    }
    return textOutput.trim();
  }
  Future<String> auditInvoiceSummary(String totalHoursBilled, String clientContext) async {
    final instructions = '''
    You are an expert financial billing analyst. 
    Draft a concise, professional, corporate line-item description summary statement for a client statement.
    Summarize the billable engagement values using the total hours context provided below.
    Example output tone format structure:
    "Professional engineering consulting services rendered for project execution parameters ledger. Total billable volume calculates to [hours] operational hours allocated toward milestone integrations, system deployment protocols, and quality assurance check routines."
    CRITICAL RULE: Keep it under 3 sentences, highly corporate, and free of Markdown code symbols ticks.
    ''';
    final content = [
      Content.multi([
        TextPart(instructions),
        TextPart('Total hours billed value: "\$totalHoursBilled hrs". Target client identity context: "\$clientContext".'),
      ])
    ];
    final response = await _model.generateContent(content);
    final textOutput = response.text;
    if (textOutput == null) {
      throw Exception('Gemini returned an empty text billing response.');
    }
    return textOutput.trim();
  }
  Future<String> auditDashboardFinancials(String rawMetricsData) async {
    if (rawMetricsData.trim().isEmpty) return '';
    final instructions = '''
    You are an elite corporate financial operations intelligence analyst advisor.
    Analyze the raw accounting balances metrics provided below and draft a professional, premium diagnostic audit executive advisory statement report text outline.
    Structure your response text cleanly with these explicit textual section layout items:
    1. FINANCIAL HEALTH CLASSIFICATION (A high-level corporate stability assessment overview)
    2. QUARTERLY RISK & RESERVES FORECAST (Estimate standard income tax liability allocations or operational risk exposures)
    3. STRATEGIC BUSINESS ADVISORY SUMMARY (Provide three punchy, actionable operational tips)
    CRITICAL QUALITY CONTROL RULES: 
    - Maintain a highly elite, professional, corporate enterprise tone.
    - Do NOT write or wrap the text blocks in Markdown ticks code structures (like ```).
    - Provide raw, formatted text strings using clear new line spaces directly.
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
