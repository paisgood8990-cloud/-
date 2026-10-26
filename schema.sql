-- ACHIEVIA Supabase schema
-- Run this in Supabase SQL Editor for a new project.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null unique,
  avatar text not null default '🙂',
  bio text not null default '',
  role text not null default 'member' check (role in ('member','admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.achievements (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null default '',
  icon text not null default '🏅',
  rarity text not null default '일반' check (rarity in ('일반','희귀','영웅','전설')),
  active boolean not null default true,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

create table if not exists public.user_achievements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  achievement_id uuid not null references public.achievements(id) on delete cascade,
  awarded_by uuid references public.profiles(id),
  awarded_at timestamptz not null default now(),
  unique(user_id, achievement_id)
);

alter table public.profiles enable row level security;
alter table public.achievements enable row level security;
alter table public.user_achievements enable row level security;

-- Profile reads are public; users can only edit their own safe profile fields.
drop policy if exists "Profiles visible to everyone" on public.profiles;
create policy "Profiles visible to everyone" on public.profiles for select using (true);
revoke update on public.profiles from authenticated;
grant update (username, avatar, bio) on public.profiles to authenticated;
drop policy if exists "Members update own profile" on public.profiles;
create policy "Members update own profile" on public.profiles for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);

-- Create profile on sign-up. Role is never copied from user metadata.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, username)
  values (new.id, coalesce(nullif(trim(new.raw_user_meta_data ->> 'username'), ''), 'member-' || substr(new.id::text, 1, 8)));
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

-- Helper checks role from the protected profiles table.
create or replace function public.is_achievia_admin()
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.profiles p
    where p.id = (select auth.uid()) and p.role = 'admin'
  );
$$;
grant execute on function public.is_achievia_admin() to authenticated;

drop policy if exists "Active achievements visible" on public.achievements;
create policy "Active achievements visible" on public.achievements for select using (active = true or public.is_achievia_admin());
drop policy if exists "Admins create achievements" on public.achievements;
create policy "Admins create achievements" on public.achievements for insert to authenticated with check (public.is_achievia_admin() and created_by = (select auth.uid()));
drop policy if exists "Admins update achievements" on public.achievements;
create policy "Admins update achievements" on public.achievements for update to authenticated using (public.is_achievia_admin()) with check (public.is_achievia_admin());
drop policy if exists "Admins delete achievements" on public.achievements;
create policy "Admins delete achievements" on public.achievements for delete to authenticated using (public.is_achievia_admin());

drop policy if exists "Award records visible" on public.user_achievements;
create policy "Award records visible" on public.user_achievements for select using (true);
drop policy if exists "Admins award badges" on public.user_achievements;
create policy "Admins award badges" on public.user_achievements for insert to authenticated with check (public.is_achievia_admin() and awarded_by = (select auth.uid()));
drop policy if exists "Admins revoke badges" on public.user_achievements;
create policy "Admins revoke badges" on public.user_achievements for delete to authenticated using (public.is_achievia_admin());

-- Default demo achievements are intentionally not inserted: the first admin can create them through the UI.
