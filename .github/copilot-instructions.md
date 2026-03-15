## Purpose
This file gives short, actionable guidance to AI coding agents working on the Shaman Flutter app so they become productive quickly.

## Big picture (what this repo is)
- Flutter app (mobile + desktop) using a feature-based, clean-architecture layout: features/<feature>/{data,domain,presentation}.
- State: Provider / ChangeNotifier. Providers are created and wired manually in `lib/main.dart` (no DI framework).
- Networking: `lib/core/network/api_client.dart` and feature remote datasources under `features/*/data/datasources` talk to a REST API. Base URL is in `lib/core/constants/api_constants.dart`.
- Auth: `lib/core/utils/token_manager.dart` stores JWTs in `flutter_secure_storage` and is used by datasources/providers to attach Authorization headers.

## Key files to inspect (examples)
- App wiring and routes: `lib/main.dart` (manual construction of ApiClient, TokenManager, repositories, and providers). Example: provider wiring for `ProductsProvider` and `AuthProvider`.
- API helpers: `lib/core/network/api_client.dart` and `lib/core/constants/api_constants.dart`.
- Token handling: `lib/core/utils/token_manager.dart` (getAccessToken, getUserIdFromAccessToken).
- Feature pattern (example: student profile):
  - `features/studentprofile/data/datasources/student_profile_remote_datasource.dart` (adds Authorization header if TokenManager present)
  - `features/studentprofile/data/repositories/student_profile_repository_impl.dart`
  - `features/studentprofile/domain/usecases/*`
  - `features/studentprofile/presentation/state/student_profile_provider.dart` (ChangeNotifier)

## Project-specific patterns and rules for code edits
- Follow the feature folder convention: when adding functionality, add files under the appropriate feature's `data`, `domain`, and `presentation` folders.
- Repository/implementation names follow the pattern `<Thing>Repository` (interface) and `<Thing>RepositoryImpl` (implementation).
- Remote data sources are suffixed `RemoteDataSource`/`RemoteDataSourceImpl` and accept an `http.Client` and optional `TokenManager`.
- Usecases are plain classes in `domain/usecases` and are injected into providers in `main.dart` via constructor wiring.
- State objects are `ChangeNotifier` classes in `presentation/state`. They expose enums for status (e.g., `StudentProfileStatus`) and use `notifyListeners()`.

## Integration points & external dependencies
- REST API: all HTTP calls go to the base URL in `lib/core/constants/api_constants.dart`.
- Authentication: JWT stored with `flutter_secure_storage` (see `TokenManager`). Many datasources call `tokenManager.getAccessToken()` and add `Authorization: Bearer <token>`.
- Packages of note (in `pubspec.yaml`): `provider`, `http`, `flutter_secure_storage`, `image_picker`, `mime`.

## Common developer workflows (commands you can run / expect)
- Install deps: `flutter pub get` (note pubspec uses a beta SDK constraint — use a Flutter channel that supports Dart SDK `^3.10.0-...`).
- Run app: `flutter run` (pass `-d <device>` as needed). For Android builds the Gradle wrapper is provided (`android/gradlew`).
- Run tests: `flutter test` (there is a `test/widget_test.dart`).
- Build: `flutter build apk` / `flutter build ios` / `flutter build windows` as usual; desktop targets use platform-specific tooling (CMake for Windows/Linux/macOS under `windows/`, `linux/`, `macos/`).

## Editing API calls and token behavior
- To change API root or endpoints, update `lib/core/constants/api_constants.dart` and feature datasource implementations (e.g., `features/*/data/datasources/*_remote_datasource.dart`).
- If you need automatic token refresh, prefer handling it in `lib/core/network/api_client.dart` or add a specialized higher-level refresh flow that does not introduce circular dependencies with TokenManager (current `ApiClient._ensureValidToken` is intentionally minimal).

## Small examples to copy-paste
- Add Authorization header in a datasource (pattern already used):
  final token = tokenManager == null ? null : await tokenManager!.getAccessToken();
  if (token != null) headers['Authorization'] = 'Bearer $token';

