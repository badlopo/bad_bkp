import 'package:bookkeeping/route/route.dart';
import 'package:bookkeeping/services/theme.dart';
import 'package:bookkeeping/utils/kv.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await KVUtils.prelude();
  bkpTheme.restore();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: bkpTheme,
      builder: (context, child) => CupertinoApp.router(
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
