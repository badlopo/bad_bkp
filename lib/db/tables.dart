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

  IntColumn get amount => integer()();

  TextColumn get description => text()();

  DateTimeColumn get time => dateTime()();

  IntColumn get categoryId => integer()
      .references(Categories, #id, onDelete: KeyAction.setNull)
      .nullable()();

  TextColumn get snapshots => text().map(MultiFileConverter())();
}

class TransactionTagLinks extends Table {
  @override
  String get tableName => 'transaction_tag_links';

  @override
  Set<Column> get primaryKey => {txId, tagId};

  IntColumn get txId =>
      integer().references(Transactions, #id, onDelete: KeyAction.cascade)();

  IntColumn get tagId =>
      integer().references(Tags, #id, onDelete: KeyAction.cascade)();
}
