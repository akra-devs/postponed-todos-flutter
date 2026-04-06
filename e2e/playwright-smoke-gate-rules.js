const recommendationCatalog = {
  timeout: [
    '클래스/페이지 로딩 대기시간을 늘리고, 앱 진입 marker 존재 여부 점검',
    'flutter startup 시 `flutter-first-frame` 이벤트와 마커 전환 경로 타이밍 로그를 확대',
  ],
  selector_or_target: [
    'Locator/target 안정성을 좌표 중심 fallback로 강화',
    '뷰/캔버스 DOM 준비 대기 정책을 보수적으로 조정',
  ],
  'count-mismatch': [
    '엔진 훅/레이디 상태 fallback 임계치를 완화하거나 마커 기반 대체 경로를 우선 적용',
    'Playwright 스모크 동작순서를 좌표 접근 후 marker 확인 순으로 재정렬',
  ],
  'text-assertion': [
    '텍스트 assertion 의존도를 축소하고 canvas 환경에서 대체 가능한 상태검증으로 전환',
  ],
  interaction: [
    '좌표 기반 click 타이밍/viewport를 조정하고, 클릭 전 hover/요소 준비 체크 추가',
    '앱 재렌더링 유발 동작 사이 간격을 확대해 상호작용 충돌 완화',
  ],
  unknown: [
    '에러 로그 상위 블록을 전체 캡처해 실패 패턴 템플릿에 매핑',
    'Playwright 브라우저 업그레이드/동작 환경 재현 여부 검토',
  ],
};

const classifyFailure = (output = '') => {
  const lines = output
    .split('\n')
    .map((line) => line.trim())
    .filter(Boolean);
  const joined = lines.join('\n');

  if (/Timeout|timed out|timedOut/i.test(joined)) {
    return 'timeout';
  }
  if (/selector.*not found|no node found|Unable to locate|Target closed/i.test(joined)) {
    return 'selector_or_target';
  }
  if (/toHaveCount\(|Expected: 3|Received: 0|count/i.test(joined)) {
    return 'count-mismatch';
  }
  if (/toHaveText|text/i.test(joined)) {
    return 'text-assertion';
  }
  if (/click/i.test(joined)) {
    return 'interaction';
  }

  return 'unknown';
};

const getRecommendations = (signature) => recommendationCatalog[signature] || recommendationCatalog.unknown;

const signatureCatalog = Object.keys(recommendationCatalog);

module.exports = {
  recommendationCatalog,
  classifyFailure,
  getRecommendations,
  signatureCatalog,
};
