import 'package:flutter/cupertino.dart';

class CategoryCreationPage extends StatefulWidget {
  const CategoryCreationPage({super.key});

  @override
  State<CategoryCreationPage> createState() => _CategoryCreationPage();
}

class _CategoryCreationPage extends State<CategoryCreationPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Form(
        autovalidateMode: AutovalidateMode.onUnfocus,
        child: CupertinoFormSection.insetGrouped(
          header: Text('Create category'),
          children: [
            CupertinoTextFormFieldRow(
              prefix: Text('Name'),
              validator: (s) => 'xx',
            ),
            CupertinoTextFormFieldRow(
              prefix: Text('Description'),
              // validator: (s) => ,
            ),
            CupertinoTextFormFieldRow(
              prefix: Text('Name'),
              // validator: (s) => ,
            ),
            CupertinoFormRow(
              prefix: Text('Icon'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Icon(CupertinoIcons.airplane),
                  SizedBox(width: 4),
                  CupertinoListTileChevron(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
