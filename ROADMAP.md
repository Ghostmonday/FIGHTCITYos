# FightCityTickets - Complete Roadmap to Revenue

## Current Status
- **Platform**: Linux development environment
- **iOS Code**: Clean, bug-free, ready for Xcode build
- **Backend**: FastAPI (needs deployment)
- **Revenue Model**: Not yet implemented

---

## Phase 1: Linux Development (Current Phase)

### 1.1 Backend API Development & Deployment
**Goal**: Get the backend API live and functional

| Task | Status | Priority |
|------|--------|----------|
| Create FastAPI backend matching `APIEndpoints.swift` | Pending | Critical |
| Implement `/health` endpoint | Pending | Critical |
| Implement `/api/citations/validate` endpoint | Pending | Critical |
| Implement `/api/appeals` endpoint | Pending | High |
| Implement `/api/status/lookup` endpoint | Pending | High |
| Implement `/mobile/ocr/telemetry` endpoint | Pending | Medium |
| Set up PostgreSQL database | Pending | Critical |
| Create Citation database models | Pending | Critical |
| Add rate limiting (429 responses) | Pending | High |
| Add input validation (422 responses) | Pending | High |
| Deploy to cloud (Railway/Render/Fly.io) | Pending | Critical |
| Set up HTTPS with valid certificate | Pending | Critical |
| Configure production environment variables | Pending | Critical |

**Deliverable**: Live API at `https://api.fightcitytickets.com`

### 1.2 City Data Population
**Goal**: Have real citation validation data

| Task | Status | Priority |
|------|--------|----------|
| Research SF (SFMTA) citation database APIs | Pending | High |
| Research LA (LADOT) citation lookup | Pending | High |
| Research NYC (DOF) citation lookup | Pending | High |
| Research Denver citation lookup | Pending | High |
| Implement web scraping/API integration per city | Pending | High |
| Create mock data for testing | Pending | Medium |

### 1.3 Unit Tests (Linux-Compatible)
**Goal**: 80%+ test coverage

| Task | Status | Priority |
|------|--------|----------|
| Create `Tests/` directory structure | Pending | High |
| Unit tests for `OCRParsingEngine` | Pending | High |
| Unit tests for `ConfidenceScorer` | Pending | High |
| Unit tests for `Citation` Codable | Pending | High |
| Unit tests for `OfflineManager` queue | Pending | Medium |
| Unit tests for `APIClient` (mocked) | Pending | Medium |
| Integration tests for API endpoints | Pending | Medium |
| Set up GitHub Actions CI | Pending | High |

**Run with**: `swift test` (via Docker on Linux)

### 1.4 Replace Print Statements with Logging
**Goal**: Production-ready logging

| Task | Status | Priority |
|------|--------|----------|
| Create `Logger` utility using `os.log` | Pending | Medium |
| Replace all `print()` calls | Pending | Medium |
| Add log levels (debug, info, warning, error) | Pending | Medium |

### 1.5 Web Assets Preparation
**Goal**: Complete web presence

| Task | Status | Priority |
|------|--------|----------|
| Create landing page (fightcitytickets.com) | Pending | High |
| Create privacy policy page | Pending | Critical |
| Create terms of service page | Pending | High |
| Create support page with contact form | Pending | High |
| Set up domain and hosting | Pending | High |

---

## Phase 2: Revenue Model Implementation

### 2.1 Choose Revenue Strategy

**Option A: Freemium + Subscription**
- Free: 3 citation scans/month
- Pro ($4.99/month or $29.99/year):
  - Unlimited scans
  - Appeal templates
  - Priority support
  - Deadline reminders

**Option B: Per-Appeal Fee**
- Free: Scan and validate
- $9.99: Appeal filing assistance
- $29.99: Full appeal with template + tracking

**Option C: Referral/Affiliate**
- Free app
- Partner with traffic lawyers
- Earn commission on referrals

**Recommended**: Option A (Freemium) - recurring revenue, predictable

### 2.2 Implement In-App Purchases (StoreKit 2)

| Task | Status | Priority |
|------|--------|----------|
| Create `SubscriptionManager.swift` | Pending | Critical |
| Define products in App Store Connect | Pending | Critical |
| Implement purchase flow UI | Pending | Critical |
| Implement restore purchases | Pending | Critical |
| Add paywall screen | Pending | High |
| Track usage limits (free tier) | Pending | High |
| Server-side receipt validation | Pending | High |
| Handle subscription status | Pending | High |

