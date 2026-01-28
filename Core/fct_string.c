/**
 * @file fct_string.c
 * @brief String utilities for FightCityTickets
 *
 * Provides memory-efficient string operations with reference counting
 * for reduced memory allocations.
 *
 * Author: FightCityTickets Team
 * Version: 1.0.0
 */

#include "fct_string.h"
#include "fct_memory.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <stdarg.h>

/*============================================================================
 * String Implementation
 *============================================================================*/

static size_t fct_string_calculate_capacity(size_t min_capacity) {
    /* Grow by at least 50% and round to power of 2 for efficiency */
    size_t capacity = 16;
    while (capacity < min_capacity) {
        capacity *= 2;
    }
    return capacity;
}

fct_string_t* fct_string_create_empty(void) {
    return fct_string_create_with_capacity(16);
}

fct_string_t* fct_string_create_with_capacity(size_t capacity) {
    fct_string_t* str = (fct_string_t*)fct_alloc(sizeof(fct_string_t));
    if (!str) return NULL;
    
    capacity = fct_string_calculate_capacity(capacity);
    str->data = (char*)fct_alloc(capacity);
    if (!str->data) {
        fct_free(str);
        return NULL;
    }
    
    str->data[0] = '\0';
    str->length = 0;
    str->capacity = capacity;
    str->ref_count = 1;
    
    return str;
}

fct_string_t* fct_string_create(const char* cstr) {
    if (!cstr) return fct_string_create_empty();
    
    size_t len = strlen(cstr);
    fct_string_t* str = fct_string_create_with_capacity(len + 1);
    if (!str) return NULL;
    
    memcpy(str->data, cstr, len + 1);
    str->length = len;
    
    return str;
}

fct_string_t* fct_string_create_with_length(const char* data, size_t len) {
    if (!data || len == 0) return fct_string_create_empty();
    
    fct_string_t* str = fct_string_create_with_capacity(len + 1);
    if (!str) return NULL;
    
    memcpy(str->data, data, len);
    str->data[len] = '\0';
    str->length = len;
    
    return str;
}

fct_string_t* fct_string_create_from_slice(fct_string_slice_t slice) {
    return fct_string_create_with_length(slice.data, slice.length);
}

fct_string_t* fct_string_copy(const fct_string_t* str) {
    if (!str) return NULL;
    
    fct_string_t* copy = fct_string_create_with_capacity(str->length + 1);
    if (!copy) return NULL;
    
    memcpy(copy->data, str->data, str->length + 1);
    copy->length = str->length;
    
    return copy;
}

fct_string_t* fct_string_ref(fct_string_t* str) {
    if (!str) return NULL;
    str->ref_count++;
    return str;
}

void fct_string_unref(fct_string_t* str) {
    if (!str) return;
    
    str->ref_count--;
    if (str->ref_count <= 0) {
        fct_free(str->data);
        fct_free(str);
    }
}

static fct_result_t fct_string_ensure_capacity(fct_string_t* str, size_t additional) {
    if (!str) return FCT_RESULT_NULL_POINTER;
    
    size_t required = str->length + additional + 1;
    if (required <= str->capacity) {
        return FCT_RESULT_OK;
    }
    
    size_t new_capacity = fct_string_calculate_capacity(required);
    char* new_data = (char*)fct_realloc(str->data, new_capacity);
    if (!new_data) {
        return FCT_RESULT_OUT_OF_MEMORY;
    }
    
    str->data = new_data;
    str->capacity = new_capacity;
    
    return FCT_RESULT_OK;
}

fct_result_t fct_string_append(fct_string_t* str, const char* cstr) {
    if (!str || !cstr) return FCT_RESULT_NULL_POINTER;
    
    size_t add_len = strlen(cstr);
    fct_result_t result = fct_string_ensure_capacity(str, add_len);
    if (result != FCT_RESULT_OK) {
        return result;
    }
    
    memcpy(str->data + str->length, cstr, add_len + 1);
    str->length += add_len;
    
    return FCT_RESULT_OK;
}

