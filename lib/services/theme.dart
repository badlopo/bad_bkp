import 'package:bookkeeping/utils/kv.dart';
import 'package:flutter/cupertino.dart';

typedef BKPThemeColor = ({String name, Color color});

const bkpThemeColors = <BKPThemeColor>[
  (name: 'Blue', color: CupertinoColors.systemBlue),
  (name: 'Green', color: CupertinoColors.systemGreen),
  (name: 'Mint', color: CupertinoColors.systemMint),
  (name: 'Indigo', color: CupertinoColors.systemIndigo),
  (name: 'Orange', color: CupertinoColors.systemOrange),
  (name: 'Pink', color: CupertinoColors.systemPink),
  (name: 'Brown', color: CupertinoColors.systemBrown),
  (name: 'Purple', color: CupertinoColors.systemPurple),
  (name: 'Red', color: CupertinoColors.systemRed),
  (name: 'Teal', color: CupertinoColors.systemTeal),
  (name: 'Cyan', color: CupertinoColors.systemCyan),
  (name: 'Yellow', color: CupertinoColors.systemYellow),
  (name: 'Grey', color: CupertinoColors.systemGrey),
];

class _BKPTheme extends ChangeNotifier {
  bool _darkMode = false;

  bool get darkMode => _darkMode;

  set darkMode(bool v) {
    _darkMode = v;
    save();
    notifyListeners();
  }

  BKPThemeColor _themeColor = bkpThemeColors[0];

  BKPThemeColor get themeColor => _themeColor;

  set themeColor(BKPThemeColor v) {
    _themeColor = v;
    save();
    notifyListeners();
  }
}

// ignore: library_private_types_in_public_api
extension BKPThemeExt on _BKPTheme {
  void save() {
    KVUtils.setTheme({
      'darkMode': _darkMode,
      'themeColorName': _themeColor.name,
    });
  }

  void restore() {
    final theme = KVUtils.getTheme();
    if (theme == null) return;

    _darkMode = theme['darkMode'];
    _themeColor = bkpThemeColors.firstWhere(
      (v) => v.name == theme['themeColorName'],
      orElse: () => bkpThemeColors[0],
    );
  }
}

final bkpTheme = _BKPTheme();
