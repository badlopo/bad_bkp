import 'package:bookkeeping/components/indicator.dart';
import 'package:bookkeeping/components/refreshable.dart';
import 'package:bookkeeping/db/database.dart';
import 'package:bookkeeping/extensions/datetime.dart';
import 'package:bookkeeping/helpers/year_month.dart';
import 'package:bookkeeping/mixins/pagination.dart';
import 'package:bookkeeping/route/route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

bool _isSameYM(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month;
}

String _formatAmount(int amount) {
  final isNegative = amount < 0;
  final absAmount = amount.abs();
  final formatted = (absAmount / 100)
      .toStringAsFixed(2)
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
  return isNegative ? '-$formatted' : '+$formatted';
}

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage>
    with PaginatedQueryMixin<TransactionPage, TransactionWithCategoryAndTags> {
  final Map<YearMonth, TxStatistic> _monthlyStatistic = {};

  Future<void> _getMonthlyStatistic() async {
    setState(() {
      _monthlyStatistic.clear();
    });

    await Future.wait([
      for (final ym
          in result!.map((e) => YearMonth.fromDateTime(e.tx.time)).toSet())
        BKPDatabase.instance.getStatisticOfYearMonth(ym)
          ..then((statistic) => _monthlyStatistic[ym] = statistic),
    ]);

    setState(() {});
  }

  @override
  Future<Iterable<TransactionWithCategoryAndTags>?> fetch() {
    return BKPDatabase.instance
        .getTransactions(pageNo: pageNo, pageSize: pageSize);
  }

  @override
  Future<void> reloadPage() async {
    await super.reloadPage();
    await _getMonthlyStatistic();
  }

  @override
  Future<void> nextPage() async {
    await super.nextPage();
    await _getMonthlyStatistic();
  }

  Future<void> handleTransactionCreation() async {
    final r = await context.pushNamed(RouteNames.transactionCreation);
    if (r == true) reloadPage();
  }

  void handleToTransactionDetail(TransactionWithCategoryAndTags d) async {
    final r = await context.pushNamed(RouteNames.transactionDetail, extra: d);
    if (r == true) reloadPage();
  }

  Widget _buildGroupHeader(YearMonth ym) {
    final statistic = _monthlyStatistic[ym];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$ym'),
        // TODO: show statistic
        if (statistic != null) Text(_formatAmount(statistic.total)),
      ],
    );
  }

  Widget _buildGroupItem(TransactionWithCategoryAndTags item) {
    return CupertinoListTile(
      onTap: () => handleToTransactionDetail(item),
      leadingSize: 36,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: item.category?.color.color,
        child: Icon(
          item.category?.icon,
          color: CupertinoColors.white,
        ),
      ),
      title: item.tx.description.isEmpty
          ? Text(
              '<No Description>',
              style: TextStyle(color: CupertinoColors.secondaryLabel),
            )
          : Text(item.tx.description),
      subtitle: Text(item.tx.time.formatted),
      additionalInfo: Text(_formatAmount(item.tx.amount)),
      trailing: CupertinoListTileChevron(),
    );
  }

  Iterable<Widget> buildGroupedItems() sync* {
    if (result?.isNotEmpty != true) return;

    int startIndex = 0;

    for (final (index, row) in result!.indexed) {
      if (index == 0) continue;

      if (_isSameYM(result![startIndex].tx.time, row.tx.time)) continue;

      // yield previous group
      yield CupertinoFormSection.insetGrouped(
        header: _buildGroupHeader(
            YearMonth.fromDateTime(result![startIndex].tx.time)),
        children: [
          for (int i = startIndex; i < index; i++) _buildGroupItem(result![i]),
        ],
      );

      startIndex = index;
    }

    // yield last group
    yield CupertinoFormSection.insetGrouped(
      header: _buildGroupHeader(
          YearMonth.fromDateTime(result![startIndex].tx.time)),
      children: [
        for (int i = startIndex; i < result!.length; i++)
          _buildGroupItem(result![i]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return CupertinoPageScaffold(
        resizeToAvoidBottomInset: false,
        navigationBar: CupertinoNavigationBar(middle: Text('Transactions')),
        child: LoadingIndicator(),
      );
    }

    if (result!.isEmpty) {
      return CupertinoPageScaffold(
        resizeToAvoidBottomInset: false,
        navigationBar: CupertinoNavigationBar(middle: Text('Transactions')),
        child: EmptyIndicator(
          hint: 'No data',
          footer: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CupertinoButton.filled(
                  onPressed: handleTransactionCreation,
                  child: Text('Create'),
                ),
                CupertinoButton(
                  onPressed: reloadPage,
                  child: Text('Refresh'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('Transactions')),
      child: SafeArea(
        child: BKPRefreshable(
          onRefresh: reloadPage,
          onLoad: nextPage,
          child: ListView(children: [...buildGroupedItems()]),
        ),
      ),
    );
  }
}
