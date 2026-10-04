import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';

class AiService {
  final GenerativeModel _model =
      FirebaseAI.googleAI().generativeModel(model: 'gemini-flash-latest',);

  Future<Map<String, dynamic>> parseClientInformation(
      String rawInputText) async {
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
        TextPart('Raw Input Text to analyze: "$rawInputText"'),
      ])
    ];

    final response = await _model.generateContent(content);
    final cleanTextResult = response.text;

    if (cleanTextResult == null) {
      throw Exception('Gemini returned an empty response.');
    }

    return jsonDecode(cleanTextResult.trim()) as Map<String, dynamic>;
  }
}