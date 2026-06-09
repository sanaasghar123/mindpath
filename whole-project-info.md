# MindPath — Whole Project Info (Admin Panel Reference)

> **Purpose:** Hand this single file to any AI agent or developer to scaffold the complete MindPath Admin Panel Flutter Web project from scratch. It contains every data model, Firestore schema, metric formula, color token, routing plan, state management guide, and feature spec needed.

---

## 1. What is MindPath?

MindPath is a mental wellness mobile app (Flutter + Firebase + local LLM backend). Users log mood check-ins and journal entries; an AI backend analyzes them and returns personalized emotional insights. The **Admin Panel** is a separate **Flutter Web** app that connects to the **same Firebase project** and gives administrators a read/write dashboard over all app data.

---

## 2. Firebase Project Details

| Key | Value |
|---|---|
| Project ID | `mindpath-78281` |
| Android API Key | `AIzaSyDArM6iO5vj7XWh-7exdxfvNAHiGI99zg4` |
| Messaging Sender ID | `333096362543` |
| Storage Bucket | `mindpath-78281.firebasestorage.app` |

> The admin panel needs its own `FirebaseOptions` for **web** platform. Run `flutterfire configure` targeting the same project to generate the web config, then add it to `firebase_options.dart`.


---

## 3. Firestore Collections & Exact Field Names

### 3.1 `users`
| Field | Type | Notes |
|---|---|---|
| `userId` | String | Same as Firebase Auth UID, also the document ID |
| `name` | String | Display name |
| `email` | String | |
| `age` | int? | Optional |
| `gender` | String? | `"Male"` / `"Female"` / `"Other"` |
| `profileImage` | String? | URL string |
| `hasCompletedFirstMoodAnalysis` | bool? | Onboarding gate flag |
| `createdAt` | Timestamp | Server timestamp on create |
| `updatedAt` | Timestamp | Server timestamp on every update |

### 3.2 `mood_records`
| Field | Type | Notes |
|---|---|---|
| `userId` | String | Foreign key → users |
| `timestamp` | Timestamp | Server timestamp (FieldValue.serverTimestamp()) |
| `moodLabel` | String | `"grateful"` / `"neutral"` / `"pensive"` / `"down"` / `"tense"` |
| `moodText` | String | Free-text note written by user |
| `moodScore` | double | 0–10 scale (grateful=8.5, neutral=6.0, pensive=5.0, down=3.0, tense=2.5) |
| `sentiment` | String | `"positive"` / `"neutral"` / `"negative"` (from LLM) |
| `emotion` | String | `"stress"/"anxiety"/"calm"/"joy"/"sadness"/"anger"/"fatigue"/"overwhelm"/"other"` |
| `insight` | String | 1–2 sentence compassionate insight from LLM |

### 3.3 `journals`
| Field | Type | Notes |
|---|---|---|
| `journalId` | String | Stored inside doc (same as doc ID) |
| `userId` | String | Foreign key → users |
| `text` | String | Full journal entry text |
| `title` | String | Auto-generated title |
| `sentiment` | String | `"positive"` / `"neutral"` / `"negative"` |
| `emotion` | String | Same enum as mood_records |
| `insight` | String | AI insight text |
| `tags` | List\<String\> | e.g. `["stress", "work", "family"]` |
| `activityType` | String | `"journal"` / `"breathing"` / `"walk"` |
| `createdAt` | Timestamp | Server timestamp |

### 3.4 `activity_logs`
| Field | Type | Notes |
|---|---|---|
| `userId` | String | Foreign key → users |
| `activityType` | String | `"breathing"` / `"walk"` |
| `duration` | int | Duration in **seconds** |
| `createdAt` | Timestamp | Server timestamp |


---

## 4. Firestore Security Rules (Required)

