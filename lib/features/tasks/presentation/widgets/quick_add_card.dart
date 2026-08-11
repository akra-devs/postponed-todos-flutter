import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing_tokens.dart';
import '../../application/task_draft_validator.dart';

class QuickAddCard extends StatefulWidget {
  const QuickAddCard({
    super.key,
    required this.onSubmit,
    this.initialTitle = '',
    this.initialNote,
    this.heading = '가볍게 넣어두기',
    this.description = '캘린더까지는 아니지만 잊고 싶지 않은 일을 빠르게 적어둘 수 있어요.',
    this.submitLabel = '미뤄둔 일 넣기',
  });

  final Future<bool> Function(String title, String? note) onSubmit;
  final String initialTitle;
  final String? initialNote;
  final String heading;
  final String description;
  final String submitLabel;

  @override
  State<QuickAddCard> createState() => _QuickAddCardState();
}

class _QuickAddCardState extends State<QuickAddCard> {
  final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(
    text: widget.initialTitle,
  );
  late final _noteController = TextEditingController(
    text: widget.initialNote ?? '',
  );
  bool _submitting = false;
  bool _showValidation = false;
  bool _submitFailed = false;

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.heroInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.heading,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacingTokens.eyebrowGap),
              Text(
                widget.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacingTokens.cardInset),
              TextFormField(
                controller: _titleController,
                autofocus: true,
                autocorrect: true,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                maxLength: TaskDraftValidator.maxTitleLength,
                autovalidateMode: _showValidation
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                validator: TaskDraftValidator.titleError,
                onChanged: (_) => _clearSubmitFailure(),
                decoration: const InputDecoration(
                  hintText: '예: 병원 예약 다시 잡기',
                  labelText: '할 일 제목',
                  helperText: '짧게 적어두면 나중에 다시 시작하기 쉬워요.',
                ),
              ),
              const SizedBox(height: AppSpacingTokens.listGap),
              TextFormField(
                controller: _noteController,
                minLines: 2,
                maxLines: 4,
                maxLength: TaskDraftValidator.maxNoteLength,
                textCapitalization: TextCapitalization.sentences,
                autovalidateMode: _showValidation
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                validator: TaskDraftValidator.noteError,
                onChanged: (_) => _clearSubmitFailure(),
                decoration: const InputDecoration(
                  hintText: '메모가 있으면 같이 적어둘래?',
                  labelText: '메모 (선택)',
                ),
              ),
              if (_submitFailed) ...[
                const SizedBox(height: AppSpacingTokens.xs),
                Text(
                  '저장하지 못했어요. 입력 내용은 그대로 두었으니 다시 시도해 주세요.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacingTokens.cardInset),
              Semantics(
                liveRegion: _submitting,
                child: FilledButton(
                  onPressed: _submitting ? null : _handleSubmit,
                  child: Text(_submitting ? '저장하는 중...' : widget.submitLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_submitting) return;
    setState(() => _showValidation = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    final submitted = await widget.onSubmit(
      _titleController.text,
      _noteController.text,
    );
    if (!mounted) return;
    if (!submitted) {
      setState(() {
        _submitting = false;
        _submitFailed = true;
      });
      return;
    }
    _titleController.clear();
    _noteController.clear();
    FocusScope.of(context).unfocus();
    setState(() => _submitting = false);
  }

  void _clearSubmitFailure() {
    if (_submitFailed && mounted) {
      setState(() => _submitFailed = false);
    }
  }
}
