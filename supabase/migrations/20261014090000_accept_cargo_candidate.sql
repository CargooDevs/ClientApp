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

  if v_post.user_id is distinct from v_user_id then
    raise exception 'Only the owner can accept an offer.' using errcode = '42501';
  end if;

  if v_post.status <> 'open' then
    raise exception 'Cargo post is no longer open.' using errcode = 'P0001';
  end if;

  if v_candidate.proposed_price is null or v_candidate.proposed_price < 0 then
    raise exception 'Cargo offer has no valid price.' using errcode = '22023';
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
