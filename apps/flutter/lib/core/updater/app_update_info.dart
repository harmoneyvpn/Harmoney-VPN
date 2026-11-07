/// Model representing the metadata and downloadable asset of an app release.
class AppUpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String tagName;
  final String releaseTitle;
  final String releaseNotes;
  final DateTime? releaseDate;
  final String assetName;
  final String downloadUrl;
  final int fileSize;
  final bool hasUpdate;
  final String htmlUrl;

  const AppUpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.tagName,
    required this.releaseTitle,
    required this.releaseNotes,
    this.releaseDate,
    required this.assetName,
    required this.downloadUrl,
    required this.fileSize,
    required this.hasUpdate,
    required this.htmlUrl,
  });

  /// Human-readable file size (e.g. "25.6 MB").
  String get formattedFileSize {
    if (fileSize <= 0) return '';
    if (fileSize >= 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    if (fileSize >= 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSize / 1024).toStringAsFixed(0)} KB';
  }

  @override
  String toString() =>
      'AppUpdateInfo(current: $currentVersion, latest: $latestVersion, hasUpdate: $hasUpdate, asset: $assetName, size: $formattedFileSize)';
}

