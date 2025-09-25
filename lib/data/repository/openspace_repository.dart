import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:openspace_mobile_app/model/openspace.dart';
import 'package:openspace_mobile_app/data/local/openspace_local.dart';
import 'package:openspace_mobile_app/service/openspace_service.dart';

class OpenSpaceRepository {
  final OpenSpaceService remoteService;
  final OpenSpaceLocal localService;

  OpenSpaceRepository({
    required this.remoteService,
    required this.localService,
  });

  Future<List<OpenSpaceMarker>> getAllOpenSpaces() async {
    final connectivity = await Connectivity().checkConnectivity();

    if (connectivity == ConnectivityResult.none) {
      // offline → fetch from local DB
      print('[OpenSpaceRepository] No internet, using local DB');
      return await localService.getOpenSpaces();
    }

    try {
      // online → fetch from API
      print('[OpenSpaceRepository] Online, fetching from GraphQL');
      final markers = await remoteService.getAllOpenSpaces();

      // cache them locally
      await localService.saveOpenSpaces(markers);

      return markers;
    } catch (e) {
      print('[OpenSpaceRepository] Error fetching online: $e');

      // fallback to offline cache
      final cached = await localService.getOpenSpaces();
      if (cached.isNotEmpty) {
        print('[OpenSpaceRepository] Returning cached data');
        return cached;
      }

      rethrow;
    }
  }
}