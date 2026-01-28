/**
 * @file fct_confidence.h
 * @brief OCR confidence scoring for FightCityTickets
 *
 * Port of Swift ConfidenceScorer to C for cross-platform testing.
 * This module provides pure C implementations that can be tested
 * on Linux without iOS dependencies.
 *
 * Author: FightCityTickets Team
 * Version: 1.0.0
 */

#ifndef FCT_CONFIDENCE_H
#define FCT_CONFIDENCE_H

#include "fct_types.h"
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/*============================================================================
 * Configuration
 *============================================================================*/

/**
 * @brief Default confidence thresholds
 */
#define FCT_CONFIDENCE_THRESHOLD_HIGH  0.85
#define FCT_CONFIDENCE_THRESHOLD_MEDIUM 0.60
#define FCT_CONFIDENCE_THRESHOLD_LOW   0.0

/*============================================================================
 * Component Weights
 *============================================================================*/

/**
 * @brief Weights for confidence components (sum = 1.0)
 */
#define FCT_CONFIDENCE_WEIGHT_VISION          0.40
#define FCT_CONFIDENCE_WEIGHT_PATTERN_MATCH   0.30
#define FCT_CONFIDENCE_WEIGHT_TEXT_COMPLETE   0.20
#define FCT_CONFIDENCE_WEIGHT_CONSISTENCY     0.10

/*============================================================================
 * Confidence Result
 *============================================================================*/

/**
 * @brief Create empty confidence result
 * @return New result (caller owns)
 */
FCT_EXPORT fct_confidence_result_t* fct_confidence_result_create(void);

/**
 * @brief Destroy confidence result
 */
FCT_EXPORT void fct_confidence_result_destroy(fct_confidence_result_t* result);

/**
 * @brief Get component by name
 * @param result Confidence result
 * @param name Component name
 * @return Component or NULL
 */
FCT_EXPORT fct_confidence_component_t* fct_confidence_get_component(
    fct_confidence_result_t* result, const char* name);

/*============================================================================
 * Confidence Scoring
 *============================================================================*/

/**
 * @brief Calculate confidence score for OCR result
 * 
 * @param raw_text Raw OCR text
 * @param confidence_values Array of confidence values (0.0 to 1.0)
 * @param confidence_count Number of confidence values
 * @param matched_pattern Priority of matched pattern (1=highest, 4=lowest, 0=none)
 * @param target_length Target length range for text
 * @return Calculated confidence result (caller owns)
 */
FCT_EXPORT fct_confidence_result_t* fct_confidence_calculate(
    const char* raw_text,
    const double* confidence_values,
    size_t confidence_count,
    int matched_pattern_priority,
    int target_length_min,
    int target_length_max);

/**
 * @brief Simplified confidence calculation
 * @param raw_text OCR text
 * @param avg_confidence Average vision confidence (0.0 to 1.0)
 * @param pattern_priority Pattern priority (1-4, 0 for unknown)
 * @return Confidence result
 */
FCT_EXPORT fct_confidence_result_t* fct_confidence_calculate_simple(
    const char* raw_text,
    double avg_confidence,
    int pattern_priority);

/**
 * @brief Calculate from Vision framework-style observations
 * 
 * This function simulates the Vision framework confidence calculation
 * for testing purposes.
 * 
 * @param raw_text Extracted text
 * @param observation_confidences Array of per-observation confidences
 * @param observation_count Number of observations
 * @param matched_city_id City ID if pattern matched (NULL for none)
 * @return Confidence result
 */
FCT_EXPORT fct_confidence_result_t* fct_confidence_from_observations(
    const char* raw_text,
    const double* observation_confidences,
    size_t observation_count,
    const char* matched_city_id);

/*============================================================================
 * Component Calculations (Exposed for Testing)
 *============================================================================*/

/**
 * @brief Calculate vision confidence component
 * @param confidences Array of confidence values
 * @param count Number of values
 * @return Average confidence (0.0 to 1.0)
 */
FCT_EXPORT double fct_confidence_calc_vision(
    const double* confidences,
    size_t count);

/**
 * @brief Calculate pattern match confidence
 * @param pattern_priority Pattern priority (1=highest)
 * @return Pattern confidence (0.0 to 1.0)
 */
FCT_EXPORT double fct_confidence_calc_pattern(int pattern_priority);

/**
 * @brief Calculate text completeness confidence
 * @param text_length Actual text length
 * @param target_min Minimum expected length
 * @param target_max Maximum expected length
 * @return Completeness score (0.0 to 1.0)
 */
FCT_EXPORT double fct_confidence_calc_completeness(
    size_t text_length,
    int target_min,
    int target_max);

/**
 * @brief Calculate consistency confidence
 * @param confidences Array of confidence values
 * @param count Number of values
 * @return Consistency score (0.0 to 1.0, higher = more consistent)
 */
FCT_EXPORT double fct_confidence_calc_consistency(
    const double* confidences,
    size_t count);

/*============================================================================
 * Level Helpers
 *============================================================================*/

/**
 * @brief Get confidence level from score
 */
FCT_EXPORT fct_confidence_level_t fct_confidence_level_from_score(double score);

/**
 * @brief Check if confidence meets auto-accept threshold
 */
FCT_EXPORT bool fct_confidence_meets_auto_accept(double score);

/**
 * @brief Check if confidence requires review
 */
FCT_EXPORT bool fct_confidence_requires_review(double score);

/**
 * @brief Get user-friendly confidence message
 */
FCT_EXPORT const char* fct_confidence_get_message(fct_confidence_level_t level);

/**
 * @brief Get recommendation from confidence level
 */
FCT_EXPORT fct_ocr_recommendation_t fct_confidence_get_recommendation(
    fct_confidence_level_t level);

/*============================================================================
 * Fallback Suggestions
 *============================================================================*/

/**
 * @brief Determine if fallback processing is needed
 */
FCT_EXPORT bool fct_confidence_should_use_fallback(fct_confidence_result_t* result);

/**
 * @brief Suggest preprocessing options based on score
 * 
 * Returns bitmask of suggested preprocessing:
 * - FCT_PREPROCESS_ENHANCE_CONTRAST  (1 << 0)
 * - FCT_PREPROCESS_REDUCE_NOISE      (1 << 1)
 * - FCT_PREPROCESS_BINARIZE          (1 << 2)
 * - FCT_PREPROCESS_CORRECT_PERSPECTIVE (1 << 3)
 */
typedef uint32_t fct_preprocess_options_t;

#define FCT_PREPROCESS_ENHANCE_CONTRAST     0x01
#define FCT_PREPROCESS_REDUCE_NOISE         0x02
#define FCT_PREPROCESS_BINARIZE             0x04
#define FCT_PREPROCESS_CORRECT_PERSPECTIVE  0x08

/**
 * @brief Suggest preprocessing options
 */
FCT_EXPORT fct_preprocess_options_t fct_confidence_suggest_preprocessing(
    fct_confidence_result_t* result);

/*============================================================================
 * Pattern-Specific Helpers
 *============================================================================*/

/**
 * @brief Get target length range for city
 * @param city_id City identifier
 * @param min Output minimum length
 * @param max Output maximum length
 * @return true if city known
 */
FCT_EXPORT bool fct_confidence_get_target_length(
    const char* city_id,
    int* min,
    int* max);

/**
 * @brief Get pattern priority for city
 * @param city_id City identifier
 * @return Priority (1-4, lower = more specific)
 */
FCT_EXPORT int fct_confidence_get_pattern_priority(const char* city_id);

#ifdef __cplusplus
}
#endif

#endif /* FCT_CONFIDENCE_H */
