import 'package:flutter/widgets.dart';

/// Allows annotation of [child] with [classes] and [attributes] to be shown in
/// Fullstory session replay.
///
/// Any classes or attributes set in this widget will be applied to the selector
/// for [child] when viewed in Fullstory.
class FSCustomAttributes extends StatelessWidget {
  final Widget child;
  final Map<String, String> attributes;
  final List<String> classes;

  const FSCustomAttributes({
    super.key,
    this.attributes = const {},
    this.classes = const [],
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
