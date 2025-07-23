import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma/core/model.dart';
import 'package:flutter_gemma/core/chat.dart';
import 'package:flutter_gemma/core/message.dart' as gemma_message;
import 'package:flutter_gemma/pigeon.g.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/model_status.dart';

class ModelManager extends ChangeNotifier {
  ModelStatus _status = ModelStatus.notDownloaded;
  DownloadProgress _downloadProgress = DownloadProgress.initial();
  String? _errorMessage;
  InferenceModel? _inferenceModel;
  InferenceChat? _chat;
  
  // Updated to use Gemma 3N E2B IT model with multimodal capabilities
  final ModelInfo _modelInfo = const ModelInfo(
    name: 'Gemma 3N E2B IT',
    version: 'E2B-IT-Preview',
    sizeInBytes: 3100000000, // ~3.1GB for the E2B model
    downloadUrl: 'https://huggingface.co/google/gemma-3n-E2B-it-litert-preview/resolve/main/gemma-3n-E2B-it-int4.task',
    description: 'Gemma 3N E2B Instruction-Tuned model with multimodal capabilities (text + image) optimized for mobile devices',
  );

  // Better model configuration based on Gemma 3N E2B
  static const String _modelUrl = 'https://huggingface.co/google/gemma-3n-E2B-it-litert-preview/resolve/main/gemma-3n-E2B-it-int4.task';
  static const String _modelFilename = 'gemma-3n-E2B-it-int4.task';
  static const String _tokenKey = 'HF_TOKEN';

  // Getters
  ModelStatus get status => _status;
  DownloadProgress get downloadProgress => _downloadProgress;
  String? get errorMessage => _errorMessage;
  ModelInfo get modelInfo => _modelInfo;
  bool get isReady => _status == ModelStatus.ready;
  bool get isDownloading => _status == ModelStatus.downloading;
  bool get needsDownload => _status == ModelStatus.notDownloaded;

  ModelManager() {
    _checkModelStatus();
  }

  Future<void> _checkModelStatus() async {
    try {
      final filePath = await _getModelFilePath();
      final file = File(filePath);
      
      if (file.existsSync()) {
        _status = ModelStatus.downloadComplete;
        notifyListeners();
        await _initializeModel();
      } else {
        _status = ModelStatus.notDownloaded;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to check model status: $e');
      if (kDebugMode) {
        print('Model status check error: $e');
      }
    }
  }

  Future<String> _getModelFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$_modelFilename';
  }

  Future<String?> getAuthToken() async {
    // First try to get token from environment variables
    final envToken = dotenv.env['HF_TOKEN'];
    if (envToken != null && envToken.isNotEmpty) {
      if (kDebugMode) {
        print('Using HF_TOKEN from environment variables');
      }
      return envToken;
    }
    
    // Fall back to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_tokenKey);
    if (kDebugMode) {
      print('Using token from SharedPreferences: ${savedToken != null ? 'found' : 'not found'}');
    }
    return savedToken;
  }

  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<bool> checkModelExists() async {
    try {
      final filePath = await _getModelFilePath();
      final file = File(filePath);
      
      if (!file.existsSync()) return false;
      
      // Check if file size matches expected (basic validation)
      final fileSize = await file.length();
      return fileSize > 100000; // At least 100KB to be considered valid
    } catch (e) {
      if (kDebugMode) {
        print('Error checking model existence: $e');
      }
      return false;
    }
  }

  Future<void> downloadModel({String? authToken}) async {
    if (_status == ModelStatus.downloading) return;

    try {
      _status = ModelStatus.downloading;
      _downloadProgress = DownloadProgress.initial();
      _errorMessage = null;
      notifyListeners();

      // Check if model already exists
      if (await checkModelExists()) {
        _status = ModelStatus.downloadComplete;
        notifyListeners();
        await _initializeModel();
        return;
      }

      // Use provided token or get saved token
      final token = authToken ?? await getAuthToken();
      
      if (token == null || token.isEmpty) {
        throw Exception(
          'Hugging Face authentication token is required. '
          'Please provide your Hugging Face token to download the model.\n\n'
          'You can get a token from: https://huggingface.co/settings/tokens'
        );
      }

      await _downloadModelFile(token);
      
      _status = ModelStatus.downloadComplete;
      notifyListeners();
      
      await _initializeModel();
    } catch (e) {
      _setError('Failed to download model: $e');
      if (kDebugMode) {
        print('Model download error: $e');
      }
    }
  }

