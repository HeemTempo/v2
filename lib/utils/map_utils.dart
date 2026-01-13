
import 'package:flutter_map/flutter_map.dart';

void zoomIn(MapController controller) {
controller.move(controller.camera.center, controller.camera.zoom + 1);
}

void zoomOut(MapController controller) {
controller.move(controller.camera.center, controller.camera.zoom - 1);
}