The mobile app currently has no security rules configured (known issue). Before building the admin panel, deploy these rules to Firebase:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users can read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Users can read/write their own mood records
    match /mood_records/{docId} {
      allow read, write: if request.auth != null
        && request.resource.data.userId == request.auth.uid;
      allow read: if request.auth != null
        && resource.data.userId == request.auth.uid;
    }

    // Users can read/write their own journals
    match /journals/{docId} {
      allow read, write: if request.auth != null
        && resource.data.userId == request.auth.uid;
    }

    // Users can read/write their own activity logs
    match /activity_logs/{docId} {
      allow read, write: if request.auth != null
        && resource.data.userId == request.auth.uid;
    }
  }
}
```

> **Admin panel** should use Firebase Admin SDK (server-side) or a dedicated admin Firebase Auth account with custom claims (`admin: true`) to bypass per-user rules. Alternatively, use a service account with the Firebase Admin SDK in a backend proxy.


---

## 5. Admin Panel — Tech Stack

| Concern | Choice | Reason |
|---|---|---|
| Framework | Flutter Web | Same language/ecosystem as mobile app |
| State Management | **GetX ^4.6.6** | Matches mobile app; reactive, minimal boilerplate |
| Routing | **GetX named routes** | Consistent with mobile; supports deep links |
| Firebase | `firebase_core`, `firebase_auth`, `cloud_firestore` | Same project, same packages |
| Charts | `fl_chart ^0.69.0` | Line charts, bar charts, pie charts |
| Data tables | Flutter built-in `DataTable` + `PaginatedDataTable` | No extra dep needed |
| PDF export | `pdf ^3.11.3` + `printing ^5.14.2` | Already in mobile pubspec |
| Date formatting | `intl: any` | Already in mobile pubspec |
| Local storage | `get_storage ^2.1.1` | Persist admin session/preferences |
| Icons | Material Icons (built-in) | Consistent with mobile |

### pubspec.yaml for admin panel
```yaml
name: mindpath_admin
description: MindPath Admin Panel — Flutter Web
publish_to: none
version: 1.0.0+1

environment:
  sdk: ^3.8.1

dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6
  get_storage: ^2.1.1
  firebase_core: ^4.7.0
  firebase_auth: ^6.4.0
  cloud_firestore: ^6.3.0
  fl_chart: ^0.69.0
  pdf: ^3.11.3
  printing: ^5.14.2
  intl: any

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
```


---

## 6. Admin Panel — Project Structure

```
lib/
├── main.dart                        # Firebase init, GetStorage init, runApp
├── firebase_options.dart            # Web FirebaseOptions (from flutterfire configure)
├── core/
│   ├── app_routes.dart              # Route name constants
│   ├── app_pages.dart               # GetX page registry
│   ├── base_controller.dart         # isLoading.obs, errorMessage.obs
│   ├── admin_auth_guard.dart        # GetX middleware — redirect if not admin
│   ├── models/
│   │   ├── app_user.dart            # (copy from mobile, same fields)
│   │   ├── mood_record.dart         # (copy from mobile)
│   │   ├── journal_entry.dart       # (copy from mobile)
│   │   └── activity_log.dart        # (copy from mobile)
│   └── services/
│       ├── admin_auth_service.dart  # Firebase Auth sign-in for admin
│       ├── user_service.dart        # Firestore users collection (all users)
│       ├── mood_service.dart        # Firestore mood_records (all users)
│       ├── journal_service.dart     # Firestore journals + activity_logs
│       └── stats_service.dart       # Aggregate queries for overview stats
├── screens/
│   ├── login/
│   │   ├── login_view.dart
│   │   ├── login_controller.dart
│   │   └── login_binding.dart
│   ├── shell/
│   │   ├── shell_view.dart          # Persistent sidebar + top bar + content area
│   │   ├── shell_controller.dart
│   │   └── shell_binding.dart
│   ├── overview/
│   │   ├── overview_view.dart       # Dashboard home — KPI cards + charts
│   │   ├── overview_controller.dart
│   │   └── overview_binding.dart
│   ├── users/
│   │   ├── users_view.dart          # Paginated user table
│   │   ├── users_controller.dart
│   │   ├── users_binding.dart
│   │   └── user_detail_view.dart    # Single user drill-down
│   ├── mood_records/
│   │   ├── mood_records_view.dart   # Filterable mood records table
│   │   ├── mood_records_controller.dart
│   │   └── mood_records_binding.dart
│   ├── journals/
│   │   ├── journals_view.dart       # Journal entries table
│   │   ├── journals_controller.dart
│   │   └── journals_binding.dart
│   ├── activity_logs/
│   │   ├── activity_logs_view.dart
│   │   ├── activity_logs_controller.dart
│   │   └── activity_logs_binding.dart
│   └── analytics/
│       ├── analytics_view.dart      # App-wide charts and trends
│       ├── analytics_controller.dart
│       └── analytics_binding.dart
└── widgets/
    ├── sidebar.dart                 # Navigation sidebar
    ├── stat_card.dart               # KPI metric card
    ├── mood_chart.dart              # Line chart wrapper (fl_chart)
    ├── sentiment_bar.dart           # Horizontal bar for sentiment %
    ├── data_table_card.dart         # Card wrapping PaginatedDataTable
    └── emotion_badge.dart           # Colored chip for emotion label
```


---

## 7. Routing

### 7.1 Route Constants (`core/app_routes.dart`)
```dart
class AdminRoutes {
  static const login    = '/login';
  static const overview = '/overview';
  static const users    = '/users';
  static const userDetail = '/users/:id';
  static const moodRecords = '/mood-records';
  static const journals    = '/journals';
  static const activityLogs = '/activity-logs';
  static const analytics   = '/analytics';
}
```

### 7.2 Page Registry (`core/app_pages.dart`)
```dart
class AdminPages {
  static final pages = <GetPage>[
    GetPage(name: AdminRoutes.login,    page: () => LoginView(),    binding: LoginBinding()),
    GetPage(name: AdminRoutes.overview, page: () => ShellView(child: OverviewView()),  binding: ShellBinding(), middlewares: [AdminAuthGuard()]),
    GetPage(name: AdminRoutes.users,    page: () => ShellView(child: UsersView()),     binding: ShellBinding(), middlewares: [AdminAuthGuard()]),
    GetPage(name: AdminRoutes.userDetail, page: () => ShellView(child: UserDetailView()), binding: ShellBinding(), middlewares: [AdminAuthGuard()]),
    GetPage(name: AdminRoutes.moodRecords, page: () => ShellView(child: MoodRecordsView()), binding: ShellBinding(), middlewares: [AdminAuthGuard()]),
    GetPage(name: AdminRoutes.journals,    page: () => ShellView(child: JournalsView()),    binding: ShellBinding(), middlewares: [AdminAuthGuard()]),
    GetPage(name: AdminRoutes.activityLogs, page: () => ShellView(child: ActivityLogsView()), binding: ShellBinding(), middlewares: [AdminAuthGuard()]),
    GetPage(name: AdminRoutes.analytics,   page: () => ShellView(child: AnalyticsView()),   binding: ShellBinding(), middlewares: [AdminAuthGuard()]),
  ];
}
```

### 7.3 Auth Guard (`core/admin_auth_guard.dart`)
```dart
class AdminAuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AdminAuthController>();
    if (!auth.isLoggedIn) {
      return const RouteSettings(name: AdminRoutes.login);
    }
    return null;
  }
}
```

### 7.4 Initial Route in `main.dart`
```dart
initialRoute: AdminRoutes.login,
// After successful login → Get.offAllNamed(AdminRoutes.overview)
// On logout → Get.offAllNamed(AdminRoutes.login)
```


---

## 8. State Management (GetX Pattern)

### 8.1 BaseController
Every controller extends this:
```dart
class BaseController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = RxnString();

  void setLoading(bool v) => isLoading.value = v;
  void setError(String? msg) => errorMessage.value = msg;
}
```

### 8.2 Controller Lifecycle
- `onInit()` — start Firestore streams or fetch initial data
- `onClose()` — cancel StreamSubscriptions
- Use `Rxn<T>` for nullable observables, `RxList<T>` for lists
- Use `Obx(() => ...)` in views for reactive rebuilds
- Use `GetView<T>` as base class for views that need one controller

### 8.3 Dependency Injection
- Permanent global controllers (put in `main()`):
  - `AdminAuthController` — manages Firebase Auth state
- Scoped controllers via Bindings — created when route is pushed, disposed when popped
- `Get.find<T>()` to access registered controllers

### 8.4 Example Controller Pattern
```dart
class UsersController extends BaseController {
  final _userService = UserService();
  final users = <AppUser>[].obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllUsers();
  }

  Future<void> fetchAllUsers() async {
    try {
      setLoading(true);
      setError(null);
      final result = await _userService.fetchAllUsers();
      users.assignAll(result);
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  List<AppUser> get filtered {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return users;
    return users.where((u) =>
      u.name.toLowerCase().contains(q) ||
      u.email.toLowerCase().contains(q)
    ).toList();
  }
}
```

### 8.5 Binding Pattern
```dart
class UsersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UsersController());
  }
}
```


---

## 9. Firebase Setup for Admin Panel

### 9.1 `main.dart`
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();
  Get.put(AdminAuthController(), permanent: true);
  runApp(const AdminApp());
}
```

### 9.2 `AdminApp` widget
```dart
class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MindPath Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E5B49)),
        useMaterial3: true,
      ),
      initialRoute: AdminRoutes.login,
      getPages: AdminPages.pages,
    );
  }
}
```

### 9.3 `firebase_options.dart` (web)
Run this command in the admin project root to generate:
```bash
flutterfire configure --project=mindpath-78281 --platforms=web
```
This generates `lib/firebase_options.dart` with the web `FirebaseOptions`.

### 9.4 Admin Authentication Strategy
- Create a dedicated admin Firebase Auth account (email/password).
- In Firestore, create a collection `admins` with a document per admin UID:
  ```
  admins/{uid} → { email: "admin@mindpath.com", role: "superadmin" }
  ```
