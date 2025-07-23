enum ModelStatus {
  notDownloaded,
  downloading,
  downloadComplete,
  initializing,
  ready,
  error,
}

class ModelInfo {
  final String name;
  final String version;
  final int sizeInBytes;
  final String downloadUrl;
  final String description;

  const ModelInfo({
    required this.name,
    required this.version,
    required this.sizeInBytes,
    required this.downloadUrl,
    required this.description,
  });

  String get sizeFormatted {
    if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    } else if (sizeInBytes < 1024 * 1024 * 1024) {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(sizeInBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}

class DownloadProgress {
  final int bytesDownloaded;
  final int totalBytes;
  final double percentage;
  final String? errorMessage;

  const DownloadProgress({
    required this.bytesDownloaded,
    required this.totalBytes,
    required this.percentage,
    this.errorMessage,
  });

  factory DownloadProgress.initial() {
    return const DownloadProgress(
      bytesDownloaded: 0,
      totalBytes: 0,
      percentage: 0.0,
    );
  }

  factory DownloadProgress.error(String message) {
    return DownloadProgress(
      bytesDownloaded: 0,
      totalBytes: 0,
      percentage: 0.0,
      errorMessage: message,
    );
  }
} 