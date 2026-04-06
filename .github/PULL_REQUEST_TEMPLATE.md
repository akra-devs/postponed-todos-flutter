# Pull Request

## 요약
- 변경 의도:
- 영향 범위:
- 연관 이슈/Ticket:

## 테스트
- [ ] 기존 유닛/통합 테스트 실행
- [ ] Flutter 분석/테스트 완료
- [ ] Playwright 관련 변경이 있는 경우 아래 항목을 추가로 확인

### Playwright CI Gate (해당 시)
- [ ] Playwright 실패 샘플을 변경/추가했는지 확인 (`e2e/playwright-smoke-gate-failure-samples.json`)
- [ ] 실패 샘플 신규 항목의 `expectedSignature`와 `getRecommendations`/`classifyFailure` 일치성 확인
- [ ] `npm run playwright-smoke-gate-ci` 실행
  - `playwright-smoke-gate-rules-test`: PASS/FAIL
  - `playwright-smoke-gate`: PASS/FAIL
- [ ] PR 본문에 `playwright-smoke-gate` 요약 반영
  - `runs`, `pass`, `fail`, `passRate`, `threshold`, `ok`

## 변경 사항

- 핵심 변경점:
- 검토 포인트:

## 스크린샷/캡처
- (필요시)