- After login, check if `admins/{uid}` exists. If not, deny access and sign out.
- Firestore rules for admin reads (add to existing rules):
  ```
  match /admins/{uid} {
    allow read: if request.auth != null && request.auth.uid == uid;
  }
  // Allow admin to read all collections:
  match /{document=**} {
    allow read, write: if request.auth != null
      && exists(/databases/$(database)/documents/admins/$(request.auth.uid));
  }
  ```


---

## 10. Admin Auth Controller

```dart
class AdminAuthController extends BaseController {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final firebaseUser = Rxn<User>();
  final isAdmin = false.obs;

  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges().listen((user) async {
      firebaseUser.value = user;
      if (user != null) {
        final doc = await _firestore.collection('admins').doc(user.uid).get();
        isAdmin.value = doc.exists;
        if (!doc.exists) {
          await _auth.signOut();
          Get.offAllNamed(AdminRoutes.login);
        }
      }
    });
  }

  bool get isLoggedIn => firebaseUser.value != null && isAdmin.value;

  Future<void> login(String email, String password) async {
    try {
      setLoading(true);
      setError(null);
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.offAllNamed(AdminRoutes.overview);
    } on FirebaseAuthException catch (e) {
      setError(e.message ?? 'Login failed');
    } finally {
      setLoading(false);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    isAdmin.value = false;
    Get.offAllNamed(AdminRoutes.login);
  }
}
```


---

## 11. Admin Services (Firestore Queries)

### 11.1 `UserService` (admin version — reads ALL users)
```dart
class UserService {
  final _db = FirebaseFirestore.instance;

  // Fetch all users (admin only)
  Future<List<AppUser>> fetchAllUsers() async {
    final snap = await _db.collection('users').orderBy('createdAt', descending: true).get();
    return snap.docs.map((d) => AppUser.fromMap(d.data())).toList();
  }

  // Fetch single user
  Future<AppUser?> fetchUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!);
  }

  // Update user profile (admin can edit name, age, gender)
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _db.collection('users').doc(userId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete user document (does NOT delete Firebase Auth account)
  Future<void> deleteUser(String userId) async {
    await _db.collection('users').doc(userId).delete();
  }

  // Stream total user count
  Stream<int> watchUserCount() {
    return _db.collection('users').snapshots().map((s) => s.size);
  }
}
```

### 11.2 `MoodService` (admin version — reads ALL records)
```dart
class AdminMoodService {
  final _db = FirebaseFirestore.instance;

  // All mood records for a specific user
  Future<List<MoodRecord>> fetchRecordsForUser(String userId, {int limit = 100}) async {
    final snap = await _db.collection('mood_records')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(MoodRecord.fromDoc).toList();
  }

  // All mood records across all users (for analytics)
  Future<List<MoodRecord>> fetchAllRecords({int limit = 500}) async {
    final snap = await _db.collection('mood_records')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(MoodRecord.fromDoc).toList();
  }

  // Delete a mood record
  Future<void> deleteRecord(String recordId) async {
    await _db.collection('mood_records').doc(recordId).delete();
  }

  // Stream total mood record count
  Stream<int> watchMoodCount() {
    return _db.collection('mood_records').snapshots().map((s) => s.size);
  }
}
```

### 11.3 `JournalService` (admin version)
```dart
class AdminJournalService {
  final _db = FirebaseFirestore.instance;

  Future<List<JournalEntry>> fetchJournalsForUser(String userId, {int limit = 100}) async {
    final snap = await _db.collection('journals')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(JournalEntry.fromDoc).toList();
  }

  Future<List<JournalEntry>> fetchAllJournals({int limit = 500}) async {
    final snap = await _db.collection('journals')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(JournalEntry.fromDoc).toList();
  }

  Future<void> deleteJournal(String journalId) async {
    await _db.collection('journals').doc(journalId).delete();
  }

  Stream<int> watchJournalCount() {
    return _db.collection('journals').snapshots().map((s) => s.size);
  }
}
```

### 11.4 `ActivityLogService` (admin version)
```dart
class AdminActivityService {
  final _db = FirebaseFirestore.instance;

  Future<List<ActivityLog>> fetchLogsForUser(String userId, {int limit = 100}) async {
    final snap = await _db.collection('activity_logs')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(ActivityLog.fromDoc).toList();
  }

  Future<List<ActivityLog>> fetchAllLogs({int limit = 500}) async {
    final snap = await _db.collection('activity_logs')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(ActivityLog.fromDoc).toList();
  }

  Stream<int> watchActivityCount() {
    return _db.collection('activity_logs').snapshots().map((s) => s.size);
  }
}
```


---

## 12. Admin Panel — Screens & Features

### 12.1 Login Screen (`/login`)
- Email + password fields
- "Sign In" button
- Shows error snackbar on failure
- On success → navigate to `/overview`
- No sign-up (admin accounts are created manually in Firebase Console)

