import 'package:bookkeeping/db/database.dart';
import 'package:flutter/cupertino.dart';

class TransactionDetailPage extends StatefulWidget {
  final Transaction transaction;
  final Category? category;
  final List<Tag> tags;

  const TransactionDetailPage({
    super.key,
    required this.transaction,
    this.category,
    required this.tags,
  });

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: ListView(
        children: [
          //
        ],
      ),
    );
  }
}
