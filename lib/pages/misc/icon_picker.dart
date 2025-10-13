import 'package:bookkeeping/constants/icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class IconPickerPage extends StatefulWidget {
  final Color? color;

  const IconPickerPage({super.key, this.color});

  @override
  State<IconPickerPage> createState() => _IconPickerPageState();
}

class _IconPickerPageState extends State<IconPickerPage> {
  final TextEditingController controller = TextEditingController();

  List<BKPIcon> icons = bkpIcons;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: CupertinoNavigationBar(
        middle: Text('Select an icon'),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: CupertinoSearchTextField(
                controller: controller,
                onSubmitted: (s) {
                  final keyword = s.trim();
                  setState(() {
                    icons = bkpIcons
                        .where((icon) => icon.name.contains(keyword))
                        .toList(growable: false);
                  });
                },
                onSuffixTap: () {
                  controller.clear();
                  setState(() {
                    icons = bkpIcons;
                  });
                },
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 48,
                ),
                itemCount: icons.length,
                itemBuilder: (context, index) {
                  final item = icons[index];
                  return GestureDetector(
                    onTap: () => context.pop(item),
                    child: Icon(item.icon, color: widget.color),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
