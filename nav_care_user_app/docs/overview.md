# Architecture Overview

This app follows a layered Flutter architecture with clear separation between presentation, data, and core infrastructure.

## Layers
- Presentation: UI widgets, pages, and Cubit state management
- Data: repositories, remote services, models, and API responses
- Core: networking, config, DI, storage, routing, and shared utilities

## State management
- `flutter_bloc` (Cubits) is used across features for predictable state and testability.

## Navigation
- `go_router` handles route definitions and navigation in `lib/core/routing/app_router.dart`.

## Data flow (API to UI)
1. UI triggers a Cubit action.
2. Cubit calls a Repository.
3. Repository uses a Remote Service (API client).
4. Remote Service uses Dio for HTTP and returns models.
5. Cubit updates state; UI reacts.

## Dependency injection
- `get_it` is used in `lib/core/di/di.dart` to wire repositories, services, and cubits.
