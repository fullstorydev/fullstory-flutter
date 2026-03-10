import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:fullstory_flutter/custom_attributes.dart';
import 'package:fullstory_flutter/src/native.dart';
import 'package:fullstory_flutter/src/blocking/block.dart';
import 'package:fullstory_flutter/src/blocking/mask.dart';

export 'package:fullstory_flutter/custom_attributes.dart';
export 'package:fullstory_flutter/src/blocking/block.dart' show BlockType;

class AttributeTracker {



  final Expando<_Properties> _propertiesExpando;

  final NativeInterface _native;
  final Masker _masker;

  AttributeTracker(this._native, [Masker? masker])
    : _propertiesExpando = Expando("attributes expando"),
      _masker = masker ?? Masker();


  bool needsAccumulating(Element el) {

    if (_propertiesExpando[el] != null) return false;

    _propertiesExpando[el] = _Properties();
    return true;
  }

  _Properties _checkedPropertiesFor(Element el) {
    final properties = _propertiesExpando[el];
    if (properties == null) {
      throw StateError(
        'Attempting to access attributes for '
        'an Element ($el) that is not being tracked.',
      );
    }
    return properties;
  }




  void computeLabel(Element el) {
    final widget = el.widget;
    final properties = _checkedPropertiesFor(el);

    String? text;
    if (widget is RichText) {
      text = widget.text.toPlainText();
    } else if (widget is EditableText) {
      if (widget.obscureText) {
        text = '•' * widget.controller.text.length;
      } else {
        text = widget.controller.text;
      }
    }

    if (text != null && text.isNotEmpty) {
      properties.attributes['label'] = text;
    }
  }



  void updateLabelBlocking(Element el, BlockType blockType) {
    final properties = _checkedPropertiesFor(el);
    properties.blockType = blockType;
    if (properties.attributes['label'] == null) return;

    switch (blockType) {
      case BlockType.masked:
        properties.attributes['label'] = _masker.maskText(
          properties.attributes['label'] ?? '',
          el.renderObject.hashCode,
        );
      case BlockType.excluded:
      case BlockType.omitted:
      case BlockType.unmatched:
        properties.attributes.remove('label');
      case BlockType.recorded:
    }
  }

  void accumulateCustomAttributes(Element el, FSCustomAttributes attr) {
    final properties = _checkedPropertiesFor(el);
    properties.classes.addAll(attr.classes);

    final attributes = attr.attributes;
    for (final MapEntry(:key, :value) in attributes.entries) {
      if (key == "className") {
        properties.classes.addAll(value.split(" "));
      } else {
        properties.attributes[key] = value;
      }
    }
  }


  Map<String, String> attributesFor(Element element) =>
      _propertiesExpando[element]?.attributes ?? {};


  String? labelFor(Element element) {
    final properties = _propertiesExpando[element];
    if (properties == null || properties.blockType != BlockType.recorded) {
      return null;
    }

    return properties.attributes['label'];
  }




  SelectorAttributes selectorAttributesFor(Element el, String tag) {
    final properties = _propertiesExpando[el];
    if (properties == null) return SelectorAttributes(tag: tag);

    final selectorAttributes = properties.selectorAttributes;
    if (selectorAttributes != null) return selectorAttributes;

    final attributes = Map<String, String>.from(properties.attributes);
    final newAttributes = SelectorAttributes(
      tag: tag,
      attributes: attributes,
      classes: properties.classes.toList(),
    );
    properties.selectorAttributes = newAttributes;

    return newAttributes;
  }

  List<int> makeCustomAttrs(Element el) {
    final _Properties(:attributes, :classes) = _checkedPropertiesFor(el);

    final stringIds = <int>[];
    for (final MapEntry(:key, :value) in attributes.entries) {
      if (key == 'className') continue;

      stringIds.add(_native.recordString(key));
      stringIds.add(_native.recordString(value));
    }

    for (String clazz in classes) {
      stringIds.add(_native.recordString('className'));
      stringIds.add(_native.recordString(clazz));
    }

    List<int> varints = [];
    for (int id in stringIds) {
      while ((id & ~0x7F) != 0) {
        varints.add((id & 0x7F) | 0x80);
        id >>= 7;
      }
      varints.add(id);
    }

    return varints;
  }
}
class _Properties {

  final LinkedHashSet<String> classes = LinkedHashSet<String>();



  final Map<String, String> attributes = {};


  SelectorAttributes? selectorAttributes;
  BlockType blockType = BlockType.unmatched;
}
