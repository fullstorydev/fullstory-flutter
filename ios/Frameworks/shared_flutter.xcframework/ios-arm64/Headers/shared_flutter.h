#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

#define PLATFORM_ANDROID 1

#define PLATFORM_IOS 2

enum BlockType {
  Excluded,
  Masked,
  Recorded,
  Omitted,
  Unmatched,
};
typedef uint32_t BlockType;

/**
 * Opaque handle to write drawings to from FFI.
 */
typedef struct DrawingBundlerHandle DrawingBundlerHandle;

typedef struct BlockRulesHandle {
  uint8_t _priv[0];
} BlockRulesHandle;

typedef struct ByteArray {
  uint8_t *ptr;
  uintptr_t len;
  uintptr_t capacity;
  bool finalized;
  bool delegated;
} ByteArray;

typedef struct KeepRulesHandle {
  uint8_t _priv[0];
} KeepRulesHandle;

/**
 * The result of evaluating a view path for block type.
 *
 * In addition to the [block_type], this may contain an [error] string if
 * something went wrong, or the [matched_selector] string if requested.
 *
 * All strings are null-terminated, owned by the caller, and must be freed by
 * calling [free_eval_result].
 */
typedef struct BlockResult {
  BlockType block_type;
  char *error;
  char *matched_selector;
} BlockResult;

/**
 * Selector info for a view in the hierarchy, with CSS-like fields used to
 * determine its visibility in playback.
 *
 * Typically used in a list representing a path from
 * the root to the target view.
 */
typedef struct SelectorAttributes {
  const char *tag;
  const char *const *classes;
  uintptr_t classes_len;
  const char *const *attr_names;
  const char *const *attr_values;
  uintptr_t attrs_len;
} SelectorAttributes;

/**
 * The result of evaluating a view path for keep rule.
 *
 * In addition to the [matched], this may contain an [error] string if
 * something went wrong, or the [matched_selector] string if requested.
 *
 * All strings are null-terminated, owned by the caller, and must be freed by
 * calling [free_keep_result].
 */
typedef struct KeepResult {
  bool matched;
  char *error;
  char *matched_selector;
} KeepResult;

/**
 * Opaque handle to in-progress data for use with FFI.
 */
typedef struct DrawingHandle {
  uint8_t _priv[0];
} DrawingHandle;

/**
 * Opaque handle to in-progress data for use with FFI.
 */
typedef struct InProgressDataHandle {
  uint8_t _priv[0];
} InProgressDataHandle;

void dont_shake_me(void);

/**
 * Stores all of the block rules in memory and returns a handle to it.
 */
struct BlockRulesHandle *decode_block_rules(struct ByteArray data);

/**
 * Stores all of the keep rules in memory and returns a handle to it.
 */
struct KeepRulesHandle *decode_keep_rules(struct ByteArray data);

struct BlockRulesHandle *decode_block_rules_from_session_data(struct ByteArray data);

struct KeepRulesHandle *decode_keep_rules_from_session_data(struct ByteArray data);

/**
 * Fills a pre-allocated buffer with a randomized string of the same length as the input.
 * This eliminates the need for manual memory management on the Dart side.
 *
 * # Safety
 * - `s` must be a valid null-terminated C string
 * - `output_buffer` must be a valid pointer to a buffer of at least `buffer_size` bytes
 * - `buffer_size` must be at least as large as the input string length + 1 (for null terminator)
 *
 * Returns the number of characters written (excluding null terminator), or 0 on error.
 */
uintptr_t randomize_string(const char *s,
                           uint32_t render_object_hash,
                           char *output_buffer,
                           uintptr_t buffer_size);

/**
 * Evaluates the block type for a given view path.
 *
 * `include_matched_selector` may be set to include the matched selector string
 * for debugging, but avoid this in production builds.
 *
 * # Safety
 * The `handle` must be a valid pointer to a `BlockRulesHandle` created by
 * `decode_block_rules`. The `view_path_ptr` must be a valid pointer to an array
 * of `View` structs of length `view_path_len`.
 *
 * The caller is responsible for freeing the returned [EvalResult] and any
 * strings it contains.
 */
const struct BlockResult *eval_view_path(struct BlockRulesHandle *handle,
                                         const struct SelectorAttributes *const *view_path_ptr,
                                         uintptr_t view_path_len,
                                         bool consented,
                                         bool include_matched_selector);

/**
 * Evaluates whether a keep rule matches the given view path and event type.
 *
 * # Safety
 * The `handle` must be a valid pointer to a `KeepRulesHandle` created by
 * `decode_keep_rules` or `decode_keep_rules_from_session_data`. The `view_path_ptr`
 * must be a valid pointer to an array of `SelectorAttributes` of length `view_path_len`.
 */
