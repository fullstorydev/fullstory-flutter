import 'dart:ffi' hide Size;
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:fullstory_flutter/src/numbers.dart';

import 'logging.dart';
import 'shared_flutter_bindings_generated.dart';
import 'encoder.dart';







class DrawingEncoder implements Finalizable {
  final EncoderBindings _bindings;

  Pointer<DrawingHandle>? _drawingHandle;

  Pointer<DrawingHandle> get _checkedHandle =>
      _drawingHandle ??
      (throw StateError(
        'DrawingEncoder not started. Ensure start() is called before any other '
        'operations.',
      ));

  void Function(SerializedData) _attachByteArrayFinalizer;
  void Function(DrawingEncoder, Pointer<DrawingHandle>) _attachHandleFinalizer;
  void Function(DrawingEncoder) _detachHandleFinalizer;

  static Uint8List? _canvasDefinition;

  static Uint8List get canvasDefinition {
    if (_canvasDefinition == null) {
      final bytes = encoderBindings.canvas_definition();
      _canvasDefinition = Uint8List.fromList(bytes.toUint8List());
      encoderBindings.free_byte_array(bytes);
    }
    return _canvasDefinition!;
  }






  SerializedData? get canvas {
    final arrayPtr = _bindings.get_drawing(_checkedHandle);
    final array = arrayPtr.ref;
    if (array.ptr == nullptr) return null;

    final data = SerializedData(arrayPtr, 0);
    _attachByteArrayFinalizer(data);
    return data;
  }

  factory DrawingEncoder([EncoderBindings? bindings]) {
    final safeBindings = bindings ?? encoderBindings;

    final handleFinalizer = NativeFinalizer(
      safeBindings.addresses.free_drawing.cast(),
    );
    final byteArrayFinalizer = NativeFinalizer(
      safeBindings.addresses.free_byte_array.cast(),
    );

    void attachByteArray(SerializedData data) {
      byteArrayFinalizer.attach(data, data.byteArray.cast(), detach: data);
    }

    void attachHandle(DrawingEncoder encoder, Pointer<DrawingHandle> handle) {
      handleFinalizer.attach(encoder, handle.cast(), detach: encoder);
    }

    void detachHandle(DrawingEncoder encoder) {
      handleFinalizer.detach(encoder);
    }

    return DrawingEncoder.forTest(
      safeBindings,
      attachByteArray,
      attachHandle,
      detachHandle,
    );
  }

  @visibleForTesting
  DrawingEncoder.forTest(
    this._bindings,
    this._attachByteArrayFinalizer,
    this._attachHandleFinalizer,
    this._detachHandleFinalizer,
  );



  void start() {
    if (_drawingHandle != null) {
      throw StateError('DrawingEncoder already started');
    }
    _drawingHandle = _bindings.start_drawing();
    _attachHandleFinalizer(this, _drawingHandle!);
  }

  void reset() {
    if (_drawingHandle == null) {
      Logger.log(
        LogLevel.debug,
        "reset called on unstarted DrawingEncoder, this is a no-op",
      );
      return;
    }

    _bindings.free_drawing(_checkedHandle);
    _detachHandleFinalizer(this);
    _drawingHandle = null;
  }

  void addViewId(int id) {
    _bindings.add_view_id(_checkedHandle, id);
  }

  void clipRect(Rect rect, ClipOp op) {
    _bindings.clip_rect(
      _checkedHandle,
      rect.left.roundSafe(),
      rect.top.roundSafe(),
      (rect.right - rect.left).roundSafe(),
      (rect.bottom - rect.top).roundSafe(),
      op.fsValue,
    );
  }

  void drawCircle(Offset center, double radius, Paint paint) {
    _bindings.draw_circle(
      _checkedHandle,
      center.dx.roundSafe(),
      center.dy.roundSafe(),
      radius,
      paint.color.aU8,
      paint.color.rU8,
      paint.color.gU8,
      paint.color.bU8,
      paint.style.fsValue,
    );
  }

  void drawDRRect(RRect outer, RRect inner, Paint paint) {








  }

  void drawLine(Offset p1, Offset p2, Paint paint) {
    _bindings.draw_line(
      _checkedHandle,
      p1.dx.roundSafe(),
      p1.dy.roundSafe(),
      (p2.dx - p1.dx).roundSafe(),
      (p2.dy - p1.dy).roundSafe(),
      paint.color.aU8,
      paint.color.rU8,
      paint.color.gU8,
      paint.color.bU8,
      paint.style.fsValue,
    );
  }

