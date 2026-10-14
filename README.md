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

3. Apply `supabase/migrations/20261014090000_accept_cargo_candidate.sql` to a staging project first. It adds missing cargo fields, replaces public post reads with reads for authenticated registered drivers and post owners, adds cargo offer read/insert policies, exposes only driver name/rating to the owning client, adds atomic offer acceptance, and enables Realtime for `post_candidates` when the Supabase Realtime publication exists.

The migration expects UUID IDs and the existing `posts`, `post_candidates`, `rides`, and `drivers` columns shown in the Supabase schema. Review it against a staging project and back up production before applying it. The acceptance function independently checks that the authenticated user owns the open post and that its offer is still pending.

## Checks

```powershell
flutter analyze
flutter test
```

The cargo flow currently reads vehicle types, creates cargo posts, streams pending driver offers, and accepts an offer through the transactional database function. Real location/geocoding, fare calculation for passenger rides, rental pricing/availability, payments, and account recovery are not implemented yet.
