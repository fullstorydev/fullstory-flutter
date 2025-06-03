import 'package:dio/dio.dart';
import 'package:fullstory_flutter/fs.dart';

/// Captures requests and responses from dio for display in Fullstory.
class FSInterceptor extends Interceptor {
  final _requestStartTimes = Expando<int>('request start epochs');

  /// Computes the size (in bytes) of request data.
  ///
  /// Defaults to use `content-length` header if set.
  final int Function(RequestOptions) computeRequestSize;

  /// Computes the size (in bytes) of response data.
  ///
  /// Defaults to use `content-length` header if set.
  final int Function(Response?) computeResponseSize;

  /// Creates a [FSInterceptor] that captures network events.
  ///
  /// The [computeRequestSize] and [computeResponseSize] functions are used to
  /// compute the size of the request and response data. By default, they
  /// assime UTF-8 encoding. If your request uses another enocoding, override
  /// these fields.
  FSInterceptor({
    this.computeRequestSize = requestContentLength,
    this.computeResponseSize = responseContentLength,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _requestStartTimes[options] = DateTime.now().millisecondsSinceEpoch;
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    FS.networkEvent(
      url: response.requestOptions.uri.toString(),
      statusCode: response.statusCode,
      method: response.requestOptions.method,
      requestSize: computeRequestSize(response.requestOptions),
      responseSize: computeResponseSize(response),
      durationMs: _durationOf(response.requestOptions),
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    FS.networkEvent(
      url: err.requestOptions.uri.toString(),
      statusCode: err.response?.statusCode,
      method: err.requestOptions.method,
      requestSize: computeRequestSize(err.requestOptions),
      responseSize: computeResponseSize(err.response),
      durationMs: _durationOf(err.requestOptions),
    );
    super.onError(err, handler);
  }

  int _durationOf(RequestOptions options) {
    final startTime = _requestStartTimes[options];
    return startTime == null
        ? 0
        : DateTime.now().millisecondsSinceEpoch - startTime;
  }
}

/// Gets the size (in bytes) of the response data, using the `content-length`
/// header, or 0 if unset.
int responseContentLength(Response? response) {
  if (response == null) return 0;

  final contentLength = response.headers.value(Headers.contentLengthHeader);
  if (contentLength != null) return _fromContentLength(contentLength);

  return 0;
}

/// Gets the size (in bytes) of the request data, using the `content-length`
/// header, or 0 if unset.
int requestContentLength(RequestOptions request) {
  final contentLength = request.headers[Headers.contentLengthHeader];
  if (contentLength != null) return _fromContentLength(contentLength);
  return 0;
}

int _fromContentLength(dynamic contentLength) {
  if (contentLength == null) return 0;
  if (contentLength is int) return contentLength;
  if (contentLength is String) return int.tryParse(contentLength) ?? 0;
  return 0;
}
