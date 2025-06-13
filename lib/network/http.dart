import 'dart:async';

import 'package:fullstory_flutter/fs.dart';
import 'package:http_interceptor/http_interceptor.dart';

/// Captures requests and responses from package:http for display in Fullstory.
///
/// Either include this interceptor in your own [InterceptedClient] or call
/// [fsHttpClient] to create a new [Client] with this interceptor preconfigured.
class FSInterceptor extends InterceptorContract {
  // Map of request URLs to epoch start times in milliseconds.
  final _requestStartTimes = Expando<int>('request start epochs');

  @override
  FutureOr<BaseRequest> interceptRequest({required BaseRequest request}) {
    _requestStartTimes[request] = DateTime.now().millisecondsSinceEpoch;
    return request;
  }

  @override
  FutureOr<BaseResponse> interceptResponse({required BaseResponse response}) {
    FS.networkEvent(
      url: response.request?.url.toString() ?? '',
      statusCode: response.statusCode,
      method: response.request?.method ?? '',
      requestSize: response.request?.contentLength,
      responseSize: response.contentLength,
      durationMs: _durationOf(response.request),
    );

    return response;
  }

  int _durationOf(BaseRequest? request) {
    if (request == null) return 0;

    final startTime = _requestStartTimes[request];
    return startTime == null
        ? 0
        : DateTime.now().millisecondsSinceEpoch - startTime;
  }
}

/// Creates an HTTP [Client] which intercepts and captures network events for
/// Fullstory.
///
/// Whether Fullstory captures events before or after other interceptors is
/// specified by [captureFirst]. This may be important if you have interceptors
/// which modify the request or response. In this case, you can configure
/// whether these modifications are captured by Fullstory or not.
Client fsHttpClient({
  List<InterceptorContract> interceptors = const [],
  Duration? requestTimeout,
  TimeoutCallback? onRequestTimeout,
  RetryPolicy? retryPolicy,
  Client? client,
  bool captureFirst = true,
}) =>
    InterceptedClient.build(
      interceptors: [
        if (captureFirst) FSInterceptor(),
        ...interceptors,
        if (!captureFirst) FSInterceptor(),
      ],
      requestTimeout: requestTimeout,
      onRequestTimeout: onRequestTimeout,
      retryPolicy: retryPolicy,
      client: client,
    );
