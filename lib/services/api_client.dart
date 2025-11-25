import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:mlco/services/sessionIdFetch.dart';

class ApiClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  String? token;

  ApiClient(this.token);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final url = request.url.toString().toLowerCase();

    if (!url.contains('login')) {
      if (token != null) {
        request.headers['X-Session-ID'] = token.toString();
      }
    }

    return _inner.send(request);
  }

  // ✅ Optional: to update the token later (e.g., after login)
  void updateToken(String? newToken) {
    token = newToken;
  }
}

class SessionInterceptor extends Interceptor {
  String? token;

  SessionInterceptor() {
    _initToken();
  }

  Future<void> _initToken() async {
    token = await UserDataUtil.getSessionId();
  }

  void updateToken(String? newToken) {
    token = newToken;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!options.path.toLowerCase().contains('login') &&
        !options.path.toLowerCase().contains('auth')) {
      if (token != null) {
        options.headers['X-Session-ID'] = token.toString();
      }
    }
    super.onRequest(options, handler);
  }
}
