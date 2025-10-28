import 'dart:io';

import 'package:bookkeeping/components/hr.dart';
import 'package:bookkeeping/components/indicator.dart';
import 'package:bookkeeping/components/refreshable.dart';
import 'package:bookkeeping/constants/constraint.dart';
import 'package:bookkeeping/db/database.dart';
import 'package:bookkeeping/extensions/datetime.dart';
import 'package:bookkeeping/helpers/decimal_text_input_formatter.dart';
import 'package:bookkeeping/mixins/pagination.dart';
import 'package:bookkeeping/route/route.dart';
import 'package:bookkeeping/utils/image.dart';
import 'package:bookkeeping/utils/storage.dart';
import 'package:bookkeeping/utils/toast.dart';
import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// region category picker

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

// endregion

// region snapshot

class _SnapshotItem extends StatelessWidget {
  final File file;
  final VoidCallback onDelete;

  const _SnapshotItem({required this.file, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            fullscreenDialog: true,
            builder: (context) => CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                  // TODO: implement download functionality
                  // trailing: CupertinoButton(
                  //   sizeStyle: CupertinoButtonSize.small,
                  //   padding: EdgeInsets.zero,
                  //   child: Text('Download'),
                  //   onPressed: () {},
                  // ),
                  ),
              child: Center(child: Image.file(file)),
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(top: 8, right: 8),
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
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: onDelete,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: CupertinoColors.separator.resolveFrom(context),
                child: Icon(
                  CupertinoIcons.delete,
                  size: 16,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SnapshotSection extends StatefulWidget {
  final Set<File> files;

  const _SnapshotSection({required this.files});

  @override
  State<StatefulWidget> createState() => _SnapshotSectionState();
}

class _SnapshotSectionState extends State<_SnapshotSection> {
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
      if (widget.files.any((f) => f.path == newFile.path)) {
        ToastUtils.error('This file has been added');
        return;
      }

      setState(() {
        widget.files.add(newFile);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
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
        if (widget.files.isNotEmpty)
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.all(12),
              children: [
                for (final file in widget.files)
                  Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: _SnapshotItem(
                      file: file,
                      onDelete: () => setState(() {
                        widget.files.remove(file);
                      }),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

// endregion

// region tag

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
    final r = await BKPDatabase.instance.getTags(filter);

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

// endregion

class TransactionSpecPage extends StatefulWidget {
  final TransactionWithCategoryAndTags? current;

  const TransactionSpecPage({super.key, this.current});

  @override
  State<StatefulWidget> createState() => _TransactionSpecPageState();
}

class _TransactionSpecPageState extends State<TransactionSpecPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

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
        final transaction = widget.current?.tx;
        if (transaction == null) {
          await BKPDatabase.instance.createTransaction(
            amount: amount * (isIncome ? 1 : -1),
            description: description,
            categoryId: category?.id,
            time: time,
            snapshotFiles: snapshotFiles,
            tagIds: tagIds,
          );
        } else {
          await BKPDatabase.instance.updateTransaction(
            transaction.id,
            amount: amount,
            description: description,
            categoryId: category?.id,
            time: time,
            snapshots: snapshotFiles,
            tagIds: tagIds,
          );
        }
      });

      // ignore: use_build_context_synchronously
      context.pop(true);
    }
  }

  void handleDeletion() async {
    final confirm = await showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Delete this transaction?'),
          content: Text('This action cannot be undone.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;

    await ToastUtils.loadingWithTxn(() async {
      await BKPDatabase.instance.deleteTransaction(widget.current!.tx.id);
    });

    // ignore: use_build_context_synchronously
    context.pop(true);
  }

  @override
  void initState() {
    super.initState();

    if (widget.current != null) {
      final tx = widget.current!.tx;

      isIncome = tx.amount > 0;
      amount = tx.amount.abs();
      description = tx.description;
      category = widget.current!.category;
      time = tx.time;
      snapshotFiles = tx.snapshots.toSet();
      tagIds = widget.current!.tags.map((t) => t.id).toSet();

      _amountController.text = '${amount / 100}';
      _descController.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: CupertinoNavigationBar(
        middle: widget.current == null
            ? Text('Create transaction')
            : Text('Transaction detail'),
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
                  initialValue: amount,
                  validator: (v) => v == 0 ? 'Required' : null,
                  builder: (field) {
                    return CupertinoFormRow(
                      prefix: Text('Amount'),
                      error: (field.errorText == null)
                          ? null
                          : Text(field.errorText!),
                      child: CupertinoTextField.borderless(
                        controller: _amountController,
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
                              Icon(category!.icon,
                                  color: category!.color.color),
                              Flexible(
                                child: Text(category!.name,
                                    overflow: TextOverflow.ellipsis),
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
                  controller: _descController,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textInputAction: TextInputAction.newline,
                  minLines: 1,
                  maxLines: 5,
                  maxLength: BKPConstraints.transactionDescriptionMaxLength,
                  placeholder: 'Enter a description for this transaction.',
                  onChanged: (v) => description = v,
                ),
              ],
            ),
            _SnapshotSection(files: snapshotFiles),
            _TagSection(selectIds: tagIds),
            if (widget.current != null)
              Padding(
                padding: EdgeInsets.fromLTRB(20, 32, 20, 0),
                child: CupertinoButton.tinted(
                  color: CupertinoColors.destructiveRed,
                  onPressed: handleDeletion,
                  child: Text(
                    'Delete',
                    style: TextStyle(color: CupertinoColors.destructiveRed),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
