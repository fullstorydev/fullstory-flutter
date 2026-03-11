import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fullstory_flutter/src/blocking/block.dart';
import 'package:fullstory_flutter/src/blocking/region.dart';
import 'package:fullstory_flutter/src/drawing.dart';
import 'package:fullstory_flutter/src/elements.dart';
import 'package:fullstory_flutter/src/encoder.dart';
import 'package:fullstory_flutter/src/numbers.dart';

import 'attributes.dart';
import 'binding.dart';
import 'kernel.dart';
import 'logging.dart';
import 'view_encoder.dart';

class ScanResult {
  final int scanId;
  final int uniqueId;

  final bool complete;

  ScanResult({
    required this.scanId,
    required this.uniqueId,
    required this.complete,
  });
}

class ViewCache {
  bool viewCached = false;
  bool childrenCached = false;

  bool scanComplete = false;

  int? canvasId;

  Set<Element>? prevChildren;

  List<SelectorAttributes>? selectorPath;
}

class Scanner {
  static final maxScanMs = 80;
  final _uniqueIdExpando = Expando<int>("uniqeID generator");
  int _uniqueIdCounter = 2;

  static const _uniqueScalingId = 1;

  bool hideElements = true;

  final _renderObjectDemapExpando = Expando<Element>(
    "render object demap expando",
  );
  var _elementCacheExpando = Expando<ViewCache>("element cache properties");

  final _dirtyCallbackExpando = Expando<void Function(RenderObject, bool)>(
    "dirtycallback",
  );
  final AttributeTracker _attributeTracker;

  final CanvasEncoder _canvasEncoder;
  final ScanEncoder _scanEncoder;
  final DrawingBundler _drawingBundler;
  final ViewBlocker _viewBlocker;
  final FullstoryBinding _binding;

  final _blockedRegions = BlockedRegions();
  Scanner(
    Kernel kernel,
    this._binding,
    this._attributeTracker,
    this._viewBlocker, [
    CanvasEncoder? canvasEncoder,
    DrawingBundler? drawingBundler,
    ScanEncoder? scanEncoder,
  ]) : _canvasEncoder = canvasEncoder ?? CanvasEncoder(),
       _drawingBundler = drawingBundler ?? DrawingBundler(encoderBindings),
       _scanEncoder = scanEncoder ?? ScanEncoder(kernel.native);

  int uniqueIdFor(Element el) {
    var id = _uniqueIdExpando[el];
    if (id != null) {
      return id;
    }
    id = _uniqueIdCounter++;
    _uniqueIdExpando[el] = id;
    return id;
  }

  // ignore: unused_element
  Future<void> _dumpRenderTree() async {
    Logger.log(LogLevel.debug, "Render tree:");

    RenderObjectVisitor visit(String depth) => (RenderObject obj) {
      var transform = obj.getTransformTo(null);

      var tl = MatrixUtils.transformPoint(
        transform,
        obj.semanticBounds.topLeft,
      );
      var br = MatrixUtils.transformPoint(
        transform,
        obj.semanticBounds.bottomRight,
      );

      Logger.log(LogLevel.debug, "$depth $obj $tl -> $br");
      obj.visitChildrenForSemantics(visit("$depth  "));
    };

    final rootObj = _binding.rootElement?.renderObject;
    if (rootObj != null) visit("")(rootObj);
  }

  int _childrenTreeMissed = 0;
  int _viewsMissed = 0;
  final _metrics = _ScanMetrics();
  bool? _consented;

  Future<ScanResult?> _scanFromElement(
    Element el, {
    RenderObject? lastObj,
    bool isRoot = false,
    Offset parentOrigin = const Offset(0.0, 0.0),
    List<Element> parents = const [],
    List<SelectorAttributes> parentSelectors = const [],
    BlockType parentBlockType = BlockType.masked,
    List<FSCustomAttributes> enclosingAttributes = const [],
    int startTime = 0,
    bool subtreeCached = true,

    required int previousId,
  }) async {
    if (!el.mounted) {
      return null;
    }
    final widgetType = el.widget.runtimeType.toString();

    final renderObject = el.renderObject;
    if (renderObject == null || !renderObject.attached) {
      return null;
    }

    if (_isOffstage(renderObject)) {
      return null;
    }

    _metrics.startFor(el);

    if (_elementCacheExpando[el] == null) {
      _elementCacheExpando[el] = ViewCache();
    }

    final cache = _elementCacheExpando[el];
    bool viewCached =
        Platform.isIOS && cache?.viewCached == true && subtreeCached;
    bool childrenCached =
        Platform.isIOS && cache?.childrenCached == true && subtreeCached;
    bool prevScanComplete = cache?.scanComplete == true;
    bool isComplete = true;
    bool timedOut =
        ((DateTime.now().millisecondsSinceEpoch) - startTime) > maxScanMs;

    isComplete = isComplete && !timedOut;

    if (!childrenCached) _childrenTreeMissed++;

    final absoluteBounds = MatrixUtils.transformRect(
      renderObject.getTransformTo(null),
      renderObject.semanticBounds,
    );
    final relativeBounds = absoluteBounds.shift(-parentOrigin);
    final uniqueId = uniqueIdFor(el);

    if (timedOut == true) {
      Logger.log(
        LogLevel.debug,
        "timed out while scanning id $uniqueId == $el (${(DateTime.now().millisecondsSinceEpoch) - startTime} is larger than $maxScanMs)",
      );
    }

    if (_isOffscreen(absoluteBounds)) {
      return null;
    }

    bool isTracking = _attributeTracker.needsAccumulating(el);
    if (isTracking) {
      _attributeTracker.computeLabel(el);

      for (FSCustomAttributes attr in enclosingAttributes) {
        _attributeTracker.accumulateCustomAttributes(el, attr);
      }
    }

    var elpath = List<Element>.from(parents)..add(el);

    final selectors = List<SelectorAttributes>.from(parentSelectors)
      ..add(_attributeTracker.selectorAttributesFor(el, widgetType));
    cache?.selectorPath = selectors;

    final blockType = _viewBlocker.evalBlockTypeFor(
      selectors,
      parentType: parentBlockType,
      consented: _consented ?? false,
    );
    if (isTracking) _attributeTracker.updateLabelBlocking(el, blockType);

    if (!blockType.captureView) {
      Logger.log(
        LogLevel.debug,
        'blocking view with dimensions $absoluteBounds',
      );
      _blockedRegions.add(absoluteBounds);
    }
    if (blockType == BlockType.omitted) {
      return null;
    }

    var csetmap = <Element, List<FSCustomAttributes>>{};
    var sset = <RenderObject, int>{};
    var rset = <RenderObject>{};
    if (!viewCached || !childrenCached || !prevScanComplete) {
      List<FSCustomAttributes> attrList = [];
      void accumulateChildren(Element childEl) {
        if (includeElement(childEl)) {
          csetmap[childEl] = List<FSCustomAttributes>.from(attrList);
        } else if (childEl.mounted) {
          final widget = childEl.widget;
          if (widget is FSCustomAttributes) {
            attrList.add(widget);
            childEl.visitChildElements(accumulateChildren);
            attrList.removeLast();
          } else {
            childEl.visitChildElements(accumulateChildren);
          }
        }
      }

      el.visitChildElements(accumulateChildren);

      for (Element el2 in csetmap.keys) {
        final ro = el2.renderObject;
        if (ro != null) {
          sset[ro] = uniqueIdFor(el2);
        }
      }

      void rvisit(RenderObject r) {
        if (!sset.containsKey(r)) {
          rset.add(r);
          _renderObjectDemapExpando[r] = el;
          r.visitChildrenForSemantics(rvisit);
        }
      }

      rvisit(renderObject);
    }

    int? canvas;
    int? metadata;

    final divFactor = isRoot ? _devicePixelRatio : 1.0;
    if (!blockType.captureView) {
      final bounds = _safeBoundsFrom(relativeBounds, divFactor, widgetType);
      metadata = _scanEncoder.viewMetadata(
        viewClass: widgetType,
        blockType: blockType,
        x1: bounds.x1,
        y1: bounds.y1,
        x2: bounds.x2,
        y2: bounds.y2,
      );
    } else if (!viewCached) {
      final canvasId = cache?.canvasId;
      if (canvasId != null) {
        canvas = canvasId;
      } else {
        _viewsMissed++;

        _canvasEncoder.resetCanvas();
        if (!timedOut) {
          _canvasEncoder.encodeElements(el, sset, blockType);
          canvas = _drawingBundler.addDrawing(
            _canvasEncoder.drawEncoder,
            uniqueId,
          );
          cache?.canvasId = canvas;
        } else {
          canvas = 0;
        }
      }

      final customAttrs = _attributeTracker.makeCustomAttrs(el);
      final bounds = _safeBoundsFrom(relativeBounds, divFactor, widgetType);
      metadata = _scanEncoder.viewMetadata(
        alpha: 255,
        blockType: blockType,
        viewClass: widgetType,
        customAttrs: customAttrs,
        x1: bounds.x1,
        y1: bounds.y1,
        x2: bounds.x2,
        y2: bounds.y2,
      );
    }

    if (!viewCached || !childrenCached) {
      bool cached = true;
      void dirty(RenderObject r, bool forLayout) {
        cache?.viewCached = false;
        cache?.childrenCached = false;
        cache?.canvasId = null;

        for (Element el2 in parents) {
          _elementCacheExpando[el2]?.childrenCached = false;
        }

        if (forLayout) {
          r.visitChildrenForSemantics((child) {
            _dirtyCallbackExpando[child]?.call(child, true);
          });
        }

        if (el.mounted) {
          Logger.log(LogLevel.debug, "invalidated $el");
        } else {
          Logger.log(LogLevel.debug, "invalidated unmounted element");
        }
      }

      for (RenderObject r in rset) {
        _dirtyCallbackExpando[r] = dirty;
      }
      if (cached && !childrenCached && !timedOut) cache?.childrenCached = true;
      if (cached && !viewCached && !timedOut) cache?.viewCached = true;
    }

    var children = <int>[];
    var newcset = <Element>{};
    var previousChild = 0;
    if (childrenCached && prevScanComplete) newcset = cache?.prevChildren ?? {};
    if ((!childrenCached || !prevScanComplete) &&
        blockType.captureView &&
        !timedOut) {
      children = [];
      for (Element el2 in csetmap.keys) {
        final usePreviousView = Platform.isAndroid || viewCached;
        final hasPrevChild = cache?.prevChildren?.contains(el2) ?? false;
        final cacheable = usePreviousView && hasPrevChild;
        _metrics.pauseFor(el);
        var result = await _scanFromElement(
          el2,
          lastObj: renderObject,
          parentOrigin: absoluteBounds.topLeft,
          parents: elpath,
          parentSelectors: selectors,
          parentBlockType: blockType,
          enclosingAttributes: csetmap[el2] ?? [],
          startTime: startTime,
          subtreeCached: subtreeCached && cacheable,
          previousId: previousChild,
        );
        _metrics.unpauseFor(el);
        if (result != null) {
          previousChild = result.scanId;
          children.add(result.scanId);
          newcset.add(el2);
          isComplete = isComplete && result.complete;
        }
      }
    }
    cache?.prevChildren = newcset;
    cache?.scanComplete = isComplete;

    _metrics.finishFor(el, widgetType);
    return ScanResult(
      complete: isComplete,
      uniqueId: uniqueId,
      scanId: _scanEncoder.view(
        id: uniqueId,
        viewCached: viewCached,
        childrenCached: childrenCached,
        canvas: canvas,
        metadata: metadata,
        children: children,
        previousId: previousId,
      ),
    );
  }

