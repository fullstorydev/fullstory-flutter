import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:fullstory_flutter/src/encoder.dart';
import 'package:fullstory_flutter/src/shared_flutter_bindings_generated.dart';

class Masker {
  final EncoderBindings _encoderBindings;

  Masker([EncoderBindings? bindings])
    : _encoderBindings = bindings ?? encoderBindings;

  String maskText(String line, int? renderObjectHash) {
    if (line.isEmpty) {
      return line;
    }

    final linePtr = line.toNativeUtf8();
    final bufferSize = line.length + 1;
    final resultBuffer = malloc<Char>(bufferSize);

    try {
      final lineLength = _encoderBindings.randomize_string(
        linePtr.cast<Char>(),
        renderObjectHash ?? 0,
        resultBuffer,
        bufferSize,
      );
      return lineLength == 0 ? '' : resultBuffer.cast<Utf8>().toDartString();
    } finally {
      malloc.free(linePtr);
      malloc.free(resultBuffer);
    }
  }
}
