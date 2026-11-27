-- =====================================================================
--  LIF Board (otpclif.mn) — Supabase хүснэгт
--  otpclicenses.mn-тэй ИЖИЛ Supabase төсөл дээр ажиллуулна:
--  Supabase → SQL Editor → New query → энэ файлыг буулгаад Run.
--  Дахин ажиллуулахад аюулгүй.
-- =====================================================================
create table if not exists public.lif_docs (
  key         text primary key,          -- 'settings', 'week:2026-W47', 'month:2026-11', 'risks', 'schedule', 'mapbg', 'riskimg'
  data        jsonb not null default '{}'::jsonb,
  client_t    bigint not null default 0, -- төхөөрөмж дээр засагдсан цаг (ms) — сүүлийнх нь давамгайлна
  updated_by  text,
  updated_at  timestamptz not null default now()
);

alter table public.lif_docs enable row level security;
drop policy if exists "lif_read"   on public.lif_docs;
drop policy if exists "lif_insert" on public.lif_docs;
drop policy if exists "lif_update" on public.lif_docs;
drop policy if exists "lif_delete" on public.lif_docs;
-- Нэвтэрсэн хэн ч харна; зөвхөн админ (app_admins) засна — сургалтын системтэй ижил дүрэм
create policy "lif_read"   on public.lif_docs for select to authenticated using (true);
create policy "lif_insert" on public.lif_docs for insert to authenticated with check (public.is_admin());
create policy "lif_update" on public.lif_docs for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "lif_delete" on public.lif_docs for delete to authenticated using (public.is_admin());

-- Олон төхөөрөмж (MAXHUB, утас, компьютер) шууд шинэчлэгдэх
do $$ begin
  alter publication supabase_realtime add table public.lif_docs;
exception when duplicate_object then null; end $$;
