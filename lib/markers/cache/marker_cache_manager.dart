import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/marker_config.dart';
import 'cache_key.dart';

/// Cache manager for marker widgets and bitmaps
///
/// Uses LRU (Least Recently Used) eviction policy to manage cache size.
/// Separate caches for widgets (Flutter Map) and bitmaps (Google Maps).
class MarkerCacheManager {
  static const _maxCacheSize = 100;

  static final Map<String, Widget> _widgetCache = {};
  static final Map<String, BitmapDescriptor> _bitmapCache = {};
  static final List<String> _cacheAccessOrder = [];

  /// Singleton instance
  static final MarkerCacheManager _instance = MarkerCacheManager._internal();
  factory MarkerCacheManager() => _instance;
  MarkerCacheManager._internal();

  /// Get a cached widget for the given configuration
  static Widget? getCachedWidget(MarkerConfig config) {
    final key = CacheKey.forWidget(config);
    _updateAccessOrder(key);
    return _widgetCache[key];
  }

  /// Cache a widget for the given configuration
  static void putWidget(MarkerConfig config, Widget widget) {
    final key = CacheKey.forWidget(config);
    _ensureCapacity();
    _widgetCache[key] = widget;
    _updateAccessOrder(key);
  }

  /// Get a cached BitmapDescriptor for Google Maps
  static BitmapDescriptor? getCachedBitmapDescriptor(
    MarkerConfig config,
  ) {
    final key = CacheKey.forBitmap(config);
    _updateAccessOrder(key);
    return _bitmapCache[key];
  }

  /// Cache a BitmapDescriptor for Google Maps
  static void putBitmapDescriptor(
    MarkerConfig config,
    BitmapDescriptor descriptor,
  ) {
    final key = CacheKey.forBitmap(config);
    _ensureCapacity();
    _bitmapCache[key] = descriptor;
    _updateAccessOrder(key);
  }

  /// Clear all caches
  static void clear() {
    _widgetCache.clear();
    _bitmapCache.clear();
    _cacheAccessOrder.clear();
  }

  /// Remove specific entry from cache
  static void remove(MarkerConfig config) {
    final widgetKey = CacheKey.forWidget(config);
    final bitmapKey = CacheKey.forBitmap(config);
    _widgetCache.remove(widgetKey);
    _bitmapCache.remove(bitmapKey);
    _cacheAccessOrder.remove(widgetKey);
    _cacheAccessOrder.remove(bitmapKey);
  }

  /// Get cache statistics
  static Map<String, dynamic> getStats() {
    return {
      'widgetCacheSize': _widgetCache.length,
      'bitmapCacheSize': _bitmapCache.length,
      'maxCacheSize': _maxCacheSize,
      'totalEntries': _widgetCache.length + _bitmapCache.length,
    };
  }

  /// Warm up the cache with pre-defined configurations
  static Future<void> warmUp(List<MarkerConfig> configs) async {
    // Pre-generate bitmaps for Google Maps
    for (final config in configs) {
      if (_bitmapCache[CacheKey.forBitmap(config)] == null) {
        // This will be populated when the adapter generates the bitmap
      }
    }
  }

  /// Ensure cache doesn't exceed maximum size using LRU eviction
  static void _ensureCapacity() {
    while (_cacheAccessOrder.length >= _maxCacheSize) {
      if (_cacheAccessOrder.isNotEmpty) {
        final oldestKey = _cacheAccessOrder.removeAt(0);
        _widgetCache.remove(oldestKey);
        _bitmapCache.remove(oldestKey);
      } else {
        break;
      }
    }
  }

  /// Update access order for LRU tracking
  static void _updateAccessOrder(String key) {
    _cacheAccessOrder.remove(key);
    _cacheAccessOrder.add(key);
  }

  /// Get approximate memory usage in bytes
  static int getEstimatedMemoryUsage() {
    // Rough estimation: each widget ~1000 bytes, each bitmap ~10KB
    return (_widgetCache.length * 1000) + (_bitmapCache.length * 10240);
  }
}
