import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/research_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import '../theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final researchService = Provider.of<ResearchService>(context);
    final messages = researchService.messages;

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: AppTheme.copilotSurface,

      // ------------------------------------------------------------
      // HEADER
      // ------------------------------------------------------------
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.copilotBlueLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppTheme.copilotBlue,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IntelliResearch AI',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.copilotDark,
                      ),
                ),
                Text(
                  'Multi‑Agent Research Assistant',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.copilotGrey,
                      ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.copilotGrey),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Chat?'),
                    content: const Text('This will delete all messages.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          researchService.clearMessages();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),

      // ------------------------------------------------------------
      // BODY
      // ------------------------------------------------------------
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return MessageBubble(message: messages[index]);
                    },
                  ),
          ),

          // ------------------------------------------------------------
          // INPUT BAR
          // ------------------------------------------------------------
          ChatInput(
            onSubmit: (text) {
              researchService.startResearch(text);
            },
            enabled: !researchService.isProcessing,
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // EMPTY STATE
  // ------------------------------------------------------------
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppTheme.copilotBlueLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 80,
                color: AppTheme.copilotBlue,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Welcome to IntelliResearch AI',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.copilotDark,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Ask me to research any topic. I’ll deploy multiple AI agents to gather insights from the web, academic papers, and trusted sources.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.copilotGrey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            _exampleCard(context, '🌍 Climate Change',
                'Latest developments in climate science'),
            const SizedBox(height: 12),
            _exampleCard(context, '🤖 AI Ethics',
                'Current debates on AI safety and regulation'),
            const SizedBox(height: 12),
            _exampleCard(context, '🚀 Space Exploration',
                'Recent missions and discoveries'),
          ],
        ),
      ),
    );
  }

  Widget _exampleCard(
      BuildContext context, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.copilotDark,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.copilotGrey,
                      ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios,
              size: 16, color: AppTheme.copilotBlue),
        ],
      ),
    );
  }
}
