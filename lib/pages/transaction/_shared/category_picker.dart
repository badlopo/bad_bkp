import 'package:bookkeeping/components/hr.dart';
import 'package:bookkeeping/components/indicator.dart';
import 'package:bookkeeping/components/refreshable.dart';
import 'package:bookkeeping/db/database.dart';
import 'package:bookkeeping/mixins/pagination.dart';
import 'package:bookkeeping/route/route.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class CategoryPicker extends StatefulWidget {
  static Future<Category?> show(BuildContext context) {
    return showCupertinoModalPopup<Category>(
      context: context,
      builder: (context) => CategoryPicker(),
    );
  }

  const CategoryPicker({super.key});

  @override
  State<StatefulWidget> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker>
    with PaginatedQueryMixin<CategoryPicker, Category> {
  final TextEditingController controller = TextEditingController();

  @override
  Future<Iterable<Category>?> fetch() {
    return BKPDatabase.instance.getCategories(
      filter: filter,
      pageNo: pageNo,
      pageSize: pageSize,
    );
  }

  void handleCategoryCreation() async {
    final r = await context.pushNamed(RouteNames.categorySpec);
    if (r == true) reloadPage();
  }

  @override
  Future<void> handleResetFilter() {
    controller.clear();
    return super.handleResetFilter();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final maxHeight = size.height - padding.top - 100;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(8),
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
      ),
      child: SizedBox(
        height: maxHeight,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: CupertinoSearchTextField(
                      controller: controller,
                      onSubmitted: handleFilter,
                      onSuffixTap: handleResetFilter,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    sizeStyle: CupertinoButtonSize.small,
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: result == null
                  ? LoadingIndicator()
                  : result!.isEmpty
                      ? EmptyIndicator(
                          hint: 'No data',
                          footer: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32),
                            child: filter.isEmpty
                                ? CupertinoButton.filled(
                                    onPressed: handleCategoryCreation,
                                    child: Text('Create'),
                                  )
                                : CupertinoButton.filled(
                                    onPressed: handleResetFilter,
                                    child: Text('Reset filter'),
                                  ),
                          ),
                        )
                      : BKPRefreshable(
                          onRefresh: reloadPage,
                          onLoad: nextPage,
                          child: ListView.separated(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            itemCount: result!.length,
                            itemBuilder: (context, index) {
                              final category = result![index];

                              return CupertinoListTile(
                                padding: EdgeInsets.zero,
                                onTap: () => Navigator.pop(context, category),
                                title: Text(category.name),
                                subtitle: category.description.isEmpty
                                    ? null
                                    : Text(category.description),
                                leading: Icon(category.icon,
                                    color: category.color.color),
                              );
                            },
                            separatorBuilder: (_, index) => Hr(),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
