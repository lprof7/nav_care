# Project Structure

Key folders and their purpose:

- `lib/`
  - `app.dart`: app root and theme setup
  - `main.dart`: app entrypoint
  - `core/`: config, DI, routing, network, storage, utilities
  - `data/`: repositories, remote services, models, responses
  - `presentation/`: UI, feature pages, shared widgets, cubits

## Naming conventions
- Features use lower_snake_case folders
- Cubits and states use `*_cubit.dart`, `*_state.dart`
- Repositories use `*_repository.dart`
- Remote services use `*_remote_service.dart`

## Where to place code
- Models: `lib/data/**/models`
- Services (API): `lib/data/**/services`
- Repositories: `lib/data/**/` root for the feature
- Shared widgets: `lib/presentation/shared/`
- Feature UI: `lib/presentation/features/<feature>/view`
- Feature state: `lib/presentation/features/<feature>/viewmodel`
