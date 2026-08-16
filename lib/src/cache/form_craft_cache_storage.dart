part of '../form_craft.dart';

/// Storage adapter used by [FormCraft.withCache] to persist and restore
/// form field values across navigation or app restarts.
///
/// Implement this on top of whatever storage the host app already uses
/// (shared_preferences, secure storage, a database, ...) instead of forcing
/// a specific dependency on every consumer of this package.
abstract class FormCraftCacheStorage {
  /// Returns the previously stored value for [key], or null if there is none.
  Future<String?> read(String key);

  /// Persists [value] under [key], overwriting any previous value.
  Future<void> write(String key, String value);

  /// Removes the stored value for [key], if any.
  Future<void> delete(String key);
}
