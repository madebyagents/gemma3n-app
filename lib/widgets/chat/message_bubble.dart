import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/message.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/dimensions.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.type == MessageType.user;
    final isAI = message.type == MessageType.ai;

    if (isUser) {
      return _buildUserMessage(context);
    } else if (isAI) {
      return _buildAIMessage(context);
    } else {
      return _buildSystemMessage(context);
    }
  }

  Widget _buildUserMessage(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: 60,
        bottom: AppDimensions.messageSpacing,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: AppDimensions.maxMessageWidth,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.messagePadding,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusLG),
                  topRight: Radius.circular(AppDimensions.radiusLG),
                  bottomLeft: Radius.circular(AppDimensions.radiusLG),
                  bottomRight: Radius.circular(AppDimensions.radiusXS),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display image if present
                  if (message.hasImage) ...[
                    _buildMessageImage(message),
                    const SizedBox(height: AppDimensions.elementSpacing),
                  ],
                  // Display text content if present
                  if (message.content.trim().isNotEmpty)
                    Text(
                      message.content,
                      style: AppTextStyles.userMessageText,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(message.timestamp),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIMessage(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        right: 60,
        bottom: AppDimensions.messageSpacing,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppDimensions.avatarSize,
            height: AppDimensions.avatarSize,
            margin: const EdgeInsets.only(right: AppDimensions.elementSpacing),
            decoration: const BoxDecoration(
              color: AppColors.darkGray,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology,
              color: AppColors.white,
              size: AppDimensions.iconSize,
            ),
          ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: AppDimensions.maxMessageWidth,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.messagePadding,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusXS),
                  topRight: Radius.circular(AppDimensions.radiusLG),
                  bottomLeft: Radius.circular(AppDimensions.radiusLG),
                  bottomRight: Radius.circular(AppDimensions.radiusLG),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: message.isLoading
                  ? _buildLoadingIndicator()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.content,
                          style: AppTextStyles.aiMessageText,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimestamp(message.timestamp),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.mediumGray,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPadding,
        vertical: AppDimensions.elementSpacing,
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
                     decoration: BoxDecoration(
             color: AppColors.mediumGray.withValues(alpha: 0.2),
             borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
           ),
          child: Text(
            message.content,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.mediumGray,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.elementSpacing),
        Text(
          'Thinking...',
          style: AppTextStyles.aiMessageText.copyWith(
            color: AppColors.mediumGray,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildMessageImage(Message message) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 250,
          maxHeight: 200,
        ),
        child: _buildImageWidget(message),
      ),
    );
  }

  Widget _buildImageWidget(Message message) {
    // Try local file first (imagePath), then network URL (imageUrl)
    if (message.imagePath != null && message.imagePath!.isNotEmpty) {
      final file = File(message.imagePath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImageErrorWidget();
          },
        );
      }
    }
    
    if (message.imageUrl != null && message.imageUrl!.isNotEmpty) {
      return Image.network(
        message.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageErrorWidget();
        },
      );
    }
    
    return _buildImageErrorWidget();
  }

  Widget _buildImageErrorWidget() {
    return Container(
      height: 100,
      color: AppColors.lightGray,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            color: AppColors.mediumGray,
            size: 32,
          ),
          SizedBox(height: 4),
          Text(
            'Image unavailable',
            style: TextStyle(
              color: AppColors.mediumGray,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      // Format as date for older messages
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
} 