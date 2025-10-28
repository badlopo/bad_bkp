import 'package:bookkeeping/components/palette.dart';
import 'package:bookkeeping/constants/color.dart';
import 'package:bookkeeping/constants/constraint.dart';
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
  IconData icon = CupertinoIcons.collections;
  BKPColor color = BKPColor.blue();

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
        await BKPDatabase.instance.createCategory(
          name: name,
          description: description,
          icon: icon,
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
      navigationBar: CupertinoNavigationBar(
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
            CupertinoFormSection.insetGrouped(
              header: Text('Base'),
              children: [
                CupertinoTextFormFieldRow(
                  textInputAction: TextInputAction.next,
                  textAlign: TextAlign.right,
                  autofocus: true,
                  maxLength: BKPConstraints.categoryNameMaxLength,
                  prefix: Text('Name'),
                  validator: (v) => v?.isNotEmpty == true ? null : 'Required',
                  onSaved: (v) => name = v!,
                ),
                CupertinoTextFormFieldRow(
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
          ],
        ),
      ),
    );
  }
}