const struct KeepResult *eval_keep_rule(struct KeepRulesHandle *handle,
                                        int16_t event_type,
                                        const struct SelectorAttributes *const *view_path_ptr,
                                        uintptr_t view_path_len,
                                        bool include_matched_selector);

/**
 * # Safety
 * Frees dart-held reference to in-progress data. Should only be called from a
 * dart finalizer or similar.
 */
void free_block_rules(struct BlockRulesHandle *data);

/**
 * # Safety
 * Frees dart-held reference to in-progress data. Should only be called from a
 * dart finalizer or similar.
 */
void free_keep_rules(struct KeepRulesHandle *data);

/**
 * # Safety
 * Frees dart-held EvalResult and any strings it contains.
 */
void free_eval_result(struct BlockResult *result);

/**
 * # Safety
 * Frees dart-held KeepResult and any strings it contains.
 */
void free_keep_result(struct KeepResult *result);

/**
 * Creates a DrawingBundler instance and returns a handle for later use
 */
struct DrawingBundlerHandle *create_drawing_bundler(void);

/**
 * Writes the passed drawing to the bundle using the passed view_id for
 * reference.
 *
 * # Safety
 * The `bundler_handle` and `drawing_handle` must point to valid `DrawingBundler`
 * and `Drawing` instances, respectively.
 */
uint32_t add_drawing_to_bundle(struct DrawingBundlerHandle *bundler_handle,
                               struct DrawingHandle *drawing_handle,
                               uint64_t view_id);

/**
 * Reads and returns the serialized drawing bundle data. Deallocates the
 * bundle once the read completes.
 *
 * # Safety
 * `bundler_handle` must point to a valid `DrawingBundler` returned by `create_drawing_bundler`.
 */
struct ByteArray *finish_bundle(struct DrawingBundlerHandle *bundler_handle);

/**
 * Reads and returns the serialized drawing bundle data. Does not deallocate
 * once complete.
 *
 * # Safety
 * `bundler_handle` must point to a valid `DrawingBundler` returned by `create_drawing_bundler`.
 */
struct ByteArray *read_bundle(struct DrawingBundlerHandle *bundler_handle);

void free_byte_array(struct ByteArray *byte_array);

struct ByteArray *canvas_definition(void);

/**
 * Starts a new drawing session and returns a handle to it.
 */
struct DrawingHandle *start_drawing(void);

/**
 * Converts the serialized drawing data for a given handle to a `ByteArray`.
 *
 * # Safety
 * The `handle` must be a valid pointer to a `DrawingHandle` created by `start_drawing`.
 */
struct ByteArray *get_drawing(struct DrawingHandle *handle);

/**
 * # Safety
 * Frees dart-held reference to in-progress data. Should only be called from a
 * dart finalizer or similar.
 */
void free_drawing(struct DrawingHandle *data);

/**
 * Adds a view ID to the drawing for the passed handle.
 *
 * # Safety
 * handle must be a valig pointer to a `DrawingHandle` created by `start_drawing`.
 */
void add_view_id(struct DrawingHandle *handle, uint32_t view_id);

/**
 * Clips the drawing to the specified rectangle.
 *
 * # Safety
 * handle must be a valid pointer to a `DrawingHandle` created by `start_drawing`.`
 */
void clip_rect(struct DrawingHandle *handle,
               int64_t left,
               int64_t top,
               int64_t right,
               int64_t bottom,
               uint8_t op);

/**
 * Draws a circle centered at (center_x, center_y) with the specified radius and color.
 *
 * # Safety
 * handle must be a valid pointer to a `DrawingHandle` created by `start_drawing`.
 */
void draw_circle(struct DrawingHandle *handle,
                 int64_t center_x,
                 int64_t center_y,
                 float radius,
                 uint8_t alpha,
                 uint8_t red,
                 uint8_t green,
                 uint8_t blue,
                 uint64_t paint_style);

/**
 * Draws a line from (start_x, start_y) to (end_x, end_y) with the specified color.
 *
 * # Safety
 * handle must be a valid pointer to a `DrawingHandle` created by `start_drawing`.
 */
void draw_line(struct DrawingHandle *handle,
               int64_t start_x,
               int64_t start_y,
               int64_t end_x,
               int64_t end_y,
               uint8_t alpha,
               uint8_t red,
               uint8_t green,
               uint8_t blue,
               uint64_t paint_style);

/**
 * Draws text at the specified position with the given properties.
 *
 * # Safety
 * handle must be a valid pointer to a `DrawingHandle` created by `start_drawing`.
 */
