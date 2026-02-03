import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/message.dart';

class ResearchService extends ChangeNotifier {
  static const String baseUrl = 'http://127.0.0.1:8000';

  final List<Message> _messages = [];
  List<Message> get messages => _messages;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  // ------------------------------------------------------------
  // MESSAGE HELPERS
  // ------------------------------------------------------------
  void addUserMessage(String content) {
    _messages.add(
      Message(
        id: DateTime.now().toString(),
        content: content,
        isUser: true,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      ),
    );
    notifyListeners();
  }

  void addAIMessage(String content, {MessageStatus status = MessageStatus.sent}) {
    _messages.add(
      Message(
        id: DateTime.now().toString(),
        content: content,
        isUser: false,
        timestamp: DateTime.now(),
        status: status,
      ),
    );
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  // ------------------------------------------------------------
  // MAIN RESEARCH FLOW (WITH POLLING)
  // ------------------------------------------------------------
  Future<void> startResearch(String topic) async {
    if (_isProcessing) return;

    _isProcessing = true;
    addUserMessage(topic);

    // "Thinking" / researching placeholder
    addAIMessage(
      "Agents are starting up and preparing your research...",
      status: MessageStatus.researching,
    );
    notifyListeners();

    try {
      // 1. Start research job
      final startUrl = Uri.parse('$baseUrl/research');
      final startRes = await http.post(
        startUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'topic': topic}),
      );

      if (startRes.statusCode != 200) {
        _replaceLastAIMessage(
          "❌ Server error: ${startRes.statusCode}",
          status: MessageStatus.error,
        );
        _isProcessing = false;
        notifyListeners();
        return;
      }

      final startData = jsonDecode(startRes.body);
      final jobId = startData['job_id'];

      // Update placeholder text
      _replaceLastAIMessage(
        "🔄 Agents are working... This may take 30–60 seconds.",
        status: MessageStatus.researching,
      );

      // 2. Poll for results
      while (true) {
        final pollUrl = Uri.parse('$baseUrl/research/$jobId');
        final pollRes = await http.get(pollUrl);

        if (pollRes.statusCode != 200) {
          _replaceLastAIMessage(
            "❌ Error fetching job status.",
            status: MessageStatus.error,
          );
          break;
        }

        final pollData = jsonDecode(pollRes.body);
        final status = pollData['status'];

        if (status == "running") {
          await Future.delayed(const Duration(seconds: 3));
          continue;
        }

        if (status == "completed") {
          final result = pollData['result'] ?? "No result returned.";
          _replaceLastAIMessage(
            result,
            status: MessageStatus.complete,
          );
          break;
        }

        if (status == "failed") {
          final error = pollData['result'] ?? "Unknown error.";
          _replaceLastAIMessage(
            "❌ Research failed:\n$error",
            status: MessageStatus.error,
          );
          break;
        }
      }
    } catch (e) {
      _replaceLastAIMessage(
        "❌ Connection Error: $e\nMake sure backend is running.",
        status: MessageStatus.error,
      );
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // ------------------------------------------------------------
  // INTERNAL: UPDATE LAST AI MESSAGE
  // ------------------------------------------------------------
  void _replaceLastAIMessage(String content, {MessageStatus? status}) {
    for (int i = _messages.length - 1; i >= 0; i--) {
      if (!_messages[i].isUser) {
        _messages[i] = _messages[i].copyWith(
          content: content,
          status: status ?? _messages[i].status,
        );
        break;
      }
    }
    notifyListeners();
  }
}
