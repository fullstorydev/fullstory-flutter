import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:fullstory_flutter/src/kernel.dart';
import 'package:fullstory_flutter/src/logging.dart';
import 'package:fullstory_flutter/fs.dart';

export 'package:fullstory_flutter/src/logging.dart' show LogLevel;

/// A Fullstory-instrumented version of [WidgetsFlutterBinding].
///
/// Use [runFullstoryApp] or [runFullstoryWidget] to run your app or widget
/// with Fullstory capturing enabled.
class FullstoryBinding extends BindingBase
    with
        GestureBinding,
        SchedulerBinding,
        ServicesBinding,
        PaintingBinding,
        SemanticsBinding,
        RendererBinding,
        WidgetsBinding {
  /// Returns an instance of the binding that implements [WidgetsBinding].
  static FullstoryBinding ensureInitialized() {
    _instance ??= FullstoryBinding();
    return _instance!;
  }

  // The lazy instantiation is necessary because whichever binding is
  // instantiated first "wins" and becomes the default binding at the top level.
  // We want to be able to swap in a different binding in tests.
  // see [BindingBase].
  static FullstoryBinding? _instance;
  static FullstoryBinding get instance => BindingBase.checkInstance(_instance);

  @override
  PipelineOwner createRootPipelineOwner() => FullstoryPipelineOwner();

  FullstoryPipelineOwner get fsPipelineOwner =>
      super.rootPipelineOwner as FullstoryPipelineOwner;
}

/// A Fullstory-instrumented version of [PipelineOwner].
///
/// This root pipeline owner performs all standard responsibilities, as well as
/// tracking render-tree nodes which need paint or layout so that these
/// invalidations can be used for view scanning.
final class FullstoryPipelineOwner extends PipelineOwner {
  FullstoryPipelineOwner() : super(onSemanticsUpdate: _onSemanticsUpdate);

  /// A map of render objects that need to be invalidated.
  ///
  /// The value of the map is whether the object needs to be invalidated for
  /// layout (true) or paint (false).
  final _invalidateChildren = <RenderObject, _Invalidation>{};

  void visitAndClearInvalidated(void Function(RenderObject, bool) visitor) {
    for (final entry in _invalidateChildren.entries) {
      visitor(entry.key, true);
    }
    _invalidateChildren.clear();
  }

  void _cacheLayoutNodes() {
    void visit(PipelineOwner owner) {
      for (final node in owner.nodesNeedingLayout) {
        final previous = _invalidateChildren[node];
        _invalidateChildren[node] =
            previous == null || previous == _Invalidation.layout
            ? _Invalidation.layout
            : _Invalidation.both;
      }
      owner.visitChildren(visit);
    }

    visit(this);
  }

  void _cachePaintNodes() {
    void visit(PipelineOwner owner) {
      for (final node in owner.nodesNeedingPaint) {
        final previous = _invalidateChildren[node];
        _invalidateChildren[node] =
            previous == null || previous == _Invalidation.paint
            ? _Invalidation.paint
            : _Invalidation.both;
      }
      owner.visitChildren(visit);
    }

    visit(this);
  }

  @override
  void flushLayout() {
    _cacheLayoutNodes();
    super.flushLayout();
  }

  @override
  void flushPaint() {
    _cachePaintNodes();
    super.flushPaint();
  }

  @override
  set rootNode(RenderObject? _) {
    assert(() {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary(
          'Cannot set a rootNode on the Fullstory root pipeline owner.',
        ),
        ErrorDescription(
          'By default, the RendererBinding.rootPipelineOwner is not configured '
          'to manage a root node because this pipeline owner does not define a '
          'proper onSemanticsUpdate callback to handle semantics for that node.',
        ),
        ErrorHint(
          'Typically, the root pipeline owner does not manage a root node. '
          'Instead, properly configured child pipeline owners (which do manage '
          'root nodes) are added to it. Alternatively, if you do want to set a '
          'root node for the root pipeline owner, override '
          'RendererBinding.createRootPipelineOwner to create a '
          'pipeline owner that is configured to properly handle semantics for '
          'the provided root node.',
        ),
      ]);
    }());
  }
}

