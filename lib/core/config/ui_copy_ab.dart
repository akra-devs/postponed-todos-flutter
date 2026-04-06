enum UiCopyAbProfile { stable, gentle, playful }

class UiCopyAbSet {
  const UiCopyAbSet({
    required this.homePrimary,
    required this.homeSnooze,
    required this.homeHolding,
    required this.detailComplete,
    required this.detailDrop,
    required this.holdingRestore,
    required this.holdingCancel,
    required this.dropCancel,
    required this.restoreDefer,
    required this.holdingSuggestionTitle,
    required this.holdingSuggestionDescription,
    required this.holdingRevisitTitle,
    required this.holdingRevisitDescription,
    required this.intent,
  });

  final String homePrimary;
  final String homeSnooze;
  final String homeHolding;
  final String detailComplete;
  final String detailDrop;
  final String holdingRestore;
  final String holdingCancel;
  final String dropCancel;
  final String restoreDefer;
  final String holdingSuggestionTitle;
  final String holdingSuggestionDescription;
  final String holdingRevisitTitle;
  final String holdingRevisitDescription;
  final String intent;
}

abstract final class UiCopyAbCatalog {
  const UiCopyAbCatalog._();

  static const UiCopyAbProfile activeProfile = UiCopyAbProfile.stable;

  static const Map<UiCopyAbProfile, UiCopyAbSet> sets = {
    UiCopyAbProfile.stable: UiCopyAbSet(
      homePrimary: '천천히 다시 이어갈래요',
      homeSnooze: '조금 천천히 미뤄둘게요',
      homeHolding: '보관함에 조용히 내려둘래요',
      detailComplete: '완료했어',
      detailDrop: '오늘은 여기서 멈출래요',
      holdingRestore: '다시 꺼내볼래요',
      holdingCancel: '그냥 둘게요',
      dropCancel: '다음에 볼게요',
      restoreDefer: '조금 뒤로 미루기',
      holdingSuggestionTitle: '지금은 잠깐 쉬어가도 괜찮아요',
      holdingSuggestionDescription: '지금은 부담이 덜할 때로 천천히 보이게 쉬어둘게요.',
      holdingRevisitTitle: '이 일, 천천히 다시 꺼낼래요?',
      holdingRevisitDescription: '한동안 쉬어뒀던 일이야. 필요하면 다시 미루는 중으로 천천히 가져올 수 있어요.',
      intent: '안전한 복귀 중심',
    ),
    UiCopyAbProfile.gentle: UiCopyAbSet(
      homePrimary: '조금씩 다시 이어가볼까요',
      homeSnooze: '천천히 내려놔둘래요',
      homeHolding: '보관함에 살짝 내려두기',
      detailComplete: '마쳤어',
      detailDrop: '일단 멈출래요',
      holdingRestore: '다시 꺼내볼래요',
      holdingCancel: '그냥 둘게요',
      dropCancel: '지금은 둘게요',
      restoreDefer: '조금 뒤로 미루기',
      holdingSuggestionTitle: '지금은 잠깐 쉬어도 괜찮아 보여',
      holdingSuggestionDescription: '조금 덜 보여도 되는 항목으로 보관함에 잠깐 둬볼까?',
      holdingRevisitTitle: '이 일을 다시 꺼내볼까?',
      holdingRevisitDescription: '한동안 쉬어둔 일이라 지금은 가볍게 다시 놓아두고 확인해요.',
      intent: '안정감 + 선택권',
    ),
    UiCopyAbProfile.playful: UiCopyAbSet(
      homePrimary: '오늘은 여기서 쉬어갈래요',
      homeSnooze: '잠깐만 내려둘래요',
      homeHolding: '보관함에 휴식 내려두기',
      detailComplete: '마무리했어',
      detailDrop: '일단 패스',
      holdingRestore: '천천히 다시 볼래요',
      holdingCancel: '그냥 넘길래요',
      dropCancel: '계속 둘게요',
      restoreDefer: '한 박자 미루기',
      holdingSuggestionTitle: '지금은 잠깐 멈춰도 괜찮은 구간 같아요',
      holdingSuggestionDescription: '지금은 보기 부담이 줄어드는 시점이라 보관함에 살짝 이동해요.',
      holdingRevisitTitle: '이 일, 다시 볼 시간인가요?',
      holdingRevisitDescription: '다시 꺼내보는 것만으로도 리듬이 생겨요. 다시 미루는 중으로 복귀해도 좋아요.',
      intent: '부담 없는 탐색',
    ),
  };
}
