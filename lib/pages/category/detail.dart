import 'package:bookkeeping/components/palette.dart';
import 'package:bookkeeping/constants/color.dart';
import 'package:bookkeeping/constants/constraint.dart';
import 'package:bookkeeping/constants/icon.dart';
import 'package:bookkeeping/db/database.dart';
import 'package:bookkeeping/extensions/datetime.dart';
import 'package:bookkeeping/route/route.dart';
import 'package:bookkeeping/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CategoryDetailPage extends StatefulWidget {
  final Category category;
  final int count;

  const CategoryDetailPage({
    super.key,
    required this.category,
    required this.count,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  late String name = widget.category.name;
  late String description = widget.category.description;
  late BKPColor color = widget.category.color;
  late IconData icon = widget.category.icon;

  void handleIconSelection() async {
    final newIcon = await context.pushNamed<BKPIcon>(
      RouteNames.iconPicker,
      extra: color.color,
    );

    if (newIcon != null) {
      setState(() {
        icon = newIcon.icon;
      });
    }
  }

  void handleSubmit() async {
    final formState = _formKey.currentState;
    if (formState == null) {
      ToastUtils.error('Unexpected internal error!');
      return;
    }

    if (formState.validate() == true) {
      formState.save();

      await ToastUtils.loadingWithTxn(() async {
        await BKPDatabase.instance.updateCategory(
          widget.category.id,
          name: name,
          description: description,
          icon: icon,
          color: color,
        );
      });
    }

    // ignore: use_build_context_synchronously
    context.pop(true);
  }

  void handleDeletion() async {
    final confirm = await showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Delete category "${widget.category.name}"?'),
          content: Text(
              'There are ${widget.count} items under that category, this will move those items to "Uncategorized".'),
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
      await BKPDatabase.instance.deleteCategory(widget.category.id);
    });

    // ignore: use_build_context_synchronously
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: CupertinoNavigationBar(
        middle: Text('Category detail'),
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
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: GestureDetector(
                    onTap: handleIconSelection,
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: color.color,
                      child: Icon(icon, size: 48, color: CupertinoColors.white),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    child: ColoredBox(
                      color: CupertinoColors.systemGroupedBackground
                          .resolveFrom(context),
                      child: CupertinoTextFormFieldRow(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        textInputAction: TextInputAction.done,
                        textAlign: TextAlign.center,
                        initialValue: name,
                        maxLength: BKPConstraints.categoryNameMaxLength,
                        validator: (v) =>
                            v?.isNotEmpty == true ? null : 'Required',
                        onSaved: (v) => name = v!,
                      ),
                    ),
                  ),
                ),
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
              children: [
                CupertinoListTile(
                  title: Text('Color'),
                  additionalInfo: Text(color.name),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: BKPPalette(
                    color: color,
                    onTap: (v) => setState(() {
                      color = v;
                    }),
                  ),
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              dividerMargin: 0,
              additionalDividerMargin: 0,
              children: [
                CupertinoListTile(
                  title: Text('Created'),
                  additionalInfo: Text(widget.category.createdAt.formatted),
                ),
                CupertinoListTile(
                  onTap: handleDeletion,
                  title: Text(
                    'Delete',
                    style: TextStyle(color: CupertinoColors.destructiveRed),
                  ),
                  trailing: CupertinoListTileChevron(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
