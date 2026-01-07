# API & Integrations

Base URL is configured via `AppConfig` -> `ApiConfig` in `lib/core/config/api_config.dart`.

## Core endpoints (examples)
Auth:
- `POST /api/users/auth/login`
- `POST /api/users/auth/register`
- `POST /api/users/auth/password/reset-code`
- `POST /api/users/auth/password/verify-code`
- `POST /api/users/auth/password/reset`

Services:
- `GET /api/services`
- `POST /api/services`
- `GET /api/service-offerings`
- `GET /api/service-offerings/:id`
- `GET /api/service-offerings/:id/related`

Hospitals:
- `GET /api/hospitals`
- `GET /api/hospitals/boosted`
- `GET /api/hospitals/:id`
- `GET /api/hospitals/:id/clinics`
- `GET /api/hospitals/:id/doctors`

Doctors:
- `GET /api/doctors`
- `GET /api/doctors/boosted`
- `GET /api/doctors/:id`

Appointments:
- `POST /api/appointments`
- `GET /api/appointments`
- `GET /api/appointments/:id`

Reviews:
- `GET /api/reviews/hospitals/:hospitalId`
- `GET /api/reviews/doctors/:doctorId`
- `GET /api/reviews/service-offerings/:offeringId`

Chat:
- `GET /api/chat/conversations`
- `GET /api/chat/conversations/:conversationId/messages`

FAQ:
- `GET /api/faq`

## Error handling
- HTTP via Dio in `lib/core/network/dio_client.dart`
- 401 or invalid token triggers session clearing

## Authentication
- Tokens are stored in secure storage and attached as `Authorization: Bearer <token>`

If you have Swagger/Postman, add links here and describe how to run them.
