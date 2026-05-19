# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run the app (development)
flutter analyze          # Lint / static analysis
flutter test             # Run all tests
flutter build apk        # Build Android APK
flutter build ios        # Build iOS
```

## Architecture

**Padly** is a Flutter padel sports platform for finding and joining matches. It uses Firebase as the primary backend and Supabase as a secondary data/auth source, with a custom `SupabaseFirebaseAuthBridge` (in `lib/services/`) that keeps both in sync.

### Entry point

`lib/main.dart` initialises Firebase, Supabase (via `.env`), and then shows `EntryPoint` (`lib/entry_point.dart`). On startup the app checks Firebase auth state and, if authenticated, checks whether the user has completed their profile — incomplete profiles are redirected to an onboarding flow before reaching `GamesOverview`.

### Screen structure

Each feature lives under `lib/screens/<feature>/`. There are two patterns:

1. **Simple screens** – a single `_screen.dart` file directly under `screens/<feature>/views/`. No ViewModel.
2. **Modular screens** (games, profile, user_info, chat) – use a `src/` sub-tree:
   ```
   src/
   ├── view/        # Widget files
   ├── domain/      # ChangeNotifier ViewModel + service classes
   └── data/        # Gateway / repository classes
   ```

State management uses **Provider** (via `ChangeNotifier`) only where a ViewModel exists. Everything else is plain `StatelessWidget` / `StatefulWidget`.

### Navigation

Named routes are declared in `lib/route/router.dart`. Use `Navigator.pushNamed(context, routeName)` throughout. The bottom navigation bar is in `lib/entry_point.dart`.

### Key backends

| Backend | SDK | Used for |
|---------|-----|----------|
| Cloud Firestore | `cloud_firestore` | Primary data store |
| Firebase Auth | `firebase_auth` | Authentication (language set to `nl`) |
| Firebase Storage | `firebase_storage` | User-uploaded files/images |
| Cloud Functions | `cloud_functions` | Server-side logic |
| Supabase | `supabase_flutter` | Secondary auth + data (synced via `SupabaseFirebaseAuthBridge`) |

### Theme

Dark theme only, defined in `lib/theme/`. Font families are **Plus Jakarta** (body) and **Grandis Extended** (display). Global color constants are in `lib/constants.dart`.

### Environment variables

Loaded from `.env` at startup via `flutter_dotenv`. The `Env` class in `lib/config/` exposes `supabaseUrl` and `supabaseAnonKey`. A `.env` file is required locally — it is not committed.

### Notable patterns

- Push notification code exists in `lib/screens/notification/` and `main.dart` but is **commented out**.
- The `lib/components/` directory contains shared UI widgets (cards, buttons, bottom nav).
- Assets are organised in `assets/` with sub-folders: `images/`, `icons/`, `illustrations/`, `lottie/`, `flags/`, `logos/`.
