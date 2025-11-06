import 'dart:ui';

import 'package:bookkeeping/db/database.dart';
import 'package:bookkeeping/pages/category/spec.dart';
import 'package:bookkeeping/pages/home/home.dart';
import 'package:bookkeeping/pages/misc/icon_picker.dart';
import 'package:bookkeeping/pages/setting/storage.dart';
import 'package:bookkeeping/pages/transaction/spec.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:go_router/go_router.dart';

abstract class RouteNames {
  static const home = '/home';

  /// 类别详情
  ///
  /// Parameters:
  /// - `extra`: `CategoryWithCount?`
  ///   - [CategoryWithCount]: 编辑类别
  ///   - `null`: 新建类别
  static const categorySpec = '/category/spec';

  /// 交易详情
  ///
  /// Parameters:
  /// - `extra`: `TransactionWithCategoryAndTags?`
  ///   - [TransactionWithCategoryAndTags]: 编辑交易
  ///   - `null`: 新建交易
  static const transactionSpec = '/transaction/spec';

  /// 存储管理
  static const storage = '/setting/storage';

  /// 图标选择
  ///
  /// Parameters:
  /// - `extra`: `Color?` 图标使用的颜色
  ///
  /// Returns: `BKPIcon?` 选择的图标
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
      name: RouteNames.categorySpec,
      path: RouteNames.categorySpec,
      builder: (ctx, state) =>
          CategorySpecPage(current: state.extra as CategoryWithCount?),
    ),
    GoRoute(
      name: RouteNames.transactionSpec,
      path: RouteNames.transactionSpec,
      builder: (ctx, state) => TransactionSpecPage(
          current: state.extra as TransactionWithCategoryAndTags?),
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
