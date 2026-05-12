# MindPath — App Features & Implementation Detail (Current State)

This document summarizes what is implemented so far in the MindPath Flutter app (GetX + Firebase + local LLM backend), what is partially implemented, what is pending, and where to find the key code.

---

## 1) Tech Stack

### Mobile app
- Flutter (Material 3)
- GetX (routing, bindings, controllers, reactive UI)
- Firebase:
  - `firebase_core`
  - `firebase_auth`
  - `cloud_firestore`
- Google Sign-In (`google_sign_in`)
- PDF export (`pdf`, `printing`)
- Persistent settings storage: `get_storage` (for language persistence)
- i18n: GetX translations + `flutter_localizations` delegates + `intl`

### Local LLM backend
- FastAPI + Pydantic (Python)
- Uses a llama.cpp OpenAI-compatible server upstream when available (`/v1/chat/completions`)
- Has deterministic fallback logic when upstream is not available

---

## 2) App Architecture (GetX Pattern)

### Key ideas
- Each screen typically has:
  - `View` (UI)
  - `Controller` (state + business logic)
  - `Binding` (dependency injection)
- Navigation uses GetX named routes.
- Reactive UI uses `Obx()` and Rx variables in controllers.

### Core folders
- `lib/core/`:
  - routing: `app_routes.dart`, `app_pages.dart`
  - controllers: `core/controllers/*`
  - services: `core/services/*`
  - models: `core/models/*`
  - translations: `core/translations/*`
- `lib/screens/`:
  - feature screens (dashboard tabs + detail flows)
- `backend/llm/`:
  - FastAPI app + local run scripts

---

## 3) Navigation Flow (Current)

### Routes
File: `lib/core/app_routes.dart`
- `/` → Splash
- `/sign-in` → Login/Signup screen
- `/complete-profile` → onboarding profile completion
- `/mood-check` → mood input + LLM analysis
- `/dashboard` → main app with 4 tabs
- Journal-related:
  - `/journal-input`
  - `/journal-detail`
  - `/journal-entry-detail`
  - `/activity-timer`
- `/edit-profile`
- `/next` (placeholder)

### Route registration
File: `lib/core/app_pages.dart`

### Startup routing logic (Auth state machine)
File: `lib/core/controllers/auth_controller.dart`
- If NOT logged in → `/sign-in`
- If logged in:
  - fetch Firestore user profile
  - if profile missing → `/complete-profile`
  - if profile exists but `hasCompletedFirstMoodAnalysis == false` → `/mood-check`
  - else → `/dashboard`

### Splash behavior
- If user is logged in, splash does not show “Get Started”
- If user is not logged in, splash shows “Get Started” and waits for user action
File: `lib/screens/splash/splash_view.dart` + `lib/screens/splash/splash_controller.dart`

---

## 4) Firebase / Firestore Data Model (Implemented)

### users (profile)
Model: `lib/core/models/app_user.dart`
Key fields:
- `userId`
- `name`
- `email`
- `age?`
- `gender?`
- `profileImage?`
- `hasCompletedFirstMoodAnalysis?` (used for gating first mood flow)
- `createdAt`, `updatedAt`

Service/controller:
- `lib/core/services/user_service.dart`
- `lib/core/controllers/user_controller.dart`

### mood_records (append-only mood history)
Model: `lib/core/models/mood_record.dart`
Create fields:
- `userId`
- `timestamp` (server timestamp)
- `moodLabel`
- `moodText`
- `moodScore` (0–10)
- `sentiment`
- `emotion`
- `insight`

Service:
- `lib/core/services/mood_service.dart`
  - create record
  - stream latest records (used by Home)

### journals (journal history + LLM results)
Model: `lib/core/models/journal_entry.dart`
Fields:
- `journalId` (stored but doc id is also used)
- `userId`
- `text`
- `sentiment`
- `emotion`
- `insight`
- `tags` (list)
- `activityType` (journal)
- `createdAt` (server timestamp)
- `title` (auto-generated)

Service:
- `lib/core/services/journal_service.dart`

### activity_logs (non-text activities)
Model: `lib/core/models/activity_log.dart`
Fields:
- `userId`
- `activityType` (breathing / walk / etc.)
- `duration` (seconds)
- `createdAt` (server timestamp)

Service:
- `lib/core/services/journal_service.dart` (`logActivity`)

