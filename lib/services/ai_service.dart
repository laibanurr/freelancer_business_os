import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  static const String _geminiApiKey =
      'AQ.Ab8RN6JQyz1nbJ72XwD5_8UposF0BXaAarNJqdrvnCLxtGACyA';
  final GenerativeModel _model;
  AiService()
      : _model =
            GenerativeModel(model: 'gemini 2.5 flash', apiKey: _geminiApiKey);
  Future<Map<String, dynamic>> parseClientInformation(
      String rawInputText) async {
    if (rawInputText.trim().isEmpty) return {};

    final prompt = '''
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

    Raw Input Text to analyze:
    "$rawInputText"
    ''';
    final response = await _model.generateContent([Content.text(prompt)]);
    final cleanTextResult = response.text;
    if (cleanTextResult == null) {
      throw Exception('Gemini returned an empty payload stream response.');
    }
    return jsonDecode(cleanTextResult.trim());
  }
}
