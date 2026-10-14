alter table public.posts
  add column if not exists pickup_address text,
  add column if not exists dropoff_address text,
  add column if not exists cargo_weight_kg numeric,
  add column if not exists is_fragile boolean not null default false,
  add column if not exists needs_helper boolean not null default false;

alter table public.post_candidates
  add column if not exists status text not null default 'pending';

drop policy if exists "posts are public" on public.posts;
drop policy if exists "cargo drivers read open posts" on public.posts;
create policy "cargo drivers read open posts"
  on public.posts
  for select
  to authenticated
  using (
    status = 'open'
    and category = 'cargo'
    and exists (
      select 1
        from public.drivers d
       where d.driver_id = (select auth.uid())
    )
  );

drop policy if exists "cargo participants can read offers"
  on public.post_candidates;
create policy "cargo participants can read offers"
  on public.post_candidates
  for select
  to authenticated
  using (
    driver_id = (select auth.uid())
    or exists (
      select 1
        from public.posts p
       where p.post_id = post_candidates.post_id
         and p.user_id = (select auth.uid())
    )
  );

drop policy if exists "registered drivers can propose cargo offers"
  on public.post_candidates;
create policy "registered drivers can propose cargo offers"
  on public.post_candidates
  for insert
  to authenticated
  with check (
    driver_id = (select auth.uid())
    and status = 'pending'
    and proposed_price > 0
    and exists (
      select 1
        from public.drivers d
       where d.driver_id = (select auth.uid())
    )
    and exists (
      select 1
        from public.posts p
       where p.post_id = post_candidates.post_id
         and p.status = 'open'
         and p.category = 'cargo'
    )
  );

create or replace function public.accept_cargo_candidate(p_candidate_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id uuid := auth.uid();
  v_candidate public.post_candidates%rowtype;
  v_post public.posts%rowtype;
  v_ride public.rides%rowtype;
begin
  if v_user_id is null then
    raise exception 'Authentication is required to accept a cargo offer.'
      using errcode = '42501';
  end if;

  select *
    into v_candidate
    from public.post_candidates
   where candidate_id = p_candidate_id;

  if not found then
    raise exception 'Cargo offer was not found.' using errcode = 'P0002';
  end if;

  select *
    into v_post
    from public.posts
   where post_id = v_candidate.post_id
   for update;

  if not found then
    raise exception 'Cargo post was not found.' using errcode = 'P0002';
  end if;

  if v_post.user_id is distinct from v_user_id then
    raise exception 'Only the owner can accept an offer.' using errcode = '42501';
  end if;

  select *
    into v_candidate
    from public.post_candidates
   where candidate_id = p_candidate_id
   for update;

  if not found or v_candidate.post_id <> v_post.post_id then
    raise exception 'Cargo offer was not found.' using errcode = 'P0002';
  end if;

  if v_candidate.status <> 'pending' then
    raise exception 'Cargo offer is no longer pending.' using errcode = 'P0001';
  end if;

  if v_post.status <> 'open' then
    raise exception 'Cargo post is no longer open.' using errcode = 'P0001';
  end if;

  if v_candidate.proposed_price is null or v_candidate.proposed_price < 0 then
    raise exception 'Cargo offer has no valid price.' using errcode = '22023';
  end if;

  if nullif(btrim(v_post.pickup_address), '') is null
     or nullif(btrim(v_post.dropoff_address), '') is null then
    raise exception 'Cargo post must have pickup and drop-off addresses.'
      using errcode = '22023';
  end if;

  insert into public.rides (
    user_id,
    driver_id,
    pick_up,
    drop_off,
    total_fare,
    status,
    ride_type
  )
  values (
    v_post.user_id,
    v_candidate.driver_id,
    v_post.pickup_address,
    v_post.dropoff_address,
    v_candidate.proposed_price,
    'driver_assigned',
    'cargo'
  )
  returning * into v_ride;

  update public.posts
     set status = 'matched',
         ride_id = v_ride.ride_id
   where post_id = v_post.post_id;

  update public.post_candidates
     set status = case
       when candidate_id = v_candidate.candidate_id then 'accepted'
       else 'rejected'
     end
   where post_id = v_post.post_id
     and status = 'pending';

  return to_jsonb(v_ride);
end;
$$;

revoke all on function public.accept_cargo_candidate(uuid) from public, anon;
grant execute on function public.accept_cargo_candidate(uuid) to authenticated;

create or replace function public.get_cargo_offer_driver_profiles(p_post_id uuid)
returns table(driver_id uuid, full_name text, rating numeric)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if auth.uid() is null or not exists (
    select 1
      from public.posts p
     where p.post_id = p_post_id
       and p.user_id = auth.uid()
  ) then
    raise exception 'Only the cargo post owner can view offer profiles.'
      using errcode = '42501';
  end if;

  return query
    select d.driver_id, d.full_name, coalesce(d.rating, 5)::numeric
      from public.post_candidates pc
      join public.drivers d on d.driver_id = pc.driver_id
     where pc.post_id = p_post_id
       and pc.status = 'pending';
end;
$$;

revoke all on function public.get_cargo_offer_driver_profiles(uuid)
  from public, anon;
grant execute on function public.get_cargo_offer_driver_profiles(uuid)
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
       and tablename = 'post_candidates'
  ) then
    alter publication supabase_realtime add table public.post_candidates;
  end if;
end;
$$;
