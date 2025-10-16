import 'package:bookkeeping/route/route.dart';
import 'package:bookkeeping/services/theme.dart';
import 'package:bookkeeping/utils/storage.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: CupertinoColors.transparent,
    systemNavigationBarColor: CupertinoColors.transparent,
  ));

  await StorageUtils.initKV();
  bkpTheme.restore();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: bkpTheme,
      builder: (context, child) => CupertinoApp.router(
        title: 'BKP',
        theme: CupertinoThemeData(
          brightness: bkpTheme.darkMode ? Brightness.dark : Brightness.light,
          primaryColor: bkpTheme.themeColor.color,
        ),
        routerConfig: router,
        builder: BotToastInit(),
      ),
    );
  }
}
