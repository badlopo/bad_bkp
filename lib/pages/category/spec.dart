import 'package:bookkeeping/components/palette.dart';
import 'package:bookkeeping/constants/color.dart';
import 'package:bookkeeping/constants/constraint.dart';
import 'package:bookkeeping/constants/icon.dart';
import 'package:bookkeeping/db/database.dart';
import 'package:bookkeeping/extensions/datetime.dart';
import 'package:bookkeeping/route/route.dart';
import 'package:bookkeeping/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class CategorySpecPage extends StatefulWidget {
  final CategoryWithCount? current;

  const CategorySpecPage({super.key, required this.current});

  @override
  State<CategorySpecPage> createState() => _CategorySpecPageState();
}

class _CategorySpecPageState extends State<CategorySpecPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  late String name = widget.current?.category.name ?? '';
  late String description = widget.current?.category.description ?? '';
  late BKPColor color = widget.current?.category.color ?? BKPColor.blue();
  late IconData icon =
      widget.current?.category.icon ?? CupertinoIcons.collections;

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
        final category = widget.current?.category;
        if (category == null) {
          await BKPDatabase.instance.createCategory(
            name: name,
            description: description,
            icon: icon,
            color: color,
          );
        } else {
          await BKPDatabase.instance.updateCategory(
            category.id,
            name: name,
            description: description,
            icon: icon,
            color: color,
          );
        }
      });
    }

    // ignore: use_build_context_synchronously
    context.pop(true);
  }

  void handleDeletion() async {
    final category = widget.current!.category;
    final count = widget.current!.count;

    final confirm = await showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Delete category "${category.name}"?'),
          content: Text(
              'There are $count items under that category, this will move those items to "Uncategorized".'),
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
      await BKPDatabase.instance.deleteCategory(category.id);
    });

    // ignore: use_build_context_synchronously
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: CupertinoNavigationBar(
        middle: widget.current == null
            ? Text('Create category')
            : Text('Category detail'),
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
            CupertinoFormSection.insetGrouped(
              header: Text('Base'),
              children: [
                CupertinoTextFormFieldRow(
                  initialValue: name,
                  textInputAction: TextInputAction.next,
                  textAlign: TextAlign.right,
                  autofocus: true,
                  maxLength: BKPConstraints.categoryNameMaxLength,
                  prefix: Text('Name'),
                  validator: (v) => v?.isNotEmpty == true ? null : 'Required',
                  onSaved: (v) => name = v!,
                ),
                CupertinoTextFormFieldRow(
                  initialValue: description,
                  textInputAction: TextInputAction.done,
                  textAlign: TextAlign.right,
                  maxLength: BKPConstraints.categoryDescriptionMaxLength,
                  prefix: Text('Description'),
                  onSaved: (v) => description = v!,
                ),
              ],
            ),
            CupertinoFormSection.insetGrouped(
              header: Text('Icon'),
              children: [
                CupertinoListTile(
                  title: Text('Icon'),
                  additionalInfo: Icon(icon, color: color.color),
                  trailing: CupertinoListTileChevron(),
                  onTap: handleIconSelection,
                ),
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
            if (widget.current != null)
              CupertinoFormSection.insetGrouped(
                header: Text('More'),
                children: [
                  CupertinoListTile(
                    title: Text('Created'),
                    additionalInfo:
                        Text(widget.current!.category.createdAt.formatted),
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
