part of 'database.dart';

class CategoryWithCount {
  final Category category;
  final int count;

  const CategoryWithCount(this.category, this.count);

  @override
  String toString() {
    return '[CategoryWithCount] <${category.id}> ${category.name} ($count)';
  }
}

class TagWithCount {
  final Tag tag;
  final int count;

  const TagWithCount(this.tag, this.count);

  @override
  String toString() {
    return '[TagWithCount] <${tag.id}> ${tag.name} ($count)';
  }
}

class TransactionWithCategory {
  final Transaction tx;
  final Category? category;

  TransactionWithCategory(this.tx, this.category);

  @override
  String toString() {
    return '[TransactionWithCategory] <${tx.id}> ${tx.amount} (${category?.name ?? 'Uncategorized'})';
  }
}

class TransactionWithCategoryAndTags extends TransactionWithCategory {
  final List<Tag> tags;

  TransactionWithCategoryAndTags(super.tx, super.category, this.tags);

  @override
  String toString() {
    return '[TransactionWithCategoryAndTags] <${tx.id}> ${tx.amount} (${category?.name ?? 'Uncategorized'}, ${tags.length} tags)';
  }
}
