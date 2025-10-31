import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bookkeeping/constants/color.dart';
import 'package:bookkeeping/helpers/year_month.dart';
import 'package:bookkeeping/utils/storage.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/cupertino.dart' hide Table, Column, View;
import 'package:flutter/material.dart' show DateTimeRange;

part 'database.g.dart';

part 'convert.dart';

part 'tables.dart';

part 'models.dart';

part 'operation.dart';

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'global',
    native: DriftNativeOptions(
      databaseDirectory: () async =>
          StorageUtils.getDirectoryOfStorage(StorageType.drift),
    ),
  );
}

@DriftDatabase(tables: [Categories, Tags, Transactions, TransactionTagLinks])
class BKPDatabase extends _$BKPDatabase {
  static BKPDatabase? _instance;

  static BKPDatabase get instance {
    _instance ??= BKPDatabase._();
    return _instance!;
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(beforeOpen: (detail) async {
      // enable foreign-key feature
      await customStatement('PRAGMA foreign_keys = ON');
    });
  }

  BKPDatabase._() : super(_openConnection());
}

// codegen: `dart run build_runner build`
