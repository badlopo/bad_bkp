import 'package:bookkeeping/pages/home/home.dart';
import 'package:go_router/go_router.dart';

abstract class RouteNames {
  static const home = 'home';
}

final router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      name: RouteNames.home,
      path: '/home',
      builder: (ctx, state) => HomePage(),
    ),
  ],
);
