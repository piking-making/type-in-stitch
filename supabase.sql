-- Type in Stitch 아카이브 테이블 설정
-- Supabase 대시보드 > SQL Editor 에 이 파일 내용을 붙여넣고 Run 하세요. (한 번만)

create extension if not exists pgcrypto with schema extensions;

create table if not exists public.patterns (
  id                uuid primary key default gen_random_uuid(),
  created_at        timestamptz not null default now(),
  title             text not null check (char_length(title) between 1 and 60),
  nickname          text check (nickname is null or char_length(nickname) <= 30),
  craft             text not null check (craft in ('knit','cross','filet')),
  cols              int  not null check (cols between 5 and 400),
  rows              int  not null check (rows between 5 and 500),
  data              jsonb not null check (jsonb_typeof(data) = 'object' and pg_column_size(data) < 200000),
  delete_token_hash text not null check (delete_token_hash ~ '^[0-9a-f]{64}$')
);
create index if not exists patterns_created_at_idx on public.patterns (created_at desc);

-- 행 단위 보안: 누구나 읽고 추가할 수 있지만, 수정·삭제는 막아요.
alter table public.patterns enable row level security;
drop policy if exists "anyone can read" on public.patterns;
drop policy if exists "anyone can add"  on public.patterns;
create policy "anyone can read" on public.patterns for select to anon, authenticated using (true);
create policy "anyone can add"  on public.patterns for insert to anon, authenticated with check (true);

-- 삭제용 키의 해시는 아무에게도 보이지 않게 열 단위 권한을 좁혀요.
revoke all on public.patterns from anon, authenticated;
grant select (id, created_at, title, nickname, craft, cols, rows, data) on public.patterns to anon, authenticated;
grant insert (title, nickname, craft, cols, rows, data, delete_token_hash) on public.patterns to anon, authenticated;

-- 올린 브라우저에 저장된 키로만 자기 도안을 지울 수 있게 하는 함수
create or replace function public.delete_pattern(p_id uuid, p_token text)
returns boolean
language plpgsql
security definer
set search_path = public, extensions
as $$
declare n int;
begin
  delete from public.patterns
   where id = p_id
     and delete_token_hash = encode(extensions.digest(p_token, 'sha256'), 'hex');
  get diagnostics n = row_count;
  return n > 0;
end
$$;
revoke all on function public.delete_pattern(uuid, text) from public;
grant execute on function public.delete_pattern(uuid, text) to anon, authenticated;
