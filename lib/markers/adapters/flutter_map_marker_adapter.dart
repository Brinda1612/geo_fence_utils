import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show BitmapDescriptor;
import '../../models/geo_point.dart';
import '../models/marker_config.dart';
import '../models/marker_type.dart';
import '../painters/svg_marker_painter.dart';
import '../widgets/marker_label.dart';
import 'base_marker_adapter.dart';

/// Marker adapter for FlutterMap (OpenStreetMap)
class FlutterMapMarkerAdapter extends BaseMarkerAdapter {
  FlutterMapMarkerAdapter();

  @override
  bool supportsMarkerType(MarkerType type) => true;

  @override
  double getHitTestRadius(MarkerConfig config) {
    return config.size / 2;
  }

  @override
  Widget buildMarker(
    MarkerConfig config, {
    VoidCallback? onTap,
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: config.opacity,
        child: Transform.rotate(
          angle: config.rotation * 3.14159 / 180,
          child: _buildMarkerWidget(config),
        ),
      ),
    );
  }

  Widget _buildMarkerWidget(MarkerConfig config) {
    switch (config.type) {
      case MarkerType.svgCustom:
        return CustomPaint(
          size: Size(config.size, config.size * config.type.aspectRatio),
          painter: SvgMarkerPainter(
            svgPath: config.svgPath!,
            color: config.color,
            borderColor: config.borderColor,
            borderWidth: config.borderWidth,
            enableShadow: config.enableShadow,
          ),
        );

      case MarkerType.pngAsset:
        return SizedBox(
          width: config.size,
          height: config.size,
          child: Image.asset(
            config.pngAssetPath!,
            width: config.size,
            height: config.size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Show a fallback if the image fails to load
              return Container(
                width: config.size,
                height: config.size,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: config.borderColor,
                    width: config.borderWidth,
                  ),
                ),
                child: Icon(
                  Icons.error,
                  color: Colors.white,
                  size: config.size * 0.5,
                ),
              );
            },
          ),
        );
    }
  }

  @override
  Widget buildMarkerWithLabel(
    MarkerConfig config, {
    VoidCallback? onTap,
    Offset labelOffset = const Offset(0, 8),
  }) {
    final marker = buildMarker(config, onTap: onTap);

    if (config.label == null) {
      return marker;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MarkerLabel(
          label: config.label!,
          backgroundColor: config.labelBackgroundColor,
          textColor: config.labelColor,
          fontSize: config.labelFontSize,
        ),
        SizedBox(height: labelOffset.dy),
        marker,
      ],
    );
  }

  @override
  Widget buildCompleteMarker({
    required MarkerConfig config,
    VoidCallback? onTap,
    bool isSelected = false,
  }) {
    // Don't show labels by default - info windows shown on tap instead
    return buildMarker(config, onTap: onTap, isSelected: isSelected);
  }

  /// Build marker with label (kept for backward compatibility)
  Widget buildMarkerWithLabelInfo(
    MarkerConfig config, {
    VoidCallback? onTap,
    Offset labelOffset = const Offset(0, 8),
  }) {
    return buildMarkerWithLabel(
      config,
      onTap: onTap,
      labelOffset: labelOffset,
    );
  }

  @override
  Future<BitmapDescriptor> buildBitmapDescriptor(
    MarkerConfig config,
  ) async {
    // For FlutterMap, we don't need BitmapDescriptor
    // This is mainly for Google Maps compatibility
    throw UnimplementedError(
      'FlutterMap uses widgets directly, not BitmapDescriptor',
    );
  }

  /// Creates a flutter_map Marker from configuration
  Marker createMapMarker({
    required String id,
    required GeoPoint position,
    required MarkerConfig config,
    VoidCallback? onTap,
  }) {
    // Calculate proper alignment based on marker config
    final alignment = _getMarkerAlignment(config);

    return Marker(
      point: LatLng(position.latitude, position.longitude),
      width: config.size,
      height: config.size * config.type.aspectRatio,
      alignment: alignment,
      child: buildCompleteMarker(
        config: config,
        onTap: onTap,
      ),
    );
  }

  /// Get the proper alignment for the marker based on its type
  Alignment _getMarkerAlignment(MarkerConfig config) {
    // Convert 0.0-1.0 range to -1.0 to 1.0 range for Alignment
    return Alignment(
      (config.anchorX * 2) - 1,
      (config.anchorY * 2) - 1,
    );
  }
}