---

## 5) Features Implemented (End-to-End)

### A) Authentication + onboarding
- Email/password login + signup
- Google Sign-In
- Complete Profile screen (name, age, gender)
- Edit Profile screen
- Logout with confirmation
Key files:
- `lib/screens/sign_in/*`
- `lib/screens/complete_profile/*`
- `lib/screens/edit_profile/*`
- `lib/core/controllers/auth_controller.dart`
- `lib/core/services/auth_service.dart`

### B) Dashboard + 4 tabs
- Dashboard container with bottom navigation
- Separated tab screens:
  - Home
  - Journal
  - Insights
  - Profile/Settings
Key files:
- `lib/screens/dashboard/*`
- `lib/screens/home/*`
- `lib/screens/journal/*`
- `lib/screens/insights/*`
- `lib/screens/profile/*`

### C) Mood check-in + LLM + history
- Mood input includes label + score + journal note
- Each submission:
  - fetches previous mood records (history)
  - sends latest + history to LLM
  - stores a new `mood_records` document (append-only)
  - sets `hasCompletedFirstMoodAnalysis = true` on first completion
- LLM response includes:
  - sentiment
  - emotion
  - insight
  - progression (vs previous state)
Key files:
- `lib/screens/mood_check/*`
- `lib/core/services/llm_service.dart`
- `lib/core/services/mood_service.dart`

### D) Home dashboard dynamic metrics (live Firestore)
- Watches `mood_records` in real time
- Recomputes dashboard metrics when records change
Key files:
- `lib/screens/home/home_controller.dart`
- `lib/screens/home/home_view.dart`

### E) Insights (dynamic)
- Weekly vs Monthly toggle (updates graph + computed stats)
- Export summary as PDF (share sheet)
- Detail screen / insight modal for entries (interactive)
Key files:
- `lib/screens/insights/*`
- `lib/screens/journal_entry_detail/*`

### F) Journal Tab (dynamic, no static data)
Implements the full journaling system with LLM reflection and activity logging:
- Activities:
  - Breathing exercise → timer screen (5 min) → saves activity log
  - Take a walk → timer screen (10 min) → saves activity log
  - Journaling prompt → journal input screen → LLM analyze → store in Firestore
- Journal history:
  - Firestore stream → list
  - Empty state
- Journal detail:
  - View full text, emotion badge, tags, AI insight
  - Edit: re-call LLM → update Firestore
  - Delete: delete document → UI updates instantly
Key files:
- `lib/screens/journal/*`
- `lib/screens/journal_input/*`
- `lib/screens/journal_detail/*`
- `lib/screens/activity_timer/*`
- `lib/core/services/journal_service.dart`
- `lib/core/services/llm_service.dart`

### G) Reusable button component
- App-wide reusable `CustomButton` with optional prefix/suffix
Key files:
- `lib/widgets/custom_button.dart`
- `lib/widgets/primary_button.dart` (compat wrapper)

---

## 6) Local LLM Backend (Implemented)

Backend location:
- `backend/llm/api/main.py`
- run script: `backend/llm/run_api.sh`

### Endpoints
- `GET /health`
- `POST /mood/analyze`
- `POST /journal/insight`
- `POST /journal/analyze`
- `POST /journal/deep_insight`

### Upstream model (optional)
- Uses llama.cpp OpenAI-compatible endpoint:
  - `${LLAMA_CPP_BASE_URL}/v1/chat/completions` (default `http://127.0.0.1:8080`)
- If upstream is not running, backend falls back to heuristic responses (returns 200 with a safe response).

### Mobile networking
- Android emulator must use host loopback mapping:
  - base URL: `http://10.0.2.2:8000`
- iOS simulator / macOS can use:
  - base URL: `http://127.0.0.1:8000`

Client file:
- `lib/core/services/llm_service.dart`

---

## 7) Bilingual Support (English + Urdu) — Current Status

### Infrastructure implemented
- GetX translations wired in `GetMaterialApp`
- `LanguageController` persists locale via `get_storage`
- RTL/LTR direction set via `Directionality` in app builder
- Flutter localization delegates enabled (`flutter_localizations`) so Material/Cupertino widgets support `ur_PK`

