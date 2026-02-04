import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

class OfflineMapService {
  static const String storeName = 'darEsSalaamMapCache';
  
  static const LatLng darNorthWest = LatLng(-6.30, 39.00);
  static const LatLng darSouthEast = LatLng(-7.20, 39.60);

  static Future<void> initialize() async {
    try {
      await FMTCObjectBoxBackend().initialise();
      await _ensureStoreExists();
      debugPrint('✅ Offline map initialized');
    } catch (e) {
      debugPrint('❌ Init error: $e');
    }
  }

  static Future<void> _ensureStoreExists() async {
    final store = FMTCStore(storeName);
    if (!await store.manage.ready) {
      await store.manage.create();
    }
  }

  static Future<void> downloadDarMap({
    required Function(DownloadProgress) onProgress,
    required VoidCallback onComplete,
    required Function(Object) onError,
  }) async {
    try {
      await _ensureStoreExists();
      final store = FMTCStore(storeName);
      final region = RectangleRegion(LatLngBounds(darNorthWest, darSouthEast));

      final download = store.download.startForeground(
        region: region.toDownloadable(
          minZoom: 8,
          maxZoom: 17,
          options: TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
        ),
      );

      await for (final progress in download.downloadProgress) {
        onProgress(progress);
      }
      
      onComplete();
    } catch (e) {
      onError(e);
    }
  }

  static Future<MapDownloadStatus> getDownloadStatus() async {
    try {
      final store = FMTCStore(storeName);
      final stats = await store.stats.all;
      return MapDownloadStatus(
        isDownloaded: stats.length > 1000,
        tilesCount: stats.length,
        sizeInMB: stats.size / (1024 * 1024),
      );
    } catch (e) {
      return MapDownloadStatus(isDownloaded: false, tilesCount: 0, sizeInMB: 0);
    }
  }

  static Future<void> deleteOfflineMap() async {
    try {
      final store = FMTCStore(storeName);
      await store.manage.delete();
      await _ensureStoreExists();
    } catch (e) {
      debugPrint('❌ Delete error: $e');
    }
  }

  static TileLayer getTileLayer() {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      tileProvider: FMTCStore(storeName).getTileProvider(),
      userAgentPackageName: 'com.kinondoni.openspace',
      maxZoom: 19,
    );
  }
}

class MapDownloadStatus {
  final bool isDownloaded;
  final int tilesCount;
  final double sizeInMB;

  MapDownloadStatus({
    required this.isDownloaded,
    required this.tilesCount,
    required this.sizeInMB,
  });
}