  bool includeElement(Element childEl) {
    if (hideElements) {
      return childEl.isIncluded;
    }

    if (!childEl.mounted) {
      return false;
    }
    return childEl.widget is! FSCustomAttributes;
  }

  bool includeRenderObject(RenderObject ro) {
    final element = elementFor(ro);
    if (element == null) {
      return false;
    }

    return includeElement(element);
  }

  static final _defaultNode = DiagnosticsNode.message('no skipCount found');
  final _offstageExpando = Expando<bool>('_RenderTheater offstage');

  bool _isOffstage(RenderObject renderObject) {
    if (renderObject.parent?.paintsChild(renderObject) == false) {
      return true;
    }

    if (renderObject.runtimeType.toString() == '_RenderTheater') {
      final diagnostic = DiagnosticPropertiesBuilder();

      // ignore: invalid_use_of_protected_member
      renderObject.debugFillProperties(diagnostic);
      final skipCountProperty = diagnostic.properties.firstWhere(
        (p) => p.name == 'skipCount',
        orElse: () => _defaultNode,
      );
      if (skipCountProperty.value is int) {
        final skipCount = skipCountProperty.value as int;

        int i = 0;
        renderObject.visitChildren((child) {
          _offstageExpando[child] = i++ < skipCount;
        });
      }
    }

    final isOffstage = _offstageExpando[renderObject] ?? false;
    if (isOffstage) {
      Logger.log(
        LogLevel.debug,
        "Skipping offstage renderObject $renderObject",
      );
    }
    return isOffstage;
  }

