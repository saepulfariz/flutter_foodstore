import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/bloc/auth/auth_bloc.dart';
import 'package:flutter_foodstore/bloc/profile/profile_bloc.dart';
import 'package:flutter_foodstore/page/auth/login_page.dart';
import 'package:flutter_foodstore/page/auth/register_page.dart';
import 'package:flutter_foodstore/page/dashboard/cart_page.dart';
import 'package:flutter_foodstore/page/dashboard/dashboard_page.dart';
import 'package:flutter_foodstore/page/dashboard/home_page.dart';
import 'package:flutter_foodstore/page/dashboard/order_page.dart';
import 'package:flutter_foodstore/page/dashboard/profile_page.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final AuthBloc authBloc;
  AppRouter({required this.authBloc});

  late final GoRouter router = GoRouter(
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    initialLocation: '/dashboard/home',
    redirect: (context, state) {
      final authState = authBloc.state;
      final isLoggedIn = authState is Authenticated;

      final protectedRoutes = [
        '/dashboard/order',
        '/dashboard/profile',
        '/dashboard/cart',
        '/order',
        '/checkout',
      ];

      final isProtected = protectedRoutes.any(
        (route) => state.matchedLocation.startsWith(route),
      );

      if (!isLoggedIn && isProtected) return '/login';

      if (isLoggedIn && state.matchedLocation == '/login') {
        return '/login';
      }

      return null;
    },
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
          // penambahan ada pada route profile
          GoRoute(
            path: '/dashboard/profile',
            builder: (context, state) {
              context.read<ProfileBloc>().add(ProfileEvent.loadProfile());
              return ProfilePage();
            },
          ),
        ],
      ),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => RegisterPage()),
    ],
  );
}

// Helper untuk konversi Bloc stream ke Listenable
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    stream.listen((_) {
      notifyListeners();
    });
  }
}
