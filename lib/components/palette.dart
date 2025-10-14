import 'package:bookkeeping/constants/color.dart';
import 'package:flutter/cupertino.dart';

class BKPPalette extends StatelessWidget {
  static const _activeDecoration = ShapeDecoration(
    shape: CircleBorder(
      side: BorderSide(width: 2, color: CupertinoColors.systemGrey4),
    ),
  );
  static const _inactiveDecoration = ShapeDecoration(
    shape: CircleBorder(
      side: BorderSide(width: 2, color: CupertinoColors.transparent),
    ),
  );

  final double itemSize;
  final BKPColor color;
  final ValueChanged<BKPColor> onTap;

  void _onTap(BKPColor v) {
    if (v == color) return;
    onTap(v);
  }

  const BKPPalette({
    super.key,
    this.itemSize = 48,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Wrap(
        alignment: WrapAlignment.start,
        children: [
          for (final item in bkpColors)
            GestureDetector(
              onTap: () => _onTap(item),
              child: Container(
                width: itemSize + 4,
                height: itemSize + 4,
                margin: EdgeInsets.all(4),
                alignment: Alignment.center,
                decoration:
                    item == color ? _activeDecoration : _inactiveDecoration,
                child: Icon(
                  CupertinoIcons.circle_fill,
                  size: itemSize,
                  color: item.color,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
