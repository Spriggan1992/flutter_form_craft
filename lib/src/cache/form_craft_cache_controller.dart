part of '../form_craft.dart';

/// Internal coordinator that debounces writes to a [FormCraftCacheStorage]
/// and keeps track of values restored from it that are waiting to be
/// applied to fields which haven't been registered yet.
base class FormCraftCacheController {
  final String key;
  final FormCraftCacheStorage storage;
  final Duration debounce;

  /// Values read from storage, kept around so fields registered *after*
  /// the cache finished loading still pick up their cached value.
  Map<String, String>? pendingRestoredValues;

  Timer? _debounceTimer;

  /// Whether a debounced write is currently scheduled and hasn't fired yet.
  bool get hasPendingSave => _debounceTimer != null;

  FormCraftCacheController({
    required this.key,
    required this.storage,
    required this.debounce,
  });

  /// Reads and decodes the cached values for [key], if any.
  Future<Map<String, String>?> load() async {
    final raw = await storage.read(key);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
    } catch (_) {
      // Corrupted or outdated cache payload — ignore it rather than crash.
      return null;
    }
  }

  /// Schedules a debounced write of `snapshot()` to storage.
  void scheduleSave(Map<String, String> Function() snapshot) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () {
      unawaited(storage.write(key, jsonEncode(snapshot())));
    });
  }

  /// Cancels any pending debounce and writes `snapshot()` immediately.
  Future<void> flush(Map<String, String> Function() snapshot) {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    return storage.write(key, jsonEncode(snapshot()));
  }

  Future<void> clear() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    pendingRestoredValues = null;
    return storage.delete(key);
  }

  void dispose() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }
}
