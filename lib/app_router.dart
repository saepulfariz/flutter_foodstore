import 'package:flutter_foodstore/page/dashboard/cart_page.dart';
import 'package:flutter_foodstore/page/dashboard/dashboard_page.dart';
import 'package:flutter_foodstore/page/dashboard/home_page.dart';
import 'package:flutter_foodstore/page/dashboard/order_page.dart';
import 'package:flutter_foodstore/page/dashboard/profile_page.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter();
  late final GoRouter router = GoRouter(
    initialLocation: '/dashboard/home',
    routes: [
      ShellRoute(
        builder: (_, __, child) => DashboardPage(child: child),
        routes: [
          GoRoute(
            path: '/dashboard/home',
            builder: (_, __) {
              return HomePage();
            },
          ),
          GoRoute(
            path: '/dashboard/order',
            builder: (context, state) {
              return OrderPage();
            },
          ),
          GoRoute(
            path: '/dashboard/cart',
            builder: (context, state) {
              return CartPage();
            },
          ),
          GoRoute(
            path: '/dashboard/profile',
            builder: (context, state) {
              return ProfilePage();
            },
          ),
        ],
      ),
    ],
  );
}
