/**
 * @file fct_c_port.h
 * @brief FightCityTickets Cross-Platform C Port
 * 
 * Architecture Overview:
 * ======================
 * This is a cross-platform C implementation of the FightCityTickets iOS app,
 * designed for maximum testability on Linux while maintaining iOS compatibility
 * through platform-specific bindings.
 *
 * Layer Structure:
 * ---------------
 * 1. CORE LAYER (Portable C - Linux Testable)
 *    - fct_types.h/.c      : Core data types and structures
 *    - fct_string.h/.c     : String utilities
 *    - fct_json.h/.c       : JSON parsing/serialization
 *    - fct_config.h/.c     : Configuration management
 *    - fct_citation.h/.c   : Citation model and validation
 *    - fct_confidence.h/.c : Confidence scoring algorithms
 *    - fct_pattern.h/.c    : City pattern matching
 *
 * 2. PLATFORM ABSTRACTION LAYER
 *    - fct_platform.h       : Platform detection (iOS/Linux)
 *    - fct_memory.h         : Memory allocation abstraction
 *    - fct_thread.h         : Threading primitives
 *    - fct_mutex.h          : Mutex/lock primitives
 *
 * 3. SERVICE LAYER (Portable where possible)
 *    - fct_network.h/.c    : HTTP client with retry logic
 *    - fct_telemetry.h/.c  : Telemetry collection
 *    - fct_offline.h/.c    : Offline queue management
 *
 * 4. IOS BINDINGS LAYER (iOS only - Objective-C)
 *    - fct_camera_ios.h/.m : AVFoundation camera integration
 *    - fct_ocr_ios.h/.m    : Vision framework OCR
 *    - fct_image_ios.h/.m  : Image processing
 *
 * 5. TEST LAYER (Linux only)
 *    - tests/test_*.c      : Unit tests
 *    - tests/mocks/        : Mock implementations
 *
 * Build System:
 * -------------
 * - CMake for cross-platform builds
 * - Meson alternative for Linux
 * - Xcode project for iOS builds
 *
 * Author: FightCityTickets Team
 * Version: 1.0.0
 */

#ifndef FCT_C_PORT_H
#define FCT_C_PORT_H

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

/* Version Information */
#define FCT_VERSION_MAJOR 1
#define FCT_VERSION_MINOR 0
#define FCT_VERSION_PATCH 0
#define FCT_VERSION_STRING "1.0.0"

/* Platform Detection */
#if defined(__APPLE__) && defined(__MACH__)
    #include <TargetConditionals.h>
    #if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
        #define FCT_PLATFORM_IOS 1
        #define FCT_PLATFORM_NAME "iOS"
    #endif
#endif

#if defined(__linux__) || defined(__CYGWIN__)
    #define FCT_PLATFORM_LINUX 1
    #define FCT_PLATFORM_NAME "Linux"
#endif

#if defined(_WIN32) || defined(_WIN64)
    #define FCT_PLATFORM_WINDOWS 1
    #define FCT_PLATFORM_NAME "Windows"
#endif

/* Fallback to Linux if no platform detected */
#if !defined(FCT_PLATFORM_IOS) && !defined(FCT_PLATFORM_LINUX)
    #define FCT_PLATFORM_LINUX 1
    #define FCT_PLATFORM_NAME "Unknown"
#endif

/* C Standard Version */
#if defined(__STDC_VERSION__)
    #if __STDC_VERSION__ >= 201112L
        #define FCT_C11 1
    #elif __STDC_VERSION__ >= 199901L
        #define FCT_C99 1
    #endif
#endif

/* Compiler Detection */
#if defined(__clang__)
    #define FCT_COMPILER_CLANG 1
#elif defined(__GNUC__)
    #define FCT_COMPILER_GCC 1
#elif defined(_MSC_VER)
    #define FCT_COMPILER_MSVC 1
#endif

/* Feature Flags */
#define FCT_FEATURE_JSON        1
#define FCT_FEATURE_NETWORK     1
#define FCT_FEATURE_TELEMETRY   1
#define FCT_FEATURE_OFFLINE     1
#define FCT_FEATURE_CAMERA      0  /* iOS only */
#define FCT_FEATURE_OCR         0  /* iOS only */

/* Export/Import Macros */
#if defined(FCT_PLATFORM_IOS)
    #if defined(FCT_SHARED)
        #define FCT_EXPORT __attribute__((visibility("default")))
    #else
        #define FCT_EXPORT
    #endif
#else
    #define FCT_EXPORT
#endif

/* Common Macros */
#define FCT_STRINGIFY(x) #x
#define FCT_CONCAT(a, b) a##b
#define FCT_UNUSED(x) (void)(x)
#define FCT_STATIC_ASSERT(condition, name) _Static_assert(condition, name)

/* Error Codes */
typedef enum fct_result {
    FCT_RESULT_OK = 0,
    FCT_RESULT_ERROR = -1,
    FCT_RESULT_NULL_POINTER = -2,
    FCT_RESULT_INVALID_ARGUMENT = -3,
    FCT_RESULT_OUT_OF_MEMORY = -4,
    FCT_RESULT_NOT_IMPLEMENTED = -5,
    FCT_RESULT_NOT_FOUND = -6,
    FCT_RESULT_ALREADY_EXISTS = -7,
    FCT_RESULT_PERMISSION_DENIED = -8,
    FCT_RESULT_TIMEOUT = -9,
    FCT_RESULT_NETWORK_ERROR = -10,
    FCT_RESULT_JSON_ERROR = -11,
    FCT_RESULT_VALIDATION_ERROR = -12,
} fct_result_t;

/* Opaque Handle Types */
typedef struct fct_citation fct_citation_t;
typedef struct fct_config fct_config_t;
typedef struct fct_network_context fct_network_context_t;
typedef struct fct_confidence_result fct_confidence_result_t;
typedef struct fct_camera_session fct_camera_session_t;
typedef struct fct_ocr_result fct_ocr_result_t;

/* Callback Types */
typedef void (*fct_free_func)(void*);
typedef void* (*fct_alloc_func)(size_t);
typedef void (*fct_log_func)(int level, const char* message, ...);

/* Logging Levels */
typedef enum fct_log_level {
    FCT_LOG_ERROR = 0,
    FCT_LOG_WARN = 1,
    FCT_LOG_INFO = 2,
    FCT_LOG_DEBUG = 3,
    FCT_LOG_TRACE = 4,
} fct_log_level_t;

/**
 * @brief Initialize the FightCityTickets library
 * @param config Configuration structure (can be NULL for defaults)
 * @return FCT_RESULT_OK on success, error code otherwise
 */
FCT_EXPORT fct_result_t fct_init(const fct_config_t* config);

/**
 * @brief Shutdown the library and release resources
 */
FCT_EXPORT void fct_shutdown(void);

/**
 * @brief Get the library version string
 * @return Version string
 */
FCT_EXPORT const char* fct_version(void);

/**
 * @brief Set the logging function
 * @param func Logging function callback (NULL to disable)
 * @param min_level Minimum log level to output
 */
FCT_EXPORT void fct_set_logging(fct_log_func func, fct_log_level_t min_level);

#endif /* FCT_C_PORT_H */
