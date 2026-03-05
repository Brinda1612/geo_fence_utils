import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/painting.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/geo_point.dart';
import '../models/marker_config.dart';
import '../models/marker_type.dart';
import '../painters/svg_marker_painter.dart';
import '../cache/marker_cache_manager.dart';
import 'base_marker_adapter.dart';

/// Fallback painter for PNG assets when used in painter contexts
class _PngFallbackPainter extends CustomPainter {
  final Color color;
  final double size;

  const _PngFallbackPainter({required this.color, required this.size});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Marker adapter for Google Maps
class GoogleMapMarkerAdapter extends BaseMarkerAdapter {
  GoogleMapMarkerAdapter();

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
    // For preview/debug purposes, render the widget
    return SizedBox(
      width: config.size,
      height: config.size * config.type.aspectRatio,
      child: _buildMarkerPainter(config),
    );
  }

  Widget _buildMarkerPainter(MarkerConfig config) {
    if (config.type == MarkerType.pngAsset) {
      return SizedBox(
        width: config.size,
        height: config.size,
        child: Image.asset(
          config.pngAssetPath!,
          width: config.size,
          height: config.size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
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
    return CustomPaint(
      painter: _getPainter(config),
      size: Size(config.size, config.size * config.type.aspectRatio),
    );
  }

  CustomPainter _getPainter(MarkerConfig config) {
    switch (config.type) {
      case MarkerType.svgCustom:
        return SvgMarkerPainter(
          svgPath: config.svgPath!,
          color: config.color,
          borderColor: config.borderColor,
          borderWidth: config.borderWidth,
          enableShadow: config.enableShadow,
        );
      case MarkerType.pngAsset:
        // PNG assets are handled separately in buildBitmapDescriptor
        // Return a fallback painter for preview purposes
        return _PngFallbackPainter(color: config.color, size: config.size);
    }
  }

  @override
  Future<BitmapDescriptor> buildBitmapDescriptor(
    MarkerConfig config,
  ) async {
    // Check cache first
    final cached = MarkerCacheManager.getCachedBitmapDescriptor(config);
    if (cached != null) {
      return cached;
    }

    BitmapDescriptor bitmapDescriptor;

    // Handle PNG assets
    if (config.type == MarkerType.pngAsset) {
      bitmapDescriptor = await _loadPngAsset(config);
    } else {
      // Generate new bitmap from painter
      final size = Size(config.size, config.size * config.type.aspectRatio);

      // Create a picture recorder and canvas
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Draw the marker
      final painter = _getPainter(config);
      painter.paint(canvas, size);

      // Convert to bitmap
      final picture = recorder.endRecording();
      // Use a fixed devicePixelRatio for consistency
      const devicePixelRatio = 2.0;
      final image = await picture.toImage(
        (size.width * devicePixelRatio).toInt(),
        (size.height * devicePixelRatio).toInt(),
      );

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw StateError('Failed to convert image to bytes');
      }

      final bytes = byteData.buffer.asUint8List();

      bitmapDescriptor = BitmapDescriptor.bytes(bytes);
    }

    // Cache the result
    MarkerCacheManager.putBitmapDescriptor(config, bitmapDescriptor);

    return bitmapDescriptor;
  }

  /// Load a PNG asset and convert it to BitmapDescriptor
  Future<BitmapDescriptor> _loadPngAsset(MarkerConfig config) async {
    try {
      final assetPath = config.pngAssetPath!;

      // For web, ensure the path starts correctly
      String normalizedPath = assetPath;
      if (!normalizedPath.startsWith('assets/') && !normalizedPath.startsWith('packages/')) {
        // Try to access the asset directly
        try {
          final byteData = await rootBundle.load(assetPath);
          final bytes = byteData.buffer.asUint8List();
          return BitmapDescriptor.bytes(bytes);
        } catch (e) {
          // Try with assets/ prefix
          try {
            final byteData = await rootBundle.load('assets/$assetPath');
            final bytes = byteData.buffer.asUint8List();
            return BitmapDescriptor.bytes(bytes);
          } catch (e2) {
            print('Failed to load PNG from $assetPath or assets/$assetPath: $e');
            rethrow;
          }
        }
      }

      final byteData = await rootBundle.load(normalizedPath);
      final bytes = byteData.buffer.asUint8List();
      return BitmapDescriptor.bytes(bytes);
    } catch (e) {
      print('Error loading PNG asset: $e');
      // If loading fails, return a fallback marker
      return await _createFallbackMarker(config);
    }
  }

  /// Create a fallback marker when PNG loading fails
  Future<BitmapDescriptor> _createFallbackMarker(MarkerConfig config) async {
    final size = Size(config.size, config.size);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw a colored circle as fallback
    final paint = Paint()
      ..color = config.color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(config.size / 2, config.size / 2),
      config.size / 2,
      paint,
    );

    final borderPaint = Paint()
      ..color = config.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = config.borderWidth;
    canvas.drawCircle(
      Offset(config.size / 2, config.size / 2),
      config.size / 2 - config.borderWidth / 2,
      borderPaint,
    );

    final picture = recorder.endRecording();
    const devicePixelRatio = 2.0;
    final image = await picture.toImage(
      (size.width * devicePixelRatio).toInt(),
      (size.height * devicePixelRatio).toInt(),
    );

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Failed to convert fallback image to bytes');
    }

    final bytes = byteData.buffer.asUint8List();
    return BitmapDescriptor.bytes(bytes);
  }

