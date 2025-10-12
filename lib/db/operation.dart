part of 'database.dart';

extension CategoryExt on BKPDatabase {
  Future<void> createCategory({
    required String name,
    required IconData icon,
    required Color color,
  }) async {
    await into(categories).insert(
      CategoriesCompanion.insert(
        name: name,
        iconCodePoint: icon.codePoint,
        iconFontFamily: icon.fontFamily ?? '',
        iconFontPackage: icon.fontPackage ?? '',
        iconColor: color.value,
      ),
    );
  }

  Future<List<Category>> getCategories({int pageNo = 1, int pageSize = 20}) {
    final query = select(categories)
      ..limit(pageSize, offset: (pageNo - 1) * pageSize)
      ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]);
    return query.get();
  }
}
