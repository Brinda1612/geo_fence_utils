/// Defines the visual style of map markers
enum MarkerType {
  /// Custom marker rendered from SVG path
  svgCustom,

  /// Custom PNG image from assets
  pngAsset,
}

/// Extension on [MarkerType] providing utility methods
extension MarkerTypeExtension on MarkerType {
  /// Whether this marker type uses SVG path for rendering
  bool get isSvgBased => this == MarkerType.svgCustom;

  /// Whether this marker type uses PNG asset for rendering
  bool get isPngBased => this == MarkerType.pngAsset;

  /// Gets the display name for the marker type
  String get displayName {
    switch (this) {
      case MarkerType.svgCustom:
        return 'SVG Custom';
      case MarkerType.pngAsset:
        return 'PNG Asset';
    }
  }

  /// Gets the aspect ratio (height/width) for this marker type
  double get aspectRatio {
    switch (this) {
      case MarkerType.svgCustom:
        return 1.0;
      case MarkerType.pngAsset:
        return 1.0;
    }
  }
}
