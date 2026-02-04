import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../models/message.dart';
import '../theme.dart';
import 'thinking_indicator.dart';

class MessageBubble extends StatefulWidget {
  final Message message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _expanded = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Auto-scroll to bottom when new logs arrive
    if (_expanded &&
        widget.message.logs.length != oldWidget.message.logs.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAvatar(isUser),
            const SizedBox(width: 11),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? const Color.fromARGB(255, 0, 0, 0) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _buildMessageContent(context, isUser),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                    if (!isUser &&
                        message.status == MessageStatus.complete) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: message.content),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Copied to clipboard'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.copy_rounded,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            _buildAvatar(isUser),
          ],
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // MESSAGE CONTENT (Markdown + Thinking + Logs)
  // ------------------------------------------------------------
  Widget _buildMessageContent(BuildContext context, bool isUser) {
    final message = widget.message;

    // USER MESSAGE
    if (isUser) {
      return Text(
        message.content,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          height: 1.4,
        ),
      );
    }

    // THINKING MESSAGE
    if (message.status == MessageStatus.researching) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ThinkingIndicator(),
          const SizedBox(height: 10),

          // Stats row
          if (message.logs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${message.logs.length} log entries',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // Toggle
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.copilotBlueLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _expanded ? Icons.visibility_off : Icons.visibility,
                    size: 14,
                    color: AppTheme.copilotBlue,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _expanded ? 'Hide agent logs' : 'Show agent logs',
                    style: const TextStyle(
                      color: AppTheme.copilotBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // DARK TERMINAL LOG BOX
          if (_expanded && message.logs.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
            width: 600,
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 200,
                maxHeight: 400,
              ),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2D2D2D),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Terminal header
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 255, 255, 255),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFBD2E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF27C93F),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Agent Logs',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const Spacer(),
                      // Copy logs button
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: message.logs.join("\n")),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Logs copied to clipboard'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.copy_rounded,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(
                    color: Color(0xFF2D2D2D),
                    height: 1,
                  ),
                  const SizedBox(height: 10),

                  // Log content
                  Expanded(
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      thickness: 6,
                      radius: const Radius.circular(3),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: SelectableText(
                          message.logs.join("\n"),
                          style: const TextStyle(
                            color: Color(0xFFB5F4A5), // Matrix green
                            fontFamily: 'monospace',
                            fontSize: 13,
                            height: 1.5,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            )
          ],

          // Empty state
          if (_expanded && message.logs.isEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.hourglass_empty,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Waiting for agent logs...',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    }

    // NORMAL AI MESSAGE
    return MarkdownBody(
      data: message.content,
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(
          color: AppTheme.copilotDark,
          fontSize: 13,
          height: 1.4,
        ),
        h1: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppTheme.copilotDark,
        ),
        h2: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppTheme.copilotDark,
        ),
        h3: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppTheme.copilotDark,
        ),
        code: TextStyle(
          backgroundColor: Colors.grey.shade100,
          fontFamily: 'monospace',
          fontSize: 14,
        ),
        codeblockDecoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // AVATAR
  // ------------------------------------------------------------
  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: isUser ? const Color.fromARGB(255, 4, 130, 255) : AppTheme.copilotBlueLight,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isUser ? Icons.person : Icons.auto_awesome,
        color: isUser ? Colors.white : AppTheme.copilotBlue,
        size: 20,
      ),
    );
  }

  // ------------------------------------------------------------
  // TIMESTAMP
  // ------------------------------------------------------------
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';

    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}