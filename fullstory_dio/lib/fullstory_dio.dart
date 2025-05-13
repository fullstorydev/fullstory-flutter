import 'package:dio/dio.dart';
import 'package:fullstory_flutter/fs.dart';

/// Captures requests and responses from dio for display in Fullstory.
class FullstoryInterceptor extends Interceptor {
  final _requestStartTimes = <Uri, int>{};

  /// Computes the size (in bytes) of the request or response data.
  /// 
  /// Defaults to always return zero. 
  final int Function(dynamic) computeSize;

  FullstoryInterceptor({this.computeSize = alwaysZero});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _requestStartTimes[options.uri] = DateTime.now().millisecondsSinceEpoch;
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    FS.networkEvent(
      url: response.requestOptions.uri.toString(),
      statusCode: response.statusCode,
      method: response.requestOptions.method,
      requestSize: computeSize(response.requestOptions.data),
      responseSize: computeSize(response.data),
      durationMs: _durationOf(response.requestOptions.uri),
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    FS.networkEvent(
      url: err.requestOptions.uri.toString(),
      statusCode: err.response?.statusCode,
      method: err.requestOptions.method,
      requestSize: computeSize(err.requestOptions.data),
      responseSize: computeSize(err.response?.data),
      durationMs: _durationOf(err.requestOptions.uri),
    );
    super.onError(err, handler);
  }

  int _durationOf(Uri uri) {
    final startTime = _requestStartTimes.remove(uri);
    return startTime == null
        ? 0
        : DateTime.now().millisecondsSinceEpoch - startTime;
  }
}

/// A default value for [FullstoryInterceptor.computeSize] that always returns 
/// zero.
int alwaysZero(dynamic _) => 0;
