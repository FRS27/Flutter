import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/message.dart';

class ResearchService extends ChangeNotifier {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    } else {
      return 'http://10.0.2.2:8000';
    }
  }


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

  void addAIMessage(String content,
      {MessageStatus status = MessageStatus.sent, List<String> logs = const []}) {
    _messages.add(
      Message(
        id: DateTime.now().toString(),
        content: content,
        isUser: false,
        timestamp: DateTime.now(),
        status: status,
        logs: logs,
      ),
    );
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  // ------------------------------------------------------------
  // MAIN RESEARCH FLOW (WITH POLLING + LOGS)
  // ------------------------------------------------------------
  Future<void> startResearch(String topic) async {
    if (_isProcessing) return;

    _isProcessing = true;
    addUserMessage(topic);

    // Initial placeholder thinking bubble
    addAIMessage(
      "Agents are starting up and preparing your research...",
      status: MessageStatus.researching,
      logs: [],
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
        "🔄 Agents are working…",
        status: MessageStatus.researching,
      );

      // 2. Poll for results
      List<String> previousLogs = [];

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

        // Extract logs (cleaned by backend)
        final logs = (pollData['logs'] as List?)?.cast<String>() ?? [];

        // Only update if new logs arrived
        if (logs.length != previousLogs.length) {
          previousLogs = logs;
          _updateLastAILogs(logs);
        }

        if (status == "running") {
          await Future.delayed(const Duration(seconds: 2));
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
  // INTERNAL HELPERS
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

  void _updateLastAILogs(List<String> logs) {
    for (int i = _messages.length - 1; i >= 0; i--) {
      if (!_messages[i].isUser &&
          _messages[i].status == MessageStatus.researching) {
        _messages[i] = _messages[i].copyWith(logs: logs);
        break;
      }
    }
    notifyListeners();
  }
}