### 12.2 Shell / Layout (`/overview`, all protected routes)
Persistent layout with:
- **Left sidebar** (fixed, 240px wide on desktop; collapsible on smaller screens):
  - App logo + "MindPath Admin" title
  - Nav items: Overview, Users, Mood Records, Journals, Activity Logs, Analytics
  - Logout button at bottom
- **Top bar**: Page title + logged-in admin email
- **Content area**: renders the active screen

### 12.3 Overview Screen (`/overview`)
KPI cards (live Firestore streams):
| Card | Value | Source |
|---|---|---|
| Total Users | count of `users` collection | `watchUserCount()` |
| Total Mood Check-ins | count of `mood_records` | `watchMoodCount()` |
| Total Journal Entries | count of `journals` | `watchJournalCount()` |
| Total Activity Sessions | count of `activity_logs` | `watchActivityCount()` |

Charts:
- **Mood Score Over Time** — line chart of daily average `moodScore` across all users (last 30 days)
- **Sentiment Distribution** — pie chart: positive / neutral / negative % from all `mood_records`
- **Emotion Frequency** — bar chart: count per `emotion` value across all records
- **Activity Type Breakdown** — bar chart: breathing vs walk session counts

Recent activity table: last 10 mood check-ins across all users (userId, moodLabel, moodScore, sentiment, timestamp).

### 12.4 Users Screen (`/users`)
- Searchable, sortable `PaginatedDataTable`
- Columns: Name, Email, Age, Gender, Onboarded (hasCompletedFirstMoodAnalysis), Joined (createdAt)
- Row actions: View Detail, Delete
- Search bar filters by name or email

### 12.5 User Detail Screen (`/users/:id`)
- User profile card: name, email, age, gender, joined date, onboarding status
- Edit button → inline form to update name, age, gender
- Tabs:
  - **Mood History** — table of all mood_records for this user (timestamp, moodLabel, moodScore, sentiment, emotion, insight)
  - **Journals** — table of all journals (title, emotion, sentiment, tags, createdAt)
  - **Activity Logs** — table (activityType, duration in minutes, createdAt)
- Each tab row has a Delete action

### 12.6 Mood Records Screen (`/mood-records`)
- Global table of all mood records across all users
- Columns: User ID, Mood Label, Score, Sentiment, Emotion, Timestamp
- Filter by: sentiment (dropdown), emotion (dropdown), date range
- Delete action per row
- Export filtered results as CSV (use `dart:html` anchor download on web)

### 12.7 Journals Screen (`/journals`)
- Global table of all journal entries
- Columns: User ID, Title, Sentiment, Emotion, Tags, Activity Type, Created At
- Filter by: sentiment, emotion, activityType
- Click row → expand to show full `text` and `insight`
- Delete action per row

### 12.8 Activity Logs Screen (`/activity-logs`)
- Global table of all activity logs
- Columns: User ID, Activity Type, Duration (formatted as mm:ss), Created At
- Filter by: activityType (breathing / walk)
- Summary cards: total breathing sessions, total walk sessions, total time logged

### 12.9 Analytics Screen (`/analytics`)
- Period selector: Last 7 days / Last 30 days / Last 90 days
- **Daily Active Users** — line chart (users with at least one record per day)
- **Average Mood Score Trend** — line chart of daily average across all users
- **Mood Label Distribution** — bar chart (grateful/neutral/pensive/down/tense counts)
- **Top Emotions** — horizontal bar chart sorted by frequency
- **Sentiment Over Time** — stacked area chart (positive/neutral/negative per day)
- **Journal Activity** — bar chart of journal entries per day
- Export current analytics view as PDF


---

## 13. Metric Formulas (from Mobile App — replicate in Admin)

### 13.1 Mood Score Normalization
```dart
double normalize(double score) => (score / 10).clamp(0.0, 1.0);
```

### 13.2 Daily Vitality Score
Average of all `moodScore` values for today, normalized to 0–1:
```dart
double vitalityScore = (todayRecords.map((r) => r.moodScore).average / 10).clamp(0, 1);
```

### 13.3 Weekly Average
Average of all `moodScore` values in the last 7 days, normalized:
```dart
double weeklyAvg = (weekRecords.map((r) => r.moodScore).average / 10).clamp(0, 1);
```

### 13.4 Consistency Streak
Count consecutive days (going back from today) that have at least one mood record:
```dart
int streak = 0;
for (int i = 0; i < 365; i++) {
  final day = today.subtract(Duration(days: i));
  final key = '${day.year}-${day.month}-${day.day}';
  if (!daysWithRecord.contains(key)) break;
  streak++;
}
```

