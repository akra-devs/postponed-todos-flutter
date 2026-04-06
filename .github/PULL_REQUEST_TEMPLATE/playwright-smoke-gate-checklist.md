# Playwright CI Gate Review Checklist

> 이 템플릿은 참고용 보조 템플릿입니다. 
> 최신 단일 원천은 `../PULL_REQUEST_TEMPLATE.md`에서 관리합니다.

## 체크리스트

- [ ] 실패 샘플 변경이 있는 경우 `e2e/playwright-smoke-gate-failure-samples.json`에 항목을 추가/수정했는가?
- [ ] 새 항목의 `expectedSignature`와 `classifyFailure`/`getRecommendations` 결과가 일치하는가?
- [ ] `npm run playwright-smoke-gate-ci`를 실행해 모든 테스트를 통과시켰는가?
  - `playwright-smoke-gate-rules-test`: PASS/FAIL
  - `playwright-smoke-gate`: PASS/FAIL
- [ ] `playwright-smoke-gate` 실행 결과를 PR 본문에 요약했는가? (`runs / pass / fail / passRate / threshold`)
- [ ] 변경으로 인한 CI 파이프라인 동작에 영향이 있는지 검토했는가?

## 실행 로그(요약)

- `npm run playwright-smoke-gate-ci` 결과:
