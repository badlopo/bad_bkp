import 'dart:ui';

import 'package:bookkeeping/db/database.dart';
import 'package:bookkeeping/pages/category/creation.dart';
import 'package:bookkeeping/pages/category/detail.dart';
import 'package:bookkeeping/pages/home/home.dart';
import 'package:bookkeeping/pages/misc/icon_picker.dart';
import 'package:bookkeeping/pages/setting/storage.dart';
import 'package:bookkeeping/pages/transaction/creation.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:go_router/go_router.dart';

abstract class RouteNames {
  static const home = '/home';

  /// 新建分类
  ///
  /// Returns: `bool` 是否有创建行为
  static const categoryCreation = '/category/creation';

  /// 分类详情
  ///
  /// Parameters:
  /// - `extra`: [CategoryWithCount]
  ///
  /// Returns: `bool` 是否有修改行为 (包括编辑、删除)
  static const categoryDetail = '/category/detail';

  /// 新建交易
  ///
  /// Returns: `bool` 是否有创建行为
  static const transactionCreation = '/transaction/creation';

  /// 存储管理
  static const storage = '/setting/storage';

  /// 图标选择
  ///
  /// Parameters:
  /// - `extra`: `Color?` 图标使用的颜色
  static const iconPicker = '/misc/icon-picker';
}

final router = GoRouter(
  initialLocation: RouteNames.home,
  observers: [BotToastNavigatorObserver()],
  routes: [
    GoRoute(
      name: RouteNames.home,
      path: RouteNames.home,
      onExit: (ctx, state) => false,
      builder: (ctx, state) => const HomePage(),
    ),
    GoRoute(
      name: RouteNames.categoryCreation,
      path: RouteNames.categoryCreation,
      builder: (ctx, state) => const CategoryCreationPage(),
    ),
    GoRoute(
      name: RouteNames.categoryDetail,
      path: RouteNames.categoryDetail,
      builder: (ctx, state) {
        final d = state.extra as CategoryWithCount;
        return CategoryDetailPage(category: d.category, count: d.count);
      },
    ),
    GoRoute(
      name: RouteNames.transactionCreation,
      path: RouteNames.transactionCreation,
      builder: (ctx, state) => const TransactionCreationPage(),
    ),
    GoRoute(
      name: RouteNames.storage,
      path: RouteNames.storage,
      builder: (ctx, state) => const StoragePage(),
    ),
    GoRoute(
      name: RouteNames.iconPicker,
      path: RouteNames.iconPicker,
      builder: (ctx, state) => IconPickerPage(color: state.extra as Color?),
    ),
  ],
);