  Future<void> _downloadModelFile(String token) async {
    http.StreamedResponse? response;
    IOSink? fileSink;

    try {
      final filePath = await _getModelFilePath();
      final file = File(filePath);

      // Check if file already exists and get partial download size
      int downloadedBytes = 0;
      if (file.existsSync()) {
        downloadedBytes = await file.length();
      }

      // Create HTTP request with authentication
      final request = http.Request('GET', Uri.parse(_modelUrl));
      request.headers['Authorization'] = 'Bearer $token';
      
      // Resume download if partially downloaded
      if (downloadedBytes > 0) {
        request.headers['Range'] = 'bytes=$downloadedBytes-';
      }

      // Send request
      response = await request.send();
      
      if (response.statusCode == 200 || response.statusCode == 206) {
        final contentLength = response.contentLength ?? 0;
        final totalBytes = downloadedBytes + contentLength;
        fileSink = file.openWrite(mode: FileMode.append);

        int received = downloadedBytes;

        // Download with progress tracking
        await for (final chunk in response.stream) {
          fileSink.add(chunk);
          received += chunk.length;

          // Update progress
          final progress = totalBytes > 0 ? received / totalBytes : 0.0;
          _downloadProgress = DownloadProgress(
            bytesDownloaded: received,
            totalBytes: totalBytes,
            percentage: progress * 100,
          );
          notifyListeners();
        }
      } else {
        // Handle different error codes
        String errorMessage = 'Download failed with status ${response.statusCode}';
        
        if (response.statusCode == 401) {
          errorMessage = 'Authentication failed. Please check your Hugging Face token and ensure it has the correct permissions.';
        } else if (response.statusCode == 403) {
          errorMessage = 'Access denied. Please ensure your token has read access to the repository.';
        } else if (response.statusCode == 404) {
          errorMessage = 'Model file not found. The model URL may be incorrect.';
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading model: $e');
      }
      rethrow;
    } finally {
      if (fileSink != null) {
        await fileSink.close();
      }
    }
  }

  Future<void> _initializeModel() async {
    try {
      _status = ModelStatus.initializing;
      notifyListeners();

      final gemma = FlutterGemmaPlugin.instance;
      final modelManager = gemma.modelManager;
      
      // Set the model path (this is the key step from the example!)
      final filePath = await _getModelFilePath();
      await modelManager.setModelPath(filePath);
      
      // Create the inference model with multimodal support
      _inferenceModel = await gemma.createModel(
        modelType: ModelType.gemmaIt,
        maxTokens: 4096, // Increased for multimodal model
        preferredBackend: PreferredBackend.gpu,
        supportImage: true, // Enable image support for Gemma 3N E2B
        maxNumImages: 1, // Support up to 1 image per message
      );

      // Create a chat instance for conversation management with image support
      _chat = await _inferenceModel!.createChat(
        temperature: 0.8,
        topK: 40,
        supportImage: true, // Enable image support in chat
      );

      _status = ModelStatus.ready;
      _errorMessage = null;
      notifyListeners();
      
      if (kDebugMode) {
        print('Model initialized successfully');
      }
    } catch (e) {
      _setError('Failed to initialize model: $e');
      if (kDebugMode) {
        print('Model initialization error: $e');
      }
    }
  }

  Future<String?> generateResponse(String prompt) async {
    if (_status != ModelStatus.ready || _chat == null) {
      throw Exception('Model is not ready. Current status: $_status');
    }

    try {
      // Create a message using the flutter_gemma Message class
      final message = gemma_message.Message.text(
        text: prompt,
        isUser: true,
      );

      // Add the message to the chat
      await _chat!.addQueryChunk(message);

      // Generate and return the response
      final response = await _chat!.generateChatResponse();
      
      if (kDebugMode) {
        print('Generated response: $response');
      }
      
      return response;
    } catch (e) {
      _setError('Failed to generate response: $e');
      if (kDebugMode) {
        print('Response generation error: $e');
      }
      return null;
    }
  }

  /// Generate response for multimodal input (text + image)
  Future<String?> generateMultimodalResponse(String prompt, Uint8List imageBytes) async {
    if (_status != ModelStatus.ready || _chat == null) {
      throw Exception('Model is not ready. Current status: $_status');
    }

    try {
      // Create a multimodal message using the flutter_gemma Message class
      final message = gemma_message.Message.withImage(
        text: prompt,
        imageBytes: imageBytes,
        isUser: true,
      );

      // Add the message to the chat
      await _chat!.addQueryChunk(message);

      // Generate and return the response
      final response = await _chat!.generateChatResponse();
      
      if (kDebugMode) {
        print('Generated multimodal response: $response');
      }
      
      return response;
    } catch (e) {
      _setError('Failed to generate multimodal response: $e');
      if (kDebugMode) {
        print('Multimodal response generation error: $e');
      }
      return null;
    }
  }

  Future<void> clearModel() async {
    try {
      // Close existing model and chat instances
      if (_chat != null) {
        _chat = null;
      }
      
      if (_inferenceModel != null) {
        await _inferenceModel!.close();
        _inferenceModel = null;
      }
      
      // Delete the model file
      final filePath = await _getModelFilePath();
      final file = File(filePath);
      if (file.existsSync()) {
        await file.delete();
      }
      
      // Clear the model from flutter_gemma
      final gemma = FlutterGemmaPlugin.instance;
      final modelManager = gemma.modelManager;
      await modelManager.deleteModel();
      
      _status = ModelStatus.notDownloaded;
      _downloadProgress = DownloadProgress.initial();
      _errorMessage = null;
      notifyListeners();
      
      if (kDebugMode) {
        print('Model cleared successfully');
      }
    } catch (e) {
      _setError('Failed to clear model: $e');
      if (kDebugMode) {
        print('Model clear error: $e');
      }
    }
  }

  void _setError(String message) {
    _status = ModelStatus.error;
    _errorMessage = message;
    _downloadProgress = DownloadProgress.error(message);
    notifyListeners();
    
    if (kDebugMode) {
      print('ModelManager Error: $message');
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_status == ModelStatus.error) {
      _status = ModelStatus.notDownloaded;
    }
    notifyListeners();
  }
} 