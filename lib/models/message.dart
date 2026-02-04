

enum MessageStatus {
  sent,
  researching,
  complete,
  error,
}

class Message {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final MessageStatus status;

  // NEW: thinking logs for researching messages
  final List<String> logs;

  // Optional: if you already have jobId or similar, keep it
  final String? jobId;

  Message({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.logs = const [],
    this.jobId,
  });

  Message copyWith({
    String? content,
    MessageStatus? status,
    List<String>? logs,
    String? jobId,
  }) {
    return Message(
      id: id,
      content: content ?? this.content,
      isUser: isUser,
      timestamp: timestamp,
      status: status ?? this.status,
      logs: logs ?? this.logs,
      jobId: jobId ?? this.jobId,
    );
  }
}
