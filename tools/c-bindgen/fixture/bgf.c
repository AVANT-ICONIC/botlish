/* bgf.c -- the implementation of the binding generator's synthetic fixture
 * (include/bgf/bgf.h; C-BINDGEN.md, "The synthetic fixture"). Compiled
 * into libbgf.a by the generator's tests; the generator itself reads only
 * the header. Every function returns something its arguments determine, so
 * a Botlish caller of the generated binding and a C caller of the header
 * can be compared value for value. */
#include "bgf/bgf.h"

struct bgf_handle { int id; };
struct bgf_window_ { int id; };

static struct bgf_handle handles[2] = {{1}, {2}};
static struct bgf_window_ windows[2] = {{10}, {20}};
static bgf_handle *handle_list[3] = {&handles[0], &handles[1], 0};
static bgf_free_fn *saved_free;
static bgf_measure saved_measure;

int bgf_add(int a, int b) { return a + b; }

bgf_size bgf_length(const char *text) {
    bgf_size n = 0;
    while (text[n]) n++;
    return n;
}

bgf_u32 bgf_mix(bgf_u8 a, bgf_i16 b, bgf_u32 c, bgf_u64 d, long e, unsigned long long f) {
    return (bgf_u32)(a * 3u + (bgf_u32)b * 5u + c * 7u + (bgf_u32)d * 11u + (bgf_u32)e * 13u + (bgf_u32)f * 17u);
}

bgf_handle *bgf_open(const char *name, bgf_u32 flags) {
    return name[0] == 'a' ? &handles[flags & 1] : 0;
}

void bgf_close(bgf_handle *handle) { (void)handle; }

bgf_window *bgf_window_of(bgf_handle *handle) {
    return handle ? &windows[handle->id - 1] : 0;
}

int bgf_count(void) { return 2; }

char bgf_plain_char(char c) { return (char)(c + 1); }

bool bgf_is_even(int n) { return n % 2 == 0; }

bool bgf_flip(bool b) { return !b; }

bgf_color bgf_next_color(bgf_color c) {
    return c == BGF_RED ? BGF_GREEN : c == BGF_GREEN ? BGF_BLUE : BGF_RED;
}

int bgf_walk(bgf_handle *handle, bgf_visit visit, void *userdata) {
    return visit ? visit(userdata, handle, 1) : -1;
}

void bgf_set_free(bgf_free_fn *free_fn) { saved_free = free_fn; }

int bgf_point_sum(const bgf_point *point) { return point->x + point->y; }

int bgf_fill(unsigned char *out, size_t count, unsigned char seed) {
    for (size_t i = 0; i < count; i++) out[i] = (unsigned char)(seed + 37 * i);
    return (int)count;
}

int bgf_keywords(int fn, int type, int in, int loop, int str) {
    return fn * 10000 + type * 1000 + in * 100 + loop * 10 + str;
}

int bgf_unnamed(int n, const char *s) { return n + (s ? s[0] : 0); }

bgf_handle **bgf_handles(void) { return handle_list; }

unsigned char *bgf_digest(const unsigned char *data, size_t len, unsigned char out[4]) {
    unsigned char h[4] = {1, 2, 3, 4};
    for (size_t i = 0; i < len; i++) h[i % 4] = (unsigned char)(h[i % 4] * 31 + data[i]);
    for (int i = 0; i < 4; i++) out[i] = h[i];
    return out;
}

int bgf_labeled(int x) { return x * 3; }

int bgf_renamed(int x) { return x * 5; }

int bgf_current(int x) { return x * 7; }

double bgf_scale(double x, float y) { return x * y; }

bgf_pair bgf_swap(bgf_pair p) { bgf_pair q = {p.b, p.a}; return q; }

int bgf_printf(const char *format, ...) { (void)format; return 0; }

int bgf_vprintf(const char *format, va_list args) { (void)format; (void)args; return 0; }

void bgf_set_measure(bgf_measure measure) { saved_measure = measure; }

#if defined(__x86_64__)
int __attribute__((ms_abi)) bgf_ms(int x) { return x; }
#endif

void bgf_wide_set(bgf_wide w) { (void)w; }

int bgf_noproto() { return 0; }

void bgf_float_out(float *out) { *out = 1.5f; }

/* The table the bgf_get macro reads, and a same-named function that is not
 * the API: a binding that linked bgf_get directly would call this one. */
static int table_get(int x) { return x * 10; }
static const bgf_table table = { table_get };
const bgf_table *bgf_table_ptr = &table;
#undef bgf_get
int bgf_get(int x) { return -x; }

#if defined(__linux__)
int bgf_linux_only(void) { return 1; }
#endif
#if defined(__APPLE__)
int bgf_apple_only(void) { return 1; }
#endif
#if defined(__aarch64__)
int bgf_arm_only(void) { return 1; }
#endif
