-- Olga & Sascha · RSVP database
-- Run this entire file in Supabase SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.rsvps (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(trim(name)) between 2 and 160),
  attendance text not null check (attendance in ('Hacer check in para el vuelo','Dudoso','No podré asistir')),
  diet text not null default '',
  message text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.rsvp_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.rsvps enable row level security;
alter table public.rsvp_admins enable row level security;

-- Public visitors can submit an RSVP, but cannot read or enumerate any guest data.
drop policy if exists "Anyone can submit an RSVP" on public.rsvps;
create policy "Anyone can submit an RSVP"
on public.rsvps for insert to anon, authenticated
with check (
  char_length(trim(name)) between 2 and 160
  and attendance in ('Hacer check in para el vuelo','Dudoso','No podré asistir')
  and char_length(diet) <= 3000
  and char_length(message) <= 3000
);

-- Only user IDs explicitly inserted into rsvp_admins can manage guest data.
drop policy if exists "Admins can read RSVPs" on public.rsvps;
create policy "Admins can read RSVPs"
on public.rsvps for select to authenticated
using (exists (select 1 from public.rsvp_admins a where a.user_id = auth.uid()));

drop policy if exists "Admins can update RSVPs" on public.rsvps;
create policy "Admins can update RSVPs"
on public.rsvps for update to authenticated
using (exists (select 1 from public.rsvp_admins a where a.user_id = auth.uid()))
with check (exists (select 1 from public.rsvp_admins a where a.user_id = auth.uid()));

drop policy if exists "Admins can delete RSVPs" on public.rsvps;
create policy "Admins can delete RSVPs"
on public.rsvps for delete to authenticated
using (exists (select 1 from public.rsvp_admins a where a.user_id = auth.uid()));

-- Admins can only see their own allowlist row; no client-side insert policy exists.
drop policy if exists "Admins can view own authorization" on public.rsvp_admins;
create policy "Admins can view own authorization"
on public.rsvp_admins for select to authenticated
using (user_id = auth.uid());

grant usage on schema public to anon, authenticated;
revoke all on table public.rsvps from anon, authenticated;
revoke all on table public.rsvp_admins from anon, authenticated;
grant insert on public.rsvps to anon, authenticated;
grant select, update, delete on public.rsvps to authenticated;
grant select on public.rsvp_admins to authenticated;
