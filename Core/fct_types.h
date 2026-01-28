/**
 * @file fct_types.h
 * @brief Core data types and structures for FightCityTickets
 *
 * This file defines the fundamental data structures used throughout
 * the application. All types are designed to be:
 * - Memory-efficient
 * - Serializable to JSON
 * - Portable across platforms
 *
 * Author: FightCityTickets Team
 * Version: 1.0.0
 */

#ifndef FCT_TYPES_H
#define FCT_TYPES_H

#include <stdint.h>
#include <stdbool.h>
#include <time.h>

#ifdef __cplusplus
extern "C" {
#endif

/*============================================================================
 * String Types
 *============================================================================*/

/**
 * @brief Dynamic string type with reference counting
 */
typedef struct fct_string {
    char* data;
    size_t length;
    size_t capacity;
    int ref_count;
} fct_string_t;

/**
 * @brief String slice (borrowed reference, no allocation)
 */
typedef struct fct_string_slice {
    const char* data;
    size_t length;
} fct_string_slice_t;

/**
 * @brief String list/array
 */
typedef struct fct_string_list {
    fct_string_t** items;
    size_t count;
    size_t capacity;
} fct_string_list_t;

/*============================================================================
 * UUID Type
 *============================================================================*/

/**
 * @brief UUID representation (128-bit)
 */
typedef struct fct_uuid {
    uint8_t bytes[16];
} fct_uuid_t;

/**
 * @brief Generate a new random UUID
 * @return New UUID instance
 */
FCT_EXPORT fct_uuid_t fct_uuid_generate(void);

/**
 * @brief Parse UUID from string
 * @param str String representation (36 chars with dashes)
 * @param uuid Output UUID
 * @return FCT_RESULT_OK on success
 */
FCT_EXPORT fct_result_t fct_uuid_from_string(const char* str, fct_uuid_t* uuid);

/**
 * @brief Convert UUID to string
 * @param uuid UUID to convert
 * @param buffer Output buffer (at least 37 chars)
 * @return String pointer (same as buffer)
 */
FCT_EXPORT char* fct_uuid_to_string(const fct_uuid_t* uuid, char* buffer);

/**
 * @brief Check if two UUIDs are equal
 */
FCT_EXPORT bool fct_uuid_equal(const fct_uuid_t* a, const fct_uuid_t* b);

/**
 * @brief Null UUID (all zeros)
 */
FCT_EXPORT extern const fct_uuid_t fct_uuid_null;

/*============================================================================
 * Citation Types
 *============================================================================*/

/**
 * @brief Citation status enumeration
 */
typedef enum fct_citation_status {
    FCT_CITATION_STATUS_PENDING = 0,
    FCT_CITATION_STATUS_VALIDATED = 1,
    FCT_CITATION_STATUS_IN_REVIEW = 2,
    FCT_CITATION_STATUS_APPEALED = 3,
    FCT_CITATION_STATUS_APPROVED = 4,
    FCT_CITATION_STATUS_DENIED = 5,
    FCT_CITATION_STATUS_PAID = 6,
    FCT_CITATION_STATUS_EXPIRED = 7,
} fct_citation_status_t;

/**
 * @brief Deadline status enumeration
 */
typedef enum fct_deadline_status {
    FCT_DEADLINE_SAFE = 0,
    FCT_DEADLINE_APPROACHING = 1,
    FCT_DEADLINE_URGENT = 2,
    FCT_DEADLINE_PAST = 3,
} fct_deadline_status_t;

/**
 * @brief Citation agency enumeration
 */
typedef enum fct_citation_agency {
    FCT_AGENCY_UNKNOWN = 0,
    FCT_AGENCY_SFMTA = 1,
    FCT_AGENCY_SFPD = 2,
    FCT_AGENCY_LADOT = 3,
    FCT_AGENCY_LAXD = 4,
    FCT_AGENCY_LAPD = 5,
    FCT_AGENCY_NYC_DO = 6,
    FCT_AGENCY_NYPD = 7,
    FCT_AGENCY_DENVER = 8,
} fct_citation_agency_t;

/**
 * @brief Main citation structure
 */
typedef struct fct_citation {
    fct_uuid_t id;
    fct_string_t* citation_number;
    fct_string_t* city_id;
    fct_string_t* city_name;
    fct_string_t* agency;
    fct_string_t* section_id;
    fct_string_t* formatted_citation;
    fct_string_t* license_plate;
    fct_string_t* violation_date;
    fct_string_t* violation_time;
    double amount;               /* Decimal as double */
    fct_string_t* deadline_date;
    int days_remaining;
    bool is_past_deadline;
    bool is_urgent;
    bool can_appeal_online;
    bool phone_confirmation_required;
    fct_citation_status_t status;
    time_t created_at;
    time_t updated_at;
} fct_citation_t;

/**
 * @brief Citation validation request
 */
typedef struct fct_citation_validation_request {
    fct_string_t* citation_number;
    fct_string_t* city_id;  /* Optional */
} fct_citation_validation_request_t;

/**
 * @brief Citation validation result
 */
typedef struct fct_citation_validation_result {
    bool is_valid;
    fct_citation_t* citation;  /* NULL if invalid */
    fct_string_t* error_message;
    double confidence;  /* 0.0 to 1.0 */
} fct_citation_validation_result_t;

/*============================================================================
 * City Configuration
 *============================================================================*/

/**
 * @brief City configuration structure
 */
typedef struct fct_city_config {
    fct_string_t* id;
    fct_string_t* name;
    fct_string_t* pattern;          /* Regex pattern */
    fct_string_t* formatted_pattern;
    int appeal_deadline_days;
    bool phone_confirmation_required;
    bool can_appeal_online;
} fct_city_config_t;

/**
 * @brief List of supported cities
 */
typedef struct fct_city_list {
    fct_city_config_t** items;
    size_t count;
} fct_city_list_t;

/*============================================================================
 * OCR Types
 *============================================================================*/

/**
 * @brief OCR recognition confidence levels
 */
typedef enum fct_confidence_level {
    FCT_CONFIDENCE_LOW = 0,
    FCT_CONFIDENCE_MEDIUM = 1,
    FCT_CONFIDENCE_HIGH = 2,
} fct_confidence_level_t;

/**
 * @brief OCR recommendation
 */
typedef enum fct_ocr_recommendation {
    FCT_OCR_REJECT = 0,
    FCT_OCR_REVIEW = 1,
    FCT_OCR_ACCEPT = 2,
} fct_ocr_recommendation_t;

/**
 * @brief OCR confidence component
 */
typedef struct fct_confidence_component {
    fct_string_t* name;
    double score;
    double weight;
    double weighted_score;
} fct_confidence_component_t;

/**
 * @brief OCR confidence scoring result
 */
typedef struct fct_confidence_result {
    double overall_confidence;
    fct_confidence_level_t level;
    fct_confidence_component_t** components;
    size_t component_count;
    fct_ocr_recommendation_t recommendation;
    bool should_auto_accept;
} fct_confidence_result_t;

/**
 * @brief OCR recognition result
 */
typedef struct fct_ocr_result {
    fct_string_t* text;
    double confidence;
    double processing_time_ms;
    fct_confidence_result_t* score;
    fct_string_t* matched_city_id;
} fct_ocr_result_t;

/*============================================================================
 * Capture Result
 *============================================================================*/

/**
 * @brief Image capture result
 */
typedef struct fct_capture_result {
    fct_string_t* image_path;       /* Path to saved image */
    uint8_t* image_data;            /* Raw image bytes */
    size_t image_size;
    int width;
    int height;
    fct_ocr_result_t* ocr_result;
    time_t captured_at;
} fct_capture_result_t;

/*============================================================================
 * API Types
 *============================================================================*/

/**
 * @brief HTTP method enumeration
 */
typedef enum fct_http_method {
    FCT_HTTP_GET = 0,
    FCT_HTTP_POST = 1,
    FCT_HTTP_PUT = 2,
    FCT_HTTP_PATCH = 3,
    FCT_HTTP_DELETE = 4,
} fct_http_method_t;

/**
 * @brief HTTP status codes
 */
typedef enum fct_http_status {
    FCT_HTTP_OK = 200,
    FCT_HTTP_BAD_REQUEST = 400,
    FCT_HTTP_UNAUTHORIZED = 401,
    FCT_HTTP_NOT_FOUND = 404,
    FCT_HTTP_VALIDATION_ERROR = 422,
    FCT_HTTP_TOO_MANY_REQUESTS = 429,
    FCT_HTTP_SERVER_ERROR = 500,
} fct_http_status_t;

/**
 * @brief API error codes
 */
typedef enum fct_api_error {
    FCT_API_ERROR_NONE = 0,
    FCT_API_ERROR_INVALID_URL,
    FCT_API_ERROR_INVALID_RESPONSE,
    FCT_API_ERROR_DECODING,
    FCT_API_ERROR_BAD_REQUEST,
    FCT_API_ERROR_UNAUTHORIZED,
    FCT_API_ERROR_NOT_FOUND,
    FCT_API_ERROR_VALIDATION,
    FCT_API_ERROR_RATE_LIMITED,
    FCT_API_ERROR_SERVER,
    FCT_API_ERROR_NETWORK_UNAVAILABLE,
} fct_api_error_t;

/**
 * @brief HTTP header key-value pair
 */
typedef struct fct_http_header {
    fct_string_t* key;
    fct_string_t* value;
} fct_http_header_t;

/**
 * @brief HTTP request
 */
typedef struct fct_http_request {
    fct_http_method_t method;
    fct_string_t* url;
    fct_http_header_t** headers;
    size_t header_count;
    fct_string_t* body;  /* JSON body */
} fct_http_request_t;

/**
 * @brief HTTP response
 */
typedef struct fct_http_response {
    int status_code;
    fct_string_t* body;
    fct_http_header_t** headers;
    size_t header_count;
} fct_http_response_t;

/*============================================================================
 * Telemetry Types
 *============================================================================*/

/**
 * @brief Telemetry record
 */
typedef struct fct_telemetry_record {
    fct_uuid_t id;
    time_t timestamp;
    fct_string_t* event_type;
    fct_string_t* city_id;
    fct_string_t* raw_text;
    double confidence_score;
    double processing_time_ms;
    bool was_accepted;
    fct_string_t* device_info;
} fct_telemetry_record_t;

/**
 * @brief Telemetry batch
 */
typedef struct fct_telemetry_batch {
    fct_telemetry_record_t** records;
    size_t record_count;
    time_t created_at;
} fct_telemetry_batch_t;

/*============================================================================
 * Configuration Types
 *============================================================================*/

/**
 * @brief API endpoints structure
 */
typedef struct fct_api_endpoints {
    fct_string_t* health;
    fct_string_t* validate_citation;
    fct_string_t* validate_ticket;
    fct_string_t* appeal_submit;
    fct_string_t* status_lookup;
    fct_string_t* telemetry_upload;
    fct_string_t* ocr_config;
} fct_api_endpoints_t;

/**
 * @brief Main configuration structure
 */
typedef struct fct_config {
    /* API Configuration */
    fct_string_t* api_base_url;
    double api_timeout_seconds;
    int max_retry_attempts;
    fct_string_t* web_base_url;
    
    /* OCR Configuration */
    double ocr_confidence_threshold;
    double ocr_review_threshold;
    int ocr_max_image_dimension;
    
    /* Telemetry Configuration */
    bool telemetry_enabled;
    int telemetry_batch_size;
    double telemetry_max_age_seconds;
    
    /* Offline Configuration */
    int offline_queue_max_size;
    double retry_backoff_multiplier;
    double retry_max_backoff_seconds;
    
    /* Endpoints (initialized from base URL) */
    fct_api_endpoints_t endpoints;
    
    /* Cities */
    fct_city_list_t* supported_cities;
} fct_config_t;

/*============================================================================
 * Result/Response Types
 *============================================================================*/

/**
 * @brief Generic operation result
 */
typedef struct fct_result_container {
    bool success;
    fct_string_t* error_message;
    int error_code;
} fct_result_container_t;

/**
 * @brief Appeal submission request
 */
typedef struct fct_appeal_request {
    fct_string_t* citation_id;
    fct_string_t* reason;
    fct_string_t* evidence_description;
    fct_string_list_t* evidence_paths;
    bool waive_hearing;
} fct_appeal_request_t;

/**
 * @brief Appeal submission result
 */
typedef struct fct_appeal_result {
    bool accepted;
    fct_string_t* appeal_id;
    fct_string_t* status;
    fct_string_t* next_steps;
    time_t submitted_at;
} fct_appeal_result_t;

/*============================================================================
 * Camera Types (Platform-specific, defined in fct_camera.h for iOS)
 *============================================================================*/

#ifdef FCT_PLATFORM_IOS
/* Forward declaration - defined in platform-specific header */
struct fct_camera_session;
typedef struct fct_camera_session fct_camera_session_t;
#endif

#ifdef __cplusplus
}
#endif

#endif /* FCT_TYPES_H */
