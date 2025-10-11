import 'package:bookkeeping/db/database.dart';
import 'package:bookkeeping/route/route.dart';
import 'package:bookkeeping/utils/kv.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await KVUtils.prelude();
  BKPDatabase.prelude();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp.router(
      theme: CupertinoThemeData(),
      routerConfig: router,
      builder: BotToastInit(),
    );
  }
}
