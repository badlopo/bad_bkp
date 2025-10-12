import 'package:bookkeeping/services/theme.dart';
import 'package:flutter/cupertino.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool darkMode = false;

  void selectThemeColor() async {
    final current = bkpTheme.themeColor.color;

    final r = await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.6),
        child: CupertinoActionSheet(
          title: Text('Theme color'),
          actions: [
            for (final option in bkpThemeColors)
              CupertinoActionSheetAction(
                onPressed: () => Navigator.pop(context, option),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      option.name,
                      style: TextStyle(color: option.color),
                    ),
                    if (current == option.color)
                      Icon(
                        CupertinoIcons.check_mark_circled,
                        color: option.color,
                      ),
                  ],
                ),
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ),
      ),
    );

    if (r != null) bkpTheme.themeColor = r;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('Settings')),
      child: ListView(
        children: [
          CupertinoFormSection.insetGrouped(
            header: Text('Preference'),
            children: [
              CupertinoListTile(
                title: Text('Theme color'),
                additionalInfo: Text(
                  bkpTheme.themeColor.name,
                  style: TextStyle(color: bkpTheme.themeColor.color),
                ),
                trailing: const CupertinoListTileChevron(),
                onTap: () => selectThemeColor(),
              ),
              CupertinoListTile(
                title: Text('Dark mode'),
                trailing: CupertinoSwitch(
                  value:
                      CupertinoTheme.brightnessOf(context) == Brightness.dark,
                  onChanged: (v) => bkpTheme.darkMode = v,
                ),
              ),
            ],
          ),
          CupertinoFormSection.insetGrouped(
            header: Text('Storage'),
            children: [
              CupertinoListTile(
                title: Text('Storage management'),
                trailing: const CupertinoListTileChevron(),
                onTap: () {
                  // TODO: storage management
                },
              ),
            ],
          ),
          CupertinoFormSection.insetGrouped(
            header: Text('About'),
            children: [
              CupertinoListTile(
                title: Text('Version'),
                additionalInfo: Text('0.0.1'),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  // TODO: open in app store
                },
              ),
              CupertinoListTile(
                title: Text('Feedback'),
                additionalInfo: Text('Rate or review on the app store'),
                trailing: const CupertinoListTileChevron(),
                onTap: () {
                  // TODO: open in app store
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
