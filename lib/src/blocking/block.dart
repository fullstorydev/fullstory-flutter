import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:fullstory_flutter/src/encoder.dart';
import 'package:fullstory_flutter/src/logging.dart';
import 'package:fullstory_flutter/src/native.dart';
import 'package:fullstory_flutter/src/shared_flutter_bindings_generated.dart';
import 'package:fullstory_flutter/src/shared_flutter_bindings_generated.dart'
    as ffi
    show SelectorAttributes;

enum BlockType {
  excluded(false),
  masked(true),
  recorded(true),
  omitted(false),
  unmatched(false);

  final bool captureView;

  const BlockType(this.captureView);
}

class ViewBlocker {
  Pointer<BlockRulesHandle> _blockRulesHandle = nullptr;
  Pointer<ByteArray>? _blockRulesArrayPtr;

  Pointer<KeepRulesHandle> _keepRulesHandle = nullptr;
  Pointer<ByteArray>? _keepRulesArrayPtr;

  bool init(Map<String, Uint8List?> privacyRules) {
    if (ready) return true;

    final blockRules = privacyRules['blockRules'];
    if (blockRules == null) {
      Logger.log(
        LogLevel.warning,
        'ViewBlocker.init() failed: blockRules is null',
      );
      return false;
    }
    _blockRulesArrayPtr = _createByteArrayFromList(blockRules);
    _blockRulesHandle = encoderBindings.decode_block_rules(
      _blockRulesArrayPtr!.ref,
    );

    final keepRules = privacyRules['keepRules'];
    if (keepRules == null) {
      Logger.log(
        LogLevel.warning,
        'ViewBlocker.init() failed: keepRules is null',
      );
      return false;
    }
    _keepRulesArrayPtr = _createByteArrayFromList(keepRules);
    _keepRulesHandle = encoderBindings.decode_keep_rules(
      _keepRulesArrayPtr!.ref,
    );

    if (_blockRulesHandle == nullptr) {
      Logger.log(
        LogLevel.error,
        'ViewBlocker.init() failed: unable to parse block rules from privacy data',
      );
      return false;
    } else if (_keepRulesHandle == nullptr) {
      Logger.log(
        LogLevel.error,
        'ViewBlocker.init() failed: unable to parse keep rules from privacy data',
      );
      return false;
    }

    return ready;
  }

  bool initFromSession(Uint8List sessionData) {
    if (ready) return true;

    if (sessionData.isEmpty) {
      Logger.log(
        LogLevel.warning,
        'ViewBlocker.initFromSession() failed: sessionData is empty',
      );
      return false;
    }

    _blockRulesArrayPtr = _createByteArrayFromList(sessionData);
    _blockRulesHandle = encoderBindings.decode_block_rules_from_session_data(
      _blockRulesArrayPtr!.ref,
    );

    _keepRulesArrayPtr = _createByteArrayFromList(sessionData);
    _keepRulesHandle = encoderBindings.decode_keep_rules_from_session_data(
      _keepRulesArrayPtr!.ref,
    );

    if (_blockRulesHandle == nullptr) {
      Logger.log(
        LogLevel.error,
        'ViewBlocker.initFromSession() failed: unable to parse block rules from session data',
      );
      return false;
    } else if (_keepRulesHandle == nullptr) {
      Logger.log(
        LogLevel.error,
        'ViewBlocker.initFromSession() failed: unable to parse keep rules from session data',
      );
      return false;
    }

    return true;
  }

  bool get ready => _blockRulesHandle != nullptr && _keepRulesHandle != nullptr;

  Pointer<BlockRulesHandle> get _blockCheckedHandle =>
      _blockRulesHandle != nullptr
      ? _blockRulesHandle
      : (throw StateError(
          'Call ViewBlocker.init() before querying block type',
        ));

  Pointer<KeepRulesHandle> get _keepCheckedHandle => _keepRulesHandle != nullptr
      ? _keepRulesHandle
      : (throw StateError('Call ViewBlocker.init() before querying keep type'));

  void dispose() {
    if (_blockRulesHandle != nullptr) {
      encoderBindings.free_block_rules(_blockRulesHandle);
      _blockRulesHandle = nullptr;
    }

    if (_blockRulesArrayPtr != null) {
      encoderBindings.free_byte_array(_blockRulesArrayPtr!);
      _blockRulesArrayPtr = null;
    }

    if (_keepRulesHandle != nullptr) {
      encoderBindings.free_keep_rules(_keepRulesHandle);
      _keepRulesHandle = nullptr;
    }

    if (_keepRulesArrayPtr != null) {
      encoderBindings.free_byte_array(_keepRulesArrayPtr!);
      _keepRulesArrayPtr = null;
    }
  }

  Pointer<ByteArray> _createByteArrayFromList(Uint8List data) {
    final ptr = malloc<Uint8>(data.length);
    ptr.asTypedList(data.length).setAll(0, data);

    final byteArray = malloc<ByteArray>();
    byteArray.ref.ptr = ptr;
    byteArray.ref.len = data.length;
    byteArray.ref.capacity = data.length;
    byteArray.ref.finalized = false;
    byteArray.ref.delegated = true;
    return byteArray;
  }

  BlockType evalBlockTypeFor(
    List<SelectorAttributes> selectors, {
    required BlockType parentType,
    bool includeMatchedSelector = false,
    required bool consented,
  }) {
    if (selectors.isEmpty) return parentType;

    final selectorPtrs = malloc<Pointer<ffi.SelectorAttributes>>(
      selectors.length,
    );
    for (int i = 0; i < selectors.length; i++) {
      selectorPtrs[i] = selectors[i].toFfi();
    }

    Pointer<BlockResult> resultPtr = nullptr;
    try {
      resultPtr = encoderBindings.eval_view_path(
        _blockCheckedHandle,
        selectorPtrs,
        selectors.length,
        consented,
        includeMatchedSelector,
      );
      final result = resultPtr.ref;
      if (result.error != nullptr) {
        final errorMsg = result.error.cast<Utf8>().toDartString();
        throw FormatException(errorMsg);
      }
      final blockType = BlockType.values[result.block_type];

      if (includeMatchedSelector) {
        _logMatchedSelector(result, selectors, blockType);
      }

      return blockType == BlockType.unmatched ? parentType : blockType;
    } finally {
      if (resultPtr != nullptr) encoderBindings.free_eval_result(resultPtr);

      malloc.free(selectorPtrs);
    }
  }

  bool evalKeepRuleFor(
    List<SelectorAttributes> selectors, {
    required InputType inputType,
    bool includeMatchedSelector = false,
  }) {
    if (selectors.isEmpty) return false;

    final selectorPtrs = malloc<Pointer<ffi.SelectorAttributes>>(
      selectors.length,
    );
    for (int i = 0; i < selectors.length; i++) {
      selectorPtrs[i] = selectors[i].toFfi();
    }

    Pointer<KeepResult> resultPtr = nullptr;
    try {
      resultPtr = encoderBindings.eval_keep_rule(
        _keepCheckedHandle,
        inputType.keepType,
        selectorPtrs,
        selectors.length,
        includeMatchedSelector,
      );
      final result = resultPtr.ref;
      if (result.error != nullptr) {
        final errorMsg = result.error.cast<Utf8>().toDartString();
        Logger.log(
          LogLevel.error,
          'evalKeepRuleFor: error from native: $errorMsg',
        );
        throw FormatException(errorMsg);
      }
      final keep = result.matched;

      if (includeMatchedSelector) {
        _logMatchedKeepSelector(result, selectors, inputType);
      }

      return keep;
    } finally {
      if (resultPtr != nullptr) encoderBindings.free_keep_result(resultPtr);

      malloc.free(selectorPtrs);
    }
  }

  void _logMatchedSelector(
    BlockResult result,
    List<SelectorAttributes> views,
    BlockType blockType,
  ) {
    final selector = result.matched_selector != nullptr
        ? result.matched_selector.cast<Utf8>().toDartString()
        : '';

    if (selector.isNotEmpty) {
      Logger.log(
        LogLevel.note,
        'View ${views.last.tag} blocked by rule: $selector, set to $blockType',
      );
    } else {
      Logger.log(
        LogLevel.note,
        'View ${views.last.tag} not blocked by any rule, defaulting to parent type',
      );
    }
  }

  void _logMatchedKeepSelector(
    KeepResult result,
    List<SelectorAttributes> views,
    InputType inputType,
  ) {
    final selector = result.matched_selector != nullptr
        ? result.matched_selector.cast<Utf8>().toDartString()
        : '';

    if (selector.isNotEmpty) {
      Logger.log(
        LogLevel.note,
        'View ${views.last.tag} captured by rule: $selector, for input type $inputType',
      );
    } else {
      Logger.log(
        LogLevel.note,
        'View ${views.last.tag} not kept by any rule, defaulting to parent type',
      );
    }
  }
}

class SelectorAttributes implements Finalizable {
  final String tag;
  final Map<String, String> attributes;
  final List<String> classes;

  Pointer<ffi.SelectorAttributes>? _cached;
  final _finalizer = Finalizer<Pointer<ffi.SelectorAttributes>>(
    (ptr) => ptr.free(),
  );

  SelectorAttributes({
    required this.tag,
    this.attributes = const {},
    this.classes = const [],
  });
  Pointer<ffi.SelectorAttributes> toFfi() {
    if (_cached != null) return _cached!;

    final tagCstr = tag.toNativeUtf8();

    final classesPtr = classes.isNotEmpty
        ? malloc<Pointer<Utf8>>(classes.length)
        : nullptr;
    for (int i = 0; i < classes.length; i++) {
      classesPtr[i] = classes[i].toNativeUtf8();
    }

    final attrNamesPtr = attributes.isNotEmpty
        ? malloc<Pointer<Utf8>>(attributes.length)
        : nullptr;
    final attrValuesPtr = attributes.isNotEmpty
        ? malloc<Pointer<Utf8>>(attributes.length)
        : nullptr;
    for (final (i, entry) in attributes.entries.indexed) {
      attrNamesPtr[i] = entry.key.toNativeUtf8();
      attrValuesPtr[i] = entry.value.toNativeUtf8();
    }

    final ffiSelector = malloc<ffi.SelectorAttributes>();
    ffiSelector.ref
      ..tag = tagCstr.cast()
      ..classes = classesPtr.cast()
      ..classes_len = classes.length
      ..attr_names = attrNamesPtr.cast()
      ..attr_values = attrValuesPtr.cast()
      ..attrs_len = attributes.length;

    _finalizer.attach(this, ffiSelector);
    _cached = ffiSelector;

    return ffiSelector;
  }
}

extension FreeAttributes on Pointer<ffi.SelectorAttributes> {
  void free() {
    if (this == nullptr) return;

    if (ref.tag != nullptr) {
      malloc.free(ref.tag);
    }
    if (ref.classes != nullptr) {
      for (int i = 0; i < ref.classes_len; i++) {
        if (ref.classes[i] != nullptr) {
          malloc.free(ref.classes[i]);
        }
      }
      malloc.free(ref.classes);
    }
    if (ref.attr_names != nullptr) {
      for (int i = 0; i < ref.attrs_len; i++) {
        if (ref.attr_names[i] != nullptr) {
          malloc.free(ref.attr_names[i]);
        }
      }
      malloc.free(ref.attr_names);
    }
    if (ref.attr_values != nullptr) {
      for (int i = 0; i < ref.attrs_len; i++) {
        if (ref.attr_values[i] != nullptr) {
          malloc.free(ref.attr_values[i]);
        }
      }
      malloc.free(ref.attr_values);
    }
    malloc.free(this);
  }
}
