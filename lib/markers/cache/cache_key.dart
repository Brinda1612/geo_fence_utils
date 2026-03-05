import '../models/marker_config.dart';

/// Generates cache keys for marker configurations
class CacheKey {
  /// Generates a unique cache key for a marker configuration
  static String forConfig(MarkerConfig config) {
    return config.cacheKey;
  }

  /// Generates a cache key for a bitmap descriptor
  static String forBitmap(MarkerConfig config, {double devicePixelRatio = 1.0}) {
    return '${config.cacheKey}_$devicePixelRatio';
  }

  /// Generates a cache key for a widget
  static String forWidget(MarkerConfig config) {
    return '${config.cacheKey}_widget';
  }

  /// Parses a cache key to extract configuration hash
  static int? parseHash(String cacheKey) {
    final parts = cacheKey.split('_');
    if (parts.length > 1) {
      return int.tryParse(parts.last);
    }
    return null;
  }
}
