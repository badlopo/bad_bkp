import 'package:bookkeeping/components/indicator.dart';
import 'package:bookkeeping/components/refreshable.dart';
import 'package:bookkeeping/constants/tunnel.dart';
import 'package:bookkeeping/db/database.dart';
import 'package:bookkeeping/route/route.dart';
import 'package:bookkeeping/utils/toast.dart';
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
        SingleTunnelListenerMixin<CategoryHomePage, Symbol> {
  @override
  bool get wantKeepAlive => true;

  @override
  TunnelIdentifier get tunnelName => BKPTunnels.category;

  @override
  void onTunnelEvent(Symbol event) {
    if (event == #create) handleCategoryCreation();
  }

  int page = 1;
  bool isEnd = false;

  final TextEditingController controller = TextEditingController();
  String filter = '';

  List<Category>? categories;

  Future<void> nextPage() async {
    if (isEnd) {
      ToastUtils.info('No more data');
      return;
    }

    final r = await BKPDatabase.instance.getCategories(
      filter: filter,
      pageNo: page,
    );

    setState(() {
      if (categories == null || page == 1) {
        categories = r;
      } else {
        categories!.addAll(r);
      }
    });

    page += 1;
    if (r.length < 20) isEnd = true;
  }

  Future<void> reloadPage() async {
    page = 1;
    isEnd = false;
    await nextPage();
    ToastUtils.success('Refreshed');
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

  void handleFilter(String s) {
    filter = s;
    reloadPage();
  }

  void handleResetFilter() {
    controller.clear();
    filter = '';
    reloadPage();
  }

  @override
  void initState() {
    super.initState();

    reloadPage();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final list = categories;

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
                child: ListView.builder(
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