fct_result_t fct_string_append_char(fct_string_t* str, char c) {
    if (!str) return FCT_RESULT_NULL_POINTER;
    
    fct_result_t result = fct_string_ensure_capacity(str, 1);
    if (result != FCT_RESULT_OK) {
        return result;
    }
    
    str->data[str->length] = c;
    str->data[str->length + 1] = '\0';
    str->length++;
    
    return FCT_RESULT_OK;
}

fct_result_t fct_string_append_string(fct_string_t* str, const fct_string_t* other) {
    if (!str || !other) return FCT_RESULT_NULL_POINTER;
    return fct_string_append(str, other->data);
}

fct_result_t fct_string_append_slice(fct_string_t* str, fct_string_slice_t slice) {
    if (!str || !slice.data) return FCT_RESULT_NULL_POINTER;
    
    fct_result_t result = fct_string_ensure_capacity(str, slice.length);
    if (result != FCT_RESULT_OK) {
        return result;
    }
    
    memcpy(str->data + str->length, slice.data, slice.length);
    str->data[str->length + slice.length] = '\0';
    str->length += slice.length;
    
    return FCT_RESULT_OK;
}

fct_result_t fct_string_vappendf(fct_string_t* str, const char* format, va_list args) {
    if (!str || !format) return FCT_RESULT_NULL_POINTER;
    
    va_list args_copy;
    va_copy(args_copy, args);
    
    /* Calculate required size */
    int needed = vsnprintf(NULL, 0, format, args_copy);
    va_end(args_copy);
    
    if (needed < 0) {
        return FCT_RESULT_INVALID_ARGUMENT;
    }
    
    fct_result_t result = fct_string_ensure_capacity(str, needed);
    if (result != FCT_RESULT_OK) {
        return result;
    }
    
    /* Format the string */
    va_copy(args_copy, args);
    vsnprintf(str->data + str->length, str->capacity - str->length, format, args_copy);
    va_end(args_copy);
    
    str->length += needed;
    
    return FCT_RESULT_OK;
}

fct_result_t fct_string_appendf(fct_string_t* str, const char* format, ...) {
    if (!str || !format) return FCT_RESULT_NULL_POINTER;
    
    va_list args;
    va_start(args, format);
    fct_result_t result = fct_string_vappendf(str, format, args);
    va_end(args);
    
    return result;
}

fct_result_t fct_string_prepend(fct_string_t* str, const char* cstr) {
    if (!str || !cstr) return FCT_RESULT_NULL_POINTER;
    
    size_t add_len = strlen(cstr);
    fct_result_t result = fct_string_ensure_capacity(str, add_len);
    if (result != FCT_RESULT_OK) {
        return result;
    }
    
    /* Shift existing content */
    memmove(str->data + add_len, str->data, str->length + 1);
    
    /* Copy new content */
    memcpy(str->data, cstr, add_len);
    str->length += add_len;
    
    return FCT_RESULT_OK;
}

fct_result_t fct_string_insert(fct_string_t* str, size_t pos, const char* cstr) {
    if (!str || !cstr) return FCT_RESULT_NULL_POINTER;
    if (pos > str->length) return FCT_RESULT_INVALID_ARGUMENT;
    
    size_t add_len = strlen(cstr);
    fct_result_t result = fct_string_ensure_capacity(str, add_len);
    if (result != FCT_RESULT_OK) {
        return result;
    }
    
    /* Shift content after position */
    memmove(str->data + pos + add_len, str->data + pos, str->length - pos + 1);
    
    /* Copy new content */
    memcpy(str->data + pos, cstr, add_len);
    str->length += add_len;
    
    return FCT_RESULT_OK;
}

fct_result_t fct_string_erase(fct_string_t* str, size_t pos, size_t len) {
    if (!str) return FCT_RESULT_NULL_POINTER;
    if (pos > str->length) return FCT_RESULT_INVALID_ARGUMENT;
    
    size_t remove_len = (pos + len > str->length) ? (str->length - pos) : len;
    
    memmove(str->data + pos, str->data + pos + remove_len, 
            str->length - pos - remove_len + 1);
    str->length -= remove_len;
    
    return FCT_RESULT_OK;
}

fct_result_t fct_string_clear(fct_string_t* str) {
    if (!str) return FCT_RESULT_NULL_POINTER;
    str->data[0] = '\0';
    str->length = 0;
    return FCT_RESULT_OK;
}

fct_result_t fct_string_trim(fct_string_t* str) {
    if (!str || str->length == 0) return FCT_RESULT_NULL_POINTER;
    
    char* start = str->data;
    char* end = str->data + str->length - 1;
    
    /* Trim leading whitespace */
    while (start <= end && isspace((unsigned char)*start)) {
        start++;
    }
    
    /* Trim trailing whitespace */
    while (end >= start && isspace((unsigned char)*end)) {
        end--;
    }
    
    /* Calculate new length */
    size_t new_length = (end >= start) ? (end - start + 1) : 0;
    
    if (start != str->data) {
        memmove(str->data, start, new_length);
    }
    
    str->data[new_length] = '\0';
    str->length = new_length;
    
    return FCT_RESULT_OK;
}

fct_result_t fct_string_resize(fct_string_t* str, size_t new_size, char fill) {
    if (!str) return FCT_RESULT_NULL_POINTER;
    
    if (new_size > str->length) {
        fct_result_t result = fct_string_ensure_capacity(str, new_size - str->length);
        if (result != FCT_RESULT_OK) {
            return result;
        }
        memset(str->data + str->length, fill, new_size - str->length);
    }
    
    str->data[new_size] = '\0';
    str->length = new_size;
    
    return FCT_RESULT_OK;
}

/*============================================================================
 * String Accessors
 *============================================================================*/

const char* fct_string_cstr(const fct_string_t* str) {
    return str ? str->data : "";
}

size_t fct_string_length(const fct_string_t* str) {
    return str ? str->length : 0;
}

size_t fct_string_capacity(const fct_string_t* str) {
    return str ? str->capacity : 0;
}

bool fct_string_empty(const fct_string_t* str) {
    return !str || str->length == 0;
}

bool fct_string_equal(const fct_string_t* a, const fct_string_t* b) {
    if (a == b) return true;
    if (!a || !b) return false;
    return a->length == b->length && memcmp(a->data, b->data, a->length) == 0;
}

bool fct_string_equal_cstr(const fct_string_t* str, const char* cstr) {
    if (!str || !cstr) return false;
    return strcmp(str->data, cstr) == 0;
}

int fct_string_compare(const fct_string_t* a, const fct_string_t* b) {
    if (!a && !b) return 0;
    if (!a) return -1;
    if (!b) return 1;
    
    size_t min_len = a->length < b->length ? a->length : b->length;
    int cmp = memcmp(a->data, b->data, min_len);
    
    if (cmp != 0) return cmp;
    if (a->length == b->length) return 0;
    return a->length < b->length ? -1 : 1;
}

int fct_string_compare_cstr(const fct_string_t* str, const char* cstr) {
    if (!str || !cstr) return str ? 1 : (cstr ? -1 : 0);
    return strcmp(str->data, cstr);
}

int fct_string_case_compare(const fct_string_t* a, const fct_string_t* b) {
    if (!a && !b) return 0;
    if (!a) return -1;
    if (!b) return 1;
    
    size_t min_len = a->length < b->length ? a->length : b->length;
    
    for (size_t i = 0; i < min_len; i++) {
        int ca = tolower((unsigned char)a->data[i]);
        int cb = tolower((unsigned char)b->data[i]);
        if (ca != cb) return ca - cb;
    }
    
    if (a->length == b->length) return 0;
    return a->length < b->length ? -1 : 1;
}

char fct_string_char_at(const fct_string_t* str, size_t index) {
    if (!str || index >= str->length) return '\0';
    return str->data[index];
}

fct_string_slice_t fct_string_slice(const fct_string_t* str, size_t pos, size_t len) {
    fct_string_slice_t slice = {NULL, 0};
    if (!str || pos >= str->length) return slice;
    
    slice.data = str->data + pos;
    slice.length = (pos + len > str->length) ? (str->length - pos) : len;
    
    return slice;
}

fct_string_t* fct_string_substring(const fct_string_t* str, size_t pos, size_t len) {
    fct_string_slice_t slice = fct_string_slice(str, pos, len);
    return fct_string_create_from_slice(slice);
}

/*============================================================================
 * String Search
 *============================================================================*/

