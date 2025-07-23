import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/model_manager.dart';
import '../services/chat_service.dart';
import '../widgets/chat/message_bubble.dart';
import '../widgets/chat/chat_input_field.dart';
import '../widgets/common/custom_app_bar.dart';
import '../theme/app_colors.dart';
import '../theme/dimensions.dart';
import 'model_download_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _checkModelStatus();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _checkModelStatus() {
    final modelManager = Provider.of<ModelManager>(context, listen: false);
    if (modelManager.needsDownload) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ModelDownloadScreen(),
          ),
        );
      });
    }
  }

  void _sendMessage() async {
    final messageText = _messageController.text.trim();
    final hasImage = _selectedImagePath != null && _selectedImagePath!.isNotEmpty;
    
    // Must have either text or image
    if (messageText.isEmpty && !hasImage) return;

    _messageController.clear();
    final imagePath = _selectedImagePath;
    _selectedImagePath = null; // Clear selected image

    final chatService = Provider.of<ChatService>(context, listen: false);
    
    if (hasImage) {
      // Send multimodal message
      await chatService.sendMultimodalMessage(messageText, imagePath!);
    } else {
      // Send text-only message
      await chatService.sendMessage(messageText);
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
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

  void _clearConversation() {
    final chatService = Provider.of<ChatService>(context, listen: false);
    chatService.clearConversation();
  }

  void _attachImageFromGallery() async {
    final chatService = Provider.of<ChatService>(context, listen: false);
    final imagePath = await chatService.pickImageFromGallery();
    
    if (imagePath != null) {
      setState(() {
        _selectedImagePath = imagePath;
      });
    }
  }

  void _takePhoto() async {
    final chatService = Provider.of<ChatService>(context, listen: false);
    final imagePath = await chatService.pickImageFromCamera();
    
    if (imagePath != null) {
      setState(() {
        _selectedImagePath = imagePath;
      });
    }
  }

  void _removeSelectedImage() {
    setState(() {
      _selectedImagePath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatService>(
      builder: (context, chatService, child) {
        return Scaffold(
          backgroundColor: AppColors.backgroundGray,
          appBar: CustomAppBar(
            title: 'Gemma Assistant',
            onMorePressed: () {
              _showOptionsMenu();
            },
          ),
          body: Column(
            children: [
              // Error Display
              if (chatService.errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          chatService.errorMessage!,
                          style: TextStyle(color: AppColors.error, fontSize: 14),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => chatService.clearError(),
                        color: AppColors.error,
                      ),
                    ],
                  ),
                ),

              // Messages List
              Expanded(
                child: chatService.messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.screenPadding,
                        ),
                        itemCount: chatService.messages.length,
                        itemBuilder: (context, index) {
                          return MessageBubble(
                            message: chatService.messages[index],
                          );
                        },
                      ),
              ),

              // Input Field
              ChatInputField(
                controller: _messageController,
                onSend: _sendMessage,
                isLoading: chatService.isGenerating,
                onAttachImage: _attachImageFromGallery,
                onTakePhoto: _takePhoto,
                onRemoveImage: _removeSelectedImage,
                selectedImagePath: _selectedImagePath,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.psychology,
            size: 64,
            color: AppColors.mediumGray.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppDimensions.spaceLG),
          Text(
            'Hello! I\'m your Gemma AI Assistant',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceSM),
          Text(
            'Ask me anything to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu() {
    final chatService = Provider.of<ChatService>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.clear_all),
                title: const Text('Clear Conversation'),
                subtitle: Text('${chatService.messageCount} messages'),
                onTap: () {
                  Navigator.pop(context);
                  _showClearConfirmation();
                },
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Model Status'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ModelDownloadScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Conversation Stats'),
                onTap: () {
                  Navigator.pop(context);
                  _showConversationStats();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Conversation'),
          content: const Text('Are you sure you want to clear all messages? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearConversation();
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _showConversationStats() {
    final chatService = Provider.of<ChatService>(context, listen: false);
    final stats = chatService.getConversationStats();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conversation Statistics'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow('Total Messages', stats['totalMessages'].toString()),
              _buildStatRow('Your Messages', stats['userMessages'].toString()),
              _buildStatRow('AI Messages', stats['aiMessages'].toString()),
              _buildStatRow('Duration', '${stats['conversationDuration']} minutes'),
              _buildStatRow('Started', DateTime.parse(stats['conversationStarted']).toString().split('.')[0]),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
} 