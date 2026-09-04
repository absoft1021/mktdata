import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mktdata/auth/login_page.dart';
import 'package:get/get.dart' hide Response, FormData;

class ApiClient extends GetxService {
  late Dio _dio;
  final box = GetStorage();
  bool _isHandlingUnauthorized = false;

  static ApiClient get to => Get.find<ApiClient>();

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(BaseOptions(
      baseUrl: 'https://mktdata.com.ng/user/api/',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = box.read('token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = token;
        }
        options.headers['Content-Type'] = 'application/json';
        options.headers['Accept'] = 'application/json';
        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _handleUnauthorized();
        }
        handler.next(error);
      },
    ));
  }

  Future<void> _handleUnauthorized() async {
    if (_isHandlingUnauthorized) return;
    _isHandlingUnauthorized = true;

    try {
      await box.erase();
      Get.offAll(() => LoginPage(), arguments: {'sessionExpired': true});
    } finally {
      _isHandlingUnauthorized = false;
    }
  }

  Dio get dio => _dio;

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path) {
    return _dio.delete(path);
  }

  Future<Response> upload(String path, {required FormData data}) {
    return _dio.post(path, data: data);
  }
}
