/* standin.c -- the probe's C ABI (rnprobe_botlish.h, as libmode.tcl
   generates it) implemented in C, for telling a React Native integration
   failure from a Botlish one (REACT-NATIVE-TARGET-CENSUS.md): the same
   functions, statuses and error identity, no Botlish runtime. */
#include "rnprobe_botlish.h"

#include <stdlib.h>
#include <string.h>

static uint8_t *last;
static size_t last_len;
static const char *error_identity = "";
static const char *error_message = "";

void rnprobe_last_error(BotlishStr *identity, BotlishStr *message) {
  identity->ptr = (const uint8_t *)error_identity;
  identity->len = strlen(error_identity);
  message->ptr = (const uint8_t *)error_message;
  message->len = strlen(error_message);
}

int32_t rnprobe_add(int64_t a, int64_t b, int64_t *out) {
  if (__builtin_add_overflow(a, b, out)) return rnprobe_INT_RANGE;
  return rnprobe_OK;
}

/* Reverses by Unicode scalar value, as Botlish's str does. */
int32_t rnprobe_reverse(const uint8_t *s, size_t n, BotlishStr *out) {
  free(last);
  last = malloc(n ? n : 1);
  last_len = n;
  size_t i = 0;
  while (i < n) {
    size_t w = s[i] < 0x80 ? 1 : s[i] < 0xE0 ? 2 : s[i] < 0xF0 ? 3 : 4;
    if (i + w > n) return rnprobe_BAD_UTF8;
    memcpy(last + n - i - w, s + i, w);
    i += w;
  }
  out->ptr = last;
  out->len = last_len;
  return rnprobe_OK;
}

int32_t rnprobe_require_positive(int64_t n, int64_t *out) {
  if (n > 0) {
    *out = n;
    return rnprobe_OK;
  }
  error_identity = "NotPositive";
  error_message = "uncaught propagated error: <error NotPositive>";
  return rnprobe_ERROR;
}

int32_t rnprobe_depth(int64_t n, int64_t *out) {
  *out = n > 0 ? n : 0;
  return rnprobe_OK;
}

int32_t rnprobe_same(const uint8_t *a, size_t a_len, const uint8_t *b, size_t b_len, bool *out) {
  *out = a_len == b_len && memcmp(a, b, a_len) == 0;
  return rnprobe_OK;
}

int32_t rnprobe_pick(bool first, const uint8_t *a, size_t a_len, const uint8_t *b, size_t b_len, BotlishStr *out) {
  out->ptr = first ? a : b;
  out->len = first ? a_len : b_len;
  return rnprobe_OK;
}
