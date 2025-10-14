import 'package:bookkeeping/components/palette.dart';
import 'package:bookkeeping/constants/color.dart';
import 'package:bookkeeping/constants/icon.dart';
import 'package:bookkeeping/db/database.dart';
import 'package:bookkeeping/route/route.dart';
import 'package:bookkeeping/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class CategoryCreationPage extends StatefulWidget {
  const CategoryCreationPage({super.key});

  @override
  State<CategoryCreationPage> createState() => _CategoryCreationPage();
}

class _CategoryCreationPage extends State<CategoryCreationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  String name = '';
  String description = '';
  BKPIcon icon = (name: 'collections', icon: CupertinoIcons.collections);
  BKPColor color = BKPColor.blue();

  void handleIconSelection() async {
    final newIcon = await context.pushNamed<BKPIcon>(
      RouteNames.iconPicker,
      extra: color.color,
    );

    if (newIcon != null) {
      setState(() {
        icon = newIcon;
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
        await BKPDatabase.instance.createCategory(
          name: name,
          description: description,
          icon: icon.icon,
          color: color,
        );
      });

      // ignore: use_build_context_synchronously
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        border: null,
        backgroundColor: CupertinoColors.systemGroupedBackground,
        automaticBackgroundVisibility: false,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: context.pop,
          child: Text('Cancel'),
        ),
        middle: Text('Create category'),
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
                CupertinoTextFormFieldRow(
                  textInputAction: TextInputAction.next,
                  textAlign: TextAlign.end,
                  autofocus: true,
                  maxLength: 10,
                  prefix: Text('Name'),
                  validator: (v) => v?.isNotEmpty == true ? null : 'Required',
                  onSaved: (v) => name = v!,
                ),
                CupertinoTextFormFieldRow(
                  textInputAction: TextInputAction.done,
                  textAlign: TextAlign.end,
                  maxLength: 20,
                  prefix: Text('Description'),
                  onSaved: (v) => description = v!,
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              dividerMargin: 0,
              additionalDividerMargin: 0,
              children: [
                CupertinoListTile(
                  title: Text('Icon'),
                  additionalInfo: Icon(icon.icon, color: color.color),
                  trailing: CupertinoListTileChevron(),
                  onTap: handleIconSelection,
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
          ],
        ),
      ),
    );
  }
}