  @override
  Widget buildMarkerWithLabel(
    MarkerConfig config, {
    VoidCallback? onTap,
    Offset labelOffset = const Offset(0, 8),
  }) {
    // Google Maps handles labels via InfoWindow
    // This is mainly for preview
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: config.labelBackgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            config.label ?? '',
            style: TextStyle(
              color: config.labelColor,
              fontSize: config.labelFontSize,
            ),
          ),
        ),
        SizedBox(height: labelOffset.dy),
        buildMarker(config, onTap: onTap),
      ],
    );
  }

  @override
  Widget buildCompleteMarker({
    required MarkerConfig config,
    VoidCallback? onTap,
    bool isSelected = false,
  }) {
    return buildMarkerWithLabel(
      config,
      onTap: onTap,
      labelOffset: const Offset(0, 8),
    );
  }

  /// Creates a Google Maps Marker from configuration
  Marker createMapMarker({
    required MarkerId markerId,
    required GeoPoint position,
    required MarkerConfig config,
    VoidCallback? onTap,
  }) {
    return Marker(
      markerId: markerId,
      position: LatLng(position.latitude, position.longitude),
      onTap: onTap,
      zIndex: config.zIndex.toDouble(),
      alpha: config.opacity,
      infoWindow: config.label != null
          ? InfoWindow(title: config.label)
          : InfoWindow.noText,
    );
  }

  /// Batch create markers with async bitmap generation
  Future<List<Marker>> createMarkersAsync({
    required List<Map<String, dynamic>> markerData,
    required MarkerConfig Function(int index) configBuilder,
  }) async {
    final markers = <Marker>[];

    for (int i = 0; i < markerData.length; i++) {
      final data = markerData[i];
      final config = configBuilder(i);
      final id = MarkerId(data['id'].toString());
      final position = GeoPoint(
        latitude: data['latitude'] as double,
        longitude: data['longitude'] as double,
      );

      final icon = await buildBitmapDescriptor(config);

      markers.add(Marker(
        markerId: id,
        position: LatLng(position.latitude, position.longitude),
        icon: icon,
        zIndex: config.zIndex.toDouble(),
        alpha: config.opacity,
        infoWindow: config.label != null
            ? InfoWindow(title: config.label)
            : InfoWindow.noText,
      ));
    }

    return markers;
  }
}
