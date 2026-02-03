class Message {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final MessageStatus status;
  final String? jobId;
  
  Message({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.jobId,
  });
  
  Message copyWith({
    String? content,
    MessageStatus? status,
  }) {
    return Message(
      id: id,
      content: content ?? this.content,
      isUser: isUser,
      timestamp: timestamp,
      status: status ?? this.status,
      jobId: jobId,
    );
  }
}

enum MessageStatus {
  sending,
  sent,
  researching,
  complete,
  error,
}