size_t fct_string_find(const fct_string_t* str, const char* needle) {
    if (!str || !needle || !*needle) return FCT_STRING_NOT_FOUND;
    
    char* found = strstr(str->data, needle);
    return found ? (size_t)(found - str->data) : FCT_STRING_NOT_FOUND;
}

size_t fct_string_find_char(const fct_string_t* str, char c) {
    if (!str) return FCT_STRING_NOT_FOUND;
    
    char* found = strchr(str->data, c);
    return found ? (size_t)(found - str->data) : FCT_STRING_NOT_FOUND;
}

size_t fct_string_rfind(const fct_string_t* str, const char* needle) {
    if (!str || !needle || !*needle) return FCT_STRING_NOT_FOUND;
    
    char* found = NULL;
    char* current = str->data;
    
    while ((current = strstr(current, needle)) != NULL) {
        found = current;
        current++;
    }
    
    return found ? (size_t)(found - str->data) : FCT_STRING_NOT_FOUND;
}

bool fct_string_contains(const fct_string_t* str, const char* needle) {
    return fct_string_find(str, needle) != FCT_STRING_NOT_FOUND;
}

bool fct_string_starts_with(const fct_string_t* str, const char* prefix) {
    if (!str || !prefix) return false;
    size_t prefix_len = strlen(prefix);
    if (str->length < prefix_len) return false;
    return memcmp(str->data, prefix, prefix_len) == 0;
}

bool fct_string_ends_with(const fct_string_t* str, const char* suffix) {
    if (!str || !suffix) return false;
    size_t suffix_len = strlen(suffix);
    if (str->length < suffix_len) return false;
    return memcmp(str->data + str->length - suffix_len, suffix, suffix_len) == 0;
}

/*============================================================================
 * String Transform
 *============================================================================*/

fct_string_t* fct_string_to_upper(const fct_string_t* str) {
    if (!str) return NULL;
    
    fct_string_t* result = fct_string_create_with_capacity(str->capacity);
    if (!result) return NULL;
    
    for (size_t i = 0; i < str->length; i++) {
        result->data[i] = (char)toupper((unsigned char)str->data[i]);
    }
    result->data[str->length] = '\0';
    result->length = str->length;
    
    return result;
}

fct_string_t* fct_string_to_lower(const fct_string_t* str) {
    if (!str) return NULL;
    
    fct_string_t* result = fct_string_create_with_capacity(str->capacity);
    if (!result) return NULL;
    
    for (size_t i = 0; i < str->length; i++) {
        result->data[i] = (char)tolower((unsigned char)str->data[i]);
    }
    result->data[str->length] = '\0';
    result->length = str->length;
    
    return result;
}

/*============================================================================
 * String List
 *============================================================================*/

fct_string_list_t* fct_string_list_create(void) {
    fct_string_list_t* list = (fct_string_list_t*)fct_alloc(sizeof(fct_string_list_t));
    if (!list) return NULL;
    
    list->items = NULL;
    list->count = 0;
    list->capacity = 0;
    
    return list;
}

void fct_string_list_destroy(fct_string_list_t* list) {
    if (!list) return;
    
    for (size_t i = 0; i < list->count; i++) {
        fct_string_unref(list->items[i]);
    }
    
    fct_free(list->items);
    fct_free(list);
}

fct_result_t fct_string_list_push(fct_string_list_t* list, fct_string_t* str) {
    if (!list || !str) return FCT_RESULT_NULL_POINTER;
    
    if (list->count >= list->capacity) {
        size_t new_capacity = list->capacity == 0 ? 4 : list->capacity * 2;
        fct_string_t** new_items = (fct_string_t**)fct_realloc(
            list->items, new_capacity * sizeof(fct_string_t*));
        if (!new_items) return FCT_RESULT_OUT_OF_MEMORY;
        
        list->items = new_items;
        list->capacity = new_capacity;
    }
    
    list->items[list->count++] = fct_string_ref(str);
    
    return FCT_RESULT_OK;
}

fct_result_t fct_string_list_push_cstr(fct_string_list_t* list, const char* cstr) {
    fct_string_t* str = fct_string_create(cstr);
    if (!str) return FCT_RESULT_OUT_OF_MEMORY;
    
    fct_result_t result = fct_string_list_push(list, str);
    fct_string_unref(str);
    
    return result;
}

