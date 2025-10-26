import 'dart:io';

import 'package:bookkeeping/constants/constraint.dart';
import 'package:bookkeeping/db/database.dart';
import 'package:bookkeeping/extensions/datetime.dart';
import 'package:bookkeeping/helpers/decimal_text_input_formatter.dart';
import 'package:bookkeeping/pages/transaction/_shared/category_picker.dart';
import 'package:bookkeeping/pages/transaction/_shared/snapshot_section.dart';
import 'package:bookkeeping/pages/transaction/_shared/tag_section.dart';
import 'package:bookkeeping/utils/toast.dart';
import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class TransactionCreationPage extends StatefulWidget {
  const TransactionCreationPage({super.key});

  @override
  State<TransactionCreationPage> createState() => _TransactionCreationPage();
}

class _TransactionCreationPage extends State<TransactionCreationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  bool isIncome = false;

  int amount = 0;
  String description = '';
  Category? category;
  DateTime time = DateTime.now();
  Set<File> snapshotFiles = {};
  Set<int> tagIds = {};

  void handleCategorySelection() async {
    final r = await CategoryPicker.show(context);
    if (r != null) {
      setState(() {
        category = r;
      });
    }
  }

  void handleSubmit() async {
    final formState = _formKey.currentState;
    if (formState == null) {
      ToastUtils.error('Unexpected internal error!');
      return;
    }

    if (formState.validate()) {
      formState.save();

      await ToastUtils.loadingWithTxn(() async {
        await BKPDatabase.instance.createTransaction(
          amount: amount * (isIncome ? 1 : -1),
          description: description,
          categoryId: category?.id,
          time: time,
          snapshotFiles: snapshotFiles,
          tagIds: tagIds,
        );
      });

      // ignore: use_build_context_synchronously
      context.pop(true);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        automaticBackgroundVisibility: false,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: context.pop,
          child: Text('Cancel'),
        ),
        middle: Text('Create transaction'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: handleSubmit,
          child: Text('Done'),
        ),
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          physics: ClampingScrollPhysics(),
          children: [
            CupertinoListSection.insetGrouped(
              dividerMargin: 0,
              additionalDividerMargin: 0,
              header: Text('Transaction'),
              children: [
                CupertinoListTile(
                  title: Text('Type'),
                  trailing: CupertinoSlidingSegmentedControl(
                    groupValue: isIncome,
                    children: {
                      true: Text('Income'),
                      false: Text('Expenditure')
                    },
                    onValueChanged: (v) {
                      setState(() {
                        isIncome = v!;
                      });
                    },
                  ),
                ),
                FormField<int>(
                  initialValue: 0,
                  validator: (v) => v == 0 ? 'Required' : null,
                  builder: (field) {
                    return CupertinoFormRow(
                      prefix: Text('Amount'),
                      error: (field.errorText == null)
                          ? null
                          : Text(field.errorText!),
                      child: CupertinoTextField.borderless(
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        inputFormatters: const [DecimalTextInputFormatter()],
                        onChanged: (s) {
                          amount =
                              s.isEmpty ? 0 : (double.parse(s) * 100).toInt();
                          field.didChange(amount);
                        },
                      ),
                    );
                  },
                ),
                CupertinoListTile(
                  onTap: handleCategorySelection,
                  title: Text('Category'),
                  additionalInfo: category == null
                      ? Text('Select')
                      : Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            spacing: 8,
                            children: [
                              Icon(
                                category!.icon,
                                color: category!.color.color,
                              ),
                              Flexible(
                                child: Text(
                                  category!.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                  trailing: CupertinoListTileChevron(),
                ),
                CupertinoListTile(
                  title: Text('Date & Time'),
                  additionalInfo: CupertinoCalendarPickerButton(
                    mode: CupertinoCalendarMode.dateTime,
                    mainColor: CupertinoTheme.of(context).primaryColor,
                    minimumDateTime: DateTime(2000, 1, 1),
                    maximumDateTime: DateTime(2099, 12, 31),
                    initialDateTime: time,
                    formatter: (d) => d.formatted,
                    onDateTimeChanged: (t) => time = t,
                  ),
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              dividerMargin: 0,
              additionalDividerMargin: 0,
              header: Text('Description'),
              children: [
                CupertinoTextField.borderless(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textInputAction: TextInputAction.newline,
                  minLines: 1,
                  maxLines: 5,
                  maxLength: BKPConstraints.transactionDescriptionMaxLength,
                  placeholder: 'Enter a description for this transaction.',
                ),
              ],
            ),
            SnapshotSection(files: snapshotFiles),
            TagSection(selectIds: tagIds),
          ],
        ),
      ),
    );
  }
}
