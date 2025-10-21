import 'dart:io';

import 'package:crypto/crypto.dart';
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

Future<int> _getSizeOfDirectoryInBytes(Directory directory) async {
  int count = 0;
  for (final item in directory.listSync(followLinks: false)) {
    if (item is File) {
      count += await item.length();
    } else if (item is Directory) {
      count += await _getSizeOfDirectoryInBytes(item);
    }
  }
  return count;
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

    getDirectoryOfStorage(StorageType.transactionSnapshot)
        .create(recursive: true);
  }

  static Directory getDirectoryOfStorage(StorageType type) =>
      Directory(join(root.path, type.name));

  static Future<int> getSizeOfStorageInBytes(StorageType type) =>
      _getSizeOfDirectoryInBytes(getDirectoryOfStorage(type));

  /// This function is idempotent.
  ///
  /// save file as transaction snapshot file
  /// at `<root>/transactionSnapshot/<current_year>/<file_md5>.<extension>`.
  static Future<File> saveTransactionSnapshot(File file) async {
    final target = File(setExtension(
      join(
        getDirectoryOfStorage(StorageType.transactionSnapshot).path,
        '${DateTime.now().year}',
        md5.convert(await file.readAsBytes()).toString(),
      ),
      extension(file.path),
    ));

    await target.parent.create(recursive: true);

    return file.copy(target.path);
  }

  static Future<File> moveTransactionSnapshot({
    required File file,
    required int txId,
    required int txYear,
  }) async {
    final target = File(setExtension(
      join(
        getDirectoryOfStorage(StorageType.transactionSnapshot).path,
        '$txYear',
        '$txId',
      ),
      extension(file.path),
    ));

    await target.parent.create(recursive: true);

    return file.rename(target.path);
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
