import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'weather_map_debug_log.dart';

/// Programmatic camera moves for the weather map (keeps logic out of the page widget).
class WeatherMapCamera {
  WeatherMapCamera._();

  /// Pans to [target] while preserving current zoom (rotation is unchanged by [MapController.move]).
  /// If [onlyIfOutsideView] is true and [target] is already inside [MapCamera.visibleBounds], does nothing.
  static void panToPreserveZoom(
    MapController controller,
    LatLng target, {
    required double fallbackZoom,
    required String reason,
    bool onlyIfOutsideView = false,
  }) {
    try {
      final cam = controller.camera;
      if (onlyIfOutsideView && cam.visibleBounds.contains(target)) {
        WeatherMapDebugLog.panSkipped(reason, 'target_already_visible');
        return;
      }
      final z = cam.zoom.isFinite ? cam.zoom : fallbackZoom;
      WeatherMapDebugLog.panApplied(target, z, reason);
      controller.move(target, z);
    } catch (_) {
      try {
        WeatherMapDebugLog.panApplied(target, fallbackZoom, '$reason (fallback_zoom)');
        controller.move(target, fallbackZoom);
      } catch (_) {}
    }
  }
}
