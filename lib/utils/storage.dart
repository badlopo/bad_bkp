import 'dart:io';

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

enum StorageType {
  /// hive files (kv storage)
  hive,

  /// drift db files
  drift,

  /// snapshot of transactions, grouped by year
  transactionSnapshot,
}

enum KVType {
  /// `Map<String, dynamic>`
  theme,
}

abstract class StorageUtils {
  static Directory? _root;

  static Directory get root {
    if (_root == null) {
      throw StateError('call "StorageUtils.prelude()" first');
    }
    return _root!;
  }

  static Future<void> prelude() async {
    _root = await getApplicationDocumentsDirectory();

    await Hive.initFlutter(StorageType.hive.name);
    _box = await Hive.openBox('global');
  }

  static Directory getDirectoryOfStorage(StorageType type) =>
      Directory(join(root.path, type.name));

  /// save file as transaction snapshot file
  /// at `<root>/transactionSnapshot/<year>/transactionId.<extension>`.
  static Future<File> saveTransactionSnapshot({
    required File file,
    required int transactionId,
    required DateTime transactionTime,
  }) {
    final target = setExtension(
      join(getDirectoryOfStorage(StorageType.transactionSnapshot).path,
          '${transactionTime.year}', '$transactionId'),
      extension(file.path),
    );

    return file.copy(target);
  }

  static Box? _box;

  static Box get box {
    if (_box == null) {
      throw StateError('call "StorageUtils.prelude()" first');
    }

    return _box!;
  }

  static void setKV(KVType type, Object? value) => box.put(type.name, value);

  static Map<String, dynamic>? getKVAsMap(KVType type) =>
      box.get(type.name)?.cast<String, dynamic>();
}
