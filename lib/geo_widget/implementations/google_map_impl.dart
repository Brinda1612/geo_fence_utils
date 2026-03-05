import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show BitmapDescriptor, CameraPosition, Cap, Circle, CircleId, GoogleMap, InfoWindow, JointType, LatLng, Marker, MarkerId, MinMaxZoomPreference, MapType, Polygon, PolygonId, Polyline, PolylineId;
import '../../models/geo_point.dart';
import '../../extensions/geo_point_extensions.dart';
import '../geo_geofence_base.dart';
import '../geo_circle_widget.dart';
import '../geo_polygon_widget.dart';
import '../geo_polyline_widget.dart';
import '../geo_marker_widget.dart';
import '../builders/circle_overlay_builder.dart';
import '../builders/polygon_overlay_builder.dart';
import '../builders/polyline_overlay_builder.dart';
import '../../markers/factory/marker_factory.dart';
import '../../markers/adapters/google_map_marker_adapter.dart';

// Callback type for marker tap
typedef OnMarkerTap = void Function(String markerId);

/// Google Maps implementation using google_maps_flutter package.
///
/// This implementation provides access to Google Maps with all its features.
/// Requires a valid Google Maps API key.
///
/// **Example:**
/// ```dart
/// GoogleMapImpl(
///   center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
///   zoom: 13.0,
///   googleMapsApiKey: 'YOUR_API_KEY',
///   geofences: [
///     GeoCircleWidget.withRadius(
///       center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
///       radius: 500,
///     ),
///   ],
/// )
/// ```
class GoogleMapImpl extends StatefulWidget {
  /// The center point of the map.
  final GeoPoint center;

  /// Initial zoom level.
  final double zoom;

  /// List of geofences to display.
  final List<GeoGeofenceBase> geofences;

  /// List of markers to display.
  final List<GeoMarkerWidget> markers;

  /// Google Maps API key.
  final String googleMapsApiKey;

  /// Callback when a geofence is tapped.
  final OnGeofenceTap? onGeofenceTap;

  /// Callback when a marker is tapped.
  final OnMarkerTap? onMarkerTap;

  /// Callback when the map is tapped.
  final OnMapTap? onMapTap;

  /// Callback when the map is long pressed.
  final OnMapLongPress? onMapLongPress;

  /// Whether to show zoom controls.
  final bool showZoomControls;

  /// Whether to show compass.
  final bool showCompass;

  /// Whether to show "my location" button.
  final bool showMyLocationButton;

  /// Minimum zoom level.
  final double minZoom;

  /// Maximum zoom level.
  final double maxZoom;

  /// Initial map rotation (in degrees).
  final double rotation;

  /// Whether the map can be rotated by user gestures.
  final bool enableRotation;

  /// Whether the map can be zoomed by user gestures.
  final bool enableZoom;

  const GoogleMapImpl({
    super.key,
    required this.center,
    required this.zoom,
    required this.geofences,
    this.markers = const [],
    required this.googleMapsApiKey,
    this.onGeofenceTap,
    this.onMarkerTap,
    this.onMapTap,
    this.onMapLongPress,
    this.showZoomControls = true,
    this.showCompass = true,
    this.showMyLocationButton = true,
    this.minZoom = 2.0,
    this.maxZoom = 18.0,
    this.rotation = 0.0,
    this.enableRotation = true,
    this.enableZoom = true,
  });

  @override
  State<GoogleMapImpl> createState() => _GoogleMapImplState();
}

class _GoogleMapImplState extends State<GoogleMapImpl> {
  final Set<Circle> _circles = {};
  final Set<Polygon> _polygons = {};
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  bool _isMarkersLoaded = false;

  static final _adapter = GoogleMapMarkerAdapter();