### 2.3 Backend Revenue Support

| Task | Status | Priority |
|------|--------|----------|
| Add user accounts/authentication | Pending | High |
| Track user subscription status | Pending | High |
| Implement usage limits per user | Pending | High |
| Receipt validation endpoint | Pending | High |

---

## Phase 3: Pre-Mac Preparation (All on Linux)

### 3.1 App Store Connect Setup (Web-Based)

| Task | Status | Priority |
|------|--------|----------|
| Apple Developer Program ($99/year) | Pending | Critical |
| Create app in App Store Connect | Pending | Critical |
| Set Bundle ID: com.fightcitytickets.app | Pending | Critical |
| Write app description (4000 chars) | Pending | High |
| Write keywords (100 chars) | Pending | High |
| Complete age rating questionnaire | Pending | High |
| Set up in-app purchase products | Pending | High |
| Complete App Privacy section | Pending | Critical |

### 3.2 Design Assets

| Task | Status | Priority |
|------|--------|----------|
| App icon (1024x1024 PNG) | Pending | Critical |
| Screenshot mockups (all sizes) | Pending | High |
| App preview video (optional) | Pending | Low |
| Feature graphics for marketing | Pending | Low |

### 3.3 Final Code Review

| Task | Status | Priority |
|------|--------|----------|
| Run `swift build` in Docker | Pending | Critical |
| Verify no TODO/FIXME comments | Pending | High |
| Verify all error handling | Pending | High |
| Verify offline functionality | Pending | High |
| Update version to 1.0.0 | Pending | High |

---

## Phase 4: Mac Day (Rent Mac for 1-2 Days)

### 4.1 Setup (30 minutes)

| Task | Time | Priority |
|------|------|----------|
| Clone repository | 5 min | Critical |
| Install Xcode (if not installed) | 20 min | Critical |
| Install XcodeGen | 2 min | Critical |
| Run `xcodegen generate` | 1 min | Critical |
| Open `.xcodeproj` | 1 min | Critical |

### 4.2 Build & Fix (2-4 hours)

| Task | Time | Priority |
|------|------|----------|
| Resolve any Xcode-specific errors | 1-2 hr | Critical |
| Configure code signing | 30 min | Critical |
| Test on iOS Simulator | 1 hr | Critical |
| Test on real device (if available) | 1 hr | High |
| Fix any UI issues | 1 hr | High |

### 4.3 Polish (2-3 hours)

| Task | Time | Priority |
|------|------|----------|
| Test all user flows | 1 hr | Critical |
| Take real screenshots | 1 hr | Critical |
| Test in-app purchases (sandbox) | 1 hr | Critical |
| Performance testing | 30 min | High |
| Accessibility testing | 30 min | Medium |

### 4.4 Submit (1-2 hours)

| Task | Time | Priority |
|------|------|----------|
| Archive build | 10 min | Critical |
| Validate build | 10 min | Critical |
| Upload to App Store Connect | 20 min | Critical |
| Upload screenshots | 30 min | Critical |
| Final review of listing | 20 min | Critical |
| Submit for review | 10 min | Critical |

---

## Phase 5: Post-Submission

### 5.1 Wait for Review (24-48 hours typically)

| Task | Status | Priority |
|------|--------|----------|
| Monitor App Store Connect status | Pending | Critical |
| Prepare responses for potential rejection | Pending | Medium |
| Test production API | Pending | High |

### 5.2 If Rejected

| Task | Status | Priority |
|------|--------|----------|
| Read rejection reason carefully | - | Critical |
| Fix issues on Linux | - | Critical |
| Re-rent Mac for resubmission | - | Critical |
| Resubmit | - | Critical |

### 5.3 Launch Activities

| Task | Status | Priority |
|------|--------|----------|
| Announce on social media | Pending | High |
| Submit to Product Hunt | Pending | Medium |
| Reach out to local news/blogs | Pending | Medium |
| Set up analytics (Firebase/Mixpanel) | Pending | High |
| Set up crash reporting (Sentry/Crashlytics) | Pending | High |

---

## Phase 6: Post-Launch Growth

### 6.1 User Acquisition

