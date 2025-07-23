import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/dimensions.dart';

class ImagePreview extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onRemove;
  final double maxHeight;
  final BorderRadius? borderRadius;

  const ImagePreview({
    super.key,
    required this.imagePath,
    this.onRemove,
    this.maxHeight = 200,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppDimensions.elementSpacing),
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusMD),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.radiusMD),
        child: Stack(
          children: [
            // Image
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: maxHeight,
                maxWidth: double.infinity,
              ),
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
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
                        SizedBox(height: AppDimensions.elementSpacing),
                        Text(
                          'Failed to load image',
                          style: TextStyle(
                            color: AppColors.mediumGray,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Remove button
            if (onRemove != null)
              Positioned(
                top: AppDimensions.elementSpacing,
                right: AppDimensions.elementSpacing,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 