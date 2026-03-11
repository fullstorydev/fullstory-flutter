import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart' hide Size;
import 'package:flutter/rendering.dart' hide Size;
import 'package:fullstory_flutter/src/blocking/block.dart';
import 'package:fullstory_flutter/src/blocking/mask.dart';

import 'drawing.dart';
import 'encoder.dart';
import 'kernel.dart';
import 'logging.dart';

class CanvasEncoder {
  final _drawEnc = DrawingEncoder();
  final _childOffsets = Expando<Offset>();
  RenderObject? _currentRenderObject;
  Element? _currentElement;
  Offset origin = Offset.zero;

  static Uint8List get canvasDefinition {
    return DrawingEncoder.canvasDefinition;
  }

  Uint8List get canvas {
    return _drawEnc.canvas?.byteArray.toUint8List() ?? Uint8List(0);
  }

  DrawingEncoder get drawEncoder => _drawEnc;

  void resetCanvas() {
    _drawEnc.reset();
  }

  void encodeElements(
    Element el,
    Map<RenderObject, int> sset,
    BlockType blockType,
  ) {
    final renderObject = el.renderObject;
    if (renderObject == null) return;
    _drawEnc.start();
    _ScanPaintingContext sctx = _ScanPaintingContext(
      this,
      blockType,
      renderObject.paintBounds,
    );

    if (sset.containsKey(renderObject)) {
      return;
    }

    final priorElement = _currentElement;
    _currentElement = el;
    sctx.paintOneChild(renderObject, sset);
    _currentElement = priorElement;
  }

  void encodeRootScaling(double ratio, int childId) {
    _drawEnc.start();
    _drawEnc.scale(sx: ratio, sy: ratio);
    _drawEnc.addViewId(childId);
  }
}

class _ScanCanvas implements Canvas {
  final CanvasEncoder _canvasEnc;
  final BlockType _blockType;
  final _masker = Masker();

  _ScanCanvas(this._canvasEnc, this._blockType);

  DrawingEncoder get _drawEnc => _canvasEnc._drawEnc;

  Rect _absoluteRect(Rect rect) => rect.shift(_canvasEnc.origin);

  RRect _absoluteRRect(RRect rrect) => rrect.shift(_canvasEnc.origin);

  Offset _absolute(Offset offset) => offset + _canvasEnc.origin;

  @override
  void clipPath(Path path, {bool doAntiAlias = true}) {
    Logger.log(LogLevel.verbose, "OP: UNSUPPORTED: clipPath");
  }

  @override
  void clipRect(
    Rect rect, {
    ClipOp clipOp = ClipOp.intersect,
    bool doAntiAlias = true,
  }) {
    Logger.log(LogLevel.verbose, "OP: clipRect: $rect");
    _drawEnc.clipRect(_absoluteRect(rect), clipOp);
  }

  @override
  void clipRRect(RRect rrect, {bool doAntiAlias = true}) {
    Logger.log(LogLevel.verbose, "OP: UNSUPPORTED: clipRRect");
  }

  @override
  void drawArc(
    Rect rect,
    double startAngle,
    double sweepAngle,
    bool useCenter,
    Paint paint,
  ) {
    Logger.log(LogLevel.verbose, "OP: UNSUPPORTED: drawArc");
  }

  @override
  void drawAtlas(
    ui.Image atlas,
    List<RSTransform> transforms,
    List<Rect> rects,
    List<Color>? colors,
    BlendMode? blendMode,
    Rect? cullRect,
    Paint paint,
  ) {
    Logger.log(LogLevel.verbose, "OP: UNSUPPORTED: drawAtlas");
  }

  @override
  void drawCircle(Offset center, double radius, Paint paint) {
    Logger.log(LogLevel.verbose, "OP: clipCircle");
    _drawEnc.drawCircle(_absolute(center), radius, paint);
  }

  @override
  void drawColor(Color c, BlendMode blendMode) {
    Logger.log(LogLevel.verbose, "OP: UNSUPPORTED: drawColor");
  }

  @override
  void drawDRRect(RRect outer, RRect inner, Paint paint) {
    Logger.log(LogLevel.verbose, "OP: UNSUPPORTED: drawDRRect");
    _drawEnc.drawDRRect(_absoluteRRect(outer), _absoluteRRect(inner), paint);
  }