size_t fct_string_list_count(const fct_string_list_t* list) {
    return list ? list->count : 0;
}

fct_string_t* fct_string_list_get(const fct_string_list_t* list, size_t index) {
    if (!list || index >= list->count) return NULL;
    return list->items[index];
}

fct_string_t** fct_string_list_items(const fct_string_list_t* list) {
    return list ? list->items : NULL;
}

/*============================================================================
 * Utility Functions
 *============================================================================*/

fct_string_t* fct_string_join(const fct_string_list_t* list, const char* separator) {
    if (!list || list->count == 0) {
        return fct_string_create_empty();
    }
    
    size_t sep_len = separator ? strlen(separator) : 0;
    
    /* Calculate total length */
    size_t total_len = 0;
    for (size_t i = 0; i < list->count; i++) {
        if (list->items[i]) {
            total_len += list->items[i]->length;
        }
    }
    
    /* Add separator lengths */
    if (sep_len > 0 && list->count > 1) {
        total_len += sep_len * (list->count - 1);
    }
    
    fct_string_t* result = fct_string_create_with_capacity(total_len + 1);
    if (!result) return NULL;
    
    for (size_t i = 0; i < list->count; i++) {
        if (i > 0 && sep_len > 0) {
            fct_string_append(result, separator);
        }
        if (list->items[i]) {
            fct_string_append_string(result, list->items[i]);
        }
    }
    
    return result;
}

fct_string_list_t* fct_string_split(const fct_string_t* str, const char* delimiter, int max_splits) {
    if (!str || !delimiter || !*delimiter) {
        fct_string_list_t* empty = fct_string_list_create();
        return empty;
    }
    
    fct_string_list_t* list = fct_string_list_create();
    if (!list) return NULL;
    
    size_t delim_len = strlen(delimiter);
    size_t pos = 0;
    int splits = 0;
    
    while (pos < str->length) {
        if (max_splits > 0 && splits >= max_splits) {
            /* Add remaining as last item */
            fct_string_t* item = fct_string_substring(str, pos, str->length - pos);
            fct_string_list_push(list, item);
            fct_string_unref(item);
            break;
        }
        
        size_t found = FCT_STRING_NOT_FOUND;
        size_t search_start = pos;
        
        while (search_start < str->length) {
            size_t match_pos = FCT_STRING_NOT_FOUND;
            
            /* Simple substring search */
            for (size_t i = search_start; i <= str->length - delim_len; i++) {
                if (memcmp(str->data + i, delimiter, delim_len) == 0) {
                    match_pos = i;
                    break;
                }
            }
            
            if (match_pos != FCT_STRING_NOT_FOUND) {
                found = match_pos;
                break;
            } else {
                break;
            }
        }
        
        if (found == FCT_STRING_NOT_FOUND) {
            /* No more delimiters, add remaining */
            fct_string_t* item = fct_string_substring(str, pos, str->length - pos);
            fct_string_list_push(list, item);
            fct_string_unref(item);
            break;
        }
        
        /* Add item before delimiter */
        if (found > pos) {
            fct_string_t* item = fct_string_substring(str, pos, found - pos);
            fct_string_list_push(list, item);
            fct_string_unref(item);
        }
        
        pos = found + delim_len;
        splits++;
    }
    
    return list;
}

/*============================================================================
 * C String Utilities
 *============================================================================*/

size_t fct_cstr_length(const char* cstr) {
    return cstr ? strlen(cstr) : 0;
}

bool fct_cstr_empty(const char* cstr) {
    return !cstr || cstr[0] == '\0';
}

char* fct_cstr_dup(const char* cstr) {
    if (!cstr) return NULL;
    
    size_t len = strlen(cstr) + 1;
    char* copy = (char*)fct_alloc(len);
    if (copy) {
        memcpy(copy, cstr, len);
    }
    return copy;
}

fct_string_t* fct_cstr_to_string(const char* cstr) {
    return fct_string_create(cstr);
}

char* fct_string_to_cstr(const fct_string_t* str) {
    return fct_cstr_dup(fct_string_cstr(str));
}
