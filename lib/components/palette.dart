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

  final BKPColor color;
  final ValueChanged<BKPColor> onTap;

  void _onTap(BKPColor v) {
    if (v == color) return;
    onTap(v);
  }

  const BKPPalette({super.key, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    CupertinoColors.destructiveRed;
    return Wrap(
      alignment: WrapAlignment.start,
      children: [
        for (final item in bkpColors)
          GestureDetector(
            onTap: () => _onTap(item),
            child: Container(
              width: 36,
              height: 36,
              margin: EdgeInsets.all(4),
              alignment: Alignment.center,
              decoration:
                  item == color ? _activeDecoration : _inactiveDecoration,
              child: Icon(
                CupertinoIcons.circle_fill,
                size: 32,
                color: item.color,
              ),
            ),
          ),
        // SizedBox(
        //   width: 44,
        //   height: 44,
        //   child: Center(
        //     child: DecoratedBox(
        //       decoration:
        //           item == color ? _activeDecoration : _inactiveDecoration,
        //       child: Padding(
        //         padding: EdgeInsets.all(2),
        //         child: Icon(
        //           CupertinoIcons.circle_fill,
        //           size: 36,
        //           color: item.color,
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