void draw_text(struct DrawingHandle *handle,
               uint64_t text_id,
               int64_t x,
               int64_t y,
               uint8_t alpha,
               uint8_t red,
               uint8_t green,
               uint8_t blue,
               float text_size,
               uint64_t text_style,
               uint64_t text_align,
               int64_t text_bounds_width,
               int64_t text_bounds_height,
               bool masked);

/**
 * Draws a rectangle with the specified bounds and color.
 *
 * # Safety
 * handle must be a valid pointer to a `DrawingHandle` created by `start_drawing`.
 */
void draw_rect(struct DrawingHandle *handle,
               int64_t left,
               int64_t top,
               int64_t right,
               int64_t bottom,
               uint8_t alpha,
               uint8_t red,
               uint8_t green,
               uint8_t blue,
               uint64_t paint_style);

/**
 * Draws a rounded rectangle with the specified radii and bounds.
 *
 * # Safety
 * handle must be a valid pointer to a `DrawingHandle` created by `start_drawing`.
 */
void draw_round_rect(struct DrawingHandle *handle,
                     int64_t radius_x,
                     int64_t radius_y,
                     int64_t left,
                     int64_t top,
                     int64_t right,
                     int64_t bottom,
                     uint8_t alpha,
                     uint8_t red,
                     uint8_t green,
                     uint8_t blue,
                     uint64_t paint_style);

/**
 * Sets a restore op on the drawing handle.
 *
 * # Safety
 * handle must be a valid pointer to a `DrawingHandle` created by `start_drawing`.`
 */
void restore(struct DrawingHandle *handle);

/**
 * Rotate the drawing by the specified angle in degrees.
 *
 * # Safety
 * handle must be a valid pointer to a `DrawingHandle` created by `start_drawing`.
 */
void rotate(struct DrawingHandle *handle, float degrees);

/**
 * Sets a save op on the drawing handle.
 *
 * # Safety
 * handle must be a valid pointer to a `DrawingHandle` created by `start_drawing`.
 */
void save(struct DrawingHandle *handle);

/**
 * Scales the drawing by the specified factors.
 * Y is optional will be ignored if skip_y is true.
 *
 * # Safety
 * handle must be a valid pointer to a `DrawingHandle` created by `start_drawing`.
 */
void scale(struct DrawingHandle *handle, float scale_x, float scale_y);

/**
 * translates the drawing by the specified x and y offsets.
 *
 * # Safety
 * handle must be a valid pointer to a `DrawingHandle` created by `start_drawing`.
 */
void translate(struct DrawingHandle *handle, float x, float y);

/**
 * # Safety
 * Frees dart-held reference to in-progress data. Should only be called from a
 * dart finalizer or similar.
 */
void free_in_progress_data(struct InProgressDataHandle *data);

/**
 * Initializes a buffer to capture arbitrary(ish) data to from Dart.
 * Returns a pointer that can be used to append data to the buffer.
 */
struct InProgressDataHandle *start_capture(unsigned int platform);

/**
 * Finishes the flatbuffer represented by `handle` from the root element
 * `root_id` and returns the resulting bytes.
 *
 * # Safety
 * The `handle` must be a valid pointer to an `InProgressDataHandle` created
 * by `start_capture`.
 */
struct ByteArray *finish_capture(struct InProgressDataHandle *handle, unsigned int root_id);

/**
 * Serializes view metadata information and returns the result as a ByteArray.
 *
 * # Safety
 *
 * The caller must pass a valid pointer to an array of length
 * `custom_attrs_len` as `custom_attrs`.
 */
unsigned int view_metadata(struct InProgressDataHandle *session_handle,
                           signed char alpha,
                           unsigned short flags1,
                           int view_class,
                           int8_t *custom_attrs,
                           uintptr_t custom_attrs_len,
                           BlockType block_type,
                           int x1,
                           int y1,
                           int x2,
                           int y2);

/**
 * Encodes a view within the view hierarchy.
 * View children are passed as an array of IDs from previous calls to `view`.
 *
 * # Safety
 * `session_handle` must be a valid pointer to an `InProgressDataHandle` created
 * by `start_capture`. The `children_ptr` must point to a valid array of `c_uint`
 * IDs, and `children_len` must match the length of that array.
 */
unsigned int view(struct InProgressDataHandle *session_handle,
                  unsigned long id,
                  bool view_cached,
                  bool children_cached,
                  int canvas,
                  unsigned int metadata,
                  unsigned int *children_ptr,
                  uintptr_t children_len,
                  unsigned int previous);

unsigned long view_id(const struct ByteArray *byte_array);
