part of 'database.dart';

class CategoryWithCount {
  final Category category;
  final int count;

  const CategoryWithCount(this.category, this.count);

  @override
  String toString() {
    return '[CategoryWithCount] $category ($count)';
  }
}

class TagWithCount {
  final Tag tag;
  final int count;

  const TagWithCount(this.tag, this.count);

  @override
  String toString() {
    return '[TagWithCount] $tag ($count)';
  }
}
