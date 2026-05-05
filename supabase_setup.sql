-- ═══════════════════════════════════════════════
-- LAP UAT — Supabase Database Setup Script
-- Run this ONCE in your Supabase SQL Editor
-- ═══════════════════════════════════════════════

-- 1. PROFILES TABLE (linked to auth.users)
create table if not exists public.profiles (
  id          uuid references auth.users(id) on delete cascade primary key,
  full_name   text,
  email       text,
  role        text check (role in ('ADMIN','CO','BPO','BCM','BBM','OPS')),
  branch_code text,
  created_at  timestamptz default now()
);

-- Auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, full_name)
  values (new.id, new.email, new.raw_user_meta_data->>'full_name');
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();


-- 2. BRANCHES TABLE
create table if not exists public.branches (
  id          uuid default gen_random_uuid() primary key,
  branch_code text unique not null,
  branch_name text not null,
  city        text,
  created_at  timestamptz default now()
);

-- Seed some branches
insert into public.branches (branch_code, branch_name, city) values
  ('S0001-MFL-MAIN',     'MFL Main Branch',        'Bengaluru'),
  ('S0142-SULB-VYTTILA', 'Vyttila Branch',          'Kochi'),
  ('S0162-SULB-MANJERI', 'Manjeri Branch',           'Manjeri'),
  ('S0089-SULB-SIVAKASI','Sivakasi Branch',          'Sivakasi'),
  ('S0413-SULB-KLK',     'Kallakurichi Branch',      'Kallakurichi'),
  ('S0517-SULB-SHIGGAON','Shiggaon Branch',          'Shiggaon'),
  ('S0236-SULB-KANA',    'Kanakapura Branch',        'Kanakapura'),
  ('S0153-SULB-PALAKKAD','Palakkad Branch',          'Palakkad')
on conflict (branch_code) do nothing;


-- 3. LEADS TABLE
create table if not exists public.leads (
  id                  uuid default gen_random_uuid() primary key,
  application_id      text unique not null,

  -- Basic
  first_name          text,
  last_name           text,
  mobile              text,
  email               text,
  loan_amount         numeric,
  loan_purpose        text,
  product_type        text,
  branch_code         text,
  source_type         text,
  tenure              integer,

  -- Personal
  dob                 date,
  gender              text,
  pan                 text,
  aadhaar             text,
  marital_status      text,
  dependents          integer,
  address             text,
  employment_type     text,
  employer            text,

  -- Co-applicant
  co_applicant_name   text,
  co_applicant_mobile text,
  co_applicant_pan    text,
  co_relation         text,

  -- Property
  property_type       text,
  property_usage      text,
  property_age        integer,
  property_area       numeric,
  property_address    text,
  market_value        numeric,
  distress_value      numeric,
  ownership_type      text,
  title_clear         text,

  -- Income
  monthly_income      numeric,
  annual_income       numeric,
  other_income        numeric,
  income_proof        text,
  existing_emi        numeric,
  outstanding_loans   numeric,
  credit_score        integer,
  bureau              text,
  remarks             text,

  -- Documents
  docs_collected      jsonb default '[]',

  -- Workflow
  stage               text default 'DDE Review',
  checklist_done      jsonb default '[]',
  stage_history       jsonb default '[]',
  assigned_to         uuid references auth.users(id),
  assigned_to_name    text,
  created_by          uuid references auth.users(id),

  created_at          timestamptz default now(),
  updated_at          timestamptz default now()
);

-- Auto-update updated_at
create or replace function public.update_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists leads_updated_at on public.leads;
create trigger leads_updated_at
  before update on public.leads
  for each row execute procedure public.update_updated_at();


-- 4. ROW LEVEL SECURITY (RLS)
alter table public.profiles enable row level security;
alter table public.branches  enable row level security;
alter table public.leads     enable row level security;

-- Profiles: users can read all, update own
create policy "profiles_select" on public.profiles for select using (true);
create policy "profiles_insert" on public.profiles for insert with check (true);
create policy "profiles_update" on public.profiles for update using (auth.uid() = id);
create policy "profiles_delete" on public.profiles for delete using (true);

-- Branches: all authenticated users can read; only admin can write
create policy "branches_select" on public.branches for select using (auth.role() = 'authenticated');
create policy "branches_insert" on public.branches for insert with check (auth.role() = 'authenticated');
create policy "branches_delete" on public.branches for delete using (auth.role() = 'authenticated');

-- Leads: all authenticated users can read and write
create policy "leads_select" on public.leads for select using (auth.role() = 'authenticated');
create policy "leads_insert" on public.leads for insert with check (auth.role() = 'authenticated');
create policy "leads_update" on public.leads for update using (auth.role() = 'authenticated');
create policy "leads_delete" on public.leads for delete using (auth.role() = 'authenticated');


-- ═══════════════════════════════════════════════
-- DONE! Now create your Admin user:
-- 1. Go to Authentication → Users → Add User
-- 2. Email: admin@mfl.com | Password: Admin@1234
-- 3. Go to Table Editor → profiles
-- 4. Find the admin row → set role = ADMIN
-- ═══════════════════════════════════════════════