// The PipelineOwner here is a root pipeline owner which is not responsible for
// semantics.
void _onSemanticsUpdate(ui.SemanticsUpdate _) {
  FS.log(
    level: FSLogLevel.error,
    message:
        'FullstoryBinding.onSemanticsUpdate called. This should not happen, '
        'since it is the root pipeline owner.',
  );
  assert(false);
}

/// Runs the given app inside a Fullstory-instrumented binding.
///
/// This is equivalent to calling the standard [runApp], but allows Fullstory
/// to capture data needed for session replay using [FullstoryBinding].
///
/// [logLevel] sets the defaul verbosity of Fullstory loggging, defaulting to
/// `note`. This is a temporary field to be replaced by use of the native SDK's
/// logging configuration.
///
/// [logScanMetrics] indicates whether to log view scan metrics to the console.
/// This is intended for debugging and performance tuning, and will negatively
/// impact performance if enabled in production. By default, enabled in debug
/// only.
///
/// [shortenSelectors] indicates whether some widgets which are typically
/// implementation details of others are hidden from the selectors created
/// during scans. This defaults to true, and typically should only be set to
/// false for debugging, as there is a performance cost associated with
/// deeper selectors.
void runFullstoryApp(
  Widget app, {
  LogLevel logLevel = LogLevel.note,
  bool logScanMetrics = kDebugMode,
  bool shortenSelectors = true,
}) {
  final WidgetsBinding binding = FullstoryBinding.ensureInitialized();
  Kernel.singleton()
    ..init()
    ..logScanMetrics = logScanMetrics
    ..hideElements = shortenSelectors;
  _runWidget(
    binding.wrapWithDefaultView(app),
    binding,
    'runFullstoryApp',
    logLevel: logLevel,
  );
}

/// Runs the given app inside a Fullstory-instrumented binding.
///
/// This is equivalent to calling the standard [runWidget], but allows Fullstory
/// to capture data needed for session replay using [FullstoryBinding].
///
/// Like with [runWidget], this will not wrap the passed [app] with a default
/// [View], so be sure to provide your own!
///
/// [logLevel] sets the defaul verbosity of Fullstory loggging, defaulting to
/// `note`. This is a temporary field to be replaced by use of the native SDK's
/// logging configuration.
///
/// [logScanMetrics] indicates whether to log view scan metrics to the console.
/// This is intended for debugging and performance tuning, and will negatively
/// impact performance if enabled in production. By default, enabled in debug
/// only.
///
/// [shortenSelectors] indicates whether some widgets which are typically
/// implementation details of others are hidden from the selectors created
/// during scans. This defaults to true, and typically should only be set to
/// false for debugging, as there is a performance cost associated with
/// deeper selectors.
void runFullstoryWidget(
  Widget app, {
  LogLevel logLevel = LogLevel.note,
  bool logScanMetrics = kDebugMode,
  bool shortenSelectors = true,
}) {
  final WidgetsBinding binding = FullstoryBinding.ensureInitialized();
  Kernel.singleton()
    ..init()
    ..logScanMetrics = logScanMetrics
    ..hideElements = shortenSelectors;
  _runWidget(app, binding, 'runFullstoryWidget', logLevel: logLevel);
}

void _runWidget(
  Widget app,
  WidgetsBinding binding,
  String debugEntryPoint, {
  LogLevel logLevel = LogLevel.note,
}) {
  assert(binding.debugCheckZone(debugEntryPoint));
  Logger.minLogged = logLevel;
  Timer.run(() {
    binding.attachRootWidget(app);
  });
  binding.scheduleWarmUpFrame();
}

/// Represents whether a view needs invalidation for layout, paint, or both.
enum _Invalidation { layout, paint, both }