Key files:
- `lib/core/translations/app_translations.dart`
- `lib/core/translations/en_US.dart`
- `lib/core/translations/ur_PK.dart`
- `lib/features/profile/controllers/language_controller.dart`
- `lib/main.dart`
- Profile toggle: `lib/screens/profile/profile_view.dart`

### LLM Urdu output wiring
- When Urdu is active, the app sends `languageInstruction` to the backend and also appends Urdu instruction to prompts (so AI output comes back in Urdu).
Client: `lib/core/services/llm_service.dart`
Backend: `backend/llm/api/main.py`

### Coverage note
- Translation infrastructure is working.
- Some screens/controllers have been converted to `.tr` already (Splash, Profile, Sign-In, parts of Mood Check, parts of Journal, some Home strings).
- Full app-wide string replacement + full RTL mirroring is still in progress.

---

## 8) Known Issues / Current Gaps

### A) Firestore PERMISSION_DENIED
Runtime logs show:
- `Missing or insufficient permissions` for queries like `journals where userId == ...`

Meaning:
- Firestore security rules currently don’t allow the authenticated user to read/write these collections.

Impact:
- Journal history and related Firestore streams will fail until rules are updated.

### B) Emulator Google Play services warnings
Logs include `DEVELOPER_ERROR` from some Google Play services components on emulator; not always fatal, but can affect Google Sign-In if emulator image/config is incompatible.

### C) i18n completeness
- Infrastructure is implemented, but not every single UI string is migrated yet.
- Not all left/right paddings and alignments have been converted to Directional variants.

---

## 9) What’s Pending (Next Work Items)

### High priority
- Firestore security rules: allow per-user access for:
  - `users`
  - `mood_records`
  - `journals`
  - `activity_logs`
- Complete i18n conversion:
  - Replace all remaining hardcoded user-facing strings with `.tr`
  - Ensure `ur_PK.dart` fully covers all keys used
  - Convert remaining `EdgeInsets.only(left/right)` and `Alignment.centerLeft/Right` to directional versions

### Medium priority
- Production hardening:
  - Better error surfaces for network failures (LLM + Firestore)
  - Add tests for services/controllers

### Optional
- OS-level notifications for nudges (true scheduled notifications)
- Offline caching / persistence for Firestore queries
- More advanced insights analytics

---

## 10) How to Run (Dev)

### Run the Flutter app
From project root:
1) `flutter pub get`
2) `flutter run -d emulator-5554`

### Run the local LLM backend
From `backend/llm`:
1) Create venv + install requirements (if not already):
   - `python3 -m venv .venv`
   - `. .venv/bin/activate`
   - `pip install -r requirements.txt`
2) Start API:
   - `./run_api.sh`
3) Health check:
   - `curl http://127.0.0.1:8000/health`

### Point app to backend
- Android emulator: `--dart-define=LLM_API_BASE_URL=http://10.0.2.2:8000`
- iOS simulator: `--dart-define=LLM_API_BASE_URL=http://127.0.0.1:8000`

---

## 11) Key Files Index (Quick Reference)

### App root + routing
- `lib/main.dart`
- `lib/core/app_routes.dart`
- `lib/core/app_pages.dart`

### Auth + user profile
- `lib/core/controllers/auth_controller.dart`
- `lib/core/controllers/user_controller.dart`
- `lib/core/services/auth_service.dart`
- `lib/core/services/user_service.dart`
- `lib/core/models/app_user.dart`

### Mood analysis + history
- `lib/screens/mood_check/*`
- `lib/core/services/mood_service.dart`
- `lib/core/models/mood_record.dart`
- `lib/core/services/llm_service.dart`

### Home dashboard
- `lib/screens/home/*`

### Journal system
- `lib/screens/journal/*`
- `lib/screens/journal_input/*`
- `lib/screens/journal_detail/*`
- `lib/screens/activity_timer/*`
- `lib/core/services/journal_service.dart`
- `lib/core/models/journal_entry.dart`
- `lib/core/models/activity_log.dart`

### Insights
- `lib/screens/insights/*`
- `lib/screens/journal_entry_detail/*`

### Profile/settings
- `lib/screens/profile/*`
- `lib/features/profile/controllers/language_controller.dart`

### i18n
- `lib/core/translations/*`

### Backend
- `backend/llm/api/main.py`
- `backend/llm/run_api.sh`
- `backend/llm/requirements.txt`

