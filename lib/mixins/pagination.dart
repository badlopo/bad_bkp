import 'package:bookkeeping/utils/toast.dart';
import 'package:flutter/cupertino.dart';

mixin PaginatedQueryMixin<T extends StatefulWidget, Item> on State<T> {
  bool get autoInitialize => true;

  Future<Iterable<Item>?> fetcher();

  String filter = '';
  int pageNo = 1;
  final int pageSize = 20;
  bool isEnd = false;

  List<Item>? result;

  Future<void> nextPage() async {
    if (isEnd) {
      ToastUtils.info('No more data');
      return;
    }

    final items = await fetcher();

    if (items == null) {
      ToastUtils.error('Fail to fetch');
      return;
    }

    setState(() {
      if (result == null || pageNo == 1) {
        result = items.toList();
      } else {
        result!.addAll(items);
      }
    });

    pageNo += 1;
    if (items.length < pageSize) isEnd = true;
  }

  Future<void> reloadPage() async {
    pageNo = 1;
    isEnd = false;
    await nextPage();
  }

  Future<void> handleFilter(String s) {
    filter = s;
    return reloadPage();
  }

  Future<void> handleResetFilter() {
    filter = '';
    return reloadPage();
  }

  @override
  void initState() {
    super.initState();

    if (autoInitialize) reloadPage();
  }
}
