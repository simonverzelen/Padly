# Padly — Refactored Architecture

## What Changed

| Area | Before | After |
|------|--------|-------|
| State management | `provider` + ChangeNotifier per screen | `flutter_riverpod` for shared global state |
| Games data | Manual refresh only | Supabase Realtime — live updates |
| Location | Hardcoded Kortrijk (50.83, 3.26) | Device GPS via `geolocator` with Kortrijk fallback |
| Auth bridge | Mutated shared headers (thread-unsafe) | Cached JWT with 55-min TTL, deduplication |
| Games query | `fethSupabaseGames()` (typo, no location) | `fetchSupabaseGames(lat, lng, sport)` |

## Migrated Screens

| Screen | State management |
|--------|-----------------|
| GamesOverview | ✅ ConsumerWidget (Riverpod) |
| FindMatch | ✅ ConsumerWidget (Riverpod) |
| ProfileScreen | ✅ ConsumerStatefulWidget (Riverpod) |
| GameDetailScreen | ⏳ `gameDetailProvider` ready, screen migration pending |
| CreateGame | Stays ChangeNotifier (complex form state) |
| SearchClub | Stays ChangeNotifier (complex form state) |
| AddPlayers | Stays ChangeNotifier (complex form state) |
| RequestsOverview | Stays ChangeNotifier (complex form state) |

## Providers Reference

| Provider | Type | Returns |
|----------|------|---------|
| `supabaseClientProvider` | `Provider` | `SupabaseClient` singleton |
| `authBridgeProvider` | `Provider` | `SupabaseFirebaseAuthBridge` singleton |
| `gamesGatewayProvider` | `Provider` | `GamesGateway` singleton |
| `firebaseAuthStateProvider` | `StreamProvider<User?>` | Firebase auth state stream |
| `currentUserProvider` | `FutureProvider<PadlyUser?>` | Current user's Firestore profile |
| `locationProvider` | `FutureProvider<LocationState>` | Device GPS (falls back to Kortrijk) |
| `sportNamesProvider` | `FutureProvider<List<String>>` | Available sport names from Supabase |
| `selectedSportProvider` | `StateNotifierProvider<_, String>` | Persisted selected sport (SharedPrefs) |
| `gamesStreamProvider(sport)` | `StreamProvider<List<Game>>` | Live-updating games list for a sport |
| `gameDetailProvider(gameId)` | `FutureProvider<Game?>` | Single game by ID |

All providers live in `lib/providers/providers.dart`.

## Real-time Architecture

Supabase Realtime must be enabled on the `games` table in the Supabase Dashboard (Database → Replication → enable INSERT/UPDATE/DELETE for `games`).

Flow:
1. `gamesStreamProvider(sport)` subscribes to Supabase channel `'games-realtime-$sport'`
2. Any INSERT/UPDATE/DELETE on the `games` table triggers the callback
3. Callback re-fetches via RPC `get_games_filtered` (which computes distance, applies filters)
4. New list emitted to all `ConsumerWidget`s watching the provider
5. When sport changes or user navigates away, `autoDispose` cleans up the channel

## Adding a New Screen with Shared Data

1. Add a provider in `lib/providers/providers.dart`:

```dart
final myFeatureProvider = FutureProvider.autoDispose.family<MyModel, String>(
  (ref, param) async {
    final gateway = ref.watch(gamesGatewayProvider);
    return gateway.fetchSomething(param);
  },
);
```

2. Use `ConsumerWidget`:

```dart
class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(myFeatureProvider('param'));

    return dataAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text(e.toString()),
      data: (data) => Text(data.toString()),
    );
  }
}
```

## Migrating a Remaining ChangeNotifier Screen

For screens still using `ChangeNotifierProvider` (CreateGame, SearchClub, etc.), only migrate if the screen reads **shared global state** (current user, games list, selected sport). Complex local form state does not benefit from Riverpod and should stay as ChangeNotifier.

Pattern:
```dart
// Before
class SomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SomeViewModel(),
      builder: (context, child) {
        final vm = context.watch<SomeViewModel>();
        // ...
      },
    );
  }
}

// After
class SomeScreen extends ConsumerWidget {
  const SomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    // use ref.read(someProvider.notifier).method() for mutations
  }
}
```

## Migrating GameDetailScreen (next step)

`gameDetailProvider(gameId)` is already defined. To complete the migration:

1. Convert `game_detail_screen.dart` to `ConsumerStatefulWidget`
2. Replace `ChangeNotifierProvider<GameDetailViewModel>` with `ref.watch(gameDetailProvider(game.id!))`
3. Delete `game_detail_viewmodel.dart`

## Running Tests

```bash
flutter test test/providers/selected_sport_test.dart  # Unit test for SelectedSportNotifier
flutter test                                           # All tests
flutter analyze                                        # Static analysis
```