### 13.5 Stability Score
Standard deviation of normalized daily average scores over the period:
```dart
final mean = points.average;
final variance = points.map((v) => pow(v - mean, 2)).average;
final stdDev = sqrt(variance);
final stability = (1 - (stdDev / 0.35)).clamp(0.0, 1.0);
```
- `0.35` is the normalization constant (max expected std dev)
- Result: 0 = very unstable, 1 = very stable

### 13.6 Sentiment Pulse (%)
From a list of MoodRecord:
```dart
// positive: sentiment == "positive" AND emotion not stress/anxiety/overwhelm
// stress: emotion contains stress, anxiety, or overwhelm
// neutral: everything else
double positiveRatio = positiveCount / total;
double neutralRatio  = neutralCount  / total;
double stressRatio   = stressCount   / total;
```

### 13.7 Average Mood Label
```dart
String label(double normalizedAvg) {
  if (normalizedAvg >= 0.75) return 'Joy & Light';
  if (normalizedAvg >= 0.58) return 'Calm & Steady';
  if (normalizedAvg >= 0.42) return 'Neutral & Okay';
  return 'Low & Heavy';
}
```

### 13.8 Mood Score → Label Mapping
| Label | Default Score |
|---|---|
| grateful | 8.5 |
| neutral | 6.0 |
| pensive | 5.0 |
| down | 3.0 |
| tense | 2.5 |


---

## 14. Design Tokens (Colors)

These are the exact colors from the mobile app. Use them in the admin panel for consistency.

```dart
// Primary brand
static const primary        = Color(0xFF1E5B49);  // Deep green — main brand color

// Dashboard backgrounds
static const dashboardBgTop    = Color(0xFFF3F6FF);
static const dashboardBgBottom = Color(0xFFEAF0FF);
static const dashboardBrand    = Color(0xFF274CFF);

// Auth screen colors
static const authPrimary       = Color(0xFF2F556F);
static const authBgTop         = Color(0xFFF7F9FF);
static const authBgBottom      = Color(0xFFEEDCFF);
static const authTextPrimary   = Color(0xFF273241);
static const authTextSecondary = Color(0xFF8B97A8);

// Sentiment colors
static const sentimentPositive = Color(0xFF22C55E);  // Green
static const sentimentNeutral  = Color(0xFFF59E0B);  // Amber
static const sentimentStress   = Color(0xFFEF4444);  // Red

// Emotion tag colors
// stress/anger   bg: 0xFFFFF1F2  fg: 0xFFEF4444
// anxiety        bg: 0xFFFFF7ED  fg: 0xFFF59E0B
// calm           bg: 0xFFEFFDF4  fg: 0xFF16A34A
// joy            bg: 0xFFECFDF5  fg: 0xFF16A34A
// sadness        bg: 0xFFEFF6FF  fg: 0xFF2563EB
// fatigue        bg: 0xFFF5F3FF  fg: 0xFF7C3AED

// Mood label colors (for badges)
// grateful  → sentimentPositive (0xFF22C55E)
// neutral   → sentimentNeutral  (0xFFF59E0B)
// pensive   → Color(0xFF6366F1)  (indigo)
// down      → Color(0xFF2563EB)  (blue)
// tense     → sentimentStress   (0xFFEF4444)
```

### Admin Panel Recommended Color Scheme
- Sidebar background: `Color(0xFF1E5B49)` (primary green)
- Sidebar text: `Colors.white`
- Content background: `Color(0xFFF3F6FF)`
- Card background: `Colors.white`
- Top bar: `Colors.white` with bottom border
- Primary action buttons: `Color(0xFF1E5B49)`
- Danger/delete buttons: `Color(0xFFEF4444)`


---

## 15. Shell Layout Implementation Guide

