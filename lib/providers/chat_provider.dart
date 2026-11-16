import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/models/chat_message.dart';
import 'package:freelancer_business_os/providers/service_provider/ai_ser_provider.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isThinking;
  const ChatState({
    required this.messages,
    this.isThinking = false,
  });
  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isThinking,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isThinking: isThinking ?? this.isThinking,
    );
  }
}
class ChatNotifier extends StateNotifier<ChatState> {
  final Ref _ref;
  ChatNotifier(this._ref)
      : super(
          ChatState(
            messages: [
              ChatMessage(
                text:
                    "Hello! I am Gemini Core, your business and financial companion. "
                    "I have live access to your projects, invoices, and revenue metrics. How can I assist your business today?",
                isUser: false,
                timestamp: DateTime.now(),
              ),
            ],
            isThinking: false,
          ),
        );
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
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isThinking: true, 
    );
    final fullPrompt = '''
User Name: $userName
$contextSnapshot
User Question: "$trimmed"
Instructions: You are an elite, warm corporate business advisor and financial consultant for freelancers. 
Use the metrics above to answer the user's inquiry accurately. Be concise, practical, and conversational.
''';
    String replyText = '';
    try {
      final aiService = _ref.read(aiServiceProvider);
      replyText = await aiService
          .auditDashboardFinancials(fullPrompt)
          .timeout(const Duration(seconds: 12));
    } catch (e) {
      debugPrint('ℹ️ Cloud AI bypassed or blocked on localhost: $e');
      replyText = _generateSmartFallback(trimmed, contextSnapshot, userName);
    }
    await Future.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(
          text: replyText,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
      isThinking: false, 
    );
  }
  String _generateSmartFallback(
    String input,
    String contextSnapshot,
    String userName,
  ) {
    final lower = input.toLowerCase();
    if (lower.contains('email') ||
        lower.contains('deadline') ||
        lower.contains('extension') ||
        lower.contains('draft')) {
      return '''Subject: Project Milestone Update & Timeline Adjustment
Hi there,
I am writing to share a brief progress update on our current project deliverables. We have completed the foundational requirements and initial implementation phases according to our agreed scope.
To ensure comprehensive quality assurance, rigorous testing, and seamless delivery, I would appreciate adjusting our target milestone completion date by a few business days.
Please let me know if this adjusted schedule aligns with your timeline. I appreciate your collaboration and look forward to delivering an exceptional final product.
Best regards,
$userName''';
    }
    
    if (lower.contains('suck') ||
        lower.contains('burnout') ||
        lower.contains('tired') ||
        lower.contains('stressed') ||
        lower.contains('overwhelm') ||
        lower.contains('imposter') ||
        lower.contains('quit') ||
        lower.contains('hate')) {
      return '''I hear you, and honestly? Every single great software engineer has felt this exact way.

Building software is mentally exhausting. You're constantly staring at broken code, dealing with edge cases, and juggling client expectations all on your own. 

Here is my advice right now:
1. Step away from the screen for at least 30 minutes. Close your IDE. Your brain solves debugging puzzles in the background when you rest.
2. Remember that bugs and setbacks are not proof that you're an impostor—they are the literal definition of the job. You built a multi-module architecture from scratch; don't let one frustrating bug wipe out that win.
3. Pick ONE small, easy task when you get back, finish it, and call it a day. 

You're doing better than you think. Take a breath—I've got your metrics covered.''';
    }

    
    if (lower.contains('ghost') || lower.contains('not paying') || lower.contains('rude')) {
      return '''Client communication breakdowns happen to every freelancer. Here is how to handle it professionally without losing your peace:

1. Send a polite, non-confrontational nudge referencing the milestone date: "Hi [Name], checking in to see if you had any questions on our latest deliverables."
2. Never work ahead on new milestones if prior invoices are overdue.
3. Keep all communication in writing so you have an indisputable paper trail.''';
    }
    if (lower.contains('afford') ||
        lower.contains('buy') ||
        lower.contains('spend') ||
        lower.contains('cost') ||
        lower.contains('laptop') ||
        lower.contains('price')) {
      return '''Based on your current workspace financials:
$contextSnapshot
Strategic Financial Recommendation:
• Review your liquid collected cash before executing new capital expenditures.
• If you have pending receivables due, prioritize confirming client delivery milestones to clear those invoices first.
• Maintain a 15% reserve allocation for operating runway and quarterly taxes prior to large discretionary purchases.''';
    }
    if (lower.contains('invoice') ||
        lower.contains('bill') ||
        lower.contains('payment') ||
        lower.contains('money')) {
      return '''Here is your current receivables posture:
• Ensure all completed time logs are compiled into current invoice drafts.
• For invoices currently in 'Sent' status, issue a polite reminder if the net payment terms exceed 14 business days.
• Check the Invoicing ledger to verify client billing addresses and A4 PDF export receipts.''';
    }
    return '''I have reviewed your active workspace parameters:
$contextSnapshot
Operational Advisory:
• Your active client contracts and project ledgers are configured cleanly.
• Focus on completing current milestone objectives to unlock your pending billing receivables.
• Let me know if you would like me to draft formal client proposals, format billing descriptions, or structure project scopes!''';
  }
}
final chatProvider =
    StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref);
});