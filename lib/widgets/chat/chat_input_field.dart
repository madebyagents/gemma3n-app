import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/dimensions.dart';
import 'image_preview.dart';

class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onSend;
  final VoidCallback? onAttachImage;
  final VoidCallback? onTakePhoto;
  final VoidCallback? onRemoveImage;
  final bool isLoading;
  final String hintText;
  final String? selectedImagePath;

  const ChatInputField({
    super.key,
    required this.controller,
    this.onSend,
    this.onAttachImage,
    this.onTakePhoto,
    this.onRemoveImage,
    this.isLoading = false,
    this.hintText = 'Ask anything...',
    this.selectedImagePath,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  @override
  void initState() {
    super.initState();
    // Add listener to text controller to update UI when text changes
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    // Remove listener to prevent memory leaks
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    // Force rebuild when text changes to update send button state
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImage = widget.selectedImagePath != null && widget.selectedImagePath!.isNotEmpty;
    final bool canSend = !widget.isLoading && (widget.controller.text.trim().isNotEmpty || hasImage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image Preview
        if (hasImage)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.screenPadding,
              0,
              AppDimensions.screenPadding,
              AppDimensions.elementSpacing,
            ),
            child: ImagePreview(
              imagePath: widget.selectedImagePath!,
              onRemove: widget.onRemoveImage,
              maxHeight: 150,
            ),
          ),

        // Input Field Container
        Container(
          margin: const EdgeInsets.all(AppDimensions.screenPadding),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPadding,
            vertical: AppDimensions.elementSpacing,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
            border: Border.all(color: AppColors.lightGray),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Attach Image Button with options
              _buildAttachButton(),
              
              // Text Input Field
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  enabled: !widget.isLoading,
                  maxLines: null,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: hasImage && widget.controller.text.trim().isEmpty
                        ? 'Add a caption (optional)...'
                        : widget.hintText,
                    hintStyle: const TextStyle(
                      color: AppColors.mediumGray,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.darkGray,
                  ),
                ),
              ),
              
              // Voice Input Button (placeholder for future)
              IconButton(
                icon: const Icon(
                  Icons.mic,
                  color: AppColors.mediumGray,
                ),
                onPressed: widget.isLoading ? null : () {
                  // TODO: Implement voice input in future phase
                },
              ),
              
              // Send Button
              IconButton(
                icon: Icon(
                  Icons.send,
                  color: canSend ? AppColors.primaryBlue : AppColors.mediumGray,
                ),
                onPressed: canSend ? widget.onSend : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttachButton() {
    if (widget.isLoading) {
      return IconButton(
        icon: const Icon(
          Icons.add,
          color: AppColors.mediumGray,
        ),
        onPressed: null,
      );
    }

    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.add,
        color: AppColors.mediumGray,
      ),
      offset: const Offset(0, -120),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'gallery',
          child: const Row(
            children: [
              Icon(Icons.photo_library, color: AppColors.darkGray),
              SizedBox(width: AppDimensions.elementSpacing),
              Text('Choose from gallery'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'camera',
          child: const Row(
            children: [
              Icon(Icons.camera_alt, color: AppColors.darkGray),
              SizedBox(width: AppDimensions.elementSpacing),
              Text('Take photo'),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'gallery':
            widget.onAttachImage?.call();
            break;
          case 'camera':
            widget.onTakePhoto?.call();
            break;
        }
      },
    );
  }
} 