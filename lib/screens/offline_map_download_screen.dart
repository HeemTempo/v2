import 'package:flutter/material.dart';
import 'package:kinondoni_openspace_app/service/offline_map_service.dart';
import 'package:kinondoni_openspace_app/utils/constants.dart';

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
  int _totalTiles = 0;
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
        title: const Text('Delete Offline Map?'),
        content: const Text('This will free up storage space but you\'ll need to download again for offline use.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
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
          const SnackBar(content: Text('Offline map deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Maps'),
        backgroundColor: AppConstants.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildStatusCard(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppConstants.primaryBlue),
                const SizedBox(width: 8),
                const Text(
                  'About Offline Maps',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Download Dar es Salaam map for offline use. This allows you to view the map and navigate even without internet connection.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.map, 'Region', 'Dar es Salaam'),
            _buildInfoRow(Icons.layers, 'Zoom Levels', '8-17'),
            _buildInfoRow(Icons.storage, 'Estimated Size', '~800-1200 MB'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      color: _isDownloaded ? Colors.green[50] : Colors.grey[100],
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
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (_isDownloading) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryBlue),
              ),
              const SizedBox(height: 8),
              Text(
                'Progress: ${(_progress * 100).toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
            if (_isDownloaded && !_isDownloading) ...[
              const SizedBox(height: 8),
              Text(
                '📦 ${_sizeInMB.toStringAsFixed(1)} MB cached',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
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
            label: const Text('Download Dar es Salaam Map'),
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
            label: const Text('Delete Offline Map'),
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