| Task | Status | Priority |
|------|--------|----------|
| ASO (App Store Optimization) | Pending | High |
| Google Ads for app installs | Pending | Medium |
| Content marketing (blog posts) | Pending | Medium |
| Social media presence | Pending | Medium |
| Referral program | Pending | Medium |

### 6.2 Retention & Engagement

| Task | Status | Priority |
|------|--------|----------|
| Push notifications for deadlines | Pending | High |
| Email reminders (with permission) | Pending | Medium |
| In-app tips and guidance | Pending | Medium |

### 6.3 Iterate Based on Feedback

| Task | Status | Priority |
|------|--------|----------|
| Monitor App Store reviews | Pending | High |
| Implement user-requested features | Pending | Medium |
| A/B test pricing | Pending | Medium |
| Expand to more cities | Pending | High |

---

## Revenue Projections

### Conservative Estimates

| Metric | Month 1 | Month 3 | Month 6 | Year 1 |
|--------|---------|---------|---------|--------|
| Downloads | 500 | 2,000 | 5,000 | 15,000 |
| Free users | 450 | 1,800 | 4,500 | 13,500 |
| Paid subscribers | 25 | 100 | 250 | 750 |
| Monthly revenue | $125 | $500 | $1,250 | $3,750 |
| ARR | - | - | - | $45,000 |

### Assumptions
- 5% free-to-paid conversion
- $4.99/month subscription
- 10% monthly churn
- Organic growth via ASO

---

## Immediate Next Steps (This Week)

### Priority 1: Backend API
```bash
# Create FastAPI project structure
mkdir -p backend/{app,tests}
cd backend
python -m venv venv
source venv/bin/activate
pip install fastapi uvicorn sqlalchemy psycopg2-binary pydantic
```

Key endpoints to implement first:
1. `POST /api/citations/validate`
2. `GET /health`

### Priority 2: Unit Tests
```bash
# Run Swift tests via Docker
docker run -v $(pwd):/workspace -w /workspace swift:5.9 swift test
```

### Priority 3: Web Presence
- Domain: fightcitytickets.com
- Hosting: Vercel/Netlify (free tier)
- Pages: Landing, Privacy, Terms, Support

---

## Timeline Summary

| Phase | Duration | Effort |
|-------|----------|--------|
| Phase 1: Linux Development | 2-3 weeks | High |
| Phase 2: Revenue Model | 1 week | Medium |
| Phase 3: Pre-Mac Prep | 3-5 days | Medium |
| Phase 4: Mac Day | 1-2 days | Intense |
| Phase 5: Review Wait | 1-3 days | Low |
| Phase 6: Post-Launch | Ongoing | Medium |

**Total to App Store**: ~4-5 weeks
**Total to First Revenue**: ~5-6 weeks

---

## Success Criteria

### Launch Criteria
- [ ] App approved on App Store
- [ ] Backend API 99.9% uptime
- [ ] In-app purchases functional
- [ ] 4 cities supported
- [ ] Privacy policy compliant

### 30-Day Criteria
- [ ] 500+ downloads
- [ ] 25+ paid subscribers
- [ ] 4.0+ star rating
- [ ] <1% crash rate
- [ ] <5% refund rate

### 90-Day Criteria
- [ ] 2,000+ downloads
- [ ] 100+ paid subscribers
- [ ] $500+/month revenue
- [ ] 2+ new cities added
- [ ] 4.5+ star rating

---

## Resources Needed

### Services (Monthly Costs)
| Service | Purpose | Cost |
|---------|---------|------|
| Apple Developer | App Store | $99/year |
| Backend hosting | API | $5-20/month |
| Database | PostgreSQL | $5-15/month |
| Domain | Website | $12/year |
| Mac rental | Build/submit | $20-50/day |

### Estimated Launch Cost: $150-300

---

## Risk Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| App rejection | Medium | High | Follow guidelines, test thoroughly |
| Backend downtime | Low | High | Use reliable hosting, monitoring |
| Low conversion | Medium | Medium | A/B test pricing, improve value |
| City API changes | Medium | Medium | Abstract integrations, monitor |
| Competition | Low | Medium | Focus on UX, add unique features |

---

**Document Version**: 1.0
**Last Updated**: 2025-01-28
**Next Review**: After Phase 1 completion
