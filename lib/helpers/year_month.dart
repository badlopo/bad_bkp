class YearMonth {
  late final int year;
  late final int month;

  DateTime get beginTime => DateTime(year, month);

  DateTime get endTime =>
      DateTime(year, month + 1).subtract(Duration(microseconds: 1));

  YearMonth(int year, int month) {
    final d = DateTime(year, month);
    this.year = d.year;
    this.month = d.month;
  }

  bool operator >(YearMonth other) =>
      (year + month / 12) > (other.year + other.month / 12);

  bool operator <(YearMonth other) =>
      (year + month / 12) < (other.year + other.month / 12);

  @override
  bool operator ==(Object other) {
    return other is YearMonth && other.year == year && other.month == month;
  }

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() {
    return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';
  }
}
