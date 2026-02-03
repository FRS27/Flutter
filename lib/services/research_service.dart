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

  void addUserMessage(String content) {
    _messages.add(Message(
      id: DateTime.now().toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  void addAIMessage(String content) {
    _messages.add(Message(
      id: DateTime.now().toString(),
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  // ---------------------------------------------------------
  // MAIN FUNCTION: Works exactly like Streamlit
  // ---------------------------------------------------------
  Future<void> startResearch(String topic) async {
    if (_isProcessing) return;

    _isProcessing = true;
    addUserMessage(topic);
    addAIMessage("🤖 Starting research on '$topic'...");
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
        addAIMessage("❌ Server error: ${startRes.statusCode}");
        _isProcessing = false;
        notifyListeners();
        return;
      }

      final startData = jsonDecode(startRes.body);
      final jobId = startData['job_id'];

      // Replace "Starting..." message with "Working..."
      _messages.removeLast();
      addAIMessage("🔄 Agents are working... This may take 30–60 seconds.");
      notifyListeners();

      // 2. Poll for results
      while (true) {
        final pollUrl = Uri.parse('$baseUrl/research/$jobId');
        final pollRes = await http.get(pollUrl);

        if (pollRes.statusCode != 200) {
          addAIMessage("❌ Error fetching job status.");
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
          _messages.removeLast(); // Remove "working..." message
          addAIMessage(result);
          break;
        }

        if (status == "failed") {
          final error = pollData['result'] ?? "Unknown error.";
          _messages.removeLast();
          addAIMessage("❌ Research failed:\n$error");
          break;
        }
      }
    } catch (e) {
      _messages.removeLast();
      addAIMessage("❌ Connection Error: $e\nMake sure backend is running.");
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
