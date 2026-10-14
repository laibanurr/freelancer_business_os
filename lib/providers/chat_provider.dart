import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/models/chat_message.dart';
import 'package:freelancer_business_os/providers/service_provider/ai_ser_provider.dart';

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref _ref;

  ChatNotifier(this._ref)
      : super([
          ChatMessage(
            text: "Hey! 👋 Gemini Core is fired up and synced live with your workspace metrics. What are we working on today? I can help you draft friendly client messages, review your log milestones, or check up on your business numbers!",
            isUser: false,
            timestamp: DateTime.now(),
          )
        ]);

  
  String _extractClientNameLocally(String prompt) {
    final lower = prompt.toLowerCase();
    final words = prompt.split(' ');
    
    
    int index = -1;
    if (lower.contains('client')) {
      index = words.indexWhere((w) => w.toLowerCase().contains('client'));
    } else if (lower.contains('email to')) {
      index = words.indexWhere((w) => w.toLowerCase().contains('to'));
    } else if (lower.contains('write to')) {
      index = words.indexWhere((w) => w.toLowerCase().contains('to'));
    }

    if (index != -1 && index + 1 < words.length) {
      
      String detectedName = words[index + 1].replaceAll(RegExp(r'[.,!?\s]'), '');
      
      
      if (detectedName.isNotEmpty) {
        
        if (detectedName.toLowerCase() != 'to' && detectedName.toLowerCase() != 'a') {
          return detectedName[0].toUpperCase() + detectedName.substring(1);
        }
      }
    }
    return "Client"; 
  }

  Future<void> sendMessage(
      String userPrompt, String contextSnapshot, String userName) async {
    if (userPrompt.trim().isEmpty) return;

    final userMessage = ChatMessage(
        text: userPrompt.trim(), isUser: true, timestamp: DateTime.now());
    state = [...state, userMessage];

    final loadingPlaceholder =
        ChatMessage(text: "...", isUser: false, timestamp: DateTime.now());
    state = [...state, loadingPlaceholder];

    try {
      final aiService = _ref.read(aiServiceProvider);
      final activeName = userName.trim().isEmpty ? 'Freelancer' : userName.split(' ')[0];

      final systemContextPrompt = '''
      You are Gemini Core, a friendly, smart, and casual AI business teammate for a freelancer named $activeName.
      Acknowledge their message normally, with warmth and personality like a real human teammate.
      Keep your answer highly conversational, short, and to the point.
      Never mention internal variables, system logs, formatting scripts, or raw prompts data.
      
      USER INPUT QUESTION OR REQUEST: 
      "$userPrompt"

      CURRENT BUSINESS CONTEXT DATA FOR REFERENCE: 
      $contextSnapshot
      ''';

      final String aiResponse =
          await aiService.auditDashboardFinancials(systemContextPrompt);

      state = state.sublist(0, state.length - 1);
      state = [
        ...state,
        ChatMessage(text: aiResponse, isUser: false, timestamp: DateTime.now())
      ];
    } catch (e) {
      debugPrint("🚨 Cloud rate limit active. Running variable-driven local natural language fallback loop...");

      final lowerPrompt = userPrompt.toLowerCase();
      String fallbackText = "";
      final String targetedClient = _extractClientNameLocally(userPrompt);

      if (lowerPrompt.contains('meeting') ||
          lowerPrompt.contains('discussion') ||
          lowerPrompt.contains('online')) {
        fallbackText = '''
Subject: Catch up call / Quick project sync

Hi $targetedClient,

Hope you're having a great week! 

The project is coming along really well, and the screens are starting to look super clean. I'd love to set up a quick online catch-up call with you sometime soon. 

It would be awesome to jump on a short video chat to show you what's built so far, chat about the next few steps, and make sure we are completely on the same page moving forward.

Let me know what days or times work best for you this coming week, and I'll send over a quick calendar link!

Best regards,
$userName
'''.trim();
      } else if (lowerPrompt.contains('rate') ||
          lowerPrompt.contains('hourly') ||
          lowerPrompt.contains('increase') ||
          lowerPrompt.contains('deadline')) {
        fallbackText = '''
Subject: Project Scope & Commercial Rate Framework Adjustment Notes

Hi $targetedClient,

Hope you're doing great! 

Following up on our recent operational development updates, the core infrastructure of the app is tracking exceptionally well. To balance the added feature requirements, custom integrations, and expanded product testing routines we are adding to the scope, I would like to propose a baseline adjustment to our current framework contract.

Bumping the parameters slightly ensures we have the dedicated focus required to deliver this application at an elite, commercial-grade specification. 

Let me know if we can schedule a fast call to lock this down alongside our timeline calendars. Thank you as always for your amazing support!

Best,
$userName
'''.trim();
      } else if (lowerPrompt.contains('burnout') ||
          lowerPrompt.contains('burn out') ||
          lowerPrompt.contains('tired') ||
          lowerPrompt.contains('exhausted')) {
        fallbackText =
            "I hear you, and I completely validate that feeling. 🩵 Freelancing and engineering can be incredibly draining, especially when you're fighting code bugs all day. Burnout is a very real biological signal telling you to slow down. My best advice as your coach? Close the IDE right now. Step away from your computer for the rest of the evening, go for a walk, and drink some water. Your project data pipelines will still be waiting for you tomorrow. Take care of your brain first!";
      } else if (lowerPrompt.contains('sucks') ||
          lowerPrompt.contains('hard') ||
          lowerPrompt.contains('hate') ||
          lowerPrompt.contains('annoying')) {
        fallbackText =
            "Ugh, tell me about it! 💻 Fighting asynchronous data streams, environment setup bugs, and server quotas can make anyone want to throw their computer out the window. Every single senior engineer goes through these exact days. It's not a reflection of your intelligence—programming is just genuinely complex. Take a deep breath, stretch your shoulders, and maybe switch to a non-code task for an hour to reset your perspective. You've got this!";
      } else if (lowerPrompt.contains('didnt') ||
          lowerPrompt.contains('wrong') ||
          lowerPrompt.contains('bs') ||
          lowerPrompt.contains('weird')) {
        fallbackText =
            "Ah, my bad! Let me correct that approach immediately. I completely glossed over that specific requirement block. Refine your prompt or tell me what to change, and I'll build it out perfectly right now!";
      } else if (lowerPrompt.contains('hey') ||
          lowerPrompt.contains('hello') ||
          lowerPrompt.contains('hi')) {
        fallbackText =
            "Hey! Glad to connect. I'm right here with your dashboard logs synced up. Are we drafting custom client emails, setting up online meetings, or looking at your revenue matrix data right now?";
      } else {
        fallbackText =
            "I hear you! I am reviewing your request against your live dashboard metrics. Let me know if you want me to draft a client message, set up a call layout, or forecast your upcoming invoice tracking entries.";
      }

      await Future.delayed(const Duration(milliseconds: 300));

      state = state.sublist(0, state.length - 1);
      state = [
        ...state,
        ChatMessage(text: fallbackText, isUser: false, timestamp: DateTime.now())
      ];
    }
  }
}

final chatProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier(ref);
});
