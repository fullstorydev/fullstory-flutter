import 'dart:ffi' hide Size;
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:flutter/widgets.dart';
import 'package:fullstory_flutter/src/blocking/block.dart';

import 'kernel.dart';
import 'native.dart';
import 'shared_flutter_bindings_generated.dart';

export 'shared_flutter_bindings_generated.dart' show ByteArray;

final encoderBindings = EncoderBindings(
  io.Platform.isAndroid
      ? DynamicLibrary.open("libshared_flutter.so")
      : DynamicLibrary.process(),
);

class ScanEncoder implements Finalizable {
  final EncoderBindings _bindings;
  final NativeInterface _native;
  Pointer<InProgressDataHandle>? _dataHandle;

  Pointer<InProgressDataHandle> get _checkedHandle =>
      _dataHandle ??
      (throw StateError(
        'Session not started. Ensure start() is called before any other '
        'operations.',
      ));

  final void Function(SerializedData, Pointer<ByteArray>)
  _attachByteArrayFinalizer;
  final void Function(ScanEncoder, Pointer<InProgressDataHandle>)
  _attachHandleFinalizer;
  final void Function(ScanEncoder) _detachHandleFinalizer;

  factory ScanEncoder(NativeInterface native) {
    final byteArrayFinalizer = NativeFinalizer(
      encoderBindings.addresses.free_byte_array.cast(),
    );
    final handleFinalizer = NativeFinalizer(
      encoderBindings.addresses.free_in_progress_data.cast(),
    );

    void attachByteArrayFinalizer(
      SerializedData data,
      Pointer<ByteArray> byteArray,
    ) {
      byteArrayFinalizer.attach(data, byteArray.cast(), detach: data);
    }

    void attachHandleFinalizer(
      ScanEncoder encoder,
      Pointer<InProgressDataHandle> handle,
    ) {
      handleFinalizer.attach(encoder, handle.cast(), detach: encoder);
    }

    void detachHandleFinalizer(ScanEncoder encoder) {
      handleFinalizer.detach(encoder);
    }

    return ScanEncoder.forTest(
      encoderBindings,
      attachByteArrayFinalizer,
      attachHandleFinalizer,
      detachHandleFinalizer,
      native,
    );
  }
  @visibleForTesting
  ScanEncoder.forTest(
    this._bindings,
    this._attachByteArrayFinalizer,
    this._attachHandleFinalizer,
    this._detachHandleFinalizer, [
    NativeInterface? native,
  ]) : _native = native ?? Kernel.singleton().native;

  void start([HostPlatform? platform]) {
    if (_dataHandle != null) {
      throw StateError(
        'Scan already started, call finish() before starting a new session.',
      );
    }

    _dataHandle = _bindings.start_capture(
      platform?._ffiId ?? HostPlatform.detected._ffiId,
    );
    _attachHandleFinalizer(this, _dataHandle!.cast());
  }

  bool get inProgress => _dataHandle != null;

  int viewMetadata({
    int alpha = 255,
    int flags1 = 0,
    String? viewClass,
    List<int>? customAttrs,
    BlockType blockType = BlockType.unmatched,
    required int x1,
    required int y1,
    required int x2,
    required int y2,
  }) {
    final index = viewClass != null ? _native.recordString(viewClass) : -1;

    Pointer<Int8> customAttrsPtr;
    int customAttrsLen;
    if (customAttrs == null || customAttrs.isEmpty) {
      customAttrsPtr = nullptr;
      customAttrsLen = 0;
    } else {
      customAttrsLen = customAttrs.length;
      customAttrsPtr = calloc<Int8>(customAttrsLen);
      for (int i = 0; i < customAttrsLen; i++) {
        customAttrsPtr[i] = customAttrs[i];
      }
    }

    try {
      return _bindings.view_metadata(
        _checkedHandle,
        alpha,
        flags1,
        index,
        customAttrsPtr,
        customAttrsLen,
        blockType.index,
        x1,
        y1,
        x2,
        y2,
      );
    } finally {
      if (customAttrsPtr != nullptr) {
        calloc.free(customAttrsPtr);
      }
    }
  }

  int view({
    required int id,
    required bool viewCached,
    required bool childrenCached,
    int? canvas,
    int? metadata,
    List<int> children = const [],
    int? previousId,
  }) {
    if (id < 0) {
      throw ArgumentError('`id` must be a non-negative integer.');
    }

    Pointer<UnsignedInt> childrenPtr;
    int childrenLen;
    if (children.isEmpty) {
      childrenPtr = nullptr;
      childrenLen = 0;
    } else {
      childrenLen = children.length;
      childrenPtr = calloc<UnsignedInt>(childrenLen);
      for (int i = 0; i < childrenLen; i++) {
        childrenPtr[i] = children[i];
      }
    }

    try {
      return _bindings.view(
        _checkedHandle,
        id,
        viewCached,
        childrenCached,
        canvas ?? 0,
        metadata ?? 0,
        childrenPtr,
        childrenLen,
        previousId ?? 0,
      );
    } finally {
      if (childrenPtr != nullptr) {
        calloc.free(childrenPtr);
      }
    }
  }

  SerializedData? finish(int id) {
    final handle = _checkedHandle;
    final resultPtr = _bindings.finish_capture(handle, id);
    final result = resultPtr.ref;
    if (result.ptr == nullptr) {
      _bindings.free_byte_array(resultPtr);
      return null;
    }
    final data = SerializedData(resultPtr, id);
    _attachByteArrayFinalizer(data, resultPtr.cast());

    _bindings.free_in_progress_data(handle);
    _detachHandleFinalizer(this);
    _dataHandle = null;
    return data;
  }
}

class SerializedData implements Finalizable {
  final Pointer<ByteArray> byteArray;
  final int id;

  SerializedData(this.byteArray, this.id);
}

extension Decoder on Pointer<ByteArray> {
  int get viewId => encoderBindings.view_id(this);
  Uint8List toUint8List() => ref.ptr.asTypedList(ref.len);
}

enum HostPlatform {
  unsupported(0),
  android(1),
  ios(2);

  final int _ffiId;

  const HostPlatform(this._ffiId);
  static HostPlatform get detected {
    if (io.Platform.isAndroid) {
      return HostPlatform.android;
    } else if (io.Platform.isIOS) {
      return HostPlatform.ios;
    } else {
      return HostPlatform.unsupported;
    }
  }
}
