import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';
import 'model_manager.dart';
import 'image_service.dart';

class ChatService extends ChangeNotifier {
  static const String _conversationKey = 'chat_conversation_history';
  static const String _conversationMetadataKey = 'chat_conversation_metadata';
  
  final ModelManager _modelManager;
  final ImageService _imageService;
  final List<Message> _messages = [];
  bool _isGenerating = false;
  String? _errorMessage;
  
  // Conversation metadata
  DateTime _conversationStarted = DateTime.now();
  int _totalMessages = 0;
  String _conversationId = '';
  
  ChatService(this._modelManager, this._imageService) {
    _conversationId = DateTime.now().millisecondsSinceEpoch.toString();
    _loadConversationHistory();
  }
  
  // Getters
  List<Message> get messages => List.unmodifiable(_messages);
  bool get isGenerating => _isGenerating;
  String? get errorMessage => _errorMessage;
  bool get hasMessages => _messages.isNotEmpty;
  int get messageCount => _messages.length;
  DateTime get conversationStarted => _conversationStarted;
  int get totalMessages => _totalMessages;
  String get conversationId => _conversationId;
  
  /// Send a text message and get AI response
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || _isGenerating) return;
    
    _clearError();
    
    // Add user message
    final userMessage = Message.user(content: content.trim());
    _addMessage(userMessage);
    
    // Start generating response
    _isGenerating = true;
    notifyListeners();
    
    try {
      // Generate AI response using ModelManager
      final response = await _modelManager.generateResponse(content);
      
      if (response != null) {
        final aiMessage = Message.ai(content: response);
        _addMessage(aiMessage);
      } else {
        _setError('Failed to generate response');
      }
    } catch (e) {
      _setError('Error generating response: $e');
      if (kDebugMode) {
        print('ChatService error: $e');
      }
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
    
    // Save conversation after each exchange
    await _saveConversationHistory();
  }

  /// Send a multimodal message (text + image) and get AI response
  Future<void> sendMultimodalMessage(String content, String imagePath) async {
    if (_isGenerating) return;
    
    _clearError();
    
    // Add user message with image
    final userMessage = Message.user(
      content: content.trim(),
      imagePath: imagePath,
    );
    _addMessage(userMessage);
    
    // Start generating response
    _isGenerating = true;
    notifyListeners();
    
    try {
      // Read image bytes from the file
      final imageBytes = await _imageService.getImageBytes(imagePath);
      
      if (imageBytes == null) {
        throw Exception('Failed to read image file');
      }
      
      // Prepare the prompt - if no text provided, ask to describe the image
      final prompt = content.trim().isEmpty 
          ? "Describe what you see in this image." 
          : content.trim();
      
      // Generate multimodal response using the new method
      final response = await _modelManager.generateMultimodalResponse(prompt, imageBytes);
      
      if (response != null) {
        final aiMessage = Message.ai(content: response);
        _addMessage(aiMessage);
      } else {
        _setError('Failed to generate response');
      }
    } catch (e) {
      _setError('Error generating response: $e');
      if (kDebugMode) {
        print('ChatService multimodal error: $e');
      }
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
    
    // Save conversation after each exchange
    await _saveConversationHistory();
  }

  /// Pick image from gallery and return path
  Future<String?> pickImageFromGallery() async {
    try {
      return await _imageService.pickImageFromGallery();
    } catch (e) {
      _setError('Error picking image from gallery: $e');
      if (kDebugMode) {
        print('Error picking image from gallery: $e');
      }
      return null;
    }
  }

  /// Pick image from camera and return path
  Future<String?> pickImageFromCamera() async {
    try {
      return await _imageService.pickImageFromCamera();
    } catch (e) {
      _setError('Error picking image from camera: $e');
      if (kDebugMode) {
        print('Error picking image from camera: $e');
      }
      return null;
    }
  }
  
  /// Add a message to the conversation
  void _addMessage(Message message) {
    _messages.add(message);
    _totalMessages++;
    notifyListeners();
  }
  
  /// Clear all messages
  Future<void> clearConversation() async {
    _messages.clear();
    _totalMessages = 0;
    _conversationStarted = DateTime.now();
    _conversationId = DateTime.now().millisecondsSinceEpoch.toString();
    _clearError();
    
    await _clearConversationHistory();
    notifyListeners();
  }
  
  /// Delete a specific message
  Future<void> deleteMessage(String messageId) async {
    _messages.removeWhere((message) => message.id == messageId);
    await _saveConversationHistory();
    notifyListeners();
  }
  
  /// Copy message content to clipboard
  String getMessageContent(String messageId) {
    final message = _messages.firstWhere(
      (msg) => msg.id == messageId,
      orElse: () => Message.system(content: ''),
    );
    return message.content;
  }
  
  /// Get conversation statistics
  Map<String, dynamic> getConversationStats() {
    final userMessages = _messages.where((msg) => msg.type == MessageType.user).length;
    final aiMessages = _messages.where((msg) => msg.type == MessageType.ai).length;
    final duration = DateTime.now().difference(_conversationStarted);
    
    return {
      'totalMessages': _messages.length,
      'userMessages': userMessages,
      'aiMessages': aiMessages,
      'conversationDuration': duration.inMinutes,
      'conversationStarted': _conversationStarted.toIso8601String(),
      'conversationId': _conversationId,
    };
  }
  
  /// Load conversation history from SharedPreferences
  Future<void> _loadConversationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversationData = prefs.getString(_conversationKey);
      final metadataData = prefs.getString(_conversationMetadataKey);
      
      if (conversationData != null) {
        final List<dynamic> messagesList = jsonDecode(conversationData);
        _messages.clear();
        
        for (final messageData in messagesList) {
          try {
            final message = Message.fromJson(messageData);
            _messages.add(message);
          } catch (e) {
            if (kDebugMode) {
              print('Error loading message: $e');
            }
          }
        }
      }
      
      if (metadataData != null) {
        final Map<String, dynamic> metadata = jsonDecode(metadataData);
        _conversationStarted = DateTime.parse(metadata['conversationStarted'] ?? DateTime.now().toIso8601String());
        _totalMessages = metadata['totalMessages'] ?? _messages.length;
        _conversationId = metadata['conversationId'] ?? DateTime.now().millisecondsSinceEpoch.toString();
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading conversation history: $e');
      }
    }
  }
  
  /// Save conversation history to SharedPreferences
  Future<void> _saveConversationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save messages
      final messagesJson = _messages.map((message) => message.toJson()).toList();
      await prefs.setString(_conversationKey, jsonEncode(messagesJson));
      
      // Save metadata
      final metadata = {
        'conversationStarted': _conversationStarted.toIso8601String(),
        'totalMessages': _totalMessages,
        'conversationId': _conversationId,
      };
      await prefs.setString(_conversationMetadataKey, jsonEncode(metadata));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving conversation history: $e');
      }
    }
  }
  
  /// Clear conversation history from SharedPreferences
  Future<void> _clearConversationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_conversationKey);
      await prefs.remove(_conversationMetadataKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing conversation history: $e');
      }
    }
  }
  
  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
  
  /// Clear error message
  void _clearError() {
    _errorMessage = null;
  }
  
  /// Clear error explicitly
  void clearError() {
    _clearError();
    notifyListeners();
  }
  
  /// Export conversation as JSON
  String exportConversation() {
    final export = {
      'metadata': getConversationStats(),
      'messages': _messages.map((message) => message.toJson()).toList(),
    };
    return jsonEncode(export);
  }
  
  /// Import conversation from JSON
  Future<void> importConversation(String jsonData) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonData);
      final List<dynamic> messagesList = data['messages'] ?? [];
      
      _messages.clear();
      for (final messageData in messagesList) {
        final message = Message.fromJson(messageData);
        _messages.add(message);
      }
      
      // Update metadata if available
      final metadata = data['metadata'];
      if (metadata != null) {
        _conversationStarted = DateTime.parse(metadata['conversationStarted'] ?? DateTime.now().toIso8601String());
        _totalMessages = metadata['totalMessages'] ?? _messages.length;
        _conversationId = metadata['conversationId'] ?? DateTime.now().millisecondsSinceEpoch.toString();
      }
      
      await _saveConversationHistory();
      notifyListeners();
    } catch (e) {
      _setError('Error importing conversation: $e');
      if (kDebugMode) {
        print('Error importing conversation: $e');
      }
    }
  }
} 