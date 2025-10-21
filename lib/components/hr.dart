import 'package:flutter/cupertino.dart';

class Hr extends StatelessWidget {
  const Hr({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.fromBorderSide(
          BorderSide(
            width: 0,
            color: CupertinoColors.separator.resolveFrom(context),
          ),
        ),
      ),
    );
  }
}
