import 'package:bookkeeping/pages/customs/category/creation.dart';
import 'package:bookkeeping/pages/home/home.dart';
import 'package:go_router/go_router.dart';

abstract class RouteNames {
  static const home = 'home';
  static const categoryCreation = 'category-creation';
}

final router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      name: RouteNames.home,
      path: '/home',
      builder: (ctx, state) => HomePage(),
    ),
    GoRoute(
      name: RouteNames.categoryCreation,
      path: '/customs/category/creation',
      builder: (ctx, state) => CategoryCreationPage(),
    ),
  ],
);
