abstract final class TaskDraftValidator {
  static const int maxTitleLength = 120;
  static const int maxNoteLength = 1_000;

  static String? titleError(String? value) {
    final title = value?.trim() ?? '';
    if (title.isEmpty) {
      return '할 일을 한 줄로 적어주세요.';
    }
    if (title.length > maxTitleLength) {
      return '제목은 $maxTitleLength자 이내로 적어주세요.';
    }
    return null;
  }

  static String? noteError(String? value) {
    if ((value ?? '').length > maxNoteLength) {
      return '메모는 $maxNoteLength자 이내로 적어주세요.';
    }
    return null;
  }

  static String normalizeTitle(String value) => value.trim();

  static String? normalizeNote(String? value) {
    final note = value?.trim() ?? '';
    return note.isEmpty ? null : note;
  }
}