  void drawParagraph({
    required int stringId,
    required Offset offset,
    required Color color,
    required double textSize,
    required Size bounds,
    required bool masked,
  }) {
    _bindings.draw_text(
      _checkedHandle,
      stringId,
      offset.dx.roundSafe(),
      offset.dy.roundSafe(),
      color.aU8,
      color.rU8,
      color.gU8,
      color.bU8,
      textSize,
 0,
 0,
      bounds.width.roundSafe(),
      bounds.height.roundSafe(),
      masked,
    );
  }
  void drawRect(Rect rect, Paint paint) {
    _bindings.draw_rect(
      _checkedHandle,
      rect.left.roundSafe(),
      rect.top.roundSafe(),
      (rect.right - rect.left).roundSafe(),
      (rect.bottom - rect.top).roundSafe(),
      paint.color.aU8,
      paint.color.rU8,
      paint.color.gU8,
      paint.color.bU8,
      paint.style.fsValue,
    );
  }

  void drawRRect(RRect rect, Paint paint) {
    _bindings.draw_round_rect(
      _checkedHandle,
      rect.tlRadiusX.roundSafe(),
      rect.tlRadiusY.roundSafe(),
      rect.left.roundSafe(),
      rect.top.roundSafe(),
      (rect.right - rect.left).roundSafe(),
      (rect.bottom - rect.top).roundSafe(),
      paint.color.aU8,
      paint.color.rU8,
      paint.color.gU8,
      paint.color.bU8,
      paint.style.fsValue,
    );
  }

  void restore() {
    _bindings.restore(_checkedHandle);
  }

  void rotate(double radians) {
    _bindings.rotate(_checkedHandle, radians / pi * 180);
  }

  void save() {
    _bindings.save(_checkedHandle);
  }

  void scale({required double sx, double? sy}) {
    _bindings.scale(_checkedHandle, sx, sy ?? sx);
  }

  void translate({required double dx, required double dy}) {
    _bindings.translate(_checkedHandle, dx, dy);
  }
}
extension _ColorExt on Color {
  int get aU8 => _colorU8(a);
  int get rU8 => _colorU8(r);
  int get gU8 => _colorU8(g);
  int get bU8 => _colorU8(b);
}

extension _ClipOpExt on ClipOp {


  int get fsValue => switch (this) {
    ClipOp.difference => 0,
    ClipOp.intersect => 1,
  };
}

extension _StyleExt on PaintingStyle {
  int get fsValue => this == PaintingStyle.fill ? 0 : 1;
}

int _colorU8(double color) => (color * 255.0).round() & 0xff;

class DrawingBundler {
  final EncoderBindings _bindings;

  Pointer<DrawingBundlerHandle>? _handle;

  Pointer<DrawingBundlerHandle> get _checkedHandle =>
      _handle ??
      (throw StateError(
        'DrawingBundler not started. Ensure startBundle() is called before any '
        'other operations.',
      ));

  DrawingBundler(this._bindings);

  void startBundle() {
    if (_handle != null) {
      throw Exception('Bundle already started');
    }

    _handle = _bindings.create_drawing_bundler();
  }





  int addDrawing(DrawingEncoder encoder, int viewId) {
    return _bindings.add_drawing_to_bundle(
      _checkedHandle,
      encoder._checkedHandle,
      viewId,
    );
  }

  Uint8List? fetchBundle() {
    final resultPtr = _bindings.read_bundle(_checkedHandle);
    final result = resultPtr.ref;

    if (result.ptr == nullptr) {
      _bindings.free_byte_array(resultPtr);
      return null;
    }

    return result.ptr.asTypedList(
      result.len,
      finalizer: _bindings.addresses.free_byte_array.cast(),
      token: resultPtr.cast(),
    );
  }
  Uint8List? finishBundle() {
    final resultPtr = _bindings.finish_bundle(_checkedHandle);
    final result = resultPtr.ref;
    _handle = null;

    if (result.ptr == nullptr) {
      _bindings.free_byte_array(resultPtr);
      return null;
    }

    return result.ptr.asTypedList(
      result.len,
      finalizer: _bindings.addresses.free_byte_array.cast(),
      token: resultPtr.cast(),
    );
  }
  bool get inProgress => _handle != null;
}
