part of 'database.dart';

extension CategoryExt on BKPDatabase {
  Future<void> createCategory({
    required String name,
    required String description,
    required IconData icon,
    required BKPColor color,
  }) async {
    await into(categories).insert(
      CategoriesCompanion.insert(
        name: name,
        description: description,
        icon: icon,
        color: color,
      ),
    );
  }

  Future<List<Category>> getCategories({int pageNo = 1, int pageSize = 20}) {
    final query = select(categories)
      ..limit(pageSize, offset: (pageNo - 1) * pageSize)
      ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]);
    return query.get();
  }

  Future<void> updateCategory(
    int id, {
    required String name,
    required String description,
    required IconData icon,
    required BKPColor color,
  }) async {
    final target = update(categories)..where((r) => r.id.equals(id));
    await target.write(
      CategoriesCompanion.insert(
        name: name,
        description: description,
        icon: icon,
        color: color,
      ),
    );
  }

  Future<void> deleteCategory(int id) async {
    final target = delete(categories)..where((r) => r.id.equals(id));
    await target.go();
  }
}

extension TagExt on BKPDatabase {
  Future<void> createTag(String name) async {
    await into(tags).insert(TagsCompanion.insert(name: name));
  }

  Future<List<Tag>> getTags({
    String? filter,
    int pageNo = 1,
    int pageSize = 20,
  }) {
    final query = select(tags)
      ..limit(pageSize, offset: (pageNo - 1) * pageSize);

    if (filter?.isNotEmpty == true) {
      final escaped = filter!
          .replaceAll(r'\', r'\\')
          .replaceAll('_', r'\_')
          .replaceAll('%', r'\%');
      query.where((r) => r.name.like('%$escaped%', escapeChar: r'\'));
    }

    return query.get();
  }

  // Future<void> updateTag(int id, {required name}) async {
  //   final target = update(tags)..where((r) => r.id.equals(id));
  //   await target.write(TagsCompanion.insert(name: name));
  // }

  Future<void> deleteTag(int id) async {
    final target = delete(tags)..where((r) => r.id.equals(id));
    await target.go();
  }
}
