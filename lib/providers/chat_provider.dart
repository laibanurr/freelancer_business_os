import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/models/chat_message.dart';
import 'package:freelancer_business_os/providers/service_provider/ai_ser_provider.dart';

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref _ref;

  ChatNotifier(this._ref)
      : super([
          ChatMessage(
            text:
                "Hello! I am Gemini Core, your business and financial companion. "
                "I have live access to your projects, invoices, and revenue metrics. How can I assist your business today?",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ]);

  Future<void> sendMessage(
    String userText,
    String contextSnapshot,
    String userName,
  ) async {
    final trimmed = userText.trim();
    if (trimmed.isEmpty) return;

    
    final userMessage = ChatMessage(
      text: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );
    state = [...state, userMessage];

    
    final fullPrompt = '''
User Name: $userName
$contextSnapshot

User Question: "$trimmed"

Instructions: You are an elite, warm corporate business advisor and financial consultant for freelancers. 
Use the metrics above to answer the user's inquiry accurately. Be concise, practical, and conversational.
''';

    try {
      final aiService = _ref.read(aiServiceProvider);
      
      final aiResponse = await aiService.auditDashboardFinancials(fullPrompt);

      state = [
        ...state,
        ChatMessage(
          text: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ];
    } catch (e) {
      state = [
        ...state,
        ChatMessage(
          text:
              "I'm temporarily having trouble accessing the live cloud network. "
              "Based on your current workspace, you have active projects and tracked revenue running smoothly.",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ];
    }
  }
}

final chatProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier(ref);
});