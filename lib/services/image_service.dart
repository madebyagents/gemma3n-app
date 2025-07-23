import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ImageService {
  static const int _maxImageWidth = 1024;
  static const int _maxImageHeight = 1024;
  static const int _compressionQuality = 85;
  static const int _maxFileSizeBytes = 5 * 1024 * 1024; // 5MB

  final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: _maxImageWidth.toDouble(),
        maxHeight: _maxImageHeight.toDouble(),
        imageQuality: _compressionQuality,
      );
      
      if (image != null) {
        return await _processAndSaveImage(image);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image from gallery: $e');
      }
    }
    return null;
  }

  /// Pick image from camera
  Future<String?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: _maxImageWidth.toDouble(),
        maxHeight: _maxImageHeight.toDouble(),
        imageQuality: _compressionQuality,
      );
      
      if (image != null) {
        return await _processAndSaveImage(image);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image from camera: $e');
      }
    }
    return null;
  }

  /// Process and save image to app directory
  Future<String?> _processAndSaveImage(XFile imageFile) async {
    try {
      // Read image bytes
      final Uint8List imageBytes = await imageFile.readAsBytes();
      
      // Check file size
      if (imageBytes.length > _maxFileSizeBytes) {
        throw Exception('Image file too large. Maximum size is 5MB.');
      }

      // Decode image
      final img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      // Resize if necessary
      img.Image processedImage = originalImage;
      if (originalImage.width > _maxImageWidth || originalImage.height > _maxImageHeight) {
        processedImage = img.copyResize(
          originalImage,
          width: originalImage.width > originalImage.height ? _maxImageWidth : null,
          height: originalImage.height > originalImage.width ? _maxImageHeight : null,
        );
      }

      // Encode as JPEG
      final List<int> compressedBytes = img.encodeJpg(
        processedImage,
        quality: _compressionQuality,
      );

      // Save to app directory
      final String savedPath = await _saveImageToAppDirectory(
        Uint8List.fromList(compressedBytes),
        path.extension(imageFile.path),
      );

      return savedPath;
    } catch (e) {
      if (kDebugMode) {
        print('Error processing image: $e');
      }
      return null;
    }
  }

  /// Save image to app directory
  Future<String> _saveImageToAppDirectory(Uint8List imageBytes, String extension) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory imageDir = Directory('${appDir.path}/chat_images');
    
    // Create directory if it doesn't exist
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    // Generate unique filename
    final String fileName = 'image_${DateTime.now().millisecondsSinceEpoch}$extension';
    final String filePath = '${imageDir.path}/$fileName';

    // Write file
    final File imageFile = File(filePath);
    await imageFile.writeAsBytes(imageBytes);

    return filePath;
  }

  /// Get image file from path
  File? getImageFile(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return null;
    final file = File(imagePath);
    return file.existsSync() ? file : null;
  }

  /// Get image bytes from path
  Future<Uint8List?> getImageBytes(String? imagePath) async {
    final file = getImageFile(imagePath);
    if (file == null) return null;
    
    try {
      return await file.readAsBytes();
    } catch (e) {
      if (kDebugMode) {
        print('Error reading image bytes: $e');
      }
      return null;
    }
  }

  /// Delete image file
  Future<bool> deleteImage(String? imagePath) async {
    final file = getImageFile(imagePath);
    if (file == null) return false;
    
    try {
      await file.delete();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting image: $e');
      }
      return false;
    }
  }

  /// Clean up old images (older than 30 days)
  Future<void> cleanupOldImages() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory imageDir = Directory('${appDir.path}/chat_images');
      
      if (!await imageDir.exists()) return;

      final DateTime cutoffDate = DateTime.now().subtract(const Duration(days: 30));
      final List<FileSystemEntity> files = imageDir.listSync();

      for (final file in files) {
        if (file is File) {
          final FileStat stat = await file.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            try {
              await file.delete();
              if (kDebugMode) {
                print('Deleted old image: ${file.path}');
              }
            } catch (e) {
              if (kDebugMode) {
                print('Error deleting old image ${file.path}: $e');
              }
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cleaning up old images: $e');
      }
    }
  }

  /// Get total size of chat images directory
  Future<int> getTotalImagesSize() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory imageDir = Directory('${appDir.path}/chat_images');
      
      if (!await imageDir.exists()) return 0;

      int totalSize = 0;
      final List<FileSystemEntity> files = imageDir.listSync();

      for (final file in files) {
        if (file is File) {
          final FileStat stat = await file.stat();
          totalSize += stat.size;
        }
      }

      return totalSize;
    } catch (e) {
      if (kDebugMode) {
        print('Error calculating images size: $e');
      }
      return 0;
    }
  }

  /// Convert bytes to human readable format
  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    int i = 0;
    double size = bytes.toDouble();
    
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    
    return '${size.toStringAsFixed(i == 0 ? 0 : 1)} ${suffixes[i]}';
  }
} 