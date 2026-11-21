import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodstore/app_router.dart';
import 'package:dio/dio.dart';
import 'package:flutter_foodstore/bloc/auth/auth_bloc.dart';
import 'package:flutter_foodstore/core/constants/app_config.dart';
import 'package:flutter_foodstore/core/utils/auth_interceptor.dart';
import 'package:flutter_foodstore/resource/remote/auth_remote_resource.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final dio = Dio(BaseOptions(baseUrl: AppConfig.API_PATH));

  // penambahan kode di sini
  final authRemoteResource = AuthRemoteResource(dio);
  final authBloc = AuthBloc(authRemoteResource)
    ..add(AuthEvent.checkLoginStatus());

  // memasukkan interceptor
  dio.interceptors.add(AuthInterceptor(authBloc));

  final appRouter = AppRouter(authBloc: authBloc);

  runApp(MyApp(appRouter: appRouter, authBloc: authBloc));
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;
  final AuthBloc authBloc;
  const MyApp({super.key, required this.appRouter, required this.authBloc});

  @override
  Widget build(BuildContext context) {
    //bungkus dengan MultiBlocProvider
    return MultiBlocProvider(
      providers: [BlocProvider.value(value: authBloc)],
      child: MaterialApp.router(
        title: 'Food Store',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.grey.shade100,
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.orange),
          useMaterial3: true,
        ),
        routerConfig: appRouter.router,
      ),
    );
  }
}
