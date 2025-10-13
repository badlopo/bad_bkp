import 'package:flutter/cupertino.dart';

class BKPColor {
  static BKPColor fromName(String name) {
    for (final item in bkpColors) {
      if (item.name == name) return item;
    }
    return bkpColors[0];
  }

  final String name;
  final Color color;

  const BKPColor._(this.name, this.color);

  const BKPColor.blue()
      : name = 'Blue',
        color = CupertinoColors.systemBlue;

  const BKPColor.green()
      : name = 'Green',
        color = CupertinoColors.systemGreen;

  const BKPColor.mint()
      : name = 'Mint',
        color = CupertinoColors.systemMint;

  const BKPColor.indigo()
      : name = 'Indigo',
        color = CupertinoColors.systemIndigo;

  const BKPColor.orange()
      : name = 'Orange',
        color = CupertinoColors.systemOrange;

  const BKPColor.pink()
      : name = 'Pink',
        color = CupertinoColors.systemPink;

  const BKPColor.brown()
      : name = 'Brown',
        color = CupertinoColors.systemBrown;

  const BKPColor.purple()
      : name = 'Purple',
        color = CupertinoColors.systemPurple;

  const BKPColor.red()
      : name = 'Red',
        color = CupertinoColors.systemRed;

  const BKPColor.teal()
      : name = 'Teal',
        color = CupertinoColors.systemTeal;

  const BKPColor.cyan()
      : name = 'Cyan',
        color = CupertinoColors.systemCyan;

  const BKPColor.yellow()
      : name = 'Yellow',
        color = CupertinoColors.systemYellow;

  const BKPColor.grey()
      : name = 'Grey',
        color = CupertinoColors.systemGrey;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is BKPColor && name == other.name && color == other.color;
  }

  @override
  int get hashCode => Object.hash(name, color);
}

const bkpColors = [
  BKPColor.blue(),
  BKPColor.green(),
  BKPColor.mint(),
  BKPColor.indigo(),
  BKPColor.orange(),
  BKPColor.pink(),
  BKPColor.brown(),
  BKPColor.purple(),
  BKPColor.red(),
  BKPColor.teal(),
  BKPColor.cyan(),
  BKPColor.yellow(),
  BKPColor.grey(),
];