  static const _standInColor = Colors.grey;
  Paint _standInPaint(Paint paint) => Paint.from(paint)..color = _standInColor;
  static final _defaultPaint = Paint()
    ..color = _standInColor
    ..style = PaintingStyle.fill;

  @override
  void drawImage(ui.Image image, Offset p, Paint paint) {
    Logger.log(LogLevel.debug, "OP: UNSUPPORTED: drawImage, drawing rect");
    final width = image.width.toDouble();
    final height = image.height.toDouble();
    final absolute = _absolute(p);

    _drawEnc.drawRect(
      Rect.fromLTWH(absolute.dx, absolute.dy, width, height),
      _standInPaint(paint),
    );
  }

  @override
  void drawImageNine(ui.Image image, Rect center, Rect dst, Paint paint) {
    Logger.log(LogLevel.debug, "OP: UNSUPPORTED: drawImageNine, drawing rect");
    _drawEnc.drawRect(_absoluteRect(dst), _standInPaint(paint));
  }

  @override
  void drawImageRect(ui.Image image, Rect src, Rect dst, Paint paint) {
    Logger.log(LogLevel.debug, "OP: UNSUPPORTED: drawImageRect, drawing rect");
    _drawEnc.drawRect(_absoluteRect(dst), _standInPaint(paint));
  }

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {
    Logger.log(LogLevel.verbose, "OP: drawLine");
    _drawEnc.drawLine(_absolute(p1), _absolute(p2), paint);
  }

  @override
  void drawOval(Rect rect, Paint paint) {
    Logger.log(LogLevel.verbose, "OP: UNSUPPORTED: drawOval");
  }

  @override
  void drawPaint(Paint paint) {
    Logger.log(LogLevel.verbose, "OP: UNSUPPORTED: drawPaint");
  }

  InlineSpan? get _currentSpan {
    final object = _canvasEnc._currentRenderObject;
    final widget = _canvasEnc._currentElement?.widget;
    switch (object) {
      case RenderParagraph():
        return object.text;
      case RenderEditable():
        return object.obscureText
            ? TextSpan(text: '•' * object.plainText.length)
            : object.text;
    }
    if (widget is Banner) {
      return TextSpan(text: widget.message, style: widget.textStyle);
    }

    Logger.log(
      LogLevel.warning,
      'OP: drawParagraph from $object represented by $widget text unavailable',
    );
    return null;
  }

  @override
  void drawParagraph(Paragraph paragraph, Offset offset) {
    final message = _currentSpan?.toPlainText() ?? 'Missing string!';

    if (_currentSpan?.toPlainText() != null) {
      Logger.log(
        LogLevel.verbose,
        "OP: drawParagraph with length: ${message.length}",
      );
    }

    final style = _currentSpan?.style;

    int firstIndex = 0;
    for (final metric in paragraph.computeLineMetrics()) {
      final range = paragraph.getLineBoundary(TextPosition(offset: firstIndex));
      if (range.start < 0 || range.end < 0 || range.end > message.length) {
        Logger.log(
          LogLevel.warning,
          "Invalid range (${range.start}, "
          "${range.end}) for message '$message'",
        );
        continue;
      }
      firstIndex = firstIndex + range.end - range.start + 1;
      _encodeTextLine(
        message.substring(range.start, range.end),
        metric,
        offset,
        masked: _blockType != BlockType.recorded,
        style: style,
      );
    }
  }

  void _encodeTextLine(
    String text,
    LineMetrics metric,
    Offset offset, {
    required bool masked,
    TextStyle? style,
  }) {
    final color = style?.color ?? Colors.black;
    final size = style?.fontSize ?? 12;

    if (masked) {
      text = _masker.maskText(text, _canvasEnc._currentRenderObject?.hashCode);
    }
    final id = Kernel.singleton().native.recordString(text);

    final absolute = _absolute(
      Offset(metric.left + offset.dx, metric.baseline + offset.dy),
    );
    _drawEnc.drawParagraph(
      stringId: id,
      offset: absolute,
      color: color,
      textSize: size,
      bounds: Size(metric.width, metric.height),
      masked: masked,
    );
  }

  @override
  void drawPath(Path path, Paint paint) {
    Logger.log(LogLevel.verbose, "OP: drawPath");
    _drawEnc.drawRect(_absoluteRect(path.getBounds()), paint);
  }

