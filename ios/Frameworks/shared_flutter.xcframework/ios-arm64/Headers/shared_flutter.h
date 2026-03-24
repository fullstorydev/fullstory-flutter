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

typedef struct BlockResult {
  BlockType block_type;
  char *error;
  char *matched_selector;
} BlockResult;

typedef struct SelectorAttributes {
  const char *tag;
  const char *const *classes;
  uintptr_t classes_len;
  const char *const *attr_names;
  const char *const *attr_values;
  uintptr_t attrs_len;
} SelectorAttributes;

typedef struct KeepResult {
  bool matched;
  char *error;
  char *matched_selector;
} KeepResult;

typedef struct DrawingHandle {
  uint8_t _priv[0];
} DrawingHandle;

typedef struct InProgressDataHandle {
  uint8_t _priv[0];
} InProgressDataHandle;

void dont_shake_me(void);

struct BlockRulesHandle *decode_block_rules(struct ByteArray data);

struct KeepRulesHandle *decode_keep_rules(struct ByteArray data);

struct BlockRulesHandle *decode_block_rules_from_session_data(struct ByteArray data);

struct KeepRulesHandle *decode_keep_rules_from_session_data(struct ByteArray data);

uintptr_t randomize_string(const char *s,
                           uint32_t render_object_hash,
                           char *output_buffer,
                           uintptr_t buffer_size);

const struct BlockResult *eval_view_path(struct BlockRulesHandle *handle,
                                         const struct SelectorAttributes *const *view_path_ptr,
                                         uintptr_t view_path_len,
                                         bool consented,
                                         bool include_matched_selector);

const struct KeepResult *eval_keep_rule(struct KeepRulesHandle *handle,
                                        int16_t event_type,
                                        const struct SelectorAttributes *const *view_path_ptr,
                                        uintptr_t view_path_len,
                                        bool include_matched_selector);

void free_block_rules(struct BlockRulesHandle *data);

void free_keep_rules(struct KeepRulesHandle *data);

void free_eval_result(struct BlockResult *result);

void free_keep_result(struct KeepResult *result);

struct DrawingBundlerHandle *create_drawing_bundler(void);

uint32_t add_drawing_to_bundle(struct DrawingBundlerHandle *bundler_handle,
                               struct DrawingHandle *drawing_handle,
                               uint64_t view_id);

struct ByteArray *finish_bundle(struct DrawingBundlerHandle *bundler_handle);

struct ByteArray *read_bundle(struct DrawingBundlerHandle *bundler_handle);

void free_byte_array(struct ByteArray *byte_array);

struct ByteArray *canvas_definition(void);

struct DrawingHandle *start_drawing(void);

struct ByteArray *get_drawing(struct DrawingHandle *handle);

void free_drawing(struct DrawingHandle *data);

void add_view_id(struct DrawingHandle *handle, uint32_t view_id);

void clip_rect(struct DrawingHandle *handle,
               int64_t left,
               int64_t top,
               int64_t right,
               int64_t bottom,
               uint8_t op);

void draw_circle(struct DrawingHandle *handle,
                 int64_t center_x,
                 int64_t center_y,
                 float radius,
                 uint8_t alpha,
                 uint8_t red,
                 uint8_t green,
                 uint8_t blue,
                 uint64_t paint_style);

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

void restore(struct DrawingHandle *handle);

void rotate(struct DrawingHandle *handle, float degrees);

void save(struct DrawingHandle *handle);

void scale(struct DrawingHandle *handle, float scale_x, float scale_y);

void translate(struct DrawingHandle *handle, float x, float y);

void free_in_progress_data(struct InProgressDataHandle *data);

struct InProgressDataHandle *start_capture(unsigned int platform);

struct ByteArray *finish_capture(struct InProgressDataHandle *handle, unsigned int root_id);

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
