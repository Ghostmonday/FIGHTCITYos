/**
 * @file fct_memory.h
 * @brief Memory allocation utilities for FightCityTickets
 *
 * Provides platform-aware memory allocation with optional
 * debugging features and custom allocator support.
 *
 * Author: FightCityTickets Team
 * Version: 1.0.0
 */

#ifndef FCT_MEMORY_H
#define FCT_MEMORY_H

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/*============================================================================
 * Memory Debugging
 *============================================================================*/

/**
 * @brief Enable memory debugging
 * When enabled, tracks all allocations for leak detection
 */
FCT_EXPORT void fct_memory_set_debugging(bool enabled);

/**
 * @brief Check for memory leaks
 * @return Number of leaked allocations (0 = no leaks)
 */
FCT_EXPORT size_t fct_memory_check_leaks(void);

/**
 * @brief Print memory statistics
 */
FCT_EXPORT void fct_memory_print_stats(void);

/**
 * @brief Get total allocated bytes
 */
FCT_EXPORT size_t fct_memory_get_allocated(void);

/**
 * @brief Get allocation count
 */
FCT_EXPORT size_t fct_memory_get_allocation_count(void);

/**
 * @brief Reset memory statistics
 */
FCT_EXPORT void fct_memory_reset_stats(void);

/*============================================================================
 * Custom Allocator
 *============================================================================*/

/**
 * @brief Custom allocator functions
 */
typedef struct fct_allocator {
    void* (*malloc)(size_t size);
    void* (*calloc)(size_t nmemb, size_t size);
    void* (*realloc)(void* ptr, size_t size);
    void (*free)(void* ptr);
    void* (*user_data);
} fct_allocator_t;

/**
 * @brief Set custom allocator
 * @param allocator New allocator (NULL to reset to default)
 * @return Previous allocator
 */
FCT_EXPORT fct_allocator_t* fct_memory_set_allocator(fct_allocator_t* allocator);

/**
 * @brief Get current allocator
 */
FCT_EXPORT fct_allocator_t* fct_memory_get_allocator(void);

/*============================================================================
 * Aligned Allocation (C11 / Platform-specific)
 *============================================================================*/

/**
 * @brief Allocate aligned memory
 * @param alignment Alignment in bytes (must be power of 2)
 * @param size Size in bytes
 * @return Aligned pointer or NULL
 */
FCT_EXPORT void* fct_aligned_alloc(size_t alignment, size_t size);

/**
 * @brief Aligned free (works with any aligned allocation)
 */
FCT_EXPORT void fct_aligned_free(void* ptr);

/*============================================================================
 * Memory Operations
 *============================================================================*/

/**
 * @brief Securely zero memory (prevents optimization)
 * Use for sensitive data like passwords, keys
 */
FCT_EXPORT void fct_memory_zero(void* ptr, size_t size);

/**
 * @brief Check if memory is all zeros
 */
FCT_EXPORT bool fct_memory_is_zero(const void* ptr, size_t size);

/**
 * @brief Compare memory with constant-time algorithm
 * Use for cryptographic comparisons to prevent timing attacks
 */
FCT_EXPORT int fct_memory_compare_ct(const void* a, const void* b, size_t size);

/**
 * @brief Duplicate memory block
 * @param src Source pointer
 * @param size Size to copy
 * @return Newly allocated copy
 */
FCT_EXPORT void* fct_memory_dup(const void* src, size_t size);

/**
 * @brief Set memory to pattern (like valgrind's VEX)
 */
FCT_EXPORT void fct_memory_set_pattern(void* ptr, size_t size, uint8_t pattern);

/**
 * @brief Check if memory matches pattern
 */
FCT_EXPORT bool fct_memory_check_pattern(const void* ptr, size_t size, uint8_t pattern);

#ifdef __cplusplus
}
#endif

/*============================================================================
 * Inline Memory Functions (Common Cases)
 *============================================================================*/

/**
 * @brief Allocate and zero memory
 */
static inline void* fct_alloc(size_t size) {
    return fct_memory_get_allocator()->malloc ?
           fct_memory_get_allocator()->malloc(size) : malloc(size);
}

/**
 * @brief Allocate and zero array
 */
static inline void* fct_calloc(size_t nmemb, size_t size) {
    if (fct_memory_get_allocator()->calloc) {
        return fct_memory_get_allocator()->calloc(nmemb, size);
    }
    void* ptr = malloc(nmemb * size);
    if (ptr) {
        memset(ptr, 0, nmemb * size);
    }
    return ptr;
}

/**
 * @brief Reallocate memory
 */
static inline void* fct_realloc(void* ptr, size_t size) {
    if (fct_memory_get_allocator()->realloc) {
        return fct_memory_get_allocator()->realloc(ptr, size);
    }
    return realloc(ptr, size);
}

/**
 * @brief Free memory
 */
static inline void fct_free(void* ptr) {
    if (!ptr) return;
    if (fct_memory_get_allocator()->free) {
        fct_memory_get_allocator()->free(ptr);
    } else {
        free(ptr);
    }
}

#endif /* FCT_MEMORY_H */
