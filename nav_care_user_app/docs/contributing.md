# Contributing (How to add a new feature)

1) Create feature folder
- `lib/presentation/features/<feature>/view`
- `lib/presentation/features/<feature>/viewmodel`
- `lib/data/<feature>/` (models, services, repository)

2) Add routing
- Update `lib/core/routing/app_router.dart` with the new route.

3) Add DI wiring
- Register service/repository/cubit in `lib/core/di/di.dart`.

4) Implement UI + state
- Build UI page(s) and Cubit state.
- Connect to repository and handle loading/error/success.

5) Update shared widgets if needed
- Place reusable widgets in `lib/presentation/shared/`.

6) Tests (if applicable)
- Add widget/unit tests under `test/`.

## Pre-merge checklist
- No hardcoded secrets
- Runs `flutter analyze`
- Passes `flutter test`
- Feature works on Android/iOS