  Future<ScanOutput> scan(bool intermediate) async {
    if (!_viewBlocker.ready) {
      Logger.log(LogLevel.debug, "ViewBlocker not ready, skipping scan.");
      return ScanOutput();
    }

    try {
      final start = DateTime.now().millisecondsSinceEpoch;
      _scanEncoder.start();

      if (!intermediate || !_drawingBundler.inProgress) {
        _startBundle();
      } else {
        _invalidateCache();
      }

      _blockedRegions.clear();
      _childrenTreeMissed = 0;
      _viewsMissed = 0;

      final root = _binding.rootElement;
      var topView = root == null
          ? null
          : await _scanFromElement(
              root,
              isRoot: true,
              startTime: start,
              previousId: 0,
            );

      final id = _injectScaling(topView) ?? 0;
      final bytes = _scanEncoder.finish(id);
      final drawings = _drawingBundler.fetchBundle();

      if ((_childrenTreeMissed != 0 || _viewsMissed != 0)) {
        _metrics.logMetrics(_childrenTreeMissed, _viewsMissed, start);
      }

      final regions = _blockedRegions.toHostList(
        Platform.isIOS ? 1.0 : _devicePixelRatio,
      );

      return ScanOutput(
        views: bytes?.byteArray.toUint8List(),
        drawings: drawings,
        blockedRegions: regions,
      );
    } catch (_) {
      if (_scanEncoder.inProgress) _scanEncoder.finish(0);
      rethrow;
    } finally {
      _metrics.reset();
    }
  }

  void _startBundle() {
    _resetViewCache();
    if (_drawingBundler.inProgress) {
      _drawingBundler.finishBundle();
    }
    _drawingBundler.startBundle();
  }

  void _invalidateCache() {
    final owner = _binding.fsPipelineOwner;
    _metrics.startInvalidation();
    owner.visitAndClearInvalidated((object, invalidateChildren) {
      _dirtyCallbackExpando[object]?.call(object, invalidateChildren);
    });
    _metrics.finishInvalidation();
  }

  int? _injectScaling(ScanResult? topView) {
    var childId = topView?.uniqueId;
    var childScanId = topView?.scanId;
    if (childId == null || childScanId == null) return null;

    if (Platform.isIOS) return childScanId;

    final ratio = _devicePixelRatio;
    if (ratio == 1.0) return childScanId;

    final physicalSize = _physicalSize;
    if (physicalSize == null) return childScanId;

    final scaleMetadata = _scanEncoder.viewMetadata(
      viewClass: 'FSScalingCorrection',
      alpha: 255,
      x1: 0,
      y1: 0,
      x2: physicalSize.width.toIntSafe("screen width for scaling"),
      y2: physicalSize.height.toIntSafe("screen height for scaling"),
    );

    _canvasEncoder.resetCanvas();
    _canvasEncoder.encodeRootScaling(ratio, childId);
    final canvas = _drawingBundler.addDrawing(
      _canvasEncoder.drawEncoder,
      _uniqueScalingId,
    );

    return _scanEncoder.view(
      id: _uniqueScalingId,
      viewCached: false,
      childrenCached: false,
      canvas: canvas,
      metadata: scaleMetadata,
      children: [childScanId],
      previousId: 0,
    );
  }

  Element? elementFor(RenderObject obj) => _renderObjectDemapExpando[obj];

  List<SelectorAttributes> getSelectorPathFor(Element element) {
    final cache = _elementCacheExpando[element];
    if (cache?.selectorPath != null) {
      return cache!.selectorPath!;
    }

    return <SelectorAttributes>[
      _attributeTracker.selectorAttributesFor(
        element,
        element.widget.runtimeType.toString(),
      ),
    ];
  }

  bool isTapBlocked(Offset pt) => _blockedRegions.contains(pt);

  set consentStatus(bool consented) {
    if (_consented == null || consented != _consented) {
      Logger.log(
        LogLevel.debug,
        "consent status changed, new status= $_consented, resetting cache",
      );
      _consented = consented;
      _resetViewCache();
    }
  }

  void _resetViewCache() {
    _elementCacheExpando = Expando("element cache properties");
    _blockedRegions.clear();
  }

  bool initBlocking(Map<String, Uint8List?> privacyRules) {
    return _viewBlocker.init(privacyRules);
  }

  bool initBlockingFromSession(Uint8List blockRules) {
    return _viewBlocker.initFromSession(blockRules);
  }

