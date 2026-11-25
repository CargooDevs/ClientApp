# Cargoo Client

Flutter app for customers to post cargo requests, request rides, and rent vehicles. The shared package lives in `cargoo_shared/`; the app currently uses Supabase Auth, Postgres, and Realtime.
## Local setup

1. Install Flutter and fetch dependencies (Run the code below inside the ClientApp and cargoo_shared folder):

   ```powershell
   flutter pub get
   ```

2. Configure the Supabase project URL and its public anon/publishable key. Do not put a service-role key in the app:

   ```powershell
   flutter run --dart-define=SUPABASE_URL=https://<project>.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=<public-key>
   ```

2. Alternative - Debbug:

Ensure adb, which can be downloaded through android studio has its location on the system variable PATH, this will allow for your mobile device to be detected by the computer and when you debugg through Visual Studio Code, it will install the app on your device.

3. Apply the Supabase migrations to a staging project first. `20261014090000_accept_cargo_candidate.sql` adds missing cargo fields, replaces public post reads with reads for authenticated registered drivers and post owners, adds cargo offer read/insert policies, exposes only driver name/rating to the owning client, adds atomic offer acceptance, and enables Realtime for `post_candidates`. `20261020090000_normalize_ride_lifecycle.sql` allows rides to start without a driver, standardizes the initial status and ride type, lets registered drivers find and atomically accept passenger rides, limits cancellation to the customer's unassigned ride, and enables ride updates in Realtime.

The migrations expect UUID IDs and the existing `posts`, `post_candidates`, `rides`, and `drivers` columns shown in the Supabase schema. Review them against a staging project and back up production before applying them. The cargo acceptance function independently checks that the authenticated user owns the open post and that its offer is still pending.

## Checks

```powershell
flutter analyze
flutter test
```

The cargo flow currently reads vehicle types, creates cargo posts, streams pending driver offers, and accepts an offer through the transactional database function. Real location/geocoding, fare calculation for passenger rides, rental pricing/availability, payments, and account recovery are not implemented yet.
