import 'dart:io';

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

enum StorageType {
  /// hive files (kv storage)
  hive,

  /// drift db files
  drift,
}

enum KVType {
  /// `Map<String, dynamic>`
  theme,
}

abstract class StorageUtils {
  static Future<Directory> getDirectoryOfStorage(StorageType type) async {
    final root = await getApplicationDocumentsDirectory();
    return Directory(join(root.path, type.name));
  }

  static Future<void> initKV() async {
    await Hive.initFlutter(StorageType.hive.name);
    _box = await Hive.openBox('global');
  }

  static Box? _box;

  static Box get box {
    if (_box == null) {
      throw StateError('call "StorageUtils.initKV()" first');
    }

    return _box!;
  }

  static void setKV(KVType type, Object? value) => box.put(type.name, value);

  static Map<String, dynamic>? getKVAsMap(KVType type) =>
      box.get(type.name)?.cast<String, dynamic>();
}
