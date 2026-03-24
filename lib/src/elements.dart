import 'package:flutter/widgets.dart';

const hiddenElements = {
  'ScrollConfiguration',
  'Focus',
  'Semantics',
  'Actions',
  'DefaultFocusTraversal',
  'FocusTraversalGroup',
  'MediaQuery',
  'Localizations',
  'Directionality',
  'InheritedElement',
  'WidgetsApp',
  'Shortcuts',
  'CheckedModeBanner',
  'Theme',
  'CupertinoTheme',
  'IconTheme',
  'Navigator',
  'Listener',
  'AbsorbPointer',
  'FocusScope',
  'Stack',
  'IgnorePointer',
  'ModalBarrier',
  'BlockSemantics',
  'ExcludeSemantics',
  'RawGestureDetector',
  'CustomPaint',
  'AnimatedTheme',
  'MouseRegion',
  'ConstrainedBox',
  'Offstage',
  'PageStorage',
  'AnimatedBuilder',
  'CupertinoPageTransition',
  'SlideTransition',
  'FractionalTranslation',
  'DecoratedBoxTransition',
  'DecoratedBox',
  'Builder',
  'PrimaryScrollController',
  'Material',
  'AnimatedPhysicalModel',
  'PhysicalModel',
  'NotificationListener<LayoutChangedNotification>',
  'AnimatedDefaultTextStyle',
  'DefaultTextStyle',
  'CustomMultiChildLayout',
  'Center',
  'AnnotatedRegion<SystemUiOverlayStyle>',
  'Align',
  'SafeArea',
  'Padding',
  'ClipRect',
  'CustomSingleChildLayout',
  'GestureDetector',
  'PositionedDirectional',
  'Positioned',
  'ScaleTransition',
  'Transform',
  'RotationTransition',
  'FlexibleSpaceBarSettings',
  'AutomaticKeepAlive',
  'KeepAlive',
  'NotificationListener<KeepAliveNotification>',
  'IndexedSemantics',
  'PhysicalShape',
  'RawMaterialButton',
  'InkWell',
  'SliverPadding',
  'SliverList',
  'KeyedSubtree',
  'ListenableBuilder',

  'FSCustomAttributes',
};

final _hiddenTypes = Expando<bool>('type hidden expando');

extension HiddenElement on Element? {
  bool get isHidden {
    final element = this;
    if (element == null) return true;
    if (!element.mounted) return true;

    final cached = _hiddenTypes[element.widget.runtimeType];
    if (cached != null) return cached;

    final type = element.widget.runtimeType.toString();
    final hidden = type.startsWith('_') || hiddenElements.contains(type);

    _hiddenTypes[element.widget.runtimeType] = hidden;
    return hidden;
  }

  bool get isIncluded => !isHidden;
}
