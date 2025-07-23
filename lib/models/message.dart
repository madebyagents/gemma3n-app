enum MessageType { user, ai, system }

enum MessageContentType { text, image, multimodal }

class Message {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isLoading;
  final String? imageUrl;
  final String? imagePath; // Local file path for images
  final MessageContentType contentType;

  const Message({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isLoading = false,
    this.imageUrl,
    this.imagePath,
    this.contentType = MessageContentType.text,
  });

  factory Message.user({
    required String content,
    String? imageUrl,
    String? imagePath,
  }) {
    MessageContentType contentType = MessageContentType.text;
    if (imageUrl != null || imagePath != null) {
      contentType = content.trim().isNotEmpty 
          ? MessageContentType.multimodal 
          : MessageContentType.image;
    }
    
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
      imageUrl: imageUrl,
      imagePath: imagePath,
      contentType: contentType,
    );
  }

  factory Message.ai({
    required String content,
    bool isLoading = false,
  }) {
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.ai,
      timestamp: DateTime.now(),
      isLoading: isLoading,
    );
  }

  factory Message.system({
    required String content,
  }) {
    return Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.system,
      timestamp: DateTime.now(),
    );
  }

  Message copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isLoading,
    String? imageUrl,
    String? imagePath,
    MessageContentType? contentType,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
      imageUrl: imageUrl ?? this.imageUrl,
      imagePath: imagePath ?? this.imagePath,
      contentType: contentType ?? this.contentType,
    );
  }

  /// Convert Message to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
      'isLoading': isLoading,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'contentType': contentType.toString(),
    };
  }

  /// Create Message from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      type: _parseMessageType(json['type']),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isLoading: json['isLoading'] ?? false,
      imageUrl: json['imageUrl'],
      imagePath: json['imagePath'],
      contentType: _parseContentType(json['contentType']),
    );
  }

  /// Parse MessageType from string
  static MessageType _parseMessageType(String? typeString) {
    switch (typeString) {
      case 'MessageType.user':
        return MessageType.user;
      case 'MessageType.ai':
        return MessageType.ai;
      case 'MessageType.system':
        return MessageType.system;
      default:
        return MessageType.system;
    }
  }

  /// Parse MessageContentType from string
  static MessageContentType _parseContentType(String? typeString) {
    switch (typeString) {
      case 'MessageContentType.text':
        return MessageContentType.text;
      case 'MessageContentType.image':
        return MessageContentType.image;
      case 'MessageContentType.multimodal':
        return MessageContentType.multimodal;
      default:
        return MessageContentType.text;
    }
  }

  /// Check if message has image content
  bool get hasImage => imageUrl != null || imagePath != null;

  /// Check if message is multimodal
  bool get isMultimodal => contentType == MessageContentType.multimodal;

  /// Check if message is image only
  bool get isImageOnly => contentType == MessageContentType.image;
} 