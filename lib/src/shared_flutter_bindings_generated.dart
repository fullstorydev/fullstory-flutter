// ignore_for_file: always_specify_types
// ignore_for_file: camel_case_types
// ignore_for_file: non_constant_identifier_names



// ignore_for_file: type=lint
import 'dart:ffi' as ffi;



class EncoderBindings {
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
  _lookup;
  EncoderBindings(ffi.DynamicLibrary dynamicLibrary)
    : _lookup = dynamicLibrary.lookup;
  EncoderBindings.fromLookup(
    ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName) lookup,
  ) : _lookup = lookup;
  ffi.Pointer<BlockRulesHandle> decode_block_rules(ByteArray data) {
    return _decode_block_rules(data);
  }

  late final _decode_block_rulesPtr =
      _lookup<
        ffi.NativeFunction<ffi.Pointer<BlockRulesHandle> Function(ByteArray)>
      >('decode_block_rules');
  late final _decode_block_rules = _decode_block_rulesPtr
      .asFunction<ffi.Pointer<BlockRulesHandle> Function(ByteArray)>();
  ffi.Pointer<KeepRulesHandle> decode_keep_rules(ByteArray data) {
    return _decode_keep_rules(data);
  }

  late final _decode_keep_rulesPtr =
      _lookup<
        ffi.NativeFunction<ffi.Pointer<KeepRulesHandle> Function(ByteArray)>
      >('decode_keep_rules');
  late final _decode_keep_rules = _decode_keep_rulesPtr
      .asFunction<ffi.Pointer<KeepRulesHandle> Function(ByteArray)>();

  ffi.Pointer<BlockRulesHandle> decode_block_rules_from_session_data(
    ByteArray data,
  ) {
    return _decode_block_rules_from_session_data(data);
  }

  late final _decode_block_rules_from_session_dataPtr =
      _lookup<
        ffi.NativeFunction<ffi.Pointer<BlockRulesHandle> Function(ByteArray)>
      >('decode_block_rules_from_session_data');
  late final _decode_block_rules_from_session_data =
      _decode_block_rules_from_session_dataPtr
          .asFunction<ffi.Pointer<BlockRulesHandle> Function(ByteArray)>();

  ffi.Pointer<KeepRulesHandle> decode_keep_rules_from_session_data(
    ByteArray data,
  ) {
    return _decode_keep_rules_from_session_data(data);
  }

  late final _decode_keep_rules_from_session_dataPtr =
      _lookup<
        ffi.NativeFunction<ffi.Pointer<KeepRulesHandle> Function(ByteArray)>
      >('decode_keep_rules_from_session_data');
  late final _decode_keep_rules_from_session_data =
      _decode_keep_rules_from_session_dataPtr
          .asFunction<ffi.Pointer<KeepRulesHandle> Function(ByteArray)>();








  int randomize_string(
    ffi.Pointer<ffi.Char> s,
    int render_object_hash,
    ffi.Pointer<ffi.Char> output_buffer,
    int buffer_size,
  ) {
    return _randomize_string(s, render_object_hash, output_buffer, buffer_size);
  }

  late final _randomize_stringPtr =
      _lookup<
        ffi.NativeFunction<
          ffi.UintPtr Function(
            ffi.Pointer<ffi.Char>,
            ffi.Uint32,
            ffi.Pointer<ffi.Char>,
            ffi.UintPtr,
          )
        >
      >('randomize_string');
  late final _randomize_string = _randomize_stringPtr
      .asFunction<
        int Function(ffi.Pointer<ffi.Char>, int, ffi.Pointer<ffi.Char>, int)
      >();











  ffi.Pointer<BlockResult> eval_view_path(
    ffi.Pointer<BlockRulesHandle> handle,
    ffi.Pointer<ffi.Pointer<SelectorAttributes>> view_path_ptr,
    int view_path_len,
    bool consented,
    bool include_matched_selector,
  ) {
    return _eval_view_path(
      handle,
      view_path_ptr,
      view_path_len,
      consented,
      include_matched_selector,
    );
  }

  late final _eval_view_pathPtr =
      _lookup<
        ffi.NativeFunction<
          ffi.Pointer<BlockResult> Function(
            ffi.Pointer<BlockRulesHandle>,
            ffi.Pointer<ffi.Pointer<SelectorAttributes>>,
            ffi.UintPtr,
            ffi.Bool,
            ffi.Bool,
          )
        >
      >('eval_view_path');
  late final _eval_view_path = _eval_view_pathPtr
      .asFunction<
        ffi.Pointer<BlockResult> Function(
          ffi.Pointer<BlockRulesHandle>,
          ffi.Pointer<ffi.Pointer<SelectorAttributes>>,
          int,
          bool,
          bool,
        )
      >();





  ffi.Pointer<KeepResult> eval_keep_rule(
    ffi.Pointer<KeepRulesHandle> handle,
    int event_type,
    ffi.Pointer<ffi.Pointer<SelectorAttributes>> view_path_ptr,
    int view_path_len,
    bool include_matched_selector,
  ) {
    return _eval_keep_rule(
      handle,
      event_type,
      view_path_ptr,
      view_path_len,
      include_matched_selector,
    );
  }

  late final _eval_keep_rulePtr =
      _lookup<
        ffi.NativeFunction<
          ffi.Pointer<KeepResult> Function(
            ffi.Pointer<KeepRulesHandle>,
            ffi.Int16,
            ffi.Pointer<ffi.Pointer<SelectorAttributes>>,
            ffi.UintPtr,
            ffi.Bool,
          )
        >
      >('eval_keep_rule');
  late final _eval_keep_rule = _eval_keep_rulePtr
      .asFunction<
        ffi.Pointer<KeepResult> Function(
          ffi.Pointer<KeepRulesHandle>,
          int,
          ffi.Pointer<ffi.Pointer<SelectorAttributes>>,
          int,
          bool,
        )
      >();


  void free_block_rules(ffi.Pointer<BlockRulesHandle> data) {
    return _free_block_rules(data);
  }

  late final _free_block_rulesPtr =
      _lookup<
        ffi.NativeFunction<ffi.Void Function(ffi.Pointer<BlockRulesHandle>)>
      >('free_block_rules');
  late final _free_block_rules = _free_block_rulesPtr
      .asFunction<void Function(ffi.Pointer<BlockRulesHandle>)>();


  void free_keep_rules(ffi.Pointer<KeepRulesHandle> data) {
    return _free_keep_rules(data);
  }

  late final _free_keep_rulesPtr =
      _lookup<
        ffi.NativeFunction<ffi.Void Function(ffi.Pointer<KeepRulesHandle>)>
      >('free_keep_rules');
  late final _free_keep_rules = _free_keep_rulesPtr
      .asFunction<void Function(ffi.Pointer<KeepRulesHandle>)>();

  void free_eval_result(ffi.Pointer<BlockResult> result) {
    return _free_eval_result(result);
  }

  late final _free_eval_resultPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<BlockResult>)>>(
        'free_eval_result',
      );
  late final _free_eval_result = _free_eval_resultPtr
      .asFunction<void Function(ffi.Pointer<BlockResult>)>();

  void free_keep_result(ffi.Pointer<KeepResult> result) {
    return _free_keep_result(result);
  }

  late final _free_keep_resultPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<KeepResult>)>>(
        'free_keep_result',
      );
  late final _free_keep_result = _free_keep_resultPtr
      .asFunction<void Function(ffi.Pointer<KeepResult>)>();
  ffi.Pointer<DrawingBundlerHandle> create_drawing_bundler() {
    return _create_drawing_bundler();
  }

  late final _create_drawing_bundlerPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<DrawingBundlerHandle> Function()>>(
        'create_drawing_bundler',
      );
  late final _create_drawing_bundler = _create_drawing_bundlerPtr
      .asFunction<ffi.Pointer<DrawingBundlerHandle> Function()>();





  int add_drawing_to_bundle(
    ffi.Pointer<DrawingBundlerHandle> bundler_handle,
    ffi.Pointer<DrawingHandle> drawing_handle,
    int view_id,
  ) {
    return _add_drawing_to_bundle(bundler_handle, drawing_handle, view_id);
  }

  late final _add_drawing_to_bundlePtr =
      _lookup<
        ffi.NativeFunction<
          ffi.Uint32 Function(
            ffi.Pointer<DrawingBundlerHandle>,
            ffi.Pointer<DrawingHandle>,
            ffi.Uint64,
          )
        >
      >('add_drawing_to_bundle');
  late final _add_drawing_to_bundle = _add_drawing_to_bundlePtr
      .asFunction<
        int Function(
          ffi.Pointer<DrawingBundlerHandle>,
          ffi.Pointer<DrawingHandle>,
          int,
        )
      >();




  ffi.Pointer<ByteArray> finish_bundle(
    ffi.Pointer<DrawingBundlerHandle> bundler_handle,
  ) {
    return _finish_bundle(bundler_handle);
  }

  late final _finish_bundlePtr =
      _lookup<
        ffi.NativeFunction<
          ffi.Pointer<ByteArray> Function(ffi.Pointer<DrawingBundlerHandle>)
        >
      >('finish_bundle');
  late final _finish_bundle = _finish_bundlePtr
      .asFunction<
        ffi.Pointer<ByteArray> Function(ffi.Pointer<DrawingBundlerHandle>)
      >();




  ffi.Pointer<ByteArray> read_bundle(
    ffi.Pointer<DrawingBundlerHandle> bundler_handle,
  ) {
    return _read_bundle(bundler_handle);
  }

  late final _read_bundlePtr =
      _lookup<
        ffi.NativeFunction<
          ffi.Pointer<ByteArray> Function(ffi.Pointer<DrawingBundlerHandle>)
        >
      >('read_bundle');
  late final _read_bundle = _read_bundlePtr
      .asFunction<
        ffi.Pointer<ByteArray> Function(ffi.Pointer<DrawingBundlerHandle>)
      >();

  void free_byte_array(ffi.Pointer<ByteArray> byte_array) {
    return _free_byte_array(byte_array);
  }

  late final _free_byte_arrayPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ByteArray>)>>(
        'free_byte_array',
      );
  late final _free_byte_array = _free_byte_arrayPtr
      .asFunction<void Function(ffi.Pointer<ByteArray>)>();

  ffi.Pointer<ByteArray> canvas_definition() {
    return _canvas_definition();
  }

  late final _canvas_definitionPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ByteArray> Function()>>(
        'canvas_definition',
      );
  late final _canvas_definition = _canvas_definitionPtr
      .asFunction<ffi.Pointer<ByteArray> Function()>();
  ffi.Pointer<DrawingHandle> start_drawing() {
    return _start_drawing();
  }

  late final _start_drawingPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<DrawingHandle> Function()>>(
        'start_drawing',
      );
  late final _start_drawing = _start_drawingPtr
      .asFunction<ffi.Pointer<DrawingHandle> Function()>();



  ffi.Pointer<ByteArray> get_drawing(ffi.Pointer<DrawingHandle> handle) {
    return _get_drawing(handle);
  }

  late final _get_drawingPtr =
      _lookup<
        ffi.NativeFunction<
          ffi.Pointer<ByteArray> Function(ffi.Pointer<DrawingHandle>)
        >
      >('get_drawing');
  late final _get_drawing = _get_drawingPtr
      .asFunction<
        ffi.Pointer<ByteArray> Function(ffi.Pointer<DrawingHandle>)
      >();


  void free_drawing(ffi.Pointer<DrawingHandle> data) {
    return _free_drawing(data);
  }

  late final _free_drawingPtr =
      _lookup<
        ffi.NativeFunction<ffi.Void Function(ffi.Pointer<DrawingHandle>)>
      >('free_drawing');
  late final _free_drawing = _free_drawingPtr
      .asFunction<void Function(ffi.Pointer<DrawingHandle>)>();



  void add_view_id(ffi.Pointer<DrawingHandle> handle, int view_id) {
    return _add_view_id(handle, view_id);
  }

  late final _add_view_idPtr =
      _lookup<
        ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<DrawingHandle>, ffi.Uint32)
        >
      >('add_view_id');
  late final _add_view_id = _add_view_idPtr
      .asFunction<void Function(ffi.Pointer<DrawingHandle>, int)>();



  void clip_rect(
    ffi.Pointer<DrawingHandle> handle,
    int left,
    int top,
    int right,
    int bottom,
    int op,
  ) {
    return _clip_rect(handle, left, top, right, bottom, op);
  }

  late final _clip_rectPtr =
      _lookup<
        ffi.NativeFunction<
          ffi.Void Function(
            ffi.Pointer<DrawingHandle>,
            ffi.Int64,
            ffi.Int64,
            ffi.Int64,
            ffi.Int64,
            ffi.Uint8,
          )
        >
      >('clip_rect');
  late final _clip_rect = _clip_rectPtr
      .asFunction<
        void Function(ffi.Pointer<DrawingHandle>, int, int, int, int, int)
      >();



  void draw_circle(
    ffi.Pointer<DrawingHandle> handle,
    int center_x,
    int center_y,
    double radius,
    int alpha,
    int red,
    int green,
    int blue,
    int paint_style,
  ) {
    return _draw_circle(
      handle,
      center_x,
      center_y,
      radius,
      alpha,
      red,
      green,
      blue,
      paint_style,
    );
  }

  late final _draw_circlePtr =
      _lookup<
        ffi.NativeFunction<
          ffi.Void Function(
            ffi.Pointer<DrawingHandle>,
            ffi.Int64,
            ffi.Int64,
            ffi.Float,
            ffi.Uint8,
            ffi.Uint8,
            ffi.Uint8,
            ffi.Uint8,
            ffi.Uint64,
          )
        >
      >('draw_circle');
  late final _draw_circle = _draw_circlePtr
      .asFunction<
        void Function(
          ffi.Pointer<DrawingHandle>,
          int,
          int,
          double,
          int,
          int,
          int,
          int,
          int,
        )
      >();



  void draw_line(
    ffi.Pointer<DrawingHandle> handle,
    int start_x,
    int start_y,
    int end_x,
    int end_y,
    int alpha,
    int red,
    int green,
    int blue,
    int paint_style,
  ) {
    return _draw_line(
      handle,
      start_x,
      start_y,
      end_x,
      end_y,
      alpha,
      red,
      green,
      blue,
      paint_style,
    );
  }

  late final _draw_linePtr =
      _lookup<
        ffi.NativeFunction<
          ffi.Void Function(
            ffi.Pointer<DrawingHandle>,
            ffi.Int64,
            ffi.Int64,
            ffi.Int64,
            ffi.Int64,
            ffi.Uint8,
            ffi.Uint8,
            ffi.Uint8,
            ffi.Uint8,
            ffi.Uint64,
          )
        >
      >('draw_line');
  late final _draw_line = _draw_linePtr
      .asFunction<
        void Function(
          ffi.Pointer<DrawingHandle>,
          int,
          int,
          int,
          int,
          int,
          int,
          int,
          int,
          int,
        )
      >();



  void draw_text(
    ffi.Pointer<DrawingHandle> handle,
    int text_id,
    int x,
    int y,
    int alpha,
    int red,
    int green,
    int blue,
    double text_size,
    int text_style,
    int text_align,
    int text_bounds_width,
    int text_bounds_height,
    bool masked,
  ) {
    return _draw_text(
      handle,
      text_id,
      x,
      y,
      alpha,
      red,
      green,
      blue,
      text_size,
      text_style,
      text_align,
      text_bounds_width,
      text_bounds_height,
      masked,
    );
  }

  late final _draw_textPtr =
      _lookup<
        ffi.NativeFunction<
          ffi.Void Function(
            ffi.Pointer<DrawingHandle>,
            ffi.Uint64,
            ffi.Int64,
            ffi.Int64,
            ffi.Uint8,
            ffi.Uint8,
            ffi.Uint8,
            ffi.Uint8,
            ffi.Float,
            ffi.Uint64,
            ffi.Uint64,
            ffi.Int64,
            ffi.Int64,
            ffi.Bool,
          )
        >
      >('draw_text');
  late final _draw_text = _draw_textPtr
      .asFunction<
        void Function(
          ffi.Pointer<DrawingHandle>,
          int,
          int,
          int,
          int,
          int,
          int,
          int,
          double,
          int,
          int,
          int,
          int,
          bool,
        )
      >();



  void draw_rect(
    ffi.Pointer<DrawingHandle> handle,
    int left,
    int top,
    int right,
    int bottom,
    int alpha,
    int red,
    int green,
    int blue,
    int paint_style,
  ) {
    return _draw_rect(
      handle,
      left,
      top,
      right,
      bottom,
      alpha,
      red,
      green,
      blue,
      paint_style,
    );
  }

  late final _draw_rectPtr =
      _lookup<
        ffi.NativeFunction<
          ffi.Void Function(
            ffi.Pointer<DrawingHandle>,
            ffi.Int64,
            ffi.Int64,
            ffi.Int64,
            ffi.Int64,
            ffi.Uint8,
            ffi.Uint8,
            ffi.Uint8,
            ffi.Uint8,
            ffi.Uint64,
          )
        >
      >('draw_rect');
  late final _draw_rect = _draw_rectPtr
      .asFunction<
        void Function(
          ffi.Pointer<DrawingHandle>,
          int,
          int,
          int,
          int,
          int,
          int,
          int,
          int,
          int,
        )
      >();



  void draw_round_rect(
    ffi.Pointer<DrawingHandle> handle,
    int radius_x,
    int radius_y,
    int left,
    int top,
    int right,
    int bottom,
    int alpha,
    int red,
    int green,
    int blue,
    int paint_style,
  ) {
    return _draw_round_rect(
      handle,
      radius_x,
      radius_y,
      left,
      top,
      right,
      bottom,
      alpha,
      red,
      green,
      blue,
      paint_style,
    );
  }

  late final _draw_round_rectPtr =
      _lookup<
        ffi.NativeFunction<
          ffi.Void Function(
            ffi.Pointer<DrawingHandle>,
            ffi.Int64,
            ffi.Int64,
            ffi.Int64,
            ffi.Int64,
            ffi.Int64,
            ffi.Int64,
            ffi.Uint8,
            ffi.Uint8,
            ffi.Uint8,
            ffi.Uint8,
            ffi.Uint64,
          )
        >
      >('draw_round_rect');
  late final _draw_round_rect = _draw_round_rectPtr
      .asFunction<
        void Function(
          ffi.Pointer<DrawingHandle>,
          int,
          int,
          int,
          int,
          int,
          int,
          int,
          int,
          int,
          int,
          int,
        )
      >();



  void restore(ffi.Pointer<DrawingHandle> handle) {
    return _restore(handle);
  }

  late final _restorePtr =
      _lookup<
        ffi.NativeFunction<ffi.Void Function(ffi.Pointer<DrawingHandle>)>
      >('restore');
  late final _restore = _restorePtr
      .asFunction<void Function(ffi.Pointer<DrawingHandle>)>();



  void rotate(ffi.Pointer<DrawingHandle> handle, double degrees) {
    return _rotate(handle, degrees);
  }

  late final _rotatePtr =
      _lookup<
        ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<DrawingHandle>, ffi.Float)
        >
      >('rotate');
  late final _rotate = _rotatePtr
      .asFunction<void Function(ffi.Pointer<DrawingHandle>, double)>();



  void save(ffi.Pointer<DrawingHandle> handle) {
    return _save(handle);
  }

  late final _savePtr =
      _lookup<
        ffi.NativeFunction<ffi.Void Function(ffi.Pointer<DrawingHandle>)>
      >('save');
  late final _save = _savePtr
      .asFunction<void Function(ffi.Pointer<DrawingHandle>)>();




  void scale(
    ffi.Pointer<DrawingHandle> handle,
    double scale_x,
    double scale_y,
  ) {
    return _scale(handle, scale_x, scale_y);
  }

  late final _scalePtr =
      _lookup<
        ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<DrawingHandle>, ffi.Float, ffi.Float)
        >
      >('scale');
  late final _scale = _scalePtr
      .asFunction<void Function(ffi.Pointer<DrawingHandle>, double, double)>();



  void translate(ffi.Pointer<DrawingHandle> handle, double x, double y) {
    return _translate(handle, x, y);
  }

  late final _translatePtr =
      _lookup<
        ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<DrawingHandle>, ffi.Float, ffi.Float)
        >
      >('translate');
  late final _translate = _translatePtr
      .asFunction<void Function(ffi.Pointer<DrawingHandle>, double, double)>();


  void free_in_progress_data(ffi.Pointer<InProgressDataHandle> data) {
    return _free_in_progress_data(data);
  }

  late final _free_in_progress_dataPtr =
      _lookup<
        ffi.NativeFunction<ffi.Void Function(ffi.Pointer<InProgressDataHandle>)>
      >('free_in_progress_data');
  late final _free_in_progress_data = _free_in_progress_dataPtr
      .asFunction<void Function(ffi.Pointer<InProgressDataHandle>)>();

  ffi.Pointer<InProgressDataHandle> start_capture(int platform) {
    return _start_capture(platform);
  }

  late final _start_capturePtr =
      _lookup<
        ffi.NativeFunction<
          ffi.Pointer<InProgressDataHandle> Function(ffi.UnsignedInt)
        >
      >('start_capture');
  late final _start_capture = _start_capturePtr
      .asFunction<ffi.Pointer<InProgressDataHandle> Function(int)>();





  ffi.Pointer<ByteArray> finish_capture(
    ffi.Pointer<InProgressDataHandle> handle,
    int root_id,
  ) {
    return _finish_capture(handle, root_id);
  }

  late final _finish_capturePtr =
      _lookup<
        ffi.NativeFunction<
          ffi.Pointer<ByteArray> Function(
            ffi.Pointer<InProgressDataHandle>,
            ffi.UnsignedInt,
          )
        >
      >('finish_capture');
  late final _finish_capture = _finish_capturePtr
      .asFunction<
        ffi.Pointer<ByteArray> Function(ffi.Pointer<InProgressDataHandle>, int)
      >();





  int view_metadata(
    ffi.Pointer<InProgressDataHandle> session_handle,
    int alpha,
    int flags1,
    int view_class,
    ffi.Pointer<ffi.Int8> custom_attrs,
    int custom_attrs_len,
    int block_type,
    int x1,
    int y1,
    int x2,
    int y2,
  ) {
    return _view_metadata(
      session_handle,
      alpha,
      flags1,
      view_class,
      custom_attrs,
      custom_attrs_len,
      block_type,
      x1,
      y1,
      x2,
      y2,
    );
  }

  late final _view_metadataPtr =
      _lookup<
        ffi.NativeFunction<
          ffi.UnsignedInt Function(
            ffi.Pointer<InProgressDataHandle>,
            ffi.SignedChar,
            ffi.UnsignedShort,
            ffi.Int,
            ffi.Pointer<ffi.Int8>,
            ffi.UintPtr,
            ffi.Uint32,
            ffi.Int,
            ffi.Int,
            ffi.Int,
            ffi.Int,
          )
        >
      >('view_metadata');
  late final _view_metadata = _view_metadataPtr
      .asFunction<
        int Function(
          ffi.Pointer<InProgressDataHandle>,
          int,
          int,
          int,
          ffi.Pointer<ffi.Int8>,
          int,
          int,
          int,
          int,
          int,
          int,
        )
      >();






  int view(
    ffi.Pointer<InProgressDataHandle> session_handle,
    int id,
    bool view_cached,
    bool children_cached,
    int canvas,
    int metadata,
    ffi.Pointer<ffi.UnsignedInt> children_ptr,
    int children_len,
    int previous,
  ) {
    return _view(
      session_handle,
      id,
      view_cached,
      children_cached,
      canvas,
      metadata,
      children_ptr,
      children_len,
      previous,
    );
  }

  late final _viewPtr =
      _lookup<
        ffi.NativeFunction<
          ffi.UnsignedInt Function(
            ffi.Pointer<InProgressDataHandle>,
            ffi.UnsignedLong,
            ffi.Bool,
            ffi.Bool,
            ffi.Int,
            ffi.UnsignedInt,
            ffi.Pointer<ffi.UnsignedInt>,
            ffi.UintPtr,
            ffi.UnsignedInt,
          )
        >
      >('view');
  late final _view = _viewPtr
      .asFunction<
        int Function(
          ffi.Pointer<InProgressDataHandle>,
          int,
          bool,
          bool,
          int,
          int,
          ffi.Pointer<ffi.UnsignedInt>,
          int,
          int,
        )
      >();

  int view_id(ffi.Pointer<ByteArray> byte_array) {
    return _view_id(byte_array);
  }

  late final _view_idPtr =
      _lookup<
        ffi.NativeFunction<ffi.UnsignedLong Function(ffi.Pointer<ByteArray>)>
      >('view_id');
  late final _view_id = _view_idPtr
      .asFunction<int Function(ffi.Pointer<ByteArray>)>();

  late final addresses = _SymbolAddresses(this);
}

class _SymbolAddresses {
  final EncoderBindings _library;
  _SymbolAddresses(this._library);
  ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ByteArray>)>>
  get free_byte_array => _library._free_byte_arrayPtr;
  ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<DrawingHandle>)>>
  get free_drawing => _library._free_drawingPtr;
  ffi.Pointer<
    ffi.NativeFunction<ffi.Void Function(ffi.Pointer<InProgressDataHandle>)>
  >
  get free_in_progress_data => _library._free_in_progress_dataPtr;
}

final class DrawingBundlerHandle extends ffi.Opaque {}

final class BlockRulesHandle extends ffi.Opaque {}

final class ByteArray extends ffi.Struct {
  external ffi.Pointer<ffi.Uint8> ptr;

  @ffi.UintPtr()
  external int len;

  @ffi.UintPtr()
  external int capacity;

  @ffi.Bool()
  external bool finalized;

  @ffi.Bool()
  external bool delegated;
}

final class KeepRulesHandle extends ffi.Opaque {}






final class BlockResult extends ffi.Struct {
  @ffi.Uint32()
  external int block_type;

  external ffi.Pointer<ffi.Char> error;

  external ffi.Pointer<ffi.Char> matched_selector;
}




final class SelectorAttributes extends ffi.Struct {
  external ffi.Pointer<ffi.Char> tag;

  external ffi.Pointer<ffi.Pointer<ffi.Char>> classes;

  @ffi.UintPtr()
  external int classes_len;

  external ffi.Pointer<ffi.Pointer<ffi.Char>> attr_names;

  external ffi.Pointer<ffi.Pointer<ffi.Char>> attr_values;

  @ffi.UintPtr()
  external int attrs_len;
}






final class KeepResult extends ffi.Struct {
  @ffi.Bool()
  external bool matched;

  external ffi.Pointer<ffi.Char> error;

  external ffi.Pointer<ffi.Char> matched_selector;
}
final class DrawingHandle extends ffi.Opaque {}
final class InProgressDataHandle extends ffi.Opaque {}
