part of 'database.dart';

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

class Transactions extends Table {
  @override
  String get tableName => 'transactions';

  IntColumn get id => integer().autoIncrement()();

  TextColumn get description => text()();

  IntColumn get categoryId => integer()
      .references(Categories, #id, onDelete: KeyAction.setNull)
      .nullable()();

  DateTimeColumn get time => dateTime()();

  TextColumn get snapshot => text().map(const FileConverter()).nullable()();
}
