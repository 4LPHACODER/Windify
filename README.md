# windify_v2

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Supabase Auth Token Testing (Postman)

Use this flow to obtain a user JWT and call protected Supabase endpoints.

### 1) Postman environment variables

- `SUPABASE_URL` (example: `https://<project-ref>.supabase.co`)
- `SUPABASE_ANON_KEY`
- `EMAIL`
- `PASSWORD`
- `ACCESS_TOKEN`

### 2) Get access token

- Method: `POST`
- URL: `{{SUPABASE_URL}}/auth/v1/token?grant_type=password`
- Headers:
  - `apikey: {{SUPABASE_ANON_KEY}}`
  - `Content-Type: application/json`
- Body (raw JSON):

```json
{
  "email": "{{EMAIL}}",
  "password": "{{PASSWORD}}"
}
```

Optional Postman Tests script to store token:

```javascript
const json = pm.response.json();
if (json.access_token) {
  pm.environment.set("ACCESS_TOKEN", json.access_token);
}
```

### 3) Call protected table endpoint

- Method: `GET`
- URL: `{{SUPABASE_URL}}/rest/v1/saved_locations?select=*`
- Headers:
  - `apikey: {{SUPABASE_ANON_KEY}}`
  - `Authorization: Bearer {{ACCESS_TOKEN}}`

The response should follow your RLS policies for the authenticated user.
