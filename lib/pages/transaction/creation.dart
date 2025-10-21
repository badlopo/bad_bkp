import 'dart:io';

import 'package:bookkeeping/components/indicator.dart';
import 'package:bookkeeping/constants/constraint.dart';
import 'package:bookkeeping/db/database.dart';
import 'package:bookkeeping/extensions/datetime.dart';
import 'package:bookkeeping/pages/transaction/_shared/category_picker.dart';
import 'package:bookkeeping/utils/image.dart';
import 'package:bookkeeping/utils/storage.dart';
import 'package:bookkeeping/utils/toast.dart';
import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class _DecimalTextInputFormatter extends TextInputFormatter {
  const _DecimalTextInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final reg = RegExp(r'^(0|[1-9]\d*)(\.\d{0,2})?$');
    if (reg.hasMatch(text)) return newValue;

    return oldValue;
  }
}

class _SnapshotItem extends StatelessWidget {
  final File file;
  final VoidCallback onPress;

  const _SnapshotItem({required this.file, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          border: Border.fromBorderSide(
            BorderSide(
              color: CupertinoColors.systemFill,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Image.file(file),
      ),
    );
  }
}

class _TagSection extends StatefulWidget {
  final Set<int> selectIds;

  const _TagSection({required this.selectIds});

  @override
  State<_TagSection> createState() => _TagSectionState();
}

class _TagSectionState extends State<_TagSection> {
  final TextEditingController controller = TextEditingController();
  String filter = '';
  List<Tag>? tags;

  Future<void> getTags() async {
    final r = await BKPDatabase.instance.getTags(
      filter: filter,
      pageSize: null,
    );

    setState(() {
      tags = r;
    });
  }

  Future<void> handleCreateTag() async {
    String name = filter;
    if (name.isEmpty) {
      final newName = await showCupertinoDialog<String>(
        context: context,
        builder: (BuildContext context) {
          String s = '';
          return CupertinoAlertDialog(
            title: Text('Create tag'),
            content: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: CupertinoTextField(
                autofocus: true,
                maxLength: BKPConstraints.tagNameMaxLength,
                clearButtonMode: OverlayVisibilityMode.editing,
                placeholder: 'Enter tag name',
                onChanged: (v) => s = v,
                onSubmitted: (v) => Navigator.pop(context, v),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.pop(context, s),
                child: const Text('Create'),
              ),
            ],
          );
        },
      );
      if (newName == null) return;
      if (newName.isEmpty) {
        ToastUtils.error('Tag name can not be empty!');
        return;
      }
      name = newName;
    }

    setState(() {
      tags = null;
    });

    final newTag = await BKPDatabase.instance.createTag(name);
    widget.selectIds.add(newTag.id);

    return handleResetFilter();
  }

  void handleFilter(String s) async {
    filter = s;
    await getTags();
  }

  void handleResetFilter() async {
    controller.clear();
    filter = '';
    await getTags();
  }

  @override
  void initState() {
    super.initState();

    getTags();
  }

  Iterable<Widget> _items() sync* {
    for (final tag in tags!) {
      final active = widget.selectIds.contains(tag.id);

      yield CupertinoButton.tinted(
        sizeStyle: CupertinoButtonSize.small,
        pressedOpacity: null,
        color: active ? null : CupertinoColors.tertiarySystemFill,
        // onPressed: null,
        onPressed: () {
          setState(() {
            active
                ? widget.selectIds.remove(tag.id)
                : widget.selectIds.add(tag.id);
          });
        },
        child: Text(
          tag.name,
          style: TextStyle(
            color: active
                ? null
                : CupertinoColors.tertiaryLabel.resolveFrom(context),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Tags'),
          CupertinoButton(
            padding: EdgeInsets.zero,
            sizeStyle: CupertinoButtonSize.small,
            onPressed: getTags,
            child: Icon(CupertinoIcons.arrow_2_circlepath),
          ),
        ],
      ),
      footer: Text(
        'Click a label to toggle its selection.',
        style: TextStyle(
          color: CupertinoColors.tertiaryLabel.resolveFrom(context),
          fontSize: 14,
        ),
      ),
      dividerMargin: 0,
      additionalDividerMargin: 0,
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: CupertinoSearchTextField(
            controller: controller,
            onChanged: (s) {
              if (s.length > BKPConstraints.tagNameMaxLength) {
                controller.text =
                    s.substring(0, BKPConstraints.tagNameMaxLength);
              }
            },
            onSubmitted: handleFilter,
            onSuffixTap: handleResetFilter,
          ),
        ),
        if (tags == null)
          SizedBox(height: 108, child: LoadingIndicator())
        else
          Padding(
            padding: EdgeInsets.all(10),
            child: SizedBox(
              width: double.infinity,
              height: 88,
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (tags!.isEmpty)
                      CupertinoButton.tinted(
                        sizeStyle: CupertinoButtonSize.small,
                        onPressed: handleCreateTag,
                        child: Text(filter.isEmpty
                            ? 'Create a tag'
                            : 'Create tag "$filter"'),
                      )
                    else
                      ..._items(),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

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

  void handleSnapshotSelection() async {
    final fromAlbum = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('Snapshot'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, false),
            child: Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.photo_camera),
                Text('Take a photo'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, true),
            child: Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.photo),
                Text('Select from album'),
              ],
            ),
          ),
        ],
      ),
    );
    if (fromAlbum == null) return;

    final r = await (fromAlbum
        ? ImageUtils.getFromAlbum()
        : ImageUtils.getByCamera());

    if (r != null) {
      final newFile = await StorageUtils.saveTransactionSnapshot(r);
      if (snapshotFiles.any((f) => f.path == newFile.path)) {
        ToastUtils.error('This file has been added');
        return;
      }

      setState(() {
        snapshotFiles.add(newFile);
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
      resizeToAvoidBottomInset: false,
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
                    children: {true: Text('Income'), false: Text('Expense')},
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
                        inputFormatters: [_DecimalTextInputFormatter()],
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
            CupertinoListSection.insetGrouped(
              dividerMargin: 0,
              additionalDividerMargin: 0,
              header: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Snapshot'),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    sizeStyle: CupertinoButtonSize.small,
                    onPressed: handleSnapshotSelection,
                    child: Icon(CupertinoIcons.add),
                  ),
                ],
              ),
              children: [
                if (snapshotFiles.isNotEmpty)
                  SizedBox(
                    height: 110,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.all(12),
                      children: [
                        for (final file in snapshotFiles)
                          Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: _SnapshotItem(
                              file: file,
                              onPress: () => setState(() {
                                snapshotFiles.remove(file);
                              }),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
            _TagSection(selectIds: tagIds),
          ],
        ),
      ),
    );
  }
}
