import 'package:hive/hive.dart';

/// Minimal key/value surface the app needs from local storage. Production
/// uses Hive ([HiveKvStore]); tests use [MemoryKvStore] because Hive's async
/// write queue cannot run inside Flutter's fake-async test zone.
abstract class KvStore {
  dynamic get(String key, {dynamic defaultValue});
  Future<void> put(String key, dynamic value);
  Future<void> delete(String key);
  Future<void> clear();
  Iterable<dynamic> get values;

  /// Every key, for backup.
  Iterable<String> get keys;
}

class HiveKvStore implements KvStore {
  HiveKvStore(this._box);
  final Box _box;

  @override
  dynamic get(String key, {dynamic defaultValue}) =>
      _box.get(key, defaultValue: defaultValue);

  @override
  Future<void> put(String key, dynamic value) => _box.put(key, value);

  @override
  Future<void> delete(String key) => _box.delete(key);

  @override
  Future<void> clear() async => _box.clear();

  @override
  Iterable<dynamic> get values => _box.values;

  @override
  Iterable<String> get keys => _box.keys.map((k) => '$k');
}

class MemoryKvStore implements KvStore {
  final Map<String, dynamic> _data = {};

  @override
  dynamic get(String key, {dynamic defaultValue}) =>
      _data.containsKey(key) ? _data[key] : defaultValue;

  @override
  Future<void> put(String key, dynamic value) async => _data[key] = value;

  @override
  Future<void> delete(String key) async => _data.remove(key);

  @override
  Future<void> clear() async => _data.clear();

  @override
  Iterable<dynamic> get values => _data.values;

  @override
  Iterable<String> get keys => _data.keys.toList();
}
