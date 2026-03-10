import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:fullstory_flutter/src/attributes.dart';
import 'package:fullstory_flutter/src/blocking/block.dart';
import 'package:fullstory_flutter/src/logging.dart';
import 'package:fullstory_flutter/src/native.dart';
import 'package:fullstory_flutter/src/view_scanner.dart';

final maxDistance = 10.0;

class _PointerState {
  _PointerState({
    required this.presses,
    required this.lastSeen,
    required this.downHit,
    required this.downOffset,
    required this.wasTap,
    required this.blocked,
  });

  int presses;
  int lastSeen;


  HitTestResult downHit;
  Offset downOffset;
  bool wasTap;
  bool blocked;
}

class PointerReceiver {
  final Map<int, _PointerState> _pointers = {};

  final Scanner _scanner;
  final NativeInterface _native;
  final AttributeTracker _attributeTracker;
  final ViewBlocker _viewBlocker;

  PointerReceiver(
    this._scanner,
    this._attributeTracker,
    this._native,
    this._viewBlocker,
  );

  void register() {
    Logger.log(LogLevel.debug, 'Registering PointerReceiver');
    GestureBinding.instance.pointerRouter.addGlobalRoute(_event);
  }

  void _event(PointerEvent event) {
    switch (event) {
      case PointerUpEvent():
        _onPointerUp(event);
      case PointerMoveEvent():
        _onPointerMove(event);
      case PointerCancelEvent():
        _onPointerCancel(event);
      case PointerDownEvent():
        _onPointerDown(event);
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    final existing = _pointers[event.pointer];
    if (existing != null) {
      existing.presses++;
      return;
    }

    Logger.log(LogLevel.debug, 'pointerDown on pointer ${event.pointer}');
    var tapBlocked = _scanner.isTapBlocked(event.position);
    Logger.log(
      LogLevel.debug,
      'PointerReceiver: tapBlocked=$tapBlocked at ${event.position}',
    );
    final pointer = _PointerState(
      presses: 1,
      lastSeen: 0,
      wasTap: true,
      downOffset: event.position,
      downHit: HitTestResult(),
      blocked: tapBlocked,
    );

    _pointers[event.pointer] = pointer;

    WidgetsBinding.instance.hitTestInView(
      pointer.downHit,
      event.position,
      event.viewId,
    );
  }

  void _onPointerCancel(PointerCancelEvent event) {
    Logger.log(
      LogLevel.error,
      'UNHANDLED: onPointerCancel on pointer ${event.pointer}',
    );
  }

  void _onPointerMove(PointerMoveEvent event) {
    final pointer = _pointers[event.pointer];
    if (pointer == null || pointer.blocked) return;

    int now = DateTime.now().millisecondsSinceEpoch;
    if (now < (pointer.lastSeen + 33)) return;
    pointer.lastSeen = now;
    Offset delta = event.position - pointer.downOffset;
    if (delta.distanceSquared > maxDistance * maxDistance) {
      if (pointer.wasTap) {
        Logger.log(LogLevel.debug, 'pointer escaped from max distance');
      }
      pointer.wasTap = false;
    }
  }

  void _onPointerUp(PointerUpEvent event) async {
    final pointer = _pointers[event.pointer];
    if (pointer == null) return;

    _pointers.remove(event.pointer);

    if (pointer.blocked) return;

    Logger.log(LogLevel.debug, 'pointerUp on pointer ${event.pointer}');

    if (pointer.wasTap) {
      HitTestResult result = HitTestResult();
      WidgetsBinding.instance.hitTestInView(
        result,
        event.position,
        event.viewId,
      );
      final target = _firstRenderObject(result);
      if (target == null) {
        Logger.log(
          LogLevel.warning,
          'No unhidden RenderObject found for tap, dropping $event',
        );
        return;
      }

      final element = _scanner.elementFor(target);
      final firstTarget = _firstRenderObject(pointer.downHit);

      if (target == firstTarget && element != null) {
        await _captureInput(element, InputType.tap);
      } else {
        Logger.log(
          LogLevel.debug,
          'no tap -- pointer escaped from object, $firstTarget -> $target',
        );
      }
    }
  }

  RenderObject? _firstRenderObject(HitTestResult result) {
    for (final entry in result.path) {
      final target = entry.target;
      if (target is RenderObject && _scanner.includeRenderObject(target)) {
        return target;
      }
    }
    return null;
  }

  Future<void> _captureInput(Element element, InputType type) async {
    final viewId = _scanner.uniqueIdFor(element);
    final viewText = _attributeTracker.labelFor(element);
    bool keepEvent;
    if (!_viewBlocker.ready) {
      Logger.log(LogLevel.debug, "ViewBlocker not ready, dropping keep event");
      keepEvent = false;
    } else {
      keepEvent = _viewBlocker.evalKeepRuleFor(
        _scanner.getSelectorPathFor(element),
        inputType: type,
      );
    }

    Logger.log(
      LogLevel.debug,
      'tap event#$viewId: $element "$viewText"\tkeepEvent: $keepEvent',
    );
    await _native.sendInputEvent(
      type: type,
      viewId: viewId,
      text: viewText,
      keep: keepEvent,
    );
  }
}
