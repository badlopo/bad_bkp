import 'package:bookkeeping/components/hr.dart';
import 'package:bookkeeping/components/indicator.dart';
import 'package:bookkeeping/components/refreshable.dart';
import 'package:bookkeeping/constants/tunnel.dart';
import 'package:bookkeeping/db/database.dart';
import 'package:bookkeeping/mixins/pagination.dart';
import 'package:bookkeeping/route/route.dart';
import 'package:bookkeeping/utils/tunnel.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class CategoryHomePage extends StatefulWidget {
  const CategoryHomePage({super.key});

  @override
  State<CategoryHomePage> createState() => _CategoryHomePageState();
}

class _CategoryHomePageState extends State<CategoryHomePage>
    with
        AutomaticKeepAliveClientMixin,
        PaginatedQueryMixin<CategoryHomePage, Category>,
        SingleTunnelListenerMixin<CategoryHomePage, Symbol> {
  @override
  bool get wantKeepAlive => true;

  @override
  TunnelIdentifier get tunnelName => BKPTunnels.category;

  @override
  void onTunnelEvent(Symbol event) {
    if (event == #create) handleCategoryCreation();
  }

  final TextEditingController controller = TextEditingController();

  @override
  Future<Iterable<Category>?> fetcher() {
    return BKPDatabase.instance.getCategories(
      filter: filter,
      pageNo: pageNo,
      pageSize: pageSize,
    );
  }

  void handleCategoryCreation() async {
    final r = await context.pushNamed(RouteNames.categoryCreation);
    if (r == true) reloadPage();
  }

  void handleToCategoryDetail(Category category) async {
    final r =
        await context.pushNamed(RouteNames.categoryDetail, extra: category);
    if (r == true) reloadPage();
  }

  @override
  Future<void> handleResetFilter() {
    controller.clear();
    return super.handleResetFilter();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final list = result;

    if (list == null) {
      return CupertinoPageScaffold(
        resizeToAvoidBottomInset: false,
        child: LoadingIndicator(),
      );
    }

    if (list.isEmpty) {
      return CupertinoPageScaffold(
        resizeToAvoidBottomInset: false,
        child: EmptyIndicator(
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
        ),
      );
    }

    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: CupertinoSearchTextField(
                controller: controller,
                onSubmitted: handleFilter,
                onSuffixTap: handleResetFilter,
              ),
            ),
            Expanded(
              child: BKPRefreshable(
                onRefresh: reloadPage,
                onLoad: nextPage,
                child: ListView.separated(
                  itemCount: list.length,
                  itemBuilder: (_, index) {
                    final category = list[index];

                    return CupertinoListTile(
                      padding: EdgeInsets.zero,
                      onTap: () => handleToCategoryDetail(category),
                      title: Text(category.name),
                      subtitle: category.description.isEmpty
                          ? null
                          : Text(category.description),
                      leading: Icon(category.icon, color: category.color.color),
                      trailing: CupertinoListTileChevron(),
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
