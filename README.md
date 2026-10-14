# Cargoo Client

Flutter app for customers to post cargo requests, request rides, and rent vehicles. The shared package lives in `cargoo_shared/`; the app currently uses Supabase Auth, Postgres, and Realtime.

## Local setup

1. Install Flutter and fetch dependencies:

   ```powershell
   flutter pub get
   ```

2. Configure the Supabase project URL and its public anon/publishable key. Do not put a service-role key in the app:

   ```powershell
   flutter run --dart-define=SUPABASE_URL=https://<project>.supabase.co --dart-define=SUPABASE_ANON_KEY=<public-key>
   ```

3. Apply `supabase/migrations/20261014090000_accept_cargo_candidate.sql` to the project database. This migration adds the atomic cargo-offer acceptance API and enables Realtime for `post_candidates` when the Supabase Realtime publication exists.

The migration expects the `posts`, `post_candidates`, and `rides` tables and columns already used by the app. Confirm their ID types and column names against the target Supabase project before applying it. Configure row-level security so users can access only their own cargo posts and related offers; the acceptance function independently checks that the authenticated user owns the open post and that its offer is still pending.

## Checks

```powershell
flutter analyze
flutter test
```

The cargo flow currently reads vehicle types, creates cargo posts, streams pending driver offers, and accepts an offer through the transactional database function. Real location/geocoding, fare calculation for passenger rides, rental pricing/availability, payments, and account recovery are not implemented yet.
