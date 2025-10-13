import 'dart:async';

import 'package:bookkeeping/components/indicator.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';

abstract class ToastUtils {
  static void toast(Icon icon, String text) {
    BotToast.showCustomText(
      onlyOne: true,
      toastBuilder: (_) => LayoutBuilder(builder: (_, constraint) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: constraint.maxWidth - 32),
          child: Text.rich(
            TextSpan(
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: icon,
                  ),
                ),
                TextSpan(text: text),
              ],
            ),
          ),
        );
      }),
    );
  }

  static void success(String text) => toast(
      Icon(CupertinoIcons.check_mark_circled,
          color: CupertinoColors.systemGreen),
      text);

  static void info(String text) => toast(
      Icon(CupertinoIcons.info_circle, color: CupertinoColors.systemBlue),
      text);

  static void error(String text) => toast(
      Icon(CupertinoIcons.xmark_circle, color: CupertinoColors.systemRed),
      text);

  static CancelFunc loading() {
    return BotToast.showCustomLoading(
      crossPage: false,
      clickClose: false,
      backButtonBehavior: BackButtonBehavior.ignore,
      toastBuilder: (_) => LoadingIndicator(),
    );
  }

  static Future<void> loadingWithTxn(FutureOr<void> Function() txn) async {
    final stop = BotToast.showCustomLoading(
      crossPage: false,
      clickClose: false,
      backButtonBehavior: BackButtonBehavior.ignore,
      toastBuilder: (_) => LoadingIndicator(),
    );

    try {
      await txn();
    } catch (_) {
    } finally {
      stop();
    }
  }
}
