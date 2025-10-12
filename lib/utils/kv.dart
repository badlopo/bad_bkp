import 'package:hive_ce_flutter/hive_flutter.dart';

enum _KVName {
  /// `Map<String, dynamic>`
  theme,
}

abstract class KVUtils {
  static Box? _box;

  static Box get box {
    if (_box == null) {
      throw StateError('call "KVUtils.prelude()" first');
    }

    return _box!;
  }

  static Future<void> prelude() async {
    await Hive.initFlutter('bookkeeping');
    _box = await Hive.openBox('global');
  }

  static void setTheme(Map<String, dynamic> theme) =>
      box.put(_KVName.theme.name, theme);

  static Map<String, dynamic>? getTheme() =>
      box.get(_KVName.theme.name)?.cast<String, dynamic>();
}
