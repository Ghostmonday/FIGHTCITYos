/**
 * @file fct_string.h
 * @brief String utilities header for FightCityTickets
 */

#ifndef FCT_STRING_H
#define FCT_STRING_H

#include "fct_types.h"
#include <stdarg.h>

#ifdef __cplusplus
extern "C" {
#endif

/*============================================================================
 * Constants
 *============================================================================*/

#define FCT_STRING_NOT_FOUND ((size_t)-1)

/*============================================================================
 * String Creation
 *============================================================================*/

/**
 * @brief Create an empty string
 * @return New string reference (caller owns)
 */
FCT_EXPORT fct_string_t* fct_string_create_empty(void);

/**
 * @brief Create a string with specified capacity
 * @param capacity Initial buffer capacity
 * @return New string reference (caller owns)
 */
FCT_EXPORT fct_string_t* fct_string_create_with_capacity(size_t capacity);

/**
 * @brief Create a string from C string
 * @param cstr C string (NULL treated as empty)
 * @return New string reference (caller owns)
 */
FCT_EXPORT fct_string_t* fct_string_create(const char* cstr);

/**
 * @brief Create a string from buffer with length
 * @param data Source data
 * @param length Number of bytes to copy
 * @return New string reference (caller owns)
 */
FCT_EXPORT fct_string_t* fct_string_create_with_length(const char* data, size_t len);

/**
 * @brief Create a string from string slice
 * @param slice String slice
 * @return New string reference (caller owns)
 */
FCT_EXPORT fct_string_t* fct_string_create_from_slice(fct_string_slice_t slice);

/**
 * @brief Copy a string
 * @param str Source string
 * @return New string reference (caller owns)
 */
FCT_EXPORT fct_string_t* fct_string_copy(const fct_string_t* str);

/**
 * @brief Increment reference count
 * @param str String to reference
 * @return Same string with incremented ref count
 */
FCT_EXPORT fct_string_t* fct_string_ref(fct_string_t* str);

/**
 * @brief Decrement reference count, free if zero
 * @param str String to release
 */
FCT_EXPORT void fct_string_unref(fct_string_t* str);

/*============================================================================
 * String Modification
 *============================================================================*/

/**
 * @brief Append C string to string
 * @param str Target string
 * @param cstr Source C string
 * @return Result code
 */
FCT_EXPORT fct_result_t fct_string_append(fct_string_t* str, const char* cstr);

/**
 * @brief Append single character
 * @param str Target string
 * @param c Character to append
 * @return Result code
 */
FCT_EXPORT fct_result_t fct_string_append_char(fct_string_t* str, char c);

/**
 * @brief Append another string
 * @param str Target string
 * @param other Source string
 * @return Result code
 */
FCT_EXPORT fct_result_t fct_string_append_string(fct_string_t* str, const fct_string_t* other);

/**
 * @brief Append string slice
 * @param str Target string
 * @param slice Source slice
 * @return Result code
 */
FCT_EXPORT fct_result_t fct_string_append_slice(fct_string_t* str, fct_string_slice_t slice);

/**
 * @brief Append formatted string (va_list version)
 */
FCT_EXPORT fct_result_t fct_string_vappendf(fct_string_t* str, const char* format, va_list args);

/**
 * @brief Append formatted string
 * @param str Target string
 * @param format Printf-style format
 * @return Result code
 */
FCT_EXPORT fct_result_t fct_string_appendf(fct_string_t* str, const char* format, ...);

/**
 * @brief Prepend C string to string
 * @param str Target string
 * @param cstr Source C string
 * @return Result code
 */
FCT_EXPORT fct_result_t fct_string_prepend(fct_string_t* str, const char* cstr);

/**
 * @brief Insert C string at position
 * @param str Target string
 * @param pos Insertion position
 * @param cstr Source C string
 * @return Result code
 */
FCT_EXPORT fct_result_t fct_string_insert(fct_string_t* str, size_t pos, const char* cstr);

/**
 * @brief Erase portion of string
 * @param str Target string
 * @param pos Start position
 * @param len Number of characters to remove
 * @return Result code
 */
FCT_EXPORT fct_result_t fct_string_erase(fct_string_t* str, size_t pos, size_t len);

/**
 * @brief Clear string contents
 * @param str Target string
 * @return Result code
 */
FCT_EXPORT fct_result_t fct_string_clear(fct_string_t* str);

/**
 * @brief Trim whitespace from both ends
 * @param str Target string
 * @return Result code
 */
FCT_EXPORT fct_result_t fct_string_trim(fct_string_t* str);

/**
 * @brief Resize string
 * @param str Target string
 * @param new_size New length
 * @param fill Character to fill new space
 * @return Result code
 */
FCT_EXPORT fct_result_t fct_string_resize(fct_string_t* str, size_t new_size, char fill);

/*============================================================================
 * String Accessors
 *============================================================================*/

/**
 * @brief Get C string pointer
 * @param str String (NULL returns empty string)
 * @return C string pointer (valid while string exists)
 */
FCT_EXPORT const char* fct_string_cstr(const fct_string_t* str);

/**
 * @brief Get string length
 * @param str String
 * @return Length in characters
 */
FCT_EXPORT size_t fct_string_length(const fct_string_t* str);

/**
 * @brief Get string capacity
 * @param str String
 * @return Buffer capacity
 */
FCT_EXPORT size_t fct_string_capacity(const fct_string_t* str);

/**
 * @brief Check if string is empty
 * @param str String
 * @return true if empty or NULL
 */
FCT_EXPORT bool fct_string_empty(const fct_string_t* str);

/**
 * @brief Compare two strings
 * @param a First string
 * @param b Second string
 * @return true if equal
 */
FCT_EXPORT bool fct_string_equal(const fct_string_t* a, const fct_string_t* b);

/**
 * @brief Compare string to C string
 * @param str String
 * @param cstr C string
 * @return true if equal
 */
FCT_EXPORT bool fct_string_equal_cstr(const fct_string_t* str, const char* cstr);

/**
 * @brief Compare two strings lexicographically
 * @param a First string
 * @param b Second string
 * @return -1 if a<b, 0 if equal, 1 if a>b
 */
FCT_EXPORT int fct_string_compare(const fct_string_t* a, const fct_string_t* b);

/**
 * @brief Compare string to C string
 * @param str String
 * @param cstr C string
 * @return -1 if str<cstr, 0 if equal, 1 if str>cstr
 */
FCT_EXPORT int fct_string_compare_cstr(const fct_string_t* str, const char* cstr);

/**
 * @brief Case-insensitive compare
 */
FCT_EXPORT int fct_string_case_compare(const fct_string_t* a, const fct_string_t* b);

/**
 * @brief Get character at index
 * @param str String
 * @param index Position
 * @return Character or '\0' if invalid
 */
FCT_EXPORT char fct_string_char_at(const fct_string_t* str, size_t index);

/**
 * @brief Get string slice
 * @param str String
 * @param pos Start position
 * @param len Length
 * @return Slice (borrowed reference)
 */
FCT_EXPORT fct_string_slice_t fct_string_slice(const fct_string_t* str, size_t pos, size_t len);

/**
 * @brief Create substring
 * @param str Source string
 * @param pos Start position
 * @param len Length
 * @return New string (caller owns)
 */
FCT_EXPORT fct_string_t* fct_string_substring(const fct_string_t* str, size_t pos, size_t len);

/*============================================================================
 * String Search
 *============================================================================*/

/**
 * @brief Find substring
 * @param str String to search
 * @param needle Substring to find
 * @return Position or FCT_STRING_NOT_FOUND
 */
FCT_EXPORT size_t fct_string_find(const fct_string_t* str, const char* needle);

/**
 * @brief Find character
 * @param str String to search
 * @param c Character to find
 * @return Position or FCT_STRING_NOT_FOUND
 */
FCT_EXPORT size_t fct_string_find_char(const fct_string_t* str, char c);

/**
 * @brief Find last occurrence of substring
 */
FCT_EXPORT size_t fct_string_rfind(const fct_string_t* str, const char* needle);

/**
 * @brief Check if string contains substring
 */
FCT_EXPORT bool fct_string_contains(const fct_string_t* str, const char* needle);

/**
 * @brief Check if string starts with prefix
 */
FCT_EXPORT bool fct_string_starts_with(const fct_string_t* str, const char* prefix);

/**
 * @brief Check if string ends with suffix
 */
FCT_EXPORT bool fct_string_ends_with(const fct_string_t* str, const char* suffix);

/*============================================================================
 * String Transform
 *============================================================================*/

/**
 * @brief Convert to uppercase
 * @param str Source string
 * @return New string in uppercase
 */
FCT_EXPORT fct_string_t* fct_string_to_upper(const fct_string_t* str);

/**
 * @brief Convert to lowercase
 * @param str Source string
 * @return New string in lowercase
 */
FCT_EXPORT fct_string_t* fct_string_to_lower(const fct_string_t* str);

/*============================================================================
 * String List
 *============================================================================*/

/**
 * @brief Create empty string list
 * @return New list (caller owns)
 */
FCT_EXPORT fct_string_list_t* fct_string_list_create(void);

/**
 * @brief Destroy string list and all strings
 */
FCT_EXPORT void fct_string_list_destroy(fct_string_list_t* list);

/**
 * @brief Add string to list
 * @param list Target list
 * @param str String to add (borrowed reference)
 * @return Result code
 */
FCT_EXPORT fct_result_t fct_string_list_push(fct_string_list_t* list, fct_string_t* str);

/**
 * @brief Add C string to list
 * @param list Target list
 * @param cstr C string to add
 * @return Result code
 */
FCT_EXPORT fct_result_t fct_string_list_push_cstr(fct_string_list_t* list, const char* cstr);

/**
 * @brief Get list length
 */
FCT_EXPORT size_t fct_string_list_count(const fct_string_list_t* list);

/**
 * @brief Get string at index
 */
FCT_EXPORT fct_string_t* fct_string_list_get(const fct_string_list_t* list, size_t index);

/**
 * @brief Get raw array (for iteration)
 */
FCT_EXPORT fct_string_t** fct_string_list_items(const fct_string_list_t* list);

/**
 * @brief Join strings with separator
 * @param list String list
 * @param separator Separator string
 * @return Joined string
 */
FCT_EXPORT fct_string_t* fct_string_join(const fct_string_list_t* list, const char* separator);

/**
 * @brief Split string by delimiter
 * @param str Source string
 * @param delimiter Delimiter pattern
 * @param max_splits Maximum splits (-1 for unlimited)
 * @return List of strings
 */
FCT_EXPORT fct_string_list_t* fct_string_split(const fct_string_t* str, 
                                               const char* delimiter, 
                                               int max_splits);

/*============================================================================
 * C String Utilities
 *============================================================================*/

/**
 * @brief Get C string length (NULL-safe)
 */
FCT_EXPORT size_t fct_cstr_length(const char* cstr);

/**
 * @brief Check if C string is empty (NULL-safe)
 */
FCT_EXPORT bool fct_cstr_empty(const char* cstr);

/**
 * @brief Duplicate C string
 * @param cstr Source (NULL returns NULL)
 * @return Newly allocated copy
 */
FCT_EXPORT char* fct_cstr_dup(const char* cstr);

/**
 * @brief Convert C string to fct_string_t
 */
FCT_EXPORT fct_string_t* fct_cstr_to_string(const char* cstr);

/**
 * @brief Convert fct_string_t to allocated C string
 */
FCT_EXPORT char* fct_string_to_cstr(const fct_string_t* str);

#ifdef __cplusplus
}
#endif

#endif /* FCT_STRING_H */
