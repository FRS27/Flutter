import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ResearchService extends ChangeNotifier {
  // ✅ FIX 1: Point to localhost 8000
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

  Future<void> startResearch(String topic) async {
    if (_isProcessing) return;
    _isProcessing = true;
    addUserMessage(topic);
    addAIMessage("🔍 Researching '$topic'... This may take a minute.");
    notifyListeners();

    try {
      // ✅ FIX 2: No '/api', just '/research'
      final url = Uri.parse('$baseUrl/research');
      
      // ✅ FIX 3: Direct POST request (No polling)
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'topic': topic}),
      ).timeout(const Duration(minutes: 5)); // Allow 5 mins for AI to think

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // ✅ FIX 4: Get 'result' from python, not 'report'
        final result = data['result'].toString(); 
        
        // Remove the "Researching..." message and add the real answer
        _messages.removeLast(); 
        addAIMessage(result);
      } else {
        addAIMessage("❌ Server Error: ${response.statusCode}");
      }
    } catch (e) {
      _messages.removeLast();
      addAIMessage("❌ Connection Error: $e\n\nMake sure backend is running!");
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}