# Playwright Web Smoke PoC

## 목적
- Flutter web 앱 화면을 실제 브라우저 기준으로 1건 smoke 검증한다.
- 핵심 동선: 홈 진입 → 퀵 추가(탭 좌표 기반 접근) → 미루는 중 탭(탭 바 좌표 기반) 이동

## 실행 방식

### A) flutter web-server 자동 구동 + Playwright 실행
```bash
cd /Users/lee/.openclaw/workspace-implementer
npx playwright test --config=playwright.config.js e2e/playwright-web-smoke.spec.js
```

- 위 명령은 `webServer` 설정이 앱 실행을 시도한다.
- 앱 렌더링/컴파일이 오래 걸릴 수 있으므로 3~5분 여유를 둔다.
- 현재 Flutter web 렌더러가 canvas 위주라 텍스트 기반 locator 검증이 제한적이다.

### B) 이미 앱 서버가 구동 중인 경우
```bash
cd /Users/lee/.openclaw/workspace-implementer
SKIP_PLAYWRIGHT_WEBSERVER=1 PLAYWRIGHT_APP_URL=http://127.0.0.1:8080 \
  npx playwright test --config=playwright.config.js e2e/playwright-web-smoke.spec.js
```

## 현재 산출 체크 포인트
- 페이지 Title 로드 확인 (`Postponed Todos`)
- `flutter-view` DOM 존재/가시성 확인
- 화면 좌표 기반 click 안정 동작
- 스크린샷 바이트 생성 여부(렌더 안정성 확인용)
