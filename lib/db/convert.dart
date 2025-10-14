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