  @override
  void initState() {
    super.initState();
    // Load overlays after the frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buildOverlays();
      _loadMarkersAsync();
    });
  }

  @override
  void didUpdateWidget(GoogleMapImpl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.geofences != widget.geofences) {
      _buildOverlays();
    }
    if (oldWidget.markers != widget.markers) {
      _loadMarkersAsync();
    }
  }

  void _buildOverlays() {
    _circles.clear();
    _polygons.clear();
    _polylines.clear();

    for (final geofence in widget.geofences) {
      if (geofence is GeoCircleWidget) {
        _circles.add(
          CircleOverlayBuilder.buildGoogleMap(
            geofence,
            widget.onGeofenceTap,
          ),
        );
      } else if (geofence is GeoPolygonWidget) {
        _polygons.add(
          PolygonOverlayBuilder.buildGoogleMap(
            geofence,
            widget.onGeofenceTap,
          ),
        );
      } else if (geofence is GeoPolylineWidget) {
        _polylines.add(
          PolylineOverlayBuilder.buildGoogleMap(
            geofence,
            widget.onGeofenceTap,
          ),
        );
      }
    }

    // Trigger rebuild after overlays are built
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadMarkersAsync() async {
    _markers.clear();
    _isMarkersLoaded = false;

    // Load regular markers
    for (final marker in widget.markers) {
      final config = marker.effectiveConfig;
      final bitmapDescriptor = await _adapter.buildBitmapDescriptor(config);

      _markers.add(Marker(
        markerId: MarkerId(marker.id),
        position: marker.position.toGoogleLatLng(),
        icon: bitmapDescriptor,
        onTap: marker.isInteractive && widget.onMarkerTap != null
            ? () => widget.onMarkerTap!(marker.id)
            : null,
        alpha: config.opacity,
        zIndex: config.zIndex.toDouble(),
        infoWindow: config.label != null
            ? InfoWindow(title: config.label)
            : InfoWindow.noText,
      ));
    }

    // Load center markers from circles
    for (final geofence in widget.geofences) {
      if (geofence is GeoCircleWidget && geofence.centerMarker != null) {
        final circleCenterMarkerId = '${geofence.id}_center_marker';
        final config = geofence.centerMarker!;
        final bitmapDescriptor = await _adapter.buildBitmapDescriptor(config);

        _markers.add(Marker(
          markerId: MarkerId(circleCenterMarkerId),
          position: geofence.center.toGoogleLatLng(),
          icon: bitmapDescriptor,
          onTap: geofence.isInteractive && widget.onMarkerTap != null
              ? () => widget.onMarkerTap!(circleCenterMarkerId)
              : null,
          alpha: config.opacity,
          zIndex: config.zIndex.toDouble(),
          infoWindow: config.label != null
              ? InfoWindow(title: config.label)
              : InfoWindow.noText,
        ));
      }
    }

    setState(() {
      _isMarkersLoaded = true;
    });
  }

  void _handleMapTap(LatLng latLng) {
    if (widget.onMapTap != null) {
      widget.onMapTap!(latLng.toGeoPoint());
    }
  }

  void _handleMapLongPress(LatLng latLng) {
    if (widget.onMapLongPress != null) {
      widget.onMapLongPress!(latLng.toGeoPoint());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.center.toGoogleLatLng(),
            zoom: widget.zoom,
            bearing: widget.rotation,
          ),
          circles: _circles,
          polygons: _polygons,
          polylines: _polylines,
          markers: _markers,
          onTap: _handleMapTap,
          onLongPress: _handleMapLongPress,
          zoomControlsEnabled: widget.showZoomControls,
          compassEnabled: widget.showCompass,
          myLocationButtonEnabled: widget.showMyLocationButton,
          minMaxZoomPreference: MinMaxZoomPreference(widget.minZoom, widget.maxZoom),
          rotateGesturesEnabled: widget.enableRotation,
          zoomGesturesEnabled: widget.enableZoom,
          myLocationEnabled: false,
          mapType: MapType.normal,
          buildingsEnabled: true,
          trafficEnabled: false,
        ),
        if (!_isMarkersLoaded)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text('Loading markers...'),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
