import 'package:dio/native_imp.dart';
export 'package:dio/dio.dart';

abstract class BaseHttp extends DioForNative {
  BaseHttp() {
    /// 初始化 加入app通用处理
    options.connectTimeout = 1000 * 2;
    options.receiveTimeout = 1000 * 2;
    init();
  }

  void init();
}

/// 添加常用Header
// class HeaderInterceptor extends InterceptorsWrapper {
//   @override
//   onRequest(RequestOptions options) async {
//     options.connectTimeout = 1000 * 45;
//     options.receiveTimeout = 1000 * 45;
//
//     // var appVersion = await PlatformUtils.getAppVersion();
//     var version = Map()
//       ..addAll({
//         // 'appVerison': appVersion,
//       });
//     options.headers['version'] = version;
//     // options.headers['platform'] = Platform.operatingSystem;
//     return options;
//   }
// }

/// 子类需要重写
/// 和微北洋基本数据结构相同
abstract class BaseResponseData {
  int code;
  String message;
  dynamic data;

  bool get success;

  BaseResponseData({this.code, this.message, this.data});

  @override
  String toString() {
    return 'BaseRespData{code: $code, message: $message, data: $data}';
  }
}

/// 接口的code没有返回为true的异常
class NotSuccessException implements Exception {
  String message;

  NotSuccessException.fromRespData(BaseResponseData respData) {
    message = respData.message;
  }

  @override
  String toString() {
    return 'NotExpectedException{respData: $message}';
  }
}

/// 没有登录，需要跳转登录页面
// {
//     "error_code":2,
//     "message":"not login",
//     "data":[]
// }
class UnAuthorizedException implements Exception {
  const UnAuthorizedException();

  @override
  String toString() => 'UnAuthorizedException';
}
