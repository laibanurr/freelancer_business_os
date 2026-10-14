import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/models/invoice.dart';
import 'package:freelancer_business_os/providers/chat_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/invoice_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/project_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/user_profile_stream_provider.dart'; 

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatMessages = ref.watch(chatProvider);
    
    final invoices = ref.watch(invoicesStreamProvider).value ?? [];
    final projects = ref.watch(projectsStreamProvider).value ?? [];
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';
    final profileAsync = ref.watch(userProfileStreamProvider(uid));
    
    final currency = profileAsync.value?.selectedCurrencySymbol ?? '\$';
    
    // 🌟 EXTRACTION COMPLETE: Pull the dynamic freelancer name directly from your active document [riverpod.dev]
    final currentUserName = profileAsync.value?.fullName ?? 'Freelancer';

    final revenueCents = invoices.where((i) => i.status == InvoiceStatus.paid).fold<int>(0, (sum, i) => sum + i.totalAmountInCents);
    final outstandingCents = invoices.where((i) => i.status == InvoiceStatus.sent).fold<int>(0, (sum, i) => sum + i.totalAmountInCents);
    final activeCount = projects.where((p) => p.projectStatus == 'active').length;
    
    final contextSnapshot = "Freelance Workspace Metrics: Total Paid Revenue Collected: $currency${(revenueCents/100).toStringAsFixed(2)}, Outstanding Receivables Due: $currency${(outstandingCents/100).toStringAsFixed(2)}, Active Contracts Project count: $activeCount.";
    
    const backgroundColor = Color(0xFFF8FAFC);
    const primaryIndigo = Color(0xFF4F46E5);
    
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: primaryIndigo.withValues(alpha: 0.06), shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome, color: primaryIndigo, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Gemini Core Business AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1F2937), letterSpacing: -0.5)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text('Workspace Intelligence Matrix Connected', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: chatMessages.length,
                itemBuilder: (context, index) {
                  final msg = chatMessages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Align(
                      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: msg.isUser ? primaryIndigo : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20),
                            topRight: const Radius.circular(20),
                            bottomLeft: Radius.circular(msg.isUser ? 20 : 4),
                            bottomRight: Radius.circular(msg.isUser ? 4 : 20),
                          ),
                          border: msg.isUser ? null : Border.all(color: Colors.grey.withValues(alpha: 0.08)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.01),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Text(
                          msg.text,
                          style: TextStyle(
                            color: msg.isUser ? Colors.white : const Color(0xFF1F2937),
                            fontSize: 14,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0, bottom: 16.0), 
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, -2))
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (val) {
                          if (val.trim().isEmpty) return;
                          // 🛰️ PASSED THE LIVE USER NAME VARIABLE INJECTION [riverpod.dev]
                          ref.read(chatProvider.notifier).sendMessage(val, contextSnapshot, currentUserName);
                          _inputController.clear();
                        },
                        style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
                        decoration: const InputDecoration(
                          hintText: 'Ask Gemini Core anything about your business...',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        final text = _inputController.text;
                        if (text.trim().isEmpty) return;
                        // 🛰️ FIXED & STITCHED: Completed your cutoff gesture detector loop cleanly [riverpod.dev]
                        ref.read(chatProvider.notifier).sendMessage(text, contextSnapshot, currentUserName);
                        _inputController.clear();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(color: primaryIndigo, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
