# React Web (Mobile) to Flutter Mobile App — Complete Conversion Guide

A practical, AI-agent-friendly playbook for converting React/Next.js mobile web apps into native Flutter mobile apps while preserving design, behavior, and business logic.

---

## 1. Discovery & Analysis Phase

Before writing any Flutter code, deeply understand the existing web app.

### 1.1 Map the Routes & Navigation
- Inspect `App.tsx`, `routes.ts`, `pages/`, or the routing library (e.g., React Router, Next.js file-based routing).
- List every screen and its parameters.
- Identify navigation patterns: stack push, bottom tabs, drawers, modals, deep links.

### 1.2 Extract Data Models
- Find `types/`, `interfaces/`, or `.d.ts` files.
- Map TypeScript interfaces to Dart classes.
- Note enums, unions, optional fields, and nested objects.

### 1.3 Inventory State Management
- Identify how state is managed:
  - React Context → `Provider` or `Riverpod`
  - Redux/Zustand → `Riverpod` / `Bloc` / `MobX`
  - React Query/SWR → `Riverpod` with `AsyncValue` or custom repositories
  - Local component state → `StatefulWidget` / `ChangeNotifier`

### 1.4 Audit UI/UX
- Capture design tokens from CSS/Tailwind:
  - Colors (hex values, primary/secondary/error/surface)
  - Typography (font family, sizes, weights)
  - Spacing (padding, margin, border radius)
  - Shadows & elevations
- Identify reusable components: buttons, cards, inputs, badges, lists, avatars, dialogs, skeletons.
- Note responsive breakpoints and safe-area constraints.

