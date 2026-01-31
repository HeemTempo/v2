import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

class OfflineMapService {
  static const String storeName = 'darEsSalaamMapCache';
  
  // Dar es Salaam region bounds (includes Kinondoni, Ilala, Temeke, Kigamboni, Ubungo)
  static const LatLng darNorthWest = LatLng(-6.30, 39.00);
  static const LatLng darSouthEast = LatLng(-7.20, 39.60);

  static Future<void> initialize() async {
    try {
      await FMTCObjectBoxBackend().initialise();
      await _ensureStoreExists();
      debugPrint('✅ Offline map service initialized');
    } catch (e) {
      debugPrint('❌ Error initializing offline map: $e');
    }
  }

  static Future<void> _ensureStoreExists() async {
    final store = FMTCStore(storeName);
    if (!await store.manage.ready) {
      await store.manage.create();
      debugPrint('✅ Map store created: $storeName');
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
      final region = RectangleRegion(
        LatLngBounds(darNorthWest, darSouthEast),
      );

      debugPrint('🗺️ Starting Dar es Salaam map download...');
      
      final downloadable = region.toDownloadable(
        minZoom: 8, // Allow zooming out further
        maxZoom: 17, // Good street detail
        options: TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
      );

      final download = store.download.startForeground(
        region: downloadable,
      );

      await for (final progress in download.downloadProgress) {
        onProgress(progress);
      }
      
      debugPrint('✅ Map download complete!');
      onComplete();
    } catch (e) {
      debugPrint('❌ Download error: $e');
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
      debugPrint('✅ Offline map deleted');
    } catch (e) {
      debugPrint('❌ Error deleting map: $e');
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
