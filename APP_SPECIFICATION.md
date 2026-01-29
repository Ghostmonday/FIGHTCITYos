# FightCityTickets - Complete Application Specification

## Language & Platform Agnostic Technical Specification

**Purpose:** Serve as the definitive source for recreating this application in any programming language or platform.

**Audience:** AI models, developers, architects evaluating implementation options.

---

# Table of Contents

1. [Application Purpose](#1-application-purpose)
2. [Core Features](#2-core-features)
3. [User Workflows](#3-user-workflows)
4. [Technical Requirements](#4-technical-requirements)
5. [Data Models](#5-data-models)
6. [Business Logic](#6-business-logic)
7. [Platform Abstractions](#7-platform-abstractions)
8. [Quality Standards](#8-quality-standards)
9. [Non-Functional Requirements](#9-non-functional-requirements)
10. [Future Considerations](#10-future-considerations)

---

# 1. Application Purpose

## 1.1 Problem Statement

Parking tickets are issued by hundreds of municipalities across different agencies, each with:
- Unique citation number formats
- Different validation rules
- Varying appeal processes
- Distinct deadline calculations
- Different payment systems

Citizens struggle to:
- Validate if a citation is legitimate
- Understand deadline urgency
- Navigate complex appeal processes
- Track multiple citations across cities

## 1.2 Solution

A mobile application that:
1. Captures parking ticket images via camera
2. Performs OCR to extract citation numbers
3. Validates citations against known patterns
4. Provides confidence scoring for extracted data
5. Retrieves citation details from backend API
6. Guides users through appeal processes
7. Stores citation history locally
8. Works offline when network is unavailable

## 1.3 Target Users

- **Primary:** Citizens who receive parking tickets
- **Secondary:** Legal advocates, car rental companies, fleet managers

---

# 2. Core Features

## 2.1 Camera Capture

### Purpose
Capture high-quality images of parking tickets for OCR processing.

### Requirements
| ID | Requirement | Priority |
|----|-------------|----------|
| CAP-01 | Access device camera | Must |
| CAP-02 | Real-time camera preview | Must |
| CAP-03 | Capture still image | Must |
| CAP-04 | Auto-focus on tap | Should |
| CAP-05 | Torch/flashlight control | Should |
| CAP-06 | Front/back camera switching | Could |
| CAP-07 | Image stabilization | Should |
| CAP-08 | Adjustable zoom | Could |

### Quality Criteria
- Minimum resolution: 1920x1080
- Focus: Sharp text readability
- Lighting: Adequate for OCR
- Angle: Minimal perspective distortion

## 2.2 OCR Processing

### Purpose
Extract text from captured images with confidence scores.

### Requirements
| ID | Requirement | Priority |
|----|-------------|----------|
| OCR-01 | Text recognition from image | Must |
| OCR-02 | Confidence score per character | Must |
| OCR-03 | Confidence score overall | Must |
| OCR-04 | Multi-language support (English) | Must |
| OCR-05 | Auto-detect language | Could |
| OCR-06 | Multiple recognition passes | Should |
| OCR-07 | Error correction | Should |

### Quality Criteria
- Character accuracy: >95% for clear images
- Processing time: <3 seconds
- Confidence threshold: 0.85 auto-accept, 0.60-0.85 review

## 2.3 Pattern Recognition

### Purpose
Identify city and validate citation format from extracted text.

### Supported Cities

| City ID | Name | Pattern | Format | Deadline |
|---------|------|---------|--------|----------|
| us-ca-san_francisco | San Francisco | ^(SFMTA\|MT)[0-9]{8}$ | SFMTA-###-### | 21 days |
| us-ca-los_angeles | Los Angeles | ^[0-9A-Z]{6,11}$ | ###### | 21 days |
| us-ny-new_york | New York | ^[0-9]{10}$ | ########## | 30 days |
| us-co-denver | Denver | ^[0-9]{5,9}$ | ####### | 21 days |

### Pattern Priority
When multiple patterns match, use priority order:
1. San Francisco (most specific)
2. New York
3. Denver
4. Los Angeles (least specific)

## 2.4 Citation Validation

### Purpose
Verify citation exists and retrieve details.

### API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| /health | GET | Service health check |
| /api/citations/validate | POST | Validate citation |
| /api/citations/{id} | GET | Get citation details |
| /api/appeals | POST | Submit appeal |
| /api/status/lookup | GET | Lookup by citation number |

### Validation Response
```json
{
  "is_valid": true,
  "citation": {
    "id": "uuid",
    "citation_number": "SFMTA12345678",
    "city_id": "us-ca-san_francisco",
    "city_name": "San Francisco",
    "agency": "SFMTA",
    "amount": 95.00,
    "violation_date": "2024-01-15",
    "violation_time": "14:30",
    "deadline_date": "2024-02-05",
    "days_remaining": 21,
    "is_past_deadline": false,
    "is_urgent": false,
    "can_appeal_online": true,
    "phone_confirmation_required": true,
    "status": "pending"
  },
  "confidence": 0.95
}
```

## 2.5 Confidence Scoring

### Purpose
Evaluate OCR quality and guide user action.

### Scoring Components

| Component | Weight | Description |
|-----------|--------|-------------|
| Vision Confidence | 40% | OCR engine confidence |
| Pattern Match | 30% | City pattern specificity |
| Completeness | 20% | Length matches expected |
| Consistency | 10% | Observation variance |

### Scoring Levels

| Level | Score | Action |
|-------|-------|--------|
| High | >= 0.85 | Auto-accept |
| Medium | 0.60 - 0.85 | User review |
| Low | < 0.60 | Retake image |

## 2.6 Offline Support

### Purpose
Queue operations when network unavailable.

### Requirements
| ID | Requirement | Priority |
|----|-------------|----------|
| OFF-01 | Queue failed operations | Must |
| OFF-02 | Sync when online | Must |
| OFF-03 | Max queue size (100) | Should |
| OFF-04 | Retry with backoff | Should |
| OFF-05 | Conflict resolution | Could |

### Retry Strategy
- Initial delay: 1 second
- Multiplier: 2x
- Maximum delay: 5 minutes
- Maximum attempts: 3

## 2.7 Telemetry

### Purpose
Improve app through aggregate data (opt-in).

### Tracked Events
- Capture attempts
- OCR success/failure
- Confidence scores
- City distribution
- Processing times

### Data Points (Anonymized)
```json
{
  "event_type": "capture_success",
  "city_id": "us-ca-san_francisco",
  "raw_text": "SFMTA12345678",
  "confidence_score": 0.92,
  "processing_time_ms": 1500,
  "was_accepted": true
}
```

---

# 3. User Workflows

## 3.1 Main Workflow: Capture and Validate

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. User opens app                                               │
│    ↓                                                            │
│ 2. Main screen shows "Capture" button                           │
│    ↓                                                            │
│ 3. Camera preview activates                                      │
│    ↓                                                            │
│ 4. User positions ticket in frame                               │
│    ↓                                                            │
│ 5. User taps capture button                                      │
│    ↓                                                            │
│ 6. App processes image                                          │
│    ├─ OCR extraction                                            │
│    ├─ Pattern matching                                          │
│    └─ Confidence scoring                                        │
│    ↓                                                            │
│ 7. If confidence >= 0.85:                                       │
│    ├─ Auto-validate via API                                     │
│    ├─ Show citation details                                     │
│    └─ User confirms                                            │
│    ↓                                                            │
│ 8. If confidence 0.60-0.85:                                     │
│    ├─ Show extracted text                                       │
│    ├─ User verifies/edits                                       │
│    └─ User confirms to validate                                 │
│    ↓                                                            │
│ 9. If confidence < 0.60:                                        │
│    ├─ Suggest preprocessing options                             │
│    └─ Prompt to retake                                          │
└─────────────────────────────────────────────────────────────────┘
```

## 3.2 Citation Detail Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. Citation validated successfully                              │
│    ↓                                                            │
│ 2. Display details:                                             │
│    ├─ Citation number (formatted)                               │
│    ├─ Amount due                                                │
│    ├─ Violation date/time                                       │
│    ├─ Days remaining                                            │
│    ├─ Deadline status (safe/approaching/urgent/past)            │
│    ├─ Appeal options                                            │
│    └─ Agency contact info                                       │
│    ↓                                                            │
│ 3. User actions:                                                │
│    ├─ Pay (opens payment portal)                                │
│    ├─ Appeal (starts appeal flow)                               │
│    └─ Save to history                                           │
└─────────────────────────────────────────────────────────────────┘
```

## 3.3 Appeal Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. User taps "Appeal" on citation                               │
│    ↓                                                            │
│ 2. Show appeal requirements:                                    │
│    ├─ Deadline (based on city)                                  │
│    ├─ Required information                                      │
│    ├─ Online vs phone options                                   │
│    └─ Phone confirmation if required                            │
│    ↓                                                            │
│ 3. User selects appeal type                                     │
│    ↓                                                            │
│ 4. Collect evidence:                                            │
│    ├─ Written explanation                                       │
│    ├─ Photo evidence upload                                     │
│    ├─ Witness statements (optional)                             │
│    └─ Waive hearing option                                      │
│    ↓                                                            │
│ 5. Submit appeal                                                │
│    ↓                                                            │
│ 6. Show confirmation                                            │
│    └─ Appeal ID for tracking                                    │
└─────────────────────────────────────────────────────────────────┘
```

## 3.4 History Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. User taps "History" tab                                      │
│    ↓                                                            │
│ 2. Show list of citations:                                      │
│    ├─ Sorted by date (newest first)                             │
│    ├─ Grouped by status                                         │
│    └─ Searchable by citation number                             │
│    ↓                                                            │
│ 3. User selects citation                                        │
│    ↓                                                            │
│ 4. Show citation details (same as detail workflow)              │
└─────────────────────────────────────────────────────────────────┘
```

---

# 4. Technical Requirements

## 4.1 Input Requirements

### Camera Input
| Property | Value |
|----------|-------|
| Format | JPEG/PNG |
| Resolution | Min 1920x1080, Max 4096x2160 |
| Color Space | sRGB |
| Orientation | Portrait |

### User Input
| Input Type | Validation |
|------------|------------|
| Citation number | Pattern match per city |
| Appeal reason | Max 2000 characters |
| Email | RFC 5322 format |
| Phone | E.164 format |

## 4.2 Output Requirements

### API Responses
| Format | Encoding |
|--------|----------|
| JSON | UTF-8 |
| HTTP Status | 200, 400, 401, 404, 422, 429, 500 |

### Display
| Element | Format |
|---------|--------|
| Currency | Locale-aware ($95.00) |
| Date | Locale-aware (Jan 15, 2024) |
| Time | 24-hour (14:30) |
| Deadline | Days remaining (21 days) |

## 4.3 Performance Requirements

| Operation | Target | Maximum |
|-----------|--------|---------|
| Camera preview | 30 FPS | 60 FPS |
| Image capture | <1s | 2s |
| OCR processing | <2s | 5s |
| API validation | <1s | 3s |
| App startup | <2s | 5s |
| Screen navigation | <0.5s | 1s |

---

# 5. Data Models

## 5.1 Citation

```
Citation:
  - id: UUID
  - citation_number: String (unique)
  - city_id: String (optional)
  - city_name: String (optional)
  - agency: String (optional)
  - section_id: String (optional)
  - formatted_citation: String (optional)
  - license_plate: String (optional)
  - violation_date: String (ISO 8601, optional)
  - violation_time: String (optional)
  - amount: Decimal (optional)
  - deadline_date: String (ISO 8601, optional)
  - days_remaining: Integer (optional)
  - is_past_deadline: Boolean
  - is_urgent: Boolean
  - can_appeal_online: Boolean
  - phone_confirmation_required: Boolean
  - status: CitationStatus
  - created_at: Timestamp
  - updated_at: Timestamp
```

## 5.2 CitationStatus

```
enum CitationStatus:
  - pending
  - validated
  - in_review
  - appealed
  - approved
  - denied
  - paid
  - expired
```

## 5.3 CityConfig

```
CityConfig:
  - id: String (unique)
  - name: String
  - pattern: String (regex)
  - formatted_pattern: String
  - appeal_deadline_days: Integer
  - phone_confirmation_required: Boolean
  - can_appeal_online: Boolean
```

## 5.4 OCRResult

```
OCRResult:
  - extracted_text: String
  - confidence: ConfidenceResult
  - matched_city_id: String (optional)
  - processing_time_ms: Double
```

## 5.5 ConfidenceResult

```
ConfidenceResult:
  - overall_confidence: Double (0.0-1.0)
  - level: ConfidenceLevel (high/medium/low)
  - components: List[ConfidenceComponent]
  - recommendation: Recommendation (accept/review/reject)
  - should_auto_accept: Boolean

ConfidenceComponent:
  - name: String
  - score: Double (0.0-1.0)
  - weight: Double
  - weighted_score: Double
```

## 5.6 CaptureResult

```
CaptureResult:
  - id: UUID
  - image_data: Binary (optional)
  - image_path: String (optional)
  - ocr_result: OCRResult (optional)
  - captured_at: Timestamp
```

---

# 6. Business Logic

## 6.1 Pattern Matching Algorithm

```
function match_pattern(citation_number):
  patterns = [
    {city: "us-ca-san_francisco", regex: "^(SFMTA|MT)[0-9]{8}$", priority: 1},
    {city: "us-ny-new_york", regex: "^[0-9]{10}$", priority: 2},
    {city: "us-co-denver", regex: "^[0-9]{5,9}$", priority: 3},
    {city: "us-ca-los_angeles", regex: "^[0-9A-Z]{6,11}$", priority: 4}
  ]
  
  for pattern in patterns:
    if regex_match(pattern.regex, citation_number):
      return pattern.city, pattern.priority
  
  return null, 0
```

## 6.2 Confidence Scoring Algorithm

```
function calculate_confidence(raw_text, observations, matched_city_id):
  components = []
  
  # Vision confidence (40%)
  vision = average(observations.confidence)
  components.append({name: "vision", score: vision, weight: 0.40})
  
  # Pattern confidence (30%)
  pattern = get_pattern_confidence(matched_city_id)
  components.append({name: "pattern", score: pattern, weight: 0.30})
  
  # Completeness (20%)
  completeness = calculate_completeness(raw_text, matched_city_id)
  components.append({name: "completeness", score: completeness, weight: 0.20})
  
  # Consistency (10%)
  consistency = calculate_consistency(observations)
  components.append({name: "consistency", score: consistency, weight: 0.10})
  
  overall = sum(component.score * component.weight)
  
  return {
    overall_confidence: overall,
    level: determine_level(overall),
    components: components,
    recommendation: determine_recommendation(level),
    should_auto_accept: level == "high"
  }
```

## 6.3 Deadline Status Algorithm

```
function calculate_deadline_status(citation):
  if citation.is_past_deadline:
    return "past"
  else if citation.is_urgent:
    return "urgent"
  else if citation.days_remaining <= 7:
    return "approaching"
  else:
    return "safe"
```

## 6.4 Retry Logic

```
function execute_with_retry(operation, max_attempts=3):
  delay = 1.0  # seconds
  multiplier = 2.0
  max_delay = 300.0  # 5 minutes
  
  for attempt in 1..max_attempts:
    try:
      return operation()
    except NetworkError:
      if attempt < max_attempts:
        sleep(delay)
        delay = min(delay * multiplier, max_delay)
      else:
        raise RetryExhaustedError
```

---

# 7. Platform Abstractions

## 7.1 Camera Abstraction

```
protocol CameraManager:
  async func requestAuthorization() -> Bool
  var isAuthorized: Bool
  var isSessionRunning: Bool
  var currentPosition: CameraPosition
  
  async func setupSession()
  async func startSession()
  async func stopSession()
  async func capturePhoto() -> Data
  async func switchCamera()
  async func setZoom(factor: Float)
  async func toggleTorch()
  async func setTorch(level: Float)

enum CameraPosition:
  - back
  - front
```

**iOS Implementation:** AVFoundation  
**Android Implementation:** CameraX  
**Web Implementation:** MediaDevices API  
**Test Implementation:** MockCameraManager

## 7.2 OCR Abstraction

```
protocol OCREngine:
  async func recognizeText(
    imageData: Data,
    configuration: OCRConfiguration
  ) -> OCRRecognitionResult
  
  async func recognizeWithHighAccuracy(imageData: Data) -> OCRRecognitionResult
  async func recognizeFast(imageData: Data) -> OCRRecognitionResult

struct OCRConfiguration:
  recognitionLevel: RecognitionLevel  # fast/accurate
  usesLanguageCorrection: Bool
  recognitionLanguages: [String]
  autoDetectLanguage: Bool

struct OCRRecognitionResult:
  text: String
  observations: [OCObservation]
  confidence: Double
  processingTime: Double
  matchedCityId: String (optional)
```

**iOS Implementation:** Vision Framework  
**Android Implementation:** ML Kit  
**Web Implementation:** Tesseract.js  
**Test Implementation:** MockOCREngine

## 7.3 Network Abstraction

```
protocol APIClient:
  async func perform(request: APIRequest) -> APIResponse
  func setAuthorizationToken(token: String?)
  func clearAuthorization()

struct APIRequest:
  path: String
  method: HTTPMethod  # GET/POST/PUT/PATCH/DELETE
  queryItems: [URLQueryItem] (optional)
  headers: [String: String]
  body: Data (optional)

struct APIResponse:
  statusCode: Integer
  body: Data (optional)
  headers: [String: String]

enum HTTPMethod:
  - get
  - post
  - put
  - patch
  - delete
```

**iOS Implementation:** URLSession  
**Android Implementation:** Retrofit/OkHttp  
**Web Implementation:** fetch API  
**Test Implementation:** MockAPIClient

## 7.4 Storage Abstraction

```
protocol Storage:
  func save(key: String, data: Data) -> Bool
  func load(key: String) -> Data (optional)
  func delete(key: String) -> Bool
  func exists(key: String) -> Bool
  func list(prefix: String) -> [String]

protocol KeyValueStore:
  func set(key: String, value: String)
  func get(key: String) -> String (optional)
  func delete(key: String)
  func clear()
```

**iOS Implementation:** UserDefaults, FileManager  
**Android Implementation:** SharedPreferences, Room  
**Web Implementation:** localStorage, IndexedDB  
**Test Implementation:** InMemoryStorage

---

# 8. Quality Standards

## 8.1 Test Coverage Requirements

| Component | Minimum Coverage |
|-----------|------------------|
| Business Logic | 90% |
| Data Models | 100% |
| API Client | 85% |
| Pattern Matching | 100% |
| Confidence Scoring | 100% |
| Overall | 80% |

## 8.2 Test Types

### Unit Tests
- Test individual functions in isolation
- Mock all external dependencies
- Cover edge cases

### Integration Tests
- Test component interactions
- Test API integration
- Test storage operations

### End-to-End Tests
- Test complete user workflows
- Test offline/online transitions
- Test error scenarios

## 8.3 Accessibility Requirements

| Requirement | Standard |
|-------------|----------|
| Screen readers | WCAG 2.1 AA |
| Color contrast | 4.5:1 minimum |
| Touch targets | 44x44 points minimum |
| VoiceOver/TalkBack | Full support |

## 8.4 Security Requirements

| Requirement | Implementation |
|-------------|----------------|
| Data encryption | TLS 1.2+ for transit |
| Local storage | Keychain/Keystore |
| API authentication | JWT tokens |
| Input validation | Server + client |
| Certificate pinning | Optional |

---

# 9. Non-Functional Requirements

## 9.1 Performance

| Metric | Target |
|--------|--------|
| Cold start time | < 5 seconds |
| Memory usage | < 100 MB |
| Battery impact | < 5% per hour |
| Network requests | Batch where possible |
| Offline storage | < 50 MB |

## 9.2 Reliability

| Metric | Target |
|--------|--------|
| Uptime | 99.9% |
| Crash rate | < 0.1% |
| OCR success rate | > 95% |
| API success rate | > 99% |

## 9.3 Scalability

- Support 100,000+ active users
- Handle 1000+ concurrent requests
- Scale API horizontally

## 9.4 Compatibility

| Platform | Minimum Version |
|----------|-----------------|
| iOS | 15.0 |
| Android | 8.0 (API 26) |
| Web | Modern browsers (ES2020) |

---

# 10. Future Considerations

## 10.1 Planned Features

| Feature | Priority | Target |
|---------|----------|--------|
| Multiple language support | High | v2.0 |
| Payment integration | High | v2.0 |
| Push notifications | Medium | v2.1 |
| Apple Watch app | Low | v3.0 |
| Android Wear support | Low | v3.0 |

## 10.2 Potential Expansions

### Additional Cities
- Chicago
- Boston
- Seattle
- Portland
- Austin

### Additional Ticket Types
- Traffic camera violations
- Red light citations
- Speed camera tickets
- Parking permits

### Additional Services
- Traffic court date scheduling
- Lawyer matching
- Ticket dispute templates

## 10.3 Technology Evolution

| Technology | Current | Future Consideration |
|------------|---------|---------------------|
| OCR | Traditional ML | On-device ML models |
| Backend | REST API | GraphQL |
| Database | PostgreSQL | Serverless |
| Authentication | JWT | Passkeys/WebAuthn |

---

# Appendix A: API Reference

## A.1 Validate Citation

```
POST /api/citations/validate

Request:
{
  "citation_number": "SFMTA12345678",
  "city_id": "us-ca-san_francisco"  // optional
}

Response (200):
{
  "is_valid": true,
  "citation": { ... },
  "confidence": 0.95
}

Response (404):
{
  "error": "Citation not found",
  "code": "NOT_FOUND"
}

Response (422):
{
  "error": "Invalid citation format",
  "code": "VALIDATION_ERROR"
}
```

## A.2 Submit Appeal

```
POST /api/appeals

Request:
{
  "citation_id": "uuid",
  "reason": "I was not parked there",
  "evidence": ["photo1.jpg", "photo2.jpg"],
  "waive_hearing": true
}

Response (202):
{
  "appeal_id": "uuid",
  "status": "submitted",
  "next_steps": "You will receive a hearing date within 30 days"
}
```

---

# Appendix B: Error Codes

| Code | Message | HTTP Status |
|------|---------|-------------|
| INVALID_URL | Invalid URL | 400 |
| INVALID_RESPONSE | Invalid server response | 500 |
| DECODING_ERROR | Failed to decode response | 500 |
| BAD_REQUEST | Invalid request | 400 |
| UNAUTHORIZED | Authentication required | 401 |
| NOT_FOUND | Resource not found | 404 |
| VALIDATION_ERROR | Validation failed | 422 |
| RATE_LIMITED | Too many requests | 429 |
| SERVER_ERROR | Server error | 500 |
| NETWORK_UNAVAILABLE | Network unavailable | N/A |

---

# Appendix C: Glossary

| Term | Definition |
|------|------------|
| Citation | Official parking ticket document |
| OCR | Optical Character Recognition |
| Pattern | Regular expression for citation format |
| Confidence | Probability score (0.0-1.0) |
| Deadline | Final date for payment or appeal |
| Appeal | Formal request to contest a ticket |
| Telemetry | Anonymous usage data collection |
| Queue | Pending operations list |

---

# Document Metadata

| Property | Value |
|----------|-------|
| Version | 1.0 |
| Created | 2024-01-28 |
| Author | FightCityTickets Team |
| Status | Draft |

**This specification is language and platform agnostic. Implementations may vary in structure and naming while maintaining the same functionality and behavior.**