### 1.5 Inventory External Integrations
- REST APIs, GraphQL, WebSockets, Firebase, push notifications, local storage, analytics, maps, camera, file picker, biometrics, payments.
- Match each integration to a Flutter package from [pub.dev](https://pub.dev).

---

## 2. Flutter Project Setup

### 2.1 Create the Project

```bash
flutter create --org com.yourcompany --project-name your_app_name ./your_app_name
cd your_app_name
```

### 2.2 Recommended Folder Structure

```
lib/
├── main.dart
├── app.dart
├── config/
│   ├── routes.dart              # GoRouter or Navigator routes
│   ├── theme.dart               # ThemeData / ColorScheme / TextTheme
│   └── constants.dart           # API URLs, keys, defaults
├── core/
│   ├── errors/
│   ├── usecases/
│   └── utils/
├── data/
│   ├── datasources/             # API, local DB, cache
│   ├── models/                  # DTOs / fromJson / toJson
│   └── repositories/            # Repository implementations
├── domain/
│   ├── entities/                # Pure Dart classes
│   └── repositories/            # Repository interfaces
├── presentation/
│   ├── screens/
│   ├── widgets/
│   ├── providers/               # Riverpod/Provider/Bloc
│   └── state/
└── services/
    └── di.dart                  # Dependency injection setup
```

Use a **feature-first** structure for larger apps:

```
lib/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── orders/
│       ├── data/
│       ├── domain/
│       └── presentation/
```

### 2.3 Essential Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.5.0       # Recommended over Provider for new projects
  # provider: ^6.1.0             # Legacy alternative

  # Navigation
  go_router: ^14.0.0             # Declarative routing like React Router

  # Networking
  dio: ^5.4.0                    # Powerful HTTP client
  retrofit: ^4.1.0               # Type-safe APIs (optional)

  # JSON serialization
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0

  # UI utilities
  google_fonts: ^6.2.0           # Easy custom fonts
  flutter_svg: ^2.0.10           # SVG assets
  cached_network_image: ^3.3.0   # Image caching
  shimmer: ^3.0.0                # Skeleton loaders

  # Icons
  lucide_icons: ^0.257.0         # Lucide icons (matches web Lucide)
  # font_awesome_flutter: ^10.7.0

  # Localization & formatting
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

  # Device/platform
  url_launcher: ^6.2.0
  share_plus: ^8.0.0
  path_provider: ^2.1.0
  image_picker: ^1.1.0
  permission_handler: ^11.3.0

  # Storage
  shared_preferences: ^2.2.0     # Key-value local storage
  hive_flutter: ^1.1.0           # NoSQL local database
  sqflite: ^2.3.0                # SQLite

  # Firebase (if needed)
  # firebase_core: ^2.24.0
  # firebase_auth: ^4.16.0
  # cloud_firestore: ^4.14.0
  # firebase_messaging: ^14.7.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0
  retrofit_generator: ^8.1.0
```

### 2.4 Configure Assets & Fonts

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
    - assets/fonts/
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```

---

## 3. Mapping React Concepts to Flutter

| React Concept | Flutter Equivalent |
|---------------|--------------------|
| JSX Widget tree | Widget tree |
| `useState` | `StatefulWidget` + `setState` or `StateProvider` |
| `useEffect` | `initState` / `didChangeDependencies` / Riverpod side effects |
| `useMemo` / `useCallback` | `const` constructors, `memo` via `RepaintBoundary` |
| Context API | `Provider` / `InheritedWidget` / `Riverpod` |
| Redux / Zustand | `Riverpod` / `Bloc` / `MobX` |
| React Router | `go_router` / `Navigator` |
| Styled-components / Tailwind | `ThemeData`, `BoxDecoration`, custom widgets |
| `useForm` / controlled inputs | `TextEditingController` + `Form` + `TextFormField` |
| `localStorage` | `shared_preferences` / `hive` / `secure_storage` |
| `fetch` / axios | `dio` / `http` |
| `react-query` | `Riverpod` `AsyncValue` / `flutter_bloc` |
| `framer-motion` | `AnimatedContainer`, `Hero`, explicit animations |

---

## 4. Converting Data Models & Business Logic

### 4.1 TypeScript Interface → Dart Class

**React / TypeScript**
```ts
interface Order {
  id: string;
  customerName: string;
  total: number;
  status: 'pending' | 'completed' | 'cancelled';
  createdAt: Date;
}
```

**Flutter Dart**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order.freezed.dart';
part 'order.g.dart';

enum OrderStatus { pending, completed, cancelled }

@freezed
class Order with _$Order {
  const factory Order({
    required String id,
    required String customerName,
    required double total,
    required OrderStatus status,
    required DateTime createdAt,
  }) = _Order;

  factory Order.fromJson(Map<String, Object?> json) => _$OrderFromJson(json);
}
```

Run code generation:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4.2 State Management Pattern with Riverpod

```dart
@riverpod
class OrderList extends _$OrderList {
  @override
  Future<List<Order>> build() async {
    return ref.watch(orderRepositoryProvider).fetchOrders();
  }

  Future<void> addOrder(Order order) async {
    await ref.read(orderRepositoryProvider).createOrder(order);
    ref.invalidateSelf();
  }

  Future<void> updateStatus(String id, OrderStatus status) async {
    await ref.read(orderRepositoryProvider).updateStatus(id, status);
    ref.invalidateSelf();
  }
}
```

---

## 5. UI Conversion Strategy

### 5.1 Theme & Design Tokens

Create a single source of truth in `lib/config/theme.dart`:

```dart
class AppTheme {
  static final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF10B981), // Tailwind emerald-500
    brightness: Brightness.light,
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
```

### 5.2 Reusable Widget Mapping

| Web Component | Flutter Widget |
|---------------|----------------|
| `<button>` | `ElevatedButton`, `TextButton`, `OutlinedButton`, `InkWell` |
| `<input>` / `<textarea>` | `TextField` / `TextFormField` |
| `<select>` | `DropdownButtonFormField` |
| `<div>` with flex | `Column`, `Row`, `Flex` |
| `<div>` scrollable | `SingleChildScrollView`, `ListView` |
| `<img>` | `Image.asset`, `Image.network`, `CachedNetworkImage` |
| `<svg>` | `SvgPicture` |
| `<span>` / text | `Text`, `RichText` |
| `<hr>` | `Divider` |
| Modal / Dialog | `Dialog`, `showModalBottomSheet`, `showDialog` |
| Toast / Snackbar | `ScaffoldMessenger.of(context).showSnackBar` |
| Loading spinner | `CircularProgressIndicator` |
| Skeleton | `Shimmer` widget |

### 5.3 Layout Equivalents

**Flexbox row**
```jsx
<div className="flex items-center justify-between gap-4">
```

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: const [Widget1(), SizedBox(width: 16), Widget2()],
)
```

**Flexbox column**
```jsx
<div className="flex flex-col gap-2">
```

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: const [Widget1(), SizedBox(height: 8), Widget2()],
)
```

**Padding / Margin**
```jsx
<div className="p-4 mb-2">
```

```dart
Padding(
  padding: const EdgeInsets.all(16).copyWith(bottom: 8),
  child: child,
)
```

### 5.4 Responsive & Safe Area

Wrap top-level screens with:

```dart
Scaffold(
  body: SafeArea(
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: child,
      ),
    ),
  ),
)
```

Use `LayoutBuilder` or `MediaQuery` for responsive sizing where the web app had breakpoints.

---

## 6. Navigation Implementation

Use `go_router` for declarative routing:

```dart
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: '/orders/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return OrderDetailScreen(orderId: id);
      },
    ),
  ],
);
```

In `main.dart`:

```dart
MaterialApp.router(
  routerConfig: _router,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
)
```

---

## 7. Forms & Validation

```dart
final _formKey = GlobalKey<FormState>();
final _emailController = TextEditingController();

Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(
        controller: _emailController,
        decoration: const InputDecoration(labelText: 'Email'),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Email is required';
          if (!value.contains('@')) return 'Enter a valid email';
          return null;
        },
      ),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // submit
          }
        },
        child: const Text('Submit'),
      ),
    ],
  ),
)
```

---

## 8. Localization & RTL

For Arabic support (RTL):

1. Add `flutter_localizations` and `intl` dependencies.
2. Generate localization files via `flutter gen-l10n` or ARB files.
3. Set `supportedLocales` and `localizationsDelegates` in `MaterialApp`.
4. For forced RTL testing:

```dart
MaterialApp(
  locale: const Locale('ar'),
  supportedLocales: const [Locale('en'), Locale('ar')],
  localizationsDelegates: AppLocalizations.localizationsDelegates,
)
```

---

## 9. Async State & Side Effects

React `useEffect` fetching data:

```jsx
useEffect(() => {
  fetchOrders().then(setOrders);
}, []);
```

Flutter with Riverpod:

```dart
@riverpod
Future<List<Order>> orders(OrdersRef ref) async {
  return ref.read(orderRepositoryProvider).fetchOrders();
}

