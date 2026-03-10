import 'dart:async';

import 'package:fullstory_flutter/src/platform/fullstory_flutter_platform_interface.dart';

import 'drawing.dart';
import 'string_table.dart';

export 'package:fullstory_flutter/src/platform/fullstory_flutter_platform_interface.dart'
    show ScanMode, HostCallbacks, FlutterScanResult;

class NativeInterface {
  static NativeInterface? _registeredSingleton;

  final _channel = FullstoryFlutterPlatform.instance;
  final stringTable = StringTable();
  Future<void> register() async {
    if (_registeredSingleton != null) {
      throw Exception('NativeInterface already registered');
    }
    _registeredSingleton = this;
    await _channel.register(DrawingEncoder.canvasDefinition);
  }

  int recordString(String string) => stringTable.idOf(string);
  Future<void> sendInputEvent({
    required InputType type,
    required int viewId,
    required bool keep,
    String? text,
  }) => _sendEvent({
    keyEventType: _FlutterEventType.input.channelValue,
    'inputType': type.channelValue,
    'viewId': viewId,
    'keepEventType': keep ? type.keepType : 0,
    if (text != null) 'viewText': text,
  });


  Future<void> _sendEvent(Map<String, dynamic> args) async {
    assert(args.containsKey(keyEventType));
    FullstoryFlutterPlatform.instance.captureEvent(args);
  }
}

const keyEventType = 'eventType';




enum InputType {
  tap(channelValue: 2, keepType: 1);

  final int channelValue;
  final int keepType;

  const InputType({required this.channelValue, required this.keepType});
}




enum _FlutterEventType {
  input(3);

  final int channelValue;

  const _FlutterEventType(this.channelValue);
}
