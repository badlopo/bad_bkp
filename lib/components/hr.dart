import 'package:flutter/cupertino.dart';

class Hr extends StatelessWidget {
  const Hr({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: CupertinoColors.separator.resolveFrom(context),
    );
  }
}