// In widget:
Consumer(builder: (context, ref, child) {
  final ordersAsync = ref.watch(ordersProvider);
  return ordersAsync.when(
    data: (orders) => OrdersList(orders: orders),
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (err, stack) => Center(child: Text('Error: $err')),
  );
});
```

---

## 10. Testing & Verification

### 10.1 Manual Checklist
- [ ] Every web route has a matching Flutter screen.
- [ ] All forms validate and submit correctly.
- [ ] Lists scroll smoothly and handle empty/error states.
- [ ] Pull-to-refresh and pagination (if web has them) work.
- [ ] RTL languages render correctly without overflow.
- [ ] Bottom sheets, dialogs, and navigation feel native.
- [ ] Loading, error, and empty states are implemented.
- [ ] Dark mode (if required) is configured via `ThemeData`.

### 10.2 Automated Tests

```bash
# Unit tests for logic
flutter test

# Widget tests for screens
flutter test test/presentation/screens/home_screen_test.dart

# Integration tests
flutter test integration_test/app_test.dart
```

Sample widget test:

```dart
testWidgets('HomeScreen shows order list', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: HomeScreen()),
    ),
  );
  expect(find.text('Orders'), findsOneWidget);
});
```

---

## 11. Build & Deployment

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web (if keeping web parity)
flutter build web --release
```

Ensure proper app signing, launcher icons, splash screens, and store metadata.

---

## 12. Best Practices for Agents

1. **Keep names consistent.** Use the same variable/function/screen names as the React project to make reviews easier.
2. **Prefer composition.** Build small, reusable widgets rather than large, nested trees.
3. **Separate UI from logic.** Use providers/repositories for business logic; keep widgets lean.
4. **Avoid premature optimization.** Start simple; add state-management complexity only when justified.
5. **Use `const` constructors everywhere possible.** This improves rebuild performance.
6. **Handle all async states.** Every future/stream should have loading, error, and empty states.
7. **Respect platform conventions.** Use native scroll physics, dialogs, and navigation patterns.
8. **Document exceptions.** If a web feature cannot be directly ported, note it clearly with an alternative.
9. **Iterate with real devices.** Emulators are fine, but test on physical devices for gestures, performance, and safe areas.
10. **Version control incrementally.** Commit after each major phase (setup, models, screens, integration).

---

## Quick Reference: Conversion Checklist

- [ ] Analyze routes, models, state, UI, and integrations.
- [ ] Create Flutter project and professional folder structure.
- [ ] Add dependencies in `pubspec.yaml`.
- [ ] Convert TypeScript models to Dart classes.
- [ ] Implement repositories and state management.
- [ ] Build theme and reusable widgets.
- [ ] Implement screens one by one.
- [ ] Wire navigation with `go_router` or `Navigator`.
- [ ] Add localization and RTL support if needed.
- [ ] Test logic, widgets, and integration.
- [ ] Build release binaries and prepare store assets.

---

*Use this guide as the single source of truth when converting React mobile web apps to Flutter. Adjust scope based on project size, but never skip the discovery phase.*
