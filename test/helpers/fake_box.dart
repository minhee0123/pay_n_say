import 'package:hive/hive.dart';

/// 테스트용 인메모리 Box 구현체.
/// Hive 디스크 I/O 없이 동기적으로 동작합니다.
class FakeBox<E> implements Box<E> {
  final Map<dynamic, E> _data = {};

  @override
  E? get(dynamic key, {E? defaultValue}) => _data[key] ?? defaultValue;

  @override
  Future<void> put(dynamic key, E value) async {
    _data[key] = value;
  }

  @override
  Future<void> delete(dynamic key) async {
    _data.remove(key);
  }

  @override
  Iterable<E> get values => _data.values;

  @override
  Iterable<dynamic> get keys => _data.keys;

  @override
  bool get isNotEmpty => _data.isNotEmpty;

  @override
  bool get isEmpty => _data.isEmpty;

  @override
  int get length => _data.length;

  @override
  bool containsKey(dynamic key) => _data.containsKey(key);

  @override
  Future<void> putAll(Map<dynamic, E> entries) async {
    _data.addAll(entries);
  }

  @override
  Future<int> clear() async {
    final count = _data.length;
    _data.clear();
    return count;
  }

  @override
  Future<void> close() async {}

  @override
  Future<void> deleteFromDisk() async {
    _data.clear();
  }

  @override
  bool get isOpen => true;

  @override
  String get name => 'fake_box';

  @override
  String? get path => null;

  @override
  bool get lazy => false;

  @override
  Map<dynamic, E> toMap() => Map.from(_data);

  @override
  E? getAt(int index) => _data.values.elementAt(index);

  @override
  Future<void> putAt(int index, E value) async {
    final key = _data.keys.elementAt(index);
    _data[key] = value;
  }

  @override
  Future<void> deleteAt(int index) async {
    final key = _data.keys.elementAt(index);
    _data.remove(key);
  }

  @override
  Future<int> add(E value) async {
    final key = _data.length;
    _data[key] = value;
    return key;
  }

  @override
  Future<Iterable<int>> addAll(Iterable<E> values) async {
    final keys = <int>[];
    for (final v in values) {
      final key = _data.length;
      _data[key] = v;
      keys.add(key);
    }
    return keys;
  }

  @override
  Future<void> deleteAll(Iterable<dynamic> keys) async {
    for (final key in keys) {
      _data.remove(key);
    }
  }

  @override
  Future<void> compact() async {}

  @override
  Iterable<E> valuesBetween({dynamic startKey, dynamic endKey}) =>
      throw UnimplementedError();

  @override
  dynamic keyAt(int index) => _data.keys.elementAt(index);

  @override
  Stream<BoxEvent> watch({dynamic key}) => const Stream.empty();

  @override
  Future<void> flush() async {}
}
