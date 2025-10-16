import 'dart:ui';

import 'package:bookkeeping/db/database.dart';
import 'package:bookkeeping/pages/category/creation.dart';
import 'package:bookkeeping/pages/category/detail.dart';
import 'package:bookkeeping/pages/home/home.dart';
import 'package:bookkeeping/pages/misc/icon_picker.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:go_router/go_router.dart';

abstract class RouteNames {
  static const home = 'home';

  /// 新建分类
  ///
  /// Returns: `bool` 是否有创建行为
  static const categoryCreation = 'category-creation';

  /// 分类详情
  ///
  /// Parameters:
  /// - `extra`: [Category]
  ///
  /// Returns: `bool` 是否有修改行为 (包括编辑、删除)
  static const categoryDetail = 'category-detail';

  /// 图标选择
  ///
  /// Parameters:
  /// - `extra`: `Color?` 图标使用的颜色
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
      path: '/category/creation',
      builder: (ctx, state) => CategoryCreationPage(),
    ),
    GoRoute(
      name: RouteNames.categoryDetail,
      path: '/category/detail',
      builder: (ctx, state) =>
          CategoryDetailPage(category: state.extra as Category),
    ),
    GoRoute(
      name: RouteNames.iconPicker,
      path: '/misc/picker/icon',
      builder: (ctx, state) => IconPickerPage(color: state.extra as Color?),
    ),
  ],
);
