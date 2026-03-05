import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show BitmapDescriptor;
import '../models/marker_config.dart';
import '../models/marker_type.dart';

/// Abstract base class for map-specific marker adapters
///
/// Each map provider (Google Maps, Flutter Map) implements this
/// interface to provide consistent marker rendering.
abstract class BaseMarkerAdapter {
  /// Builds a Flutter widget representing the marker
  ///
  /// Used by FlutterMap and for preview purposes
  Widget buildMarker(
    MarkerConfig config, {
    VoidCallback? onTap,
    bool isSelected = false,
  });

  /// Converts a marker configuration to a BitmapDescriptor
  ///
  /// Used by Google Maps which requires bitmaps for markers
  Future<BitmapDescriptor> buildBitmapDescriptor(
    MarkerConfig config,
  );

  /// Creates a marker with label positioned below it
  Widget buildMarkerWithLabel(
    MarkerConfig config, {
    VoidCallback? onTap,
    Offset labelOffset = const Offset(0, 8),
  });

  /// Validates if the adapter supports the given marker type
  bool supportsMarkerType(MarkerType type);

  /// Gets the approximate hit-test radius for the marker
  double getHitTestRadius(MarkerConfig config);

  /// Creates a complete marker widget with all features
  Widget buildCompleteMarker({
    required MarkerConfig config,
    VoidCallback? onTap,
    bool isSelected = false,
  });
}
