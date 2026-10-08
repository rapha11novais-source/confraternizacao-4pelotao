-- New tables only. Does not modify older forms or responses.
begin;
create table public.rsvp_4p_2026 (
  id uuid primary key default gen_random_uuid(),
  registration text not null unique check (registration ~ '^[0-9]{4,20}$'),
  name text not null check (char_length(name) between 3 and 160),
  municipality text not null check (char_length(municipality) between 2 and 100),
  attending boolean not null,
  guests jsonb not null default '[]'::jsonb check (jsonb_typeof(guests)='array'),
  edit_hash text not null unique,
  version integer not null default 1 check (version > 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (attending or guests='[]'::jsonb)
);
alter table public.rsvp_4p_2026 enable row level security;
revoke all on public.rsvp_4p_2026 from anon, authenticated;
grant select (id, registration, name, municipality, attending, guests, version, created_at, updated_at) on public.rsvp_4p_2026 to authenticated;
create policy owner_read_only on public.rsvp_4p_2026 for select to authenticated
  using ((select auth.uid()) is not null and lower((select auth.jwt())->>'email')='rapha11novais@gmail.com');

create function public.rsvp_4p_load(p_token text) returns jsonb
language plpgsql security definer set search_path='' as $$
declare r public.rsvp_4p_2026;
begin
  if p_token is null or p_token !~ '^[a-f0-9]{64}$' then raise exception 'Link pessoal inválido.'; end if;
  select * into r from public.rsvp_4p_2026 where edit_hash=encode(sha256(convert_to(p_token,'UTF8')),'hex');
  if not found then return null; end if;
  return jsonb_build_object('id',r.id,'name',r.name,'registration',r.registration,'municipality',r.municipality,'attending',r.attending,'guests',r.guests,'version',r.version,'createdAt',r.created_at,'updatedAt',r.updated_at);
end;
$$;
revoke all on function public.rsvp_4p_load(text) from public;
grant execute on function public.rsvp_4p_load(text) to anon,authenticated;

create function public.rsvp_4p_save(p_entry jsonb,p_token text) returns jsonb
language plpgsql security definer set search_path='' as $$
declare r public.rsvp_4p_2026; v integer; g jsonb; n text; m text; matricula text; presence boolean; token_hash text;
begin
  if p_token is null or p_token !~ '^[a-f0-9]{64}$' then raise exception 'Link pessoal inválido.'; end if;
  if p_entry is null or jsonb_typeof(p_entry)<>'object' or octet_length(p_entry::text)>40000 then raise exception 'Dados inválidos.'; end if;
  if jsonb_typeof(p_entry->'name') is distinct from 'string' or jsonb_typeof(p_entry->'registration') is distinct from 'string' or jsonb_typeof(p_entry->'municipality') is distinct from 'string' then raise exception 'Informe nome, matrícula e município de lotação.'; end if;
  n=btrim(p_entry->>'name'); m=initcap(regexp_replace(btrim(p_entry->>'municipality'),'\s+',' ','g')); matricula=btrim(p_entry->>'registration');
  if char_length(n) not between 3 and 160 or char_length(m) not between 2 and 100 or matricula !~ '^[0-9]{4,20}$' then raise exception 'Confira nome completo, matrícula e município de lotação.'; end if;
  if jsonb_typeof(p_entry->'attending') is distinct from 'boolean' or jsonb_typeof(p_entry->'version') is distinct from 'number' or (p_entry->>'version') !~ '^[0-9]{1,9}$' then raise exception 'Dados de confirmação inválidos.'; end if;
  presence=(p_entry->>'attending')::boolean; v=(p_entry->>'version')::integer; g=p_entry->'guests';
  if jsonb_typeof(g) is distinct from 'array' then raise exception 'Informe os convidados corretamente.'; end if;
  if jsonb_array_length(g)>100 then raise exception 'Limite de 100 convidados por resposta.'; end if;
  if exists(select 1 from jsonb_array_elements(g) a where jsonb_typeof(a) is distinct from 'string' or char_length(btrim(a#>>'{}')) not between 3 and 160) then raise exception 'Preencha o nome de todos os convidados.'; end if;
  select coalesce(jsonb_agg(btrim(a#>>'{}') order by ord),'[]'::jsonb) into g from jsonb_array_elements(g) with ordinality as items(a,ord);
  if not presence and jsonb_array_length(g)>0 then raise exception 'Uma resposta de ausência não pode conter convidados.'; end if;
  token_hash=encode(sha256(convert_to(p_token,'UTF8')),'hex');
  if v=0 then
    insert into public.rsvp_4p_2026(registration,name,municipality,attending,guests,edit_hash)
      values(matricula,n,m,presence,g,token_hash) returning * into r;
  else
    update public.rsvp_4p_2026 set name=n,municipality=m,attending=presence,guests=g,version=version+1,updated_at=now()
      where edit_hash=token_hash and version=v and registration=matricula returning * into r;
    if not found then raise exception 'Link inválido ou resposta alterada em outra aba. Recarregue sua resposta pelo link pessoal.'; end if;
  end if;
  return jsonb_build_object('id',r.id,'name',r.name,'registration',r.registration,'municipality',r.municipality,'attending',r.attending,'guests',r.guests,'version',r.version,'createdAt',r.created_at,'updatedAt',r.updated_at);
exception when unique_violation then
  raise exception 'Já existe uma resposta para esta matrícula. Abra seu link pessoal de atualização ou procure a organização.';
end;
$$;
revoke all on function public.rsvp_4p_save(jsonb,text) from public;
grant execute on function public.rsvp_4p_save(jsonb,text) to anon,authenticated;
commit;
