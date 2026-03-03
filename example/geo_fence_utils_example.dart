import 'package:flutter/material.dart';
import 'package:geo_fence_utils/geo_fence_utils.dart';

void main() {
  runApp(const GeoFenceUtilsDemo());
}

class GeoFenceUtilsDemo extends StatefulWidget {
  const GeoFenceUtilsDemo({super.key});

  @override
  State<GeoFenceUtilsDemo> createState() => _GeoFenceUtilsDemoState();
}

class _GeoFenceUtilsDemoState extends State<GeoFenceUtilsDemo> {
  // Page navigation
  int _selectedPage = 0;

  // Map settings
  double _mapLatitude = 37.7749;
  double _mapLongitude = -122.4194;
  double _mapZoom = 13.0;
  MapProvider _mapProvider = MapProvider.flutterMap;
  String _googleMapsApiKey = '';

  // Circle settings
  bool _showCircle = true;
  double _circleRadius = 500;
  Color _circleFillColor = Colors.blue.withOpacity(0.3);
  Color _circleBorderColor = Colors.blue;
  double _circleStrokeWidth = 2.0;
  CirclePreset _circlePreset = CirclePreset.none;

  // Polygon settings
  bool _showPolygon = false;
  final List<GeoPoint> _polygonPoints = [];
  final List<TextEditingController> _polygonLatControllers = [];
  final List<TextEditingController> _polygonLngControllers = [];

  // Polyline settings
  bool _showPolyline = false;
  final List<GeoPoint> _polylinePoints = [];
  final List<TextEditingController> _polylineLatControllers = [];
  final List<TextEditingController> _polylineLngControllers = [];
  Color _polylineColor = Colors.red;
  double _polylineWidth = 4.0;

  // Status
  String? _tappedGeofenceId;
  String? _tappedLocation;

