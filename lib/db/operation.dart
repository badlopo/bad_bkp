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

  Future<List<Category>> getCategories({
    String? filter,
    int pageNo = 1,
    int pageSize = 20,
  }) {
    final query = select(categories)
      ..limit(pageSize, offset: (pageNo - 1) * pageSize)
      ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]);

    if (filter?.isNotEmpty == true) {
      final escaped = filter!
          .replaceAll(r'\', r'\\')
          .replaceAll('_', r'\_')
          .replaceAll('%', r'\%');

      query.where((r) =>
          r.name.like('%$escaped%', escapeChar: r'\') |
          r.description.like('%$escaped%', escapeChar: r'\'));
    }

    return query.get();
  }

  Future<List<CategoryWithCount>> getCategoriesWithCount({
    String? filter,
    int pageNo = 1,
    int pageSize = 20,
  }) async {
    final variables = <Variable<Object>>[];
    String whereClause = '';

    if (filter?.isNotEmpty == true) {
      final escaped = filter!
          .replaceAll(r'\', r'\\')
          .replaceAll('_', r'\_')
          .replaceAll('%', r'\%');
      final variable = Variable.withString('%$escaped%');

      whereClause =
          r"WHERE categories.name LIKE ? ESCAPE '\' OR categories.description LIKE ? ESCAPE '\'";
      variables.add(variable);
      variables.add(variable);
    }

    variables.addAll([
      Variable.withInt(pageSize),
      Variable.withInt((pageNo - 1) * pageSize),
    ]);

    final rows = await customSelect(
      '''WITH category_tx_count AS (SELECT category_id, COUNT(id) as count
                           FROM transactions
                           GROUP BY category_id)
SELECT categories.*, COALESCE(category_tx_count.count, 0) as tx_count
FROM categories
         LEFT JOIN category_tx_count ON categories.id = category_tx_count.category_id
$whereClause
ORDER BY categories.created_at DESC
LIMIT ? OFFSET ?;''',
      variables: variables,
    ).get();

    return rows.map((r) {
      return CategoryWithCount(categories.map(r.data), r.read<int>('tx_count'));
    }).toList();
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
  Future<Tag> createTag(String name) async {
    return into(tags).insertReturning(TagsCompanion.insert(name: name));
  }

  Future<List<Tag>> getTags([String? filter]) {
    final query = select(tags);

    if (filter?.isNotEmpty == true) {
      final escaped = filter!
          .replaceAll(r'\', r'\\')
          .replaceAll('_', r'\_')
          .replaceAll('%', r'\%');
      query.where((r) => r.name.like('%$escaped%', escapeChar: r'\'));
    }

    return query.get();
  }

  Future<List<TagWithCount>> getTagsWithCount([String? filter]) async {
    final variables = <Variable<Object>>[];
    String whereClause = '';

    if (filter?.isNotEmpty == true) {
      final escaped = filter!
          .replaceAll(r'\', r'\\')
          .replaceAll('_', r'\_')
          .replaceAll('%', r'\%');
      final variable = Variable.withString('%$escaped%');

      whereClause = r"WHERE tags.name LIKE ? ESCAPE '\'";
      variables.add(variable);
    }

    final rows = await customSelect(
      '''WITH tag_tx_count AS (SELECT tag_id, COUNT(tx_id) AS count
                      FROM transaction_tag_links
                      GROUP BY tag_id)
SELECT tags.*, COALESCE(tag_tx_count.count, 0) as tx_count
FROM tags
         LEFT JOIN tag_tx_count ON tags.id = tag_tx_count.tag_id
$whereClause
ORDER BY tags.id;
    ''',
      variables: variables,
    ).get();

    return rows.map((r) {
      return TagWithCount(tags.map(r.data), r.read<int>('tx_count'));
    }).toList();
  }

  Future<void> deleteTag(int id) async {
    final target = delete(tags)..where((r) => r.id.equals(id));
    await target.go();
  }
}

extension TransactionExt on BKPDatabase {
  Future<void> createTransaction({
    required int amount,
    required String description,
    int? categoryId,
    required DateTime time,
    Set<File> snapshotFiles = const {},
    Set<int> tagIds = const {},
  }) async {
    return transaction(
      () async {
        // 1. transaction:
        // create a new row of the transaction.
        final tx = await into(transactions).insertReturning(
          TransactionsCompanion.insert(
            amount: amount,
            description: description,
            categoryId: Value(categoryId),
            time: time,
            snapshots: snapshotFiles,
          ),
        );

        // 2. tags:
        // since tags are created and deleted during form creation,
        // we only need to add rows of link.
        await transactionTagLinks.insertAll(
          tagIds.map((tagId) =>
              TransactionTagLinksCompanion.insert(txId: tx.id, tagId: tagId)),
          mode: InsertMode.insertOrIgnore,
        );
      },
    );
  }

  /// 获取所有发生交易的'年月'
  Future<List<YearMonth>> getTransactionYearMonths() async {
    return customSelect(
            "SELECT DISTINCT strftime('%Y-%m', time, 'unixepoch', 'localtime') as ym FROM transactions ORDER BY ym DESC")
        .map((r) {
      final ym = r.read<String>('ym').split('-');
      return YearMonth(int.parse(ym[0]), int.parse(ym[1]));
    }).get();
  }

  Future<List<TransactionWithCategory>> getTransactionsWithCategoryByMonth(
      YearMonth ym) async {
    final rows = await customSelect(
      '''SELECT transactions.id          as 'transactions.id',
       transactions.amount      as 'transactions.amount',
       transactions.description as 'transactions.description',
       transactions.time        as 'transactions.time',
       transactions.category_id as 'transactions.category_id',
       transactions.snapshots   as 'transactions.snapshots',
       categories.id            as 'categories.id',
       categories.name          as 'categories.name',
       categories.description   as 'categories.description',
       categories.icon          as 'categories.icon',
       categories.color         as 'categories.color',
       categories.description   as 'categories.description',
       categories.created_at    as 'categories.created_at'
FROM transactions
         LEFT JOIN categories ON categories.id = transactions.category_id
WHERE transactions.time BETWEEN ? AND ?
ORDER BY transactions.time DESC;''',
      variables: [
        Variable.withInt(ym.beginTime.millisecondsSinceEpoch ~/ 1000),
        Variable.withInt(ym.endTime.millisecondsSinceEpoch ~/ 1000),
      ],
    ).get();

    return rows.map((row) {
      final tx = transactions.map(row.data, tablePrefix: 'transactions');
      final category = tx.categoryId == null
          ? null
          : categories.map(row.data, tablePrefix: 'categories');
      return TransactionWithCategory(tx, category);
    }).toList();
  }

  Future<List<TransactionWithCategoryAndTags>>
      getTransactionsWithCategoryAndTagsByMonth(YearMonth ym) async {
    final rows = await customSelect(
      '''WITH tx_tags AS (SELECT transaction_tag_links.tx_id,
                        json_group_array(json_object('id', tags.id, 'name', tags.name)) AS tx_tags
                 FROM transaction_tag_links
                          LEFT JOIN tags ON transaction_tag_links.tag_id = tags.id
                 GROUP BY transaction_tag_links.tx_id)
SELECT transactions.id          as 'transactions.id',
       transactions.amount      as 'transactions.amount',
       transactions.description as 'transactions.description',
       transactions.time        as 'transactions.time',
       transactions.category_id as 'transactions.category_id',
       transactions.snapshots   as 'transactions.snapshots',
       categories.id            as 'categories.id',
       categories.name          as 'categories.name',
       categories.description   as 'categories.description',
       categories.icon          as 'categories.icon',
       categories.color         as 'categories.color',
       categories.description   as 'categories.description',
       categories.created_at    as 'categories.created_at',
       tx_tags.tx_tags          as 'tags'
FROM transactions
         LEFT JOIN categories ON categories.id = transactions.category_id
         LEFT JOIN tx_tags ON tx_tags.tx_id = transactions.id
WHERE transactions.time BETWEEN ? AND ?
ORDER BY transactions.time DESC;''',
      variables: [
        Variable.withInt(ym.beginTime.millisecondsSinceEpoch ~/ 1000),
        Variable.withInt(ym.endTime.millisecondsSinceEpoch ~/ 1000),
      ],
    ).get();

    return rows.map((row) {
      final tx = transactions.map(row.data, tablePrefix: 'transactions');
      final category = tx.categoryId == null
          ? null
          : categories.map(row.data, tablePrefix: 'categories');
      final tagsJson = row.read<String?>('tags');
      final tags = tagsJson == null
          ? <Tag>[]
          : (jsonDecode(tagsJson) as List)
              .map((e) => Tag(id: e['id'] as int, name: e['name'] as String))
              .toList();

      return TransactionWithCategoryAndTags(tx, category, tags);
    }).toList();
  }

  // TODO: getLatestTransactions(int n)

  // TODO: updateTransaction

  Future<void> deleteTransaction(int id) async {
    final target = delete(transactions)..where((r) => r.id.equals(id));
    await target.go();
  }
}