```dart
class ShellView extends StatelessWidget {
  const ShellView({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar — always visible on desktop
          const SidebarWidget(),
          // Content area
          Expanded(
            child: Column(
              children: [
                const TopBarWidget(),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### Sidebar nav items
```dart
final navItems = [
  NavItem(icon: Icons.dashboard_rounded,     label: 'Overview',       route: AdminRoutes.overview),
  NavItem(icon: Icons.people_rounded,        label: 'Users',          route: AdminRoutes.users),
  NavItem(icon: Icons.mood_rounded,          label: 'Mood Records',   route: AdminRoutes.moodRecords),
  NavItem(icon: Icons.edit_note_rounded,     label: 'Journals',       route: AdminRoutes.journals),
  NavItem(icon: Icons.timer_rounded,         label: 'Activity Logs',  route: AdminRoutes.activityLogs),
  NavItem(icon: Icons.insights_rounded,      label: 'Analytics',      route: AdminRoutes.analytics),
];
```

---

## 16. Chart Implementation Guide (fl_chart)

### Line Chart (Mood Score Trend)
```dart
LineChartData buildMoodLineChart(List<double> points) {
  return LineChartData(
    gridData: FlGridData(show: true),
    titlesData: FlTitlesData(show: true),
    borderData: FlBorderData(show: false),
    lineBarsData: [
      LineChartBarData(
        spots: points.asMap().entries
            .map((e) => FlSpot(e.key.toDouble(), e.value))
            .toList(),
        isCurved: true,
        color: const Color(0xFF1E5B49),
        barWidth: 2.5,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: const Color(0xFF1E5B49).withOpacity(0.1),
        ),
      ),
    ],
  );
}
```

### Pie Chart (Sentiment Distribution)
```dart
PieChartData buildSentimentPie(double positive, double neutral, double stress) {
  return PieChartData(
    sections: [
      PieChartSectionData(value: positive * 100, color: Color(0xFF22C55E), title: 'Positive'),
      PieChartSectionData(value: neutral  * 100, color: Color(0xFFF59E0B), title: 'Neutral'),
      PieChartSectionData(value: stress   * 100, color: Color(0xFFEF4444), title: 'Stress'),
    ],
  );
}
```

---

## 17. PDF Export (Admin Analytics)

```dart
Future<void> exportAnalyticsPdf({
  required String period,
  required double avgScore,
  required double stability,
  required List<MoodRecord> records,
}) async {
  final doc = pw.Document();
  doc.addPage(pw.MultiPage(
    build: (_) => [
      pw.Text('MindPath Admin — $period Analytics',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 10),
      pw.Text('Average Mood Score: ${(avgScore * 100).round()}%'),
      pw.Text('Stability: ${(stability * 100).round()}%'),
      pw.Text('Total Records: ${records.length}'),
      pw.SizedBox(height: 14),
      pw.Text('Records', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ...records.take(50).map((r) => pw.Text(
        '${r.timestamp?.toDate().toIso8601String()} | ${r.moodLabel} | ${r.moodScore} | ${r.sentiment} | ${r.emotion}',
      )),
    ],
  ));
  await Printing.sharePdf(bytes: await doc.save(), filename: 'mindpath_admin_$period.pdf');
}
```


---

## 18. Data Models (Copy Exactly from Mobile App)

These models are identical to the mobile app. Copy them verbatim into the admin panel's `lib/core/models/`.

### AppUser
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  const AppUser({
    required this.userId, required this.name, required this.email,
    this.age, this.gender, this.profileImage,
    this.hasCompletedFirstMoodAnalysis, this.createdAt, this.updatedAt,
  });

  final String userId;
  final String name;
  final String email;
  final int? age;
  final String? gender;
  final String? profileImage;
  final bool? hasCompletedFirstMoodAnalysis;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  static AppUser fromMap(Map<String, dynamic> map) {
    return AppUser(
      userId: (map['userId'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      age: map['age'] is int ? map['age'] as int : null,
      gender: map['gender'] as String?,
      profileImage: map['profileImage'] as String?,
      hasCompletedFirstMoodAnalysis: map['hasCompletedFirstMoodAnalysis'] as bool?,
      createdAt: map['createdAt'] as Timestamp?,
      updatedAt: map['updatedAt'] as Timestamp?,
    );
  }
}
```

### MoodRecord
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MoodRecord {
  const MoodRecord({
    required this.id, required this.userId, required this.timestamp,
    required this.moodLabel, required this.moodText, required this.moodScore,
    required this.sentiment, required this.emotion, required this.insight,
  });

  final String id;
  final String userId;
  final Timestamp? timestamp;
  final String moodLabel;   // grateful | neutral | pensive | down | tense
  final String moodText;
  final double moodScore;   // 0–10
  final String sentiment;   // positive | neutral | negative
  final String emotion;     // stress | anxiety | calm | joy | sadness | anger | fatigue | overwhelm | other
  final String insight;

  static MoodRecord fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return MoodRecord(
      id: doc.id,
      userId: (data['userId'] ?? '') as String,
      timestamp: data['timestamp'] as Timestamp?,
      moodLabel: (data['moodLabel'] ?? '') as String,
      moodText: (data['moodText'] ?? '') as String,
      moodScore: (data['moodScore'] is num) ? (data['moodScore'] as num).toDouble() : 0,
      sentiment: (data['sentiment'] ?? '') as String,
      emotion: (data['emotion'] ?? '') as String,
      insight: (data['insight'] ?? '') as String,
    );
  }
}
```

### JournalEntry
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  const JournalEntry({
    required this.id, required this.userId, required this.text,
    required this.sentiment, required this.emotion, required this.insight,
    required this.tags, required this.activityType,
    required this.createdAt, required this.title,
  });

  final String id;
  final String userId;
  final String text;
  final String title;
  final String sentiment;   // positive | neutral | negative
  final String emotion;
  final String insight;
  final List<String> tags;
  final String activityType; // journal | breathing | walk
  final Timestamp? createdAt;

  static JournalEntry fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final rawTags = data['tags'];
    final tags = rawTags is List ? rawTags.map((e) => e.toString()).toList() : <String>[];
    return JournalEntry(
      id: doc.id,
      userId: (data['userId'] ?? '') as String,
      text: (data['text'] ?? '') as String,
      title: (data['title'] ?? '') as String,
      sentiment: (data['sentiment'] ?? '') as String,
      emotion: (data['emotion'] ?? '') as String,
      insight: (data['insight'] ?? '') as String,
      tags: tags,
      activityType: (data['activityType'] ?? '') as String,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }
}
```