  @override
  void dispose() {
    for (var controller in [..._polygonLatControllers, ..._polygonLngControllers, ..._polylineLatControllers, ..._polylineLngControllers]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geo Fence Utils - Complete Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Geo Fence Utils Demo'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 900) {
              return _buildDesktopLayout();
            }
            return _buildMobileLayout();
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        SizedBox(
          width: 400,
          child: _buildControlPanel(),
        ),
        Expanded(
          child: _buildMapArea(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: _buildMapArea(),
        ),
        Expanded(
          flex: 3,
          child: _buildControlPanel(),
        ),
      ],
    );
  }

  Widget _buildControlPanel() {
    return Container(
      color: Colors.grey.shade100,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Page selector
          _buildPageSelector(),
          const SizedBox(height: 16),

          // Map settings
          _buildSectionTitle('Map Settings', Icons.map),
          const SizedBox(height: 8),
          _buildMapSettings(),
          const SizedBox(height: 16),

          // Page content
          _buildSelectedPageContent(),
        ],
      ),
    );
  }

  Widget _buildPageSelector() {
    return SegmentedButton<int>(
      segments: const [
        ButtonSegment(
          value: 0,
          label: Text('Circle'),
          icon: Icon(Icons.radio_button_unchecked),
        ),
        ButtonSegment(
          value: 1,
          label: Text('Polygon'),
          icon: Icon(Icons.change_history),
        ),
        ButtonSegment(
          value: 2,
          label: Text('Polyline'),
          icon: Icon(Icons.show_chart),
        ),
      ],
      selected: {_selectedPage},
      onSelectionChanged: (Set<int> newSelection) {
        setState(() {
          _selectedPage = newSelection.first;
        });
      },
    );
  }

  Widget _buildSelectedPageContent() {
    switch (_selectedPage) {
      case 0:
        return _buildCircleControls();
      case 1:
        return _buildPolygonControls();
      case 2:
        return _buildPolylineControls();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMapSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildLatLongInput('Map Center Latitude', _mapLatitude, (value) {
              _mapLatitude = double.tryParse(value) ?? _mapLatitude;
            }),
            const SizedBox(height: 8),
            _buildLatLongInput('Map Center Longitude', _mapLongitude, (value) {
              _mapLongitude = double.tryParse(value) ?? _mapLongitude;
            }),
            const SizedBox(height: 8),
            _buildZoomSlider(),
            const SizedBox(height: 8),
            _buildProviderSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleControls() {
    return Column(
      children: [
        _buildSectionTitle('Circle Geofence', Icons.circle_outlined),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Show Circle'),
          value: _showCircle,
          onChanged: (value) => setState(() => _showCircle = value),
        ),
        if (_showCircle) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildCirclePresetSelector(),
                  const SizedBox(height: 12),
                  _buildRadiusSlider(),
                  const SizedBox(height: 12),
                  _buildColorPickers(),
                  const SizedBox(height: 12),
                  _buildStrokeWidthSlider(),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _buildStatusCard(),
      ],
    );
  }

  Widget _buildPolygonControls() {
    return Column(
      children: [
        _buildSectionTitle('Polygon Geofence', Icons.change_history),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Show Polygon'),
          value: _showPolygon,
          onChanged: (value) => setState(() => _showPolygon = value),
        ),
        if (_showPolygon) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _addPolygonPoint,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Point'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _clearPolygonPoints,
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _loadPresetPolygon,
                        icon: const Icon(Icons.star),
                        label: const Text('Load Preset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildPointsList('Polygon Points', _polygonPoints, _polygonLatControllers, _polygonLngControllers, _updatePolygonPoint, _removePolygonPoint),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _buildStatusCard(),
      ],
    );
  }

  Widget _buildPolylineControls() {
    return Column(
      children: [
        _buildSectionTitle('Polyline Route', Icons.show_chart),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Show Polyline'),
          value: _showPolyline,
          onChanged: (value) => setState(() => _showPolyline = value),
        ),
        if (_showPolyline) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildPolylineColorPicker(),
                  const SizedBox(height: 12),
                  _buildPolylineWidthSlider(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _addPolylinePoint,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Point'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _clearPolylinePoints,
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _loadPresetPolyline,
                        icon: const Icon(Icons.star),
                        label: const Text('Load Preset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildPointsList('Polyline Points', _polylinePoints, _polylineLatControllers, _polylineLngControllers, _updatePolylinePoint, _removePolylinePoint),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _buildStatusCard(),
      ],
    );
  }

  Widget _buildPointsList(
    String title,
    List<GeoPoint> points,
    List<TextEditingController> latControllers,
    List<TextEditingController> lngControllers,
    Function(int, double, double) onUpdate,
    Function(int) onRemove,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (points.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No points added. Click "Add Point" to start.'),
            ),
          )
        else
          ...List.generate(points.length, (index) {
            // Ensure controllers exist
            while (latControllers.length <= index) {
              latControllers.add(TextEditingController());
            }
            while (lngControllers.length <= index) {
              lngControllers.add(TextEditingController());
            }
            // Set initial values
            if (latControllers[index].text.isEmpty) {
              latControllers[index].text = points[index].latitude.toString();
            }
            if (lngControllers[index].text.isEmpty) {
              lngControllers[index].text = points[index].longitude.toString();
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: latControllers[index],
                        decoration: const InputDecoration(
                          labelText: 'Lat',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        onChanged: (value) {
                          final lat = double.tryParse(value);
                          final lng = double.tryParse(lngControllers[index].text);
                          if (lat != null && lng != null) {
                            onUpdate(index, lat, lng);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: lngControllers[index],
                        decoration: const InputDecoration(
                          labelText: 'Lng',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        onChanged: (value) {
                          final lat = double.tryParse(latControllers[index].text);
                          final lng = double.tryParse(value);
                          if (lat != null && lng != null) {
                            onUpdate(index, lat, lng);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onRemove(index),
                      tooltip: 'Remove point',
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildMapArea() {
    final center = GeoPoint(latitude: _mapLatitude, longitude: _mapLongitude);
    final geofences = _buildGeofences();

    return Container(
      color: Colors.grey.shade300,
      child: Stack(
        children: [
          GeoGeofenceMap(
            center: center,
            zoom: _mapZoom,
            geofences: geofences,
            provider: _mapProvider,
            googleMapsApiKey: _googleMapsApiKey,
            showZoomControls: true,
            showCompass: true,
            onGeofenceTap: (id) {
              setState(() => _tappedGeofenceId = id);
              _showSnackBar('Tapped: $id');
            },
            onMapTap: (location) {
              setState(() {
                _tappedLocation = '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
              });
            },
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildMapStatusCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapStatusCard() {
    return Card(
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Map: ${_mapProvider.displayName}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Center: ${_mapLatitude.toStringAsFixed(4)}, ${_mapLongitude.toStringAsFixed(4)}'),
            Text('Zoom: ${_mapZoom.toStringAsFixed(1)}'),
            if (_tappedGeofenceId != null) Text('Tapped: $_tappedGeofenceId', style: const TextStyle(color: Colors.blue)),
            if (_tappedLocation != null) Text('Location: $_tappedLocation', style: const TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final geofences = _buildGeofences();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Active Geofences: ${geofences.length}'),
            if (_showCircle) Text('Circle Radius: ${_circleRadius.toInt()}m'),
            if (_showPolygon) Text('Polygon Points: ${_polygonPoints.length}'),
            if (_showPolyline) Text('Polyline Points: ${_polylinePoints.length}'),
          ],
        ),
      ),
    );
  }

  List<GeoGeofenceBase> _buildGeofences() {
    final center = GeoPoint(latitude: _mapLatitude, longitude: _mapLongitude);
    final geofences = <GeoGeofenceBase>[];

    if (_showCircle) {
      geofences.add(_createCircleGeofence(center));
    }

    if (_showPolygon && _polygonPoints.length >= 3) {
      geofences.add(
        GeoPolygonWidget(
          id: 'user_polygon',
          points: List.from(_polygonPoints),
          color: const Color(0x339C27B0),
          borderColor: const Color(0xFF9C27B0),
          strokeWidth: 2.0,
        ),
      );
    }

    if (_showPolyline && _polylinePoints.length >= 2) {
      geofences.add(
        GeoPolylineWidget(
          id: 'user_polyline',
          points: List.from(_polylinePoints),
          strokeColor: _polylineColor,
          width: _polylineWidth,
        ),
      );
    }

    return geofences;
  }

  GeoCircleWidget _createCircleGeofence(GeoPoint center) {
    switch (_circlePreset) {
      case CirclePreset.dangerZone:
        return GeoCircleWidget.dangerZone(center: center, radius: _circleRadius);
      case CirclePreset.safeZone:
        return GeoCircleWidget.safeZone(center: center, radius: _circleRadius);
      case CirclePreset.warningZone:
        return GeoCircleWidget.warningZone(center: center, radius: _circleRadius);
      case CirclePreset.noFlyZone:
        return GeoCircleWidget.noFlyZone(center: center, radius: _circleRadius);
      case CirclePreset.none:
      default:
        return GeoCircleWidget(
          id: 'user_circle',
          center: center,
          radius: _circleRadius,
          color: _circleFillColor,
          borderColor: _circleBorderColor,
          strokeWidth: _circleStrokeWidth,
        );
    }
  }

  // Control builders
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildLatLongInput(String label, double value, Function(String) onChanged) {
    final controller = TextEditingController(text: value.toString());
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      onChanged: onChanged,
    );
  }

  Widget _buildZoomSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Zoom'),
            Text(_mapZoom.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: _mapZoom,
          min: 2,
          max: 18,
          divisions: 16,
          label: _mapZoom.toStringAsFixed(1),
          onChanged: (value) => setState(() => _mapZoom = value),
        ),
      ],
    );
  }

  Widget _buildProviderSelector() {
    return SegmentedButton<MapProvider>(
      segments: const [
        ButtonSegment(
          value: MapProvider.flutterMap,
          label: Text('OSM'),
          icon: Icon(Icons.map_outlined),
        ),
        ButtonSegment(
          value: MapProvider.googleMap,
          label: Text('Google'),
          icon: Icon(Icons.map),
        ),
      ],
      selected: {_mapProvider},
      onSelectionChanged: (Set<MapProvider> selection) {
        final provider = selection.first;
        setState(() => _mapProvider = provider);
        if (provider == MapProvider.googleMap && _googleMapsApiKey.isEmpty) {
          _showApiKeyDialog();
        }
      },
    );
  }

  Widget _buildCirclePresetSelector() {
    return DropdownButtonFormField<CirclePreset>(
      value: _circlePreset,
      decoration: const InputDecoration(
        labelText: 'Preset Style',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: const [
        DropdownMenuItem(value: CirclePreset.none, child: Text('Custom')),
        DropdownMenuItem(value: CirclePreset.dangerZone, child: Text('Danger Zone (Red)')),
        DropdownMenuItem(value: CirclePreset.safeZone, child: Text('Safe Zone (Green)')),
        DropdownMenuItem(value: CirclePreset.warningZone, child: Text('Warning Zone (Orange)')),
        DropdownMenuItem(value: CirclePreset.noFlyZone, child: Text('No Fly Zone')),
      ],
      onChanged: (CirclePreset? preset) {
        if (preset != null) {
          setState(() => _circlePreset = preset);
          _applyCirclePreset(preset);
        }
      },
    );
  }

  Widget _buildRadiusSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Radius (meters)'),
            Text('${_circleRadius.toInt()}m', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: _circleRadius,
          min: 10,
          max: 5000,
          divisions: 100,
          label: '${_circleRadius.toInt()}m',
          onChanged: (value) => setState(() => _circleRadius = value),
        ),
      ],
    );
  }

  Widget _buildColorPickers() {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            title: const Text('Fill'),
            trailing: CircleAvatar(backgroundColor: _circleFillColor),
            onTap: () => _pickColor('fill'),
          ),
        ),
        Expanded(
          child: ListTile(
            title: const Text('Border'),
            trailing: CircleAvatar(backgroundColor: _circleBorderColor),
            onTap: () => _pickColor('border'),
          ),
        ),
      ],
    );
  }

  Widget _buildStrokeWidthSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Border Width'),
            Text('${_circleStrokeWidth.toInt()}px', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: _circleStrokeWidth,
          min: 1,
          max: 10,
          divisions: 18,
          label: '${_circleStrokeWidth.toInt()}px',
          onChanged: (value) => setState(() => _circleStrokeWidth = value),
        ),
      ],
    );
  }

  Widget _buildPolylineColorPicker() {
    return ListTile(
      title: const Text('Line Color'),
      trailing: CircleAvatar(backgroundColor: _polylineColor),
      onTap: () => _pickPolylineColor(),
    );
  }

  Widget _buildPolylineWidthSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Line Width'),
            Text('${_polylineWidth.toInt()}px', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: _polylineWidth,
          min: 1,
          max: 10,
          divisions: 18,
          label: '${_polylineWidth.toInt()}px',
          onChanged: (value) => setState(() => _polylineWidth = value),
        ),
      ],
    );
  }

  // Actions
  void _addPolygonPoint() {
    setState(() {
      _polygonPoints.add(GeoPoint(
        latitude: _mapLatitude + (DateTime.now().millisecond % 100 - 50) * 0.001,
        longitude: _mapLongitude + (DateTime.now().millisecond % 100 - 50) * 0.001,
      ));
    });
  }

  void _updatePolygonPoint(int index, double lat, double lng) {
    setState(() {
      _polygonPoints[index] = GeoPoint(latitude: lat, longitude: lng);
    });
  }

  void _removePolygonPoint(int index) {
    setState(() {
      _polygonPoints.removeAt(index);
      if (index < _polygonLatControllers.length) {
        _polygonLatControllers.removeAt(index);
      }
      if (index < _polygonLngControllers.length) {
        _polygonLngControllers.removeAt(index);
      }
    });
  }

  void _clearPolygonPoints() {
    setState(() {
      _polygonPoints.clear();
      _polygonLatControllers.clear();
      _polygonLngControllers.clear();
    });
  }

  void _loadPresetPolygon() {
    setState(() {
      _polygonPoints.clear();
      _polygonLatControllers.clear();
      _polygonLngControllers.clear();
      _polygonPoints.addAll([
        const GeoPoint(latitude: 37.78, longitude: -122.42),
        const GeoPoint(latitude: 37.78, longitude: -122.40),
        const GeoPoint(latitude: 37.76, longitude: -122.40),
        const GeoPoint(latitude: 37.76, longitude: -122.42),
      ]);
    });
  }

  void _addPolylinePoint() {
    setState(() {
      _polylinePoints.add(GeoPoint(
        latitude: _mapLatitude + (DateTime.now().millisecond % 100 - 50) * 0.001,
        longitude: _mapLongitude + (DateTime.now().millisecond % 100 - 50) * 0.001,
      ));
    });
  }

  void _updatePolylinePoint(int index, double lat, double lng) {
    setState(() {
      _polylinePoints[index] = GeoPoint(latitude: lat, longitude: lng);
    });
  }

  void _removePolylinePoint(int index) {
    setState(() {
      _polylinePoints.removeAt(index);
      if (index < _polylineLatControllers.length) {
        _polylineLatControllers.removeAt(index);
      }
      if (index < _polylineLngControllers.length) {
        _polylineLngControllers.removeAt(index);
      }
    });
  }

  void _clearPolylinePoints() {
    setState(() {
      _polylinePoints.clear();
      _polylineLatControllers.clear();
      _polylineLngControllers.clear();
    });
  }

  void _loadPresetPolyline() {
    setState(() {
      _polylinePoints.clear();
      _polylineLatControllers.clear();
      _polylineLngControllers.clear();
      _polylinePoints.addAll([
        const GeoPoint(latitude: 37.7749, longitude: -122.4194),
        const GeoPoint(latitude: 37.7849, longitude: -122.4094),
        const GeoPoint(latitude: 37.7949, longitude: -122.3994),
        const GeoPoint(latitude: 37.8049, longitude: -122.3894),
      ]);
    });
  }

  void _applyCirclePreset(CirclePreset preset) {
    switch (preset) {
      case CirclePreset.dangerZone:
        setState(() {
          _circleFillColor = Colors.red.withOpacity(0.3);
          _circleBorderColor = Colors.red;
          _circleStrokeWidth = 3.0;
        });
        break;
      case CirclePreset.safeZone:
        setState(() {
          _circleFillColor = Colors.green.withOpacity(0.3);
          _circleBorderColor = Colors.green;
          _circleStrokeWidth = 2.0;
        });
        break;
      case CirclePreset.warningZone:
        setState(() {
          _circleFillColor = Colors.orange.withOpacity(0.3);
          _circleBorderColor = Colors.orange;
          _circleStrokeWidth = 2.5;
        });
        break;
      case CirclePreset.noFlyZone:
        setState(() {
          _circleFillColor = Colors.red.withOpacity(0.4);
          _circleBorderColor = Colors.red.shade900;
          _circleStrokeWidth = 4.0;
        });
        break;
      case CirclePreset.none:
        break;
    }
  }

  Future<void> _pickColor(String type) async {
    final colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange,
      Colors.purple, Colors.cyan, Colors.amber, Colors.indigo,
    ];
    final selected = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select ${type} color'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: colors.map((color) => ListTile(
            leading: CircleAvatar(backgroundColor: color),
            title: Text(color.toString().split('(0x')[1].split(')')[0].toUpperCase()),
            onTap: () => Navigator.pop(context, color),
          )).toList(),
        ),
      ),
    );
    if (selected != null) {
      setState(() {
        if (type == 'fill') {
          _circleFillColor = selected.withOpacity(0.3);
        } else {
          _circleBorderColor = selected;
        }
      });
    }
  }

  Future<void> _pickPolylineColor() async {
    final colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange,
      Colors.purple, Colors.cyan, Colors.amber, Colors.indigo,
    ];
    final selected = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select polyline color'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: colors.map((color) => ListTile(
            leading: CircleAvatar(backgroundColor: color),
            title: Text(color.toString().split('(0x')[1].split(')')[0].toUpperCase()),
            onTap: () => Navigator.pop(context, color),
          )).toList(),
        ),
      ),
    );
    if (selected != null) {
      setState(() => _polylineColor = selected);
    }
  }

  void _showApiKeyDialog() {
    final controller = TextEditingController(text: _googleMapsApiKey);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Google Maps API Key'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'API Key'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _mapProvider = MapProvider.flutterMap);
              Navigator.pop(context);
            },
            child: const Text('Use OpenStreetMap'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _googleMapsApiKey = controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

enum CirclePreset {
  none,
  dangerZone,
  safeZone,
  warningZone,
  noFlyZone,
}
