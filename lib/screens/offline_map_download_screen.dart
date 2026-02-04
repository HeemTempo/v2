import 'package:flutter/material.dart';
import 'package:kinondoni_openspace_app/service/offline_map_service.dart';
import 'package:kinondoni_openspace_app/utils/constants.dart';
import 'package:kinondoni_openspace_app/l10n/app_localizations.dart';

class OfflineMapDownloadScreen extends StatefulWidget {
  const OfflineMapDownloadScreen({super.key});

  @override
  State<OfflineMapDownloadScreen> createState() => _OfflineMapDownloadScreenState();
}

class _OfflineMapDownloadScreenState extends State<OfflineMapDownloadScreen> {
  bool _isDownloading = false;
  bool _isDownloaded = false;
  double _progress = 0.0;
  int _tilesDownloaded = 0;
  final int _totalTiles = 0;
  double _sizeInMB = 0.0;
  String _statusMessage = 'Ready to download';

  @override
  void initState() {
    super.initState();
    _checkDownloadStatus();
  }

  Future<void> _checkDownloadStatus() async {
    final status = await OfflineMapService.getDownloadStatus();
    setState(() {
      _isDownloaded = status.isDownloaded;
      _tilesDownloaded = status.tilesCount;
      _sizeInMB = status.sizeInMB;
      _statusMessage = status.isDownloaded 
          ? 'Map downloaded (${status.sizeInMB.toStringAsFixed(1)} MB)'
          : 'No offline map available';
    });
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _progress = 0.0;
      _statusMessage = 'Preparing download...';
    });

    await OfflineMapService.downloadDarMap(
      onProgress: (progress) {
        if (!mounted) return;
        setState(() {
          _progress = progress.percentageProgress / 100;
          _statusMessage = 'Downloading: ${progress.percentageProgress.toStringAsFixed(1)}%';
        });
      },
      onComplete: () {
        if (!mounted) return;
        setState(() {
          _isDownloading = false;
          _isDownloaded = true;
          _statusMessage = 'Download complete!';
        });
        _checkDownloadStatus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Dar es Salaam map downloaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _isDownloading = false;
          _statusMessage = 'Download failed';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Download failed: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  Future<void> _deleteMap() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteOfflineMap),
        content: Text(AppLocalizations.of(context)!.mapDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await OfflineMapService.deleteOfflineMap();
      _checkDownloadStatus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.mapDeleteSuccess)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[850] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.grey[400] : Colors.grey[700];
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.offlineMapsTitle),
        backgroundColor: isDark ? Colors.grey[850] : AppConstants.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(cardColor, textColor, subtextColor),
            const SizedBox(height: 24),
            _buildStatusCard(cardColor, textColor, subtextColor, isDark),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Color? cardColor, Color textColor, Color? subtextColor) {
    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppConstants.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  'About Offline Maps',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Download Dar es Salaam map for offline use. This allows you to view the map and navigate even without internet connection.',
              style: TextStyle(fontSize: 14, height: 1.5, color: textColor),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.map, 'Region', 'Dar es Salaam', subtextColor),
            _buildInfoRow(Icons.layers, 'Zoom Levels', '8-17', subtextColor),
            _buildInfoRow(Icons.storage, 'Estimated Size', '~800-1200 MB', subtextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color? subtextColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: subtextColor),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: subtextColor)),
        ],
      ),
    );
  }

  Widget _buildStatusCard(Color? cardColor, Color textColor, Color? subtextColor, bool isDark) {
    final bgColor = _isDownloaded 
        ? (isDark ? Colors.green[900] : Colors.green[50])
        : (isDark ? Colors.grey[800] : Colors.grey[100]);
    
    return Card(
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isDownloaded ? Icons.check_circle : Icons.cloud_download,
                  color: _isDownloaded ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _statusMessage,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
                  ),
                ),
              ],
            ),
            if (_isDownloading) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryBlue),
              ),
              const SizedBox(height: 8),
              Text(
                'Progress: ${(_progress * 100).toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 12, color: subtextColor),
              ),
            ],
            if (_isDownloaded && !_isDownloading) ...[
              const SizedBox(height: 8),
              Text(
                '📦 ${_sizeInMB.toStringAsFixed(1)} MB cached',
                style: TextStyle(fontSize: 12, color: subtextColor),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_isDownloaded && !_isDownloading)
          ElevatedButton.icon(
            onPressed: _startDownload,
            icon: const Icon(Icons.download),
            label: Text(AppLocalizations.of(context)!.downloadOfflineMap),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
          ),
        if (_isDownloading)
          ElevatedButton.icon(
            onPressed: null,
            icon: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            label: const Text('Downloading...'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        if (_isDownloaded && !_isDownloading) ...[
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.check),
            label: const Text('Map Ready - Go to Map'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _deleteMap,
            icon: const Icon(Icons.delete_outline),
            label: Text(AppLocalizations.of(context)!.deleteOfflineMap),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ],
    );
  }
}
