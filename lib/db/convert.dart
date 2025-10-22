part of 'database.dart';

class BKPColorConverter extends TypeConverter<BKPColor, String> {
  const BKPColorConverter();

  @override
  BKPColor fromSql(String fromDb) => BKPColor.fromName(fromDb);

  @override
  String toSql(BKPColor value) => value.name;
}

class IconDataConverter extends TypeConverter<IconData, String> {
  const IconDataConverter();

  @override
  IconData fromSql(String fromDb) {
    final parts = fromDb.split(":");
    return IconData(
      int.parse(parts[0], radix: 10),
      fontFamily: parts[1],
      fontPackage: parts[2],
    );
  }

  @override
  String toSql(IconData value) =>
      '${value.codePoint}:${value.fontFamily ?? ''}:${value.fontPackage ?? ''}';
}

class SingleFileConverter extends TypeConverter<File, String> {
  const SingleFileConverter();

  @override
  File fromSql(String fromDb) => File(fromDb);

  @override
  String toSql(File value) => value.path;
}

/// NOTE: since we ensure the path of file will not contains the character ';',
/// so we use this as separator here.
class MultiFileConverter extends TypeConverter<Iterable<File>, String> {
  const MultiFileConverter();

  @override
  Iterable<File> fromSql(String fromDb) => fromDb
      .split(';')
      .where((path) => path.isNotEmpty)
      .map((path) => File(path));

  @override
  String toSql(Iterable<File> value) =>
      value.map((file) => file.path).join(';');
}