  bool _isOffscreen(Rect absoluteBounds) {
    final physicalSize = _physicalSize;
    if (physicalSize == null) {
      return true;
    }

    final screenSize = physicalSize / _devicePixelRatio;
    if (absoluteBounds.top > screenSize.height ||
        absoluteBounds.left > screenSize.width ||
        absoluteBounds.bottom < 0 ||
        absoluteBounds.right < 0) {
      return true;
    }
    return false;
  }

  double get _devicePixelRatio {
    final views = _binding.platformDispatcher.views;
    if (views.isEmpty) {
      return 1.0;
    }

    return views.first.devicePixelRatio;
  }

  Size? get _physicalSize {
    final views = _binding.platformDispatcher.views;
    if (views.isEmpty) {
      return null;
    }

    return views.first.physicalSize;
  }

  bool get logMetrics => _metrics.tracking;
  set logMetrics(bool value) {
    _metrics.tracking = value;
  }
}

class ScanOutput {
  final Uint8List? views;
  final Uint8List? drawings;
  final List<List<int>>? blockedRegions;

  ScanOutput({this.views, this.drawings, this.blockedRegions});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ScanOutput) return false;

    return listEquals(views, other.views) &&
        listEquals(drawings, other.drawings) &&
        _regionsEqual(other.blockedRegions);
  }

  bool _regionsEqual(List<List<int>>? otherRegions) {
    final myRegions = blockedRegions;
    if (myRegions == null && otherRegions == null) {
      return true;
    }

    if (myRegions == null || otherRegions == null) {
      return false;
    }

    if (myRegions.length != otherRegions.length) {
      return false;
    }

    for (var i = 0; i < myRegions.length; i++) {
      if (!listEquals(myRegions[i], otherRegions[i])) {
        return false;
      }
    }

    return true;
  }

  @override
  int get hashCode => Object.hash(views, drawings, blockedRegions);

  @override
  String toString() =>
      'ScanOutput(${views?.length} view bytes, ${drawings?.length} drawing bytes, ${blockedRegions?.length} blocked regions)';
}

class _ScanMetrics {
  final _elMetrics = <String, (int, int)>{};
  final _elWatches = <Element, Stopwatch>{};
  final _invalidationWatch = Stopwatch();

  bool tracking = kDebugMode;

  void startInvalidation() {
    if (tracking) _invalidationWatch.start();
  }

  void finishInvalidation() {
    if (tracking) _invalidationWatch.stop();
  }

  void reset() {
    if (tracking) {
      _invalidationWatch.reset();
      _elWatches.clear();
      _elMetrics.clear();
    }
  }

  void startFor(Element el) {
    if (tracking) _elWatches[el] = Stopwatch()..start();
  }

  void pauseFor(Element el) {
    if (tracking) _elWatches[el]?.stop();
  }

  void unpauseFor(Element el) {
    if (tracking) _elWatches[el]?.start();
  }

  void finishFor(Element el, String widgetType) {
    final (count, durationUs) = _elMetrics[widgetType] ?? (0, 0);
    final elWatch = _elWatches[el];
    elWatch?.stop();

    _elMetrics[widgetType] = (
      count + 1,
      durationUs + (elWatch?.elapsedMicroseconds ?? 0),
    );

    elWatch?.reset();
    _elWatches.remove(el);
  }

  void logMetrics(int countHierarchy, int countStructure, int startMs) {
    if (!tracking) return;

    Logger.log(
      LogLevel.debug,
      "viewScanner: rescanned $countHierarchy for hierarchy, and $countStructure"
      " for structure, in ${(DateTime.now().millisecondsSinceEpoch) - startMs} ms",
    );
    Logger.log(
      LogLevel.debug,
      "viewScanner: scan spent ${_invalidationWatch.elapsedMicroseconds}us invalidating",
    );
    for (final entry in _elMetrics.entries) {
      if (entry.value.$2 > 0) {
        Logger.log(
          LogLevel.verbose,
          "Spent ${entry.value.$2}us scanning ${entry.value.$1} ${entry.key}",
        );
      }
    }
  }
}

({int x1, int y1, int x2, int y2}) _safeBoundsFrom(
  Rect relativeBounds,
  double divFactor, [
  String? widgetType,
]) => (
  x1: (relativeBounds.left / divFactor).toIntSafe('left', widgetType),
  y1: (relativeBounds.top / divFactor).toIntSafe('top', widgetType),
  x2: (relativeBounds.right / divFactor).toIntSafe('right', widgetType),
  y2: (relativeBounds.bottom / divFactor).toIntSafe('bottom', widgetType),
);
