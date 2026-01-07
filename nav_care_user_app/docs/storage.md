# Local Storage

## What is stored
- Auth token: `flutter_secure_storage`
- User profile: `shared_preferences`

## Files
- Token store: `lib/core/storage/secure_token_store.dart`
- User store: `lib/core/storage/user_store.dart`

## Keys
- Token key: `auth_token`
- User key: `user_data`

## Clearing
- Token and user are cleared on logout or unauthorized responses.
