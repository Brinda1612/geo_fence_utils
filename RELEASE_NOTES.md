# Release Notes

## [Unreleased] - 2026-03-04

### 🎉 New Features

#### GeoMarkerWidget - Map Markers Support
- **New `GeoMarkerWidget` class** for displaying points of interest on maps
- Customizable markers with:
  - Position (latitude, longitude)
  - Optional label text
  - Custom colors and sizes
  - Border styling
  - Alpha/transparency control
  - Custom image asset support
- **Preset factory methods** for common use cases:
  - `location()` - Blue location marker
  - `store()` - Green store/shop marker
  - `warning()` - Orange warning marker
  - `danger()` - Red danger/hazard marker
  - `checkpoint()` - Purple numbered checkpoint marker
  - `poi()` - Amber point of interest marker
  - `at()` - Quick marker creation at position

#### Enhanced Map Functionality
- **Markers support** - Added `markers` parameter to `GeoGeofenceMap`
- **Marker tap detection** - New `onMarkerTap` callback for marker interactions
- **Scroll wheel zoom** - Mouse/touchpad zoom now works on desktop
- **Improved geofence tap detection** - Better hit testing for circles, polygons, and polylines

#### Enhanced Example App
- **Complete UI redesign** with modern Material 3 design
- **6 main sections**: Circles, Polygons, Polylines, Markers, Scenarios, Services
- **9 marker examples** showcasing all preset styles
- **Interactive selection** with animated card highlights
- **Expandable code examples** for each feature
- **Fixed layout issues** with proper scroll handling

### 🐛 Bug Fixes

- ✅ Fixed map zoom not working with mouse scroll wheel/touchpad
- ✅ Fixed geofence tap detection - now works for circles, polygons, and polylines
- ✅ Fixed "BOTTOM OVERFLOWED BY XX PIXELS" error in control panel
- ✅ Fixed null crash when accessing `metadata` on preset widgets
- ✅ Fixed missing IDs in preset geofence widgets
- ✅ Fixed SegmentedButton layout break on smaller screens
- ✅ Fixed map status card overlapping zoom controls
- ✅ Fixed `_tappedLocation` not being cleared on page change
- ✅ Fixed scenario selection using string parsing (now uses dedicated state)

### 📝 API Changes

#### GeoGeofenceMap
```dart
GeoGeofenceMap(
  center: GeoPoint(...),
  zoom: 13.0,
  geofences: [...],
  markers: [              // NEW
    GeoMarkerWidget.location(
      id: 'marker1',
      position: GeoPoint(...),
      label: 'Location',
    ),
  ],
  onMarkerTap: (id) {    // NEW
    print('Tapped: $id');
  },
)
```

#### GeoMarkerWidget
```dart
// Simple marker
GeoMarkerWidget.location(
  id: 'my_location',
  position: GeoPoint(latitude: 37.7749, longitude: -122.4194),
  label: 'Current Location',
)

// Custom marker
GeoMarkerWidget(
  id: 'custom',
  position: GeoPoint(latitude: 37.78, longitude: -122.41),
  label: 'My Marker',
  markerColor: Colors.teal,
  markerSize: 40,
  alpha: 0.8,
)
```

### 🔧 Internal Changes

- Added `dart:ui` import prefix to resolve Path conflicts in flutter_map_impl.dart
- Improved marker painter with custom pin shape rendering
- Added marker overlay builder for FlutterMap
- Added marker support for Google Maps implementation
- Refactored control panel layout to prevent overflow
- Added proper scroll handling for page content

### 📚 Documentation

- Added comprehensive documentation for GeoMarkerWidget
- Updated example code with all new features
- Added inline comments explaining marker usage
- Enhanced code examples in example app

### 🎨 UI/UX Improvements

- Modern card-based design with rounded corners
- Animated selection states with color transitions
- Improved visual hierarchy with better spacing
- Enhanced iconography with color-coded markers
- Better feedback on tap interactions
- Cleaner status card display

---

## Migration Guide

### Adding Markers to Your Existing Map

**Before:**
```dart
GeoGeofenceMap(
  center: GeoPoint(...),
  geofences: [...],
  onGeofenceTap: (id) => print('Tapped: $id'),
)
```

**After:**
```dart
GeoGeofenceMap(
  center: GeoPoint(...),
  geofences: [...],
  markers: [                    // Add markers
    GeoMarkerWidget.location(
      id: 'marker1',
      position: GeoPoint(...),
      label: 'Location',
    ),
  ],
  onGeofenceTap: (id) => print('Tapped: $id'),
  onMarkerTap: (id) => print('Marker: $id'),  // Add marker tap handler
)
```

### Using Marker Presets

```dart
// Location marker (blue)
GeoMarkerWidget.location(id: 'loc', position: GeoPoint(...))

// Store marker (green)
GeoMarkerWidget.store(id: 'store', position: GeoPoint(...), label: 'My Store')

// Warning marker (orange)
GeoMarkerWidget.warning(id: 'warn', position: GeoPoint(...))

// Danger marker (red)
GeoMarkerWidget.danger(id: 'danger', position: GeoPoint(...), label: 'Hazard')

// Checkpoint marker (purple, numbered)
GeoMarkerWidget.checkpoint(
  id: 'cp1',
  position: GeoPoint(...),
  checkpointNumber: 1,
)

// POI marker (amber)
GeoMarkerWidget.poi(id: 'poi', position: GeoPoint(...), label: 'Point of Interest')
```

---

## Dependencies

No new dependencies added. Uses existing:
- `flutter_map` for OpenStreetMap rendering
- `google_maps_flutter` for Google Maps (optional)

---

## Full Changelog

### Added
- `GeoMarkerWidget` class with full customization support
- `markers` parameter to `GeoGeofenceMap`
- `onMarkerTap` callback to `GeoGeofenceMap`
- Marker rendering in `FlutterMapImpl`
- Marker rendering in `GoogleMapImpl`
- Marker tap detection with proximity threshold
- Scroll wheel zoom support for desktop
- Markers page in example app with 9 examples

### Changed
- Enhanced example app UI with modern design
- Improved control panel layout to prevent overflow
- Better geofence tap detection accuracy
- All preset widgets now include explicit IDs
- Map status card positioned to avoid control overlap
- Page selector wrapped with horizontal scroll

### Fixed
- Mouse/touchpad zoom not working
- Geofence tap detection not working for all types
- Bottom overflow error in control panel
- Null crash when accessing metadata on presets
- Missing IDs causing selection issues
- Location state not clearing on page change

---

**Version**: 1.1.0
**Release Date**: March 4, 2026
**Compatibility**: Dart 3.0+, Flutter 3.10+