  @override
  void drawPicture(Picture picture) {
    Logger.log(LogLevel.verbose, "OP: UNSUPPORTED: drawPicture, drawing rect");
    final object = _canvasEnc._currentRenderObject;
    if (object == null) {
      Logger.log(LogLevel.note, "Unable to find RenderObject for drawPicture");
      return;
    }

    _drawEnc.drawRect(_absoluteRect(object.paintBounds), _defaultPaint);
  }

  @override
  void drawPoints(PointMode pointMode, List<Offset> points, Paint paint) {
    Logger.log(LogLevel.verbose, "OP: UNSUPPORTED: drawPoints");
  }

  @override
  void drawRawAtlas(
    ui.Image atlas,
    Float32List rstTransforms,
    Float32List rects,
    Int32List? colors,
    BlendMode? blendMode,
    Rect? cullRect,
    Paint paint,
  ) {
    Logger.log(LogLevel.verbose, "OP: UNSUPPORTED: drawRawAtlas");
  }

  @override
  void drawRawPoints(PointMode pointMode, Float32List points, Paint paint) {
    Logger.log(LogLevel.verbose, "OP: UNSUPPORTED: drawRawPoints");
  }

  @override
  void drawRect(Rect rect, Paint paint) {
    Logger.log(LogLevel.verbose, "OP: drawRect");
    _drawEnc.drawRect(_absoluteRect(rect), paint);
  }

  @override
  void drawRRect(RRect rect, Paint paint) {
    Logger.log(LogLevel.verbose, "OP: drawRRect");
    if (rect.tlRadiusX != rect.trRadiusX ||
        rect.tlRadiusX != rect.blRadiusX ||
        rect.tlRadiusX != rect.brRadiusX ||
        rect.tlRadiusY != rect.trRadiusY ||
        rect.tlRadiusY != rect.blRadiusY ||
        rect.tlRadiusY != rect.brRadiusY) {
      Logger.log(
        LogLevel.verbose,
        "OP: UNSUPPORTED: RRects with asymmetric radii",
      );
    }

    _drawEnc.drawRRect(_absoluteRRect(rect), paint);
  }

  @override
  void drawShadow(
    Path path,
    Color color,
    double elevation,
    bool transparentOccluder,
  ) {
    Logger.log(LogLevel.verbose, "OP: UNSUPPORTED: drawShadow");
  }

  @override
  void drawVertices(Vertices vertices, BlendMode blendMode, Paint paint) {
    Logger.log(LogLevel.verbose, "OP: UNSUPPORTED: drawVertices");
  }

  int _saveCount = 1;
  @override
  int getSaveCount() {
    return _saveCount;
  }

  @override
  void restore() {
    if (_saveCount > 1) {
      _saveCount--;
      _drawEnc.restore();
    }
  }

  @override
  void rotate(double radians) {
    Logger.log(LogLevel.verbose, "OP: rotate ${radians * 360 / (pi * 2)}");
    _drawEnc.rotate(radians);
  }

  @override
  void save() {
    _saveCount++;
    _drawEnc.save();
  }

  @override
  void saveLayer(Rect? bounds, Paint paint) {
    Logger.log(LogLevel.verbose, "OP: saveLayer");
    _saveCount++;
    _drawEnc.save();
  }

  @override
  void scale(double sx, [double? sy]) {
    Logger.log(LogLevel.verbose, "OP: scale");
    _drawEnc.scale(sx: sx, sy: sy);
  }

  @override
  void skew(double sx, sy) {
    Logger.log(LogLevel.verbose, "OP: UNSUPPORTED: skew");
  }

  @override
  void transform(Float64List matrix4) {
    Logger.log(
      LogLevel.verbose,
      "OP: UNSUPPORTED: transform, ${StackTrace.current}",
    );
  }

  @override
  void translate(double dx, double dy) {
    if (dx == 0.0 && dy == 0.0) {
      return;
    }

    Logger.log(LogLevel.verbose, "OP: translate");
    _drawEnc.translate(dx: dx, dy: dy);
  }

  @override
  Rect getDestinationClipBounds() {
    Logger.log(
      LogLevel.debug,
      "OP: UNSUPPORTED: getDestinationClipBounds, ${StackTrace.current}",
    );
    return Rect.zero;
  }

  @override
  Rect getLocalClipBounds() {
    Logger.log(
      LogLevel.debug,
      "OP: UNSUPPORTED: getLocalClipBounds, ${StackTrace.current}",
    );
    return Rect.zero;
  }