- Provider fetch pattern (see `StudentProfileProvider.fetchProfile`):
  set status to loading, call usecase, assign result, set status to loaded or error, notifyListeners()

## Editing guidelines for AI agents
- Preserve the existing structure and naming conventions. Prefer small, minimal changes in the same pattern rather than introducing new architectural frameworks.
- When adding services, mirror the manual wiring style in `lib/main.dart` unless the PR explicitly intends to introduce a DI change (ask humans first).
- When modifying endpoints or tokens, run a quick smoke test with `flutter run` or targeted unit tests if you add them.

## Where to look for more context
- Root `README.md` (repo-level notes).
- `lib/main.dart` for wiring and routes.
- Any feature under `lib/features` for domain/data/presentation examples.

If anything here is unclear or missing (for example, a private API key flow or CI commands), tell me what you want added and I will update this file.

## قواعد المشروع (مقتبَس ومُلخّص من `AI_PROJECT_RULES.md`)
ملاحظات سريعة ومباشرة للوكيل الآلي — هذه القواعد يجب الاتّباع بها حرفياً عند توليد كود جديد:

- اللغة: كل الشروحات والتعليقات يجب أن تكون بالعربية، بينما يبقى الكود والمُسَمَّيات باللغة الإنجليزية.
- بنية المشروع: اتّبع بنية Clean Architecture على مستوى الميزات: `lib/features/{feature}/presentation`, `domain`, `data`.
- الطبقة المشتركة (core): تضمّ المجلد `lib/core/` مع هذه المجلدات الفرعية المتوقعة: `constants`, `errors`, `network`, `providers`, `services`, `theme`, `utils`, `widgets`.
- أسماء الملفات والأنماط:
  - واجهات المستودعات: `<Thing>Repository` والبادج إنفِلس: `<Thing>RepositoryImpl`.
  - Data sources: `*RemoteDataSource` / `*RemoteDataSourceImpl` وتجب قبول `http.Client` و`TokenManager?` (إن وُجد).
  - UseCases: صفوف بسيطة في `domain/usecases` وتُحقَن في الـ Providers في `lib/main.dart`.
- الشبكات والتوكن:
  - كل طلبات API يجب أن تمر عبر `api_client.dart` أو عبر datasources التي تستخدمه.
  - توكن المصادقة يجب تخزينه في تخزين آمن (secure storage). القِصَدُ المذكور في القواعد: `core/services/token_service.dart` — في هذا المستودع الفعلي توجد `lib/core/utils/token_manager.dart`، فالمَهمّ هو: استخدم ملف إدارة التوكن الموجود بدلاً من إنشاء تكرار.
  - أضف رأس HTTP `Authorization: Bearer <token>` تلقائياً عندما يكون التوكن متاحاً.
- واجهة المستخدم والقوَاعِد البصرية:
  - استخدم Material 3، بطاقات مدوَّرة، تباعد متسق، ورسوم انتقال سلسة.
  - المكوّنات القابلة لإعادة الاستخدام توضع في `lib/core/widgets/`.
- الرسوم المتكررة: ضع الحركات القابلة لإعادة الاستخدام في `lib/core/utils/animations.dart` (أمثلة: `fade_animation.dart`, `scale_animation.dart`, `page_transition.dart`).
- عند إنشاء ميزة جديدة (AI يجب أن يولّد تلقائياً):
  1. Entity
  2. Repository interface
  3. UseCase(s)
  4. Model
  5. Remote/local Datasource
  6. Repository implementation
  7. Provider (ChangeNotifier) وتوصيله في `lib/main.dart`
  8. Page وWidgets اللازمة

- قاعدة مهمة: لا تُكرر كود موجود أصلاً في `lib/core` — إذا كانت وظيفة موجودة في `core` استخدمها بدل إعادة تنفيذها.

هذه الإضافات تُشبه قواعد المشروع المجمّعة في `AI_PROJECT_RULES.md` وقد تم توضيح أي اختلافات مكانية (مثل موقع TokenManager) لتجنّب الارتباك.
