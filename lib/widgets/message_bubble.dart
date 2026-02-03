import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../models/message.dart';
import '../theme.dart';
import 'thinking_indicator.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(width: 12),
          ],

          // ------------------------------------------------------------
          // MESSAGE BUBBLE
          // ------------------------------------------------------------
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppTheme.copilotBlue
                        : Colors.white,
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

                // Timestamp + Copy Icon
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
                              ClipboardData(text: message.content));
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
  // MESSAGE CONTENT (Markdown + Thinking Indicator)
  // ------------------------------------------------------------
  Widget _buildMessageContent(BuildContext context, bool isUser) {
    if (!isUser && message.status == MessageStatus.researching) {
      return const ThinkingIndicator();
    }

    if (isUser) {
      return Text(
        message.content,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          height: 1.4,
        ),
      );
    }

    return MarkdownBody(
      data: message.content,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(
          color: AppTheme.copilotDark,
          fontSize: 16,
          height: 1.45,
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
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: isUser ? AppTheme.copilotBlue : AppTheme.copilotBlueLight,
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