  @override
  Float64List getTransform() {
    Logger.log(
      LogLevel.debug,
      "OP: UNSUPPORTED: getTransform, ${StackTrace.current}",
    );
    return Float64List(0);
  }

  @override
  void restoreToCount(int count) {
    Logger.log(
      LogLevel.debug,
      "OP: UNSUPPORTED: restorToCount($count), ${StackTrace.current}",
    );
  }

  @override
  void clipRSuperellipse(ui.RSuperellipse rse, {bool doAntiAlias = true}) {
    Logger.log(LogLevel.verbose, "OP: UNSUPPORTED: clipRSuperellipse");
  }

  @override
  void drawRSuperellipse(ui.RSuperellipse rse, ui.Paint paint) {
    Logger.log(LogLevel.verbose, "OP: UNSUPPORTED: drawRSuperellipse");
  }
}

class _ScanPaintingContext extends PaintingContext {
  final CanvasEncoder _canvasEnc;
  final BlockType _blockType;
  Map<RenderObject, int> _sset = {};

  DrawingEncoder get _tokenEnc => _canvasEnc._drawEnc;

  _ScanPaintingContext(this._canvasEnc, this._blockType, Rect estimatedBounds)
    : super(ContainerLayer(), estimatedBounds);

  @override
  Canvas get canvas => _ScanCanvas(_canvasEnc, _blockType);

  @override
  void addLayer(Layer l) {
    Logger.log(LogLevel.debug, "UNSUPPORTED: PaintingContext.addLayer $l");
  }

  @override
  void appendLayer(Layer l) {
    Logger.log(LogLevel.debug, "UNSUPPORTED: PaintingContext.appendLayer $l");
  }

  @override
  PaintingContext createChildContext(ContainerLayer childLayer, Rect bounds) {
    Logger.log(
      LogLevel.note,
      "UNTESTED: PaintingContext.createChildContext $childLayer",
    );
    return this;
  }

  static const _skippedRenderObjects = [
    'RenderVisibilityDetector',
    'RenderSliverVisibilityDetector',
  ];

  @override
  void paintChild(RenderObject child, Offset offset) {
    if (_skippedRenderObjects.contains(child.runtimeType.toString())) {
      Logger.log(
        LogLevel.verbose,
        "Skipping rendering of ${child.runtimeType}",
      );
      child.visitChildren((grandchild) => paintChild(grandchild, offset));
      return;
    }

    if (_sset.containsKey(child)) {
      final id = _sset[child];
      if (id != null) {
        _tokenEnc.addViewId(id);
      } else {
        Logger.log(
          LogLevel.error,
          "PaintingContext.paintChild: no ID for view: $child",
        );
      }
      _canvasEnc._childOffsets[child] = offset;
      return;
    }

    final previous = _canvasEnc._currentRenderObject;
    _canvasEnc._currentRenderObject = child;
    try {
      child.paint(this, child.isRepaintBoundary ? Offset.zero : offset);
    } catch (e, stack) {
      Logger.log(
        LogLevel.error,
        'Error painting ${child.runtimeType}. This view will be skipped; '
        'playback will be affected. Please contact Fullstory and share the '
        'following stack trace:\n'
        '$child\n$e\n$stack',
      );
    } finally {
      _canvasEnc._currentRenderObject = previous;
    }
  }

  void paintOneChild(RenderObject child, Map<RenderObject, int> sset) {
    _sset = sset;

    final chOfs = child.isRepaintBoundary
        ? Offset.zero
        : _canvasEnc._childOffsets[child] ?? Offset.zero;

    final prevOrigin = _canvasEnc.origin;
    _canvasEnc.origin = -chOfs;
    try {
      paintChild(child, chOfs);
    } finally {
      _canvasEnc.origin = prevOrigin;
    }
  }

  @override
  void pushLayer(
    ContainerLayer childLayer,
    PaintingContextCallback painter,
    Offset offset, {
    Rect? childPaintBounds,
  }) {
    Logger.log(
      LogLevel.debug,
      "UNSUPPORTED: PaintingContext.pushLayer($childLayer)",
    );
    painter(this, offset);
  }

  @override
  void stopRecordingIfNeeded() {
    Logger.log(LogLevel.verbose, "PaintingContext.stopRecordingIfNeeded");
    return;

    // ignore: dead_code
    super.stopRecordingIfNeeded();
  }
}
