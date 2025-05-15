# Fullstory dio support

This package adds support for Fullstory capture of network events emitted by
[dio](https://pub.dev/packages/dio). 

It requires integration with [fullstory_flutter](https://pub.dev/packages/fullstory_flutter)
to get started. Once you've 
[set up Fullstory for Flutter](https://help.fullstory.com/hc/en-us/articles/27461129353239-Getting-Started-with-Fullstory-for-Flutter-Mobile-Apps)
you're ready to start here.

⚠️ This is a preview release, some breaking changes are possible before the 1.0.0 release.

## Quick Links

- [Getting Started guide](https://help.fullstory.com/hc/en-us/articles/27461129353239)
- [Usage examples](https://github.com/fullstorydev/fullstory-flutter/tree/main/example/lib)
- [Fullstory API](https://developer.fullstory.com/mobile/flutter/)
- [Email us](mailto:mobile-support@fullstory.com)

## Setup

Add the `FullstoryInterceptor` to your dio interceptor list:

```
final dio = Dio()..interceptors.add(FullstoryInterceptor());
```

If you use an encoding other than UTF-8 for your data, provide a function to
compute request/response sizes for accurate measurment:

```
FullstoryInterceptor(
    computeRequestSize: myRequestSizer,
    computeResponseSize: myResponseSizer,
);

int myRequestSizer(_) => 42;
int myResponseSizer(Response? response) => _myComplexFunction(response?.data);
```