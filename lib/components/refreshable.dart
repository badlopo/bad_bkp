import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';

class BKPRefreshable extends StatelessWidget {
  final FutureOr<dynamic> Function()? onRefresh;
  final FutureOr<dynamic> Function()? onLoad;
  final Widget child;

  const BKPRefreshable({
    super.key,
    this.onRefresh,
    this.onLoad,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      header: CupertinoHeader(),
      footer: CupertinoFooter(infiniteOffset: null),
      onRefresh: onRefresh,
      onLoad: onLoad,
      child: child,
    );
  }
}
