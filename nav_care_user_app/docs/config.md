# Config & Environments

## Environment loading
The app loads env variables via `flutter_dotenv`:
- Loader: `lib/core/config/config_loader.dart`
- Env access: `lib/core/config/env.dart`

In `lib/main.dart`:
```dart
await ConfigLoader.load(AppEnv.development);
```

## Env files
- `assets/env/.env.development`
- `assets/env/.env.production`

## Keys in use
From `lib/core/config/env.dart`:
- `VPSMain`
- `VpsChat`
- `SocketMain`
- `SocketChat`
- `MAPS_API_KEY`
- `sentryDns`

## Do not commit secrets
- Keep real API keys and tokens out of git.
- Use local env files for sensitive values.
