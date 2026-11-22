import 'package:dio/dio.dart';
import 'package:flutter_foodstore/bloc/auth/auth_bloc.dart';
import 'package:flutter_foodstore/resource/local/auth_local_resource.dart';

class AuthInterceptor extends Interceptor {
  final AuthBloc authBloc;

  AuthInterceptor(this.authBloc);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await AuthLocalResource.getToken();
    options.headers['Accept'] = 'application/json';
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      authBloc.add(const AuthEvent.logoutRequested());
      await AuthLocalResource.deleteToken();
    }
    handler.next(err);
  }
}
