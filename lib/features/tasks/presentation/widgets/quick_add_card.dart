import 'package:flutter/material.dart';

class QuickAddCard extends StatefulWidget {
  const QuickAddCard({super.key, required this.onSubmit});

  final Future<void> Function(String title, String? note) onSubmit;

  @override
  State<QuickAddCard> createState() => _QuickAddCardState();
}

class _QuickAddCardState extends State<QuickAddCard> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('가볍게 넣어두기', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '캘린더까지는 아니지만 잊고 싶지 않은 일을 빠르게 적어둘 수 있어요.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleSubmit(),
              decoration: const InputDecoration(
                hintText: '예: 병원 예약 다시 잡기',
                labelText: '할 일 제목',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: '메모가 있으면 같이 적어둘래?',
                labelText: '메모',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submitting ? null : _handleSubmit,
              child: Text(_submitting ? '넣는 중...' : '미뤄둔 일 넣기'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    await widget.onSubmit(_titleController.text, _noteController.text);
    if (!mounted) return;
    _titleController.clear();
    _noteController.clear();
    FocusScope.of(context).unfocus();
    setState(() => _submitting = false);
  }
}
