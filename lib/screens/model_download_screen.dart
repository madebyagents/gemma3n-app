import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/model_manager.dart';
import '../models/model_status.dart';
import '../theme/app_colors.dart';
import '../theme/dimensions.dart';
import '../widgets/common/custom_app_bar.dart';

class ModelDownloadScreen extends StatefulWidget {
  const ModelDownloadScreen({super.key});

  @override
  State<ModelDownloadScreen> createState() => _ModelDownloadScreenState();
}

class _ModelDownloadScreenState extends State<ModelDownloadScreen> {
  final TextEditingController _tokenController = TextEditingController();
  bool _tokenObscured = true;
  String? _savedToken;

  @override
  void initState() {
    super.initState();
    _loadSavedToken();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedToken() async {
    final modelManager = context.read<ModelManager>();
    final token = await modelManager.getAuthToken();
    if (token != null) {
      setState(() {
        _savedToken = token;
        _tokenController.text = token;
      });
    }
  }

  Future<void> _saveToken() async {
    final token = _tokenController.text.trim();
    if (token.isNotEmpty) {
      final modelManager = context.read<ModelManager>();
      await modelManager.saveAuthToken(token);
      setState(() {
        _savedToken = token;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Token saved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: const CustomAppBar(
        title: 'Model Setup',
      ),
      body: Consumer<ModelManager>(
        builder: (context, modelManager, child) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimensions.spaceLG),
                  
                  // Model Info Card
                  _buildModelInfoCard(modelManager),
                  
                  const SizedBox(height: AppDimensions.spaceLG),
                  
                  // Token Input Section
                  _buildTokenInputSection(),
                  
                  const SizedBox(height: AppDimensions.spaceLG),
                  
                  // Status Section
                  _buildStatusSection(modelManager),
                  
                  const SizedBox(height: AppDimensions.spaceLG),
                  
                  // Progress Section
                  if (modelManager.isDownloading)
                    _buildProgressSection(modelManager),
                  
                  const Spacer(),
                  
                  // Action Button
                  _buildActionButton(context, modelManager),
                  
                  const SizedBox(height: AppDimensions.spaceLG),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModelInfoCard(ModelManager modelManager) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  size: 32,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: AppDimensions.spaceMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gemma 3N E2B IT',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGray,
                        ),
                      ),
                      Text(
                        'Multimodal instruction-tuned model',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            Text(
              'A multimodal 1.5B parameter model with vision capabilities, optimized for on-device inference. Supports both text and image inputs for advanced conversational AI tasks.',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.darkGray,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceSM),
            Row(
              children: [
                Icon(
                  Icons.storage,
                  size: 16,
                  color: AppColors.mediumGray,
                ),
                const SizedBox(width: AppDimensions.spaceXS),
                Text(
                  'Size: ~3.1GB',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mediumGray,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenInputSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.key,
                  size: 20,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: AppDimensions.spaceSM),
                Text(
                  'Hugging Face Authentication',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceSM),
            TextField(
              controller: _tokenController,
              obscureText: _tokenObscured,
              decoration: InputDecoration(
                hintText: 'Enter your Hugging Face token',
                hintStyle: const TextStyle(color: AppColors.mediumGray),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  borderSide: const BorderSide(color: AppColors.lightGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  borderSide: const BorderSide(color: AppColors.primaryBlue),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _tokenObscured ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.mediumGray,
                      ),
                      onPressed: () {
                        setState(() {
                          _tokenObscured = !_tokenObscured;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.save,
                        color: AppColors.primaryBlue,
                      ),
                      onPressed: _saveToken,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceSM),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.mediumGray,
                ),
                children: [
                  const TextSpan(
                    text: 'Need a token? Create one at ',
                  ),
                  TextSpan(
                    text: 'huggingface.co/settings/tokens',
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse('https://huggingface.co/settings/tokens'));
                      },
                  ),
                  const TextSpan(
                    text: ' with read access.',
                  ),
                ],
              ),
            ),
            if (_savedToken != null)
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.spaceSM),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: AppDimensions.spaceXS),
                    Text(
                      'Token saved',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(ModelManager modelManager) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (modelManager.status) {
      case ModelStatus.notDownloaded:
        statusText = 'Ready to Download';
        statusColor = AppColors.warning;
        statusIcon = Icons.download;
        break;
      case ModelStatus.downloading:
        statusText = 'Downloading...';
        statusColor = AppColors.primaryBlue;
        statusIcon = Icons.downloading;
        break;
      case ModelStatus.downloadComplete:
        statusText = 'Download Complete';
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case ModelStatus.initializing:
        statusText = 'Initializing Model...';
        statusColor = AppColors.primaryBlue;
        statusIcon = Icons.sync;
        break;
      case ModelStatus.ready:
        statusText = 'Model Ready';
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case ModelStatus.error:
        statusText = 'Error';
        statusColor = AppColors.error;
        statusIcon = Icons.error;
        break;
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Row(
          children: [
            Icon(
              statusIcon,
              color: statusColor,
              size: 24,
            ),
            const SizedBox(width: AppDimensions.spaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mediumGray,
                    ),
                  ),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                  if (modelManager.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        modelManager.errorMessage!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(ModelManager modelManager) {
    final progress = modelManager.downloadProgress;
    
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Download Progress',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGray,
                  ),
                ),
                Text(
                  '${progress.percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceSM),
            LinearProgressIndicator(
              value: progress.percentage / 100,
              backgroundColor: AppColors.lightGray,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
            const SizedBox(height: AppDimensions.spaceSM),
            Text(
              '${_formatBytes(progress.bytesDownloaded)} / ${_formatBytes(progress.totalBytes)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.mediumGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, ModelManager modelManager) {
    String buttonText;
    VoidCallback? onPressed;
    bool isLoading = false;

    switch (modelManager.status) {
      case ModelStatus.notDownloaded:
        buttonText = 'Download Model';
        onPressed = () {
          final token = _tokenController.text.trim();
          if (token.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter your Hugging Face token first'),
                backgroundColor: AppColors.error,
              ),
            );
            return;
          }
          modelManager.downloadModel(authToken: token);
        };
        break;
      case ModelStatus.downloading:
        buttonText = 'Downloading...';
        onPressed = null;
        isLoading = true;
        break;
      case ModelStatus.downloadComplete:
      case ModelStatus.initializing:
        buttonText = 'Initializing...';
        onPressed = null;
        isLoading = true;
        break;
      case ModelStatus.ready:
        buttonText = 'Start Chatting';
        onPressed = () => Navigator.of(context).pop();
        break;
      case ModelStatus.error:
        buttonText = 'Retry';
        onPressed = () {
          modelManager.clearError();
          final token = _tokenController.text.trim();
          modelManager.downloadModel(authToken: token.isNotEmpty ? token : null);
        };
        break;
    }

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
} 