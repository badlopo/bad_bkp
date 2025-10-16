import 'package:bookkeeping/constants/color.dart';
import 'package:bookkeeping/utils/storage.dart';
import 'package:flutter/cupertino.dart';

class _BKPTheme extends ChangeNotifier {
  bool _darkMode = false;

  bool get darkMode => _darkMode;

  set darkMode(bool v) {
    _darkMode = v;
    save();
    notifyListeners();
  }

  BKPColor _themeColor = bkpColors[0];

  BKPColor get themeColor => _themeColor;

  set themeColor(BKPColor v) {
    _themeColor = v;
    save();
    notifyListeners();
  }
}

// ignore: library_private_types_in_public_api
extension BKPThemeExt on _BKPTheme {
  void save() {
    StorageUtils.setKV(KVType.theme, {
      'darkMode': _darkMode,
      'themeColorName': _themeColor.name,
    });
  }

  void restore() {
    final theme = StorageUtils.getKVAsMap(KVType.theme);
    if (theme == null) return;

    _darkMode = theme['darkMode'];
    _themeColor = BKPColor.fromName(theme['themeColorName']);
  }
}

final bkpTheme = _BKPTheme();