### ActivityLog
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLog {
  const ActivityLog({
    required this.id, required this.userId,
    required this.activityType, required this.durationSeconds, required this.createdAt,
  });

  final String id;
  final String userId;
  final String activityType;  // breathing | walk
  final int durationSeconds;  // stored as 'duration' in Firestore
  final Timestamp? createdAt;

  static ActivityLog fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ActivityLog(
      id: doc.id,
      userId: (data['userId'] ?? '') as String,
      activityType: (data['activityType'] ?? '') as String,
      durationSeconds: (data['duration'] is num) ? (data['duration'] as num).toInt() : 0,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }
}
```


---

## 19. How to Scaffold the Admin Panel (Step-by-Step)

1. **Create new Flutter project**
   ```bash
   flutter create mindpath_admin --platforms=web
   cd mindpath_admin
   ```

2. **Update `pubspec.yaml`** with the dependencies from Section 5.

3. **Configure Firebase for web**
   ```bash
   flutterfire configure --project=mindpath-78281 --platforms=web
   ```
   This generates `lib/firebase_options.dart` with web `FirebaseOptions`.

4. **Create Firestore `admins` collection** in Firebase Console:
   - Document ID = your admin Firebase Auth UID
   - Fields: `email: "your@email.com"`, `role: "superadmin"`

5. **Deploy Firestore security rules** from Section 4.

6. **Copy models** from Section 18 into `lib/core/models/`.

7. **Create `lib/core/app_routes.dart`** from Section 7.1.

8. **Create `lib/core/base_controller.dart`** from Section 8.1.

9. **Create `AdminAuthController`** from Section 10.

10. **Create services** from Section 11.

11. **Create screens** following Section 12 feature specs.

12. **Create `lib/core/app_pages.dart`** from Section 7.2.

13. **Update `lib/main.dart`** from Section 9.1.

14. **Run**
    ```bash
    flutter run -d chrome
    ```

---

## 20. Known Constraints & Notes

- The mobile app's `firebase_options.dart` does **not** have a web config — you must generate it separately with `flutterfire configure`.
- Firestore security rules are not yet deployed on the live project (known issue from mobile app). Deploy them before testing the admin panel.
- The admin panel reads data that the mobile app writes. Do not change Firestore field names — they must match exactly as documented in Section 3.
- `activity_logs` stores duration as `duration` (not `durationSeconds`) — the Dart model maps this correctly in `fromDoc`.
- `journals` stores the doc ID both as the Firestore document ID and inside the document as `journalId`.
- All timestamps are Firestore `Timestamp` objects (server-side). Use `.toDate()` to convert to `DateTime` for display.
- The LLM backend is only used by the mobile app. The admin panel does **not** call the LLM API.
- For CSV export on Flutter Web, use `dart:html`:
  ```dart
  import 'dart:html' as html;
  final blob = html.Blob([csvString]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', 'export.csv')
    ..click();
  html.Url.revokeObjectUrl(url);
  ```

---

## 21. LLM Backend Reference (Read-Only for Admin)

The admin panel does not call the LLM. This is for reference only.

| Endpoint | Method | Purpose |
|---|---|---|
| `/mood/analyze` | POST | Analyzes mood check-in → returns sentiment, emotion, insight, progression |
| `/journal/analyze` | POST | Analyzes journal text → returns sentiment, emotion, insight, tags |
| `/journal/insight` | POST | Generates reflection, suggestion, nextStep for a journal entry |
| `/journal/deep_insight` | POST | Deeper AI reflection on a journal entry |

Backend location: `backend/llm/api/main.py`
Run: `./backend/llm/run_api.sh`
Default URL: `http://127.0.0.1:8000` (iOS/desktop) or `http://10.0.2.2:8000` (Android emulator)

