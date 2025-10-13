import 'dart:ui';

import 'package:bookkeeping/pages/customs/category/creation.dart';
import 'package:bookkeeping/pages/home/home.dart';
import 'package:bookkeeping/pages/misc/icon_picker.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:go_router/go_router.dart';

abstract class RouteNames {
  static const home = 'home';

  static const categoryCreation = 'category-creation';

  /// `extra`: `Color?` 图标使用的颜色
  static const iconPicker = 'icon-picker';
}

final router = GoRouter(
  initialLocation: '/home',
  observers: [BotToastNavigatorObserver()],
  routes: [
    GoRoute(
      name: RouteNames.home,
      path: '/home',
      onExit: (context, state) => false,
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      name: RouteNames.categoryCreation,
      path: '/customs/category/creation',
      builder: (ctx, state) => CategoryCreationPage(),
    ),
    GoRoute(
      name: RouteNames.iconPicker,
      path: '/misc/picker/icon',
      builder: (ctx, state) => IconPickerPage(color: state.extra as Color?),
    ),
  ],
);
