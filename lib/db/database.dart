import 'package:bookkeeping/constants/color.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/cupertino.dart' hide Table;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

part 'convert.dart';

part 'operation.dart';

class Categories extends Table {
  @override
  String get tableName => 'categories';

  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  TextColumn get description => text()();

  TextColumn get icon => text().map(const IconDataConverter())();

  TextColumn get color => text().map(const BKPColorConverter())();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Tags extends Table {
  @override
  String get tableName => 'tags';

  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'bkp',
    native: DriftNativeOptions(
      // TODO: which directory to use ?
      databaseDirectory: getApplicationSupportDirectory,
    ),
  );
}

@DriftDatabase(tables: [Categories, Tags])
class BKPDatabase extends _$BKPDatabase {
  static BKPDatabase? _instance;

  static BKPDatabase get instance {
    _instance ??= BKPDatabase._();
    return _instance!;
  }

  @override
  int get schemaVersion => 1;

  BKPDatabase._() : super(_openConnection());
}
