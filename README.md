# Type in Stitch

글자를 뜨개·십자수·방안뜨기 도안으로 바꿔 주는 웹앱입니다. 정적 파일만으로 돌아가고, 아카이브(도안 공유)는 Supabase 무료 DB를 씁니다.

## 폴더 구성

| 파일 | 설명 |
|---|---|
| `index.html` | 앱 전체 |
| `config.js` | Supabase 연결 정보 (직접 채워 넣기) |
| `supabase.sql` | 아카이브 테이블·보안 규칙 설정 SQL (한 번만 실행) |
| `fonts/` | 도스명조·도스고딕(MIT), Neo둥근모(SIL OFL) 웹폰트와 라이선스 |

## 1. Supabase 설정 (약 5분)

1. https://supabase.com 에서 무료 계정을 만들고 **New project**를 만듭니다. (지역은 Seoul 추천)
2. 왼쪽 메뉴 **SQL Editor** → 새 쿼리에 `supabase.sql` 내용을 통째로 붙여넣고 **Run**.
3. **Project Settings → API**(또는 **API Keys**)에서 두 값을 복사합니다.
   - Project URL (예: `https://abcd1234.supabase.co`)
   - `anon` 키 또는 `publishable` 키
4. `config.js`에 붙여넣습니다.

```js
window.TIS_CONFIG = {
  supabaseUrl: "https://abcd1234.supabase.co",
  supabaseAnonKey: "여기에 anon 또는 publishable 키"
};
```

> ⚠️ `service_role`·`secret` 키는 절대 넣지 마세요. 이 키가 공개되면 DB 전체를 마음대로 바꿀 수 있어요.
> anon/publishable 키는 공개돼도 괜찮아요. `supabase.sql`의 보안 규칙 때문에 "읽기·추가"만 됩니다.

## 2. GitHub Pages에 올리기

1. GitHub에서 새 저장소를 만듭니다. (예: `type-in-stitch`, Public)
2. 이 폴더의 파일을 전부 올립니다. (`index.html`, `config.js`, `fonts/` 등)
   - 웹에서: 저장소 → **Add file → Upload files** 로 폴더째 드래그
3. 저장소 **Settings → Pages** → Source: **Deploy from a branch**, Branch: `main` / `/ (root)` → Save
4. 1~2분 뒤 `https://<아이디>.github.io/<저장소이름>/` 에서 열립니다.

## 아카이브 동작 방식

- 로그인 없이 누구나 도안을 올리고 볼 수 있어요.
- 올릴 때 브라우저에 무작위 "삭제 키"가 저장돼서, **올린 브라우저에서만** 그 도안을 지울 수 있어요. (방문 기록·사이트 데이터를 지우면 키도 사라져요)
- 서버 쪽에서 제목 60자, 닉네임 30자, 도안 크기(가로 5–400, 세로 5–500), 데이터 용량(약 200KB) 제한을 검사해요.

### 관리(부적절한 도안 지우기)

Supabase 대시보드 → **Table Editor → patterns** 에서 행을 선택해 삭제하면 됩니다.

### 알아둘 점

- 로그인이 없어서 도배·스팸을 완전히 막을 수는 없어요. 문제가 생기면 Supabase **SQL Editor**에서 아래를 실행해 업로드를 잠시 막을 수 있어요.
  ```sql
  revoke insert on public.patterns from anon, authenticated;   -- 업로드 중지
  grant insert (title, nickname, craft, cols, rows, data, delete_token_hash) on public.patterns to anon, authenticated;  -- 다시 허용
  ```
- Supabase 무료 프로젝트는 일주일 넘게 아무 요청이 없으면 일시정지돼요. 대시보드에서 **Restore**를 누르면 다시 켜집니다.

## 폰트

| 서체 | 출처 | 비고 |
|---|---|---|
| Noto Sans KR · Noto Serif KR · Inter · Baskervville | Google Fonts | |
| Tiny5 · Bitcount Prop Double · Jacquarda Bastarda 9 | Google Fonts | 픽셀 서체 |
| Neo둥근모 · 도스고딕 · 도스명조 | `fonts/` 폴더 | 픽셀 서체 |

### 픽셀 서체 처리

픽셀 서체는 서체 파일에 들어 있는 픽셀 격자를 그대로 도안으로 옮겨요.

- **서체 픽셀 1개 = 도안 1칸.** 게이지(코·단 비율)와 상관없이 가로·세로 모두 1칸에 맞춰요.
- 글자 크기는 서체의 기준 픽셀 수의 배수로만 바뀌어요. (Tiny5 8단 → 대문자 5단, Bitcount 10단 → 대문자 6단, Jacquarda Bastarda 9 13단, Neo둥근모·도스 16단)
- 장평은 100% 단위, 자간·행간은 1픽셀 단위로 맞춰져서 픽셀이 칸 사이에 걸치지 않아요.
- Bitcount의 둥근 점은 점 하나를 픽셀 한 칸으로 봐요. (굵기 설정과 상관없이)
- 최적화: **최소 도안 크기** = 서체 원래 크기(픽셀 1개 = 1칸), **가장 잘 보이게** = 2배(픽셀 1개 = 2×2칸)

## 폰트 라이선스

- 도스명조·도스고딕 — © Damheo Lee, MIT License (`fonts/LICENSE-DOSfonts.txt`). 웹용으로 한글·영문·기호만 남겨 용량을 줄였어요.
- Neo둥근모 — © Eunbin Jeong (Dalgona.), SIL Open Font License 1.1 (`fonts/LICENSE-neodgm.txt`)
- Google Fonts 서체들은 각 서체의 라이선스(대부분 SIL OFL)를 따르며 Google Fonts에서 불러와요.
