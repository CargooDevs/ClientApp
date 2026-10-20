alter table public.rides
  alter column driver_id drop not null,
  alter column status set default 'searching',
  alter column ride_type set default 'passenger';

update public.rides
   set status = 'searching'
 where status = 'requested';

update public.rides
   set ride_type = 'passenger'
 where ride_type = 'standard';

drop policy if exists "registered drivers read searching passenger rides"
  on public.rides;
create policy "registered drivers read searching passenger rides"
  on public.rides
  for select
  to authenticated
  using (
    status = 'searching'
    and ride_type = 'passenger'
    and exists (
      select 1
        from public.drivers d
       where d.driver_id = (select auth.uid())
    )
  );

drop policy if exists "users cancel unassigned rides" on public.rides;
create policy "users cancel unassigned rides"
  on public.rides
  for update
  to authenticated
  using (
    user_id = (select auth.uid())
    and driver_id is null
    and status = 'searching'
  )
  with check (
    user_id = (select auth.uid())
    and driver_id is null
    and status = 'cancelled'
  );

create or replace function public.accept_passenger_ride(p_ride_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_driver_id uuid := auth.uid();
  v_ride public.rides%rowtype;
begin
  if v_driver_id is null then
    raise exception 'Authentication is required to accept a ride.'
      using errcode = '42501';
  end if;

  if not exists (
    select 1
      from public.drivers d
     where d.driver_id = v_driver_id
  ) then
    raise exception 'Only registered drivers can accept rides.'
      using errcode = '42501';
  end if;

  select *
    into v_ride
    from public.rides
   where ride_id = p_ride_id
   for update;

  if not found then
    raise exception 'Ride was not found.' using errcode = 'P0002';
  end if;

  if v_ride.status <> 'searching'
     or v_ride.driver_id is not null
     or v_ride.ride_type <> 'passenger' then
    raise exception 'Ride is no longer available.' using errcode = 'P0001';
  end if;

  update public.rides
     set driver_id = v_driver_id,
         status = 'driver_assigned'
   where ride_id = v_ride.ride_id
  returning * into v_ride;

  return to_jsonb(v_ride);
end;
$$;

revoke all on function public.accept_passenger_ride(uuid)
  from public, anon;
grant execute on function public.accept_passenger_ride(uuid)
  to authenticated;

do $$
begin
  if exists (
    select 1
      from pg_publication
     where pubname = 'supabase_realtime'
  ) and not exists (
    select 1
      from pg_publication_tables
     where pubname = 'supabase_realtime'
       and schemaname = 'public'
       and tablename = 'rides'
  ) then
    alter publication supabase_realtime add table public.rides;
  end if;
end;
$$;
