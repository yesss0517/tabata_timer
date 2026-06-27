import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/interval_segment.dart';
import '../providers/providers.dart';
import 'number_stepper.dart';

/// 인터벌 구간별 배경 색상
const _kColors = [
  Color(0xFFE53935),
  Color(0xFFFB8C00),
  Color(0xFF43A047),
  Color(0xFF1E88E5),
  Color(0xFF8E24AA),
];

class IntervalSetupTab extends ConsumerWidget {
  final List<IntervalSegment> segments;

  const IntervalSetupTab({super.key, required this.segments});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(intervalSegmentsProvider.notifier);

    return Column(
      children: [
        // ── 구간 목록 ──────────────────────────────────────
        Expanded(
          child: segments.isEmpty
              ? const _EmptyState()
              : ReorderableListView.builder(
                  padding:
                      const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  buildDefaultDragHandles: false,
                  onReorder: notifier.reorder,
                  itemCount: segments.length,
                  itemBuilder: (ctx, i) {
                    final seg = segments[i];
                    return _SegmentCard(
                      key: ValueKey(seg.id),
                      segment: seg,
                      index: i,
                      color: _kColors[i % _kColors.length],
                      onDelete: () =>
                          notifier.removeSegment(seg.id),
                    );
                  },
                ),
        ),
        // ── 구간 추가 버튼 ─────────────────────────────────
        if (segments.length < 10)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () =>
                    _showAddDialog(context, ref),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('구간 추가',
                    style: TextStyle(fontSize: 15)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side:
                      const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        if (segments.length >= 10)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              '최대 10개까지 추가할 수 있습니다',
              style:
                  TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ),
      ],
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (_) => _AddSegmentDialog(
        onAdd: (label, seconds) {
          ref.read(intervalSegmentsProvider.notifier).addSegment(
                IntervalSegment(label: label, seconds: seconds),
              );
        },
      ),
    );
  }
}

// ─── 빈 목록 안내 ────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.playlist_add, size: 48, color: Colors.white24),
            SizedBox(height: 12),
            Text(
              '구간을 추가해주세요',
              style: TextStyle(color: Colors.white38, fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              '최소 1개, 최대 10개',
              style: TextStyle(color: Colors.white24, fontSize: 13),
            ),
          ],
        ),
      );
}

// ─── 구간 카드 ───────────────────────────────────────────────

class _SegmentCard extends StatelessWidget {
  final IntervalSegment segment;
  final int index;
  final Color color;
  final VoidCallback onDelete;

  const _SegmentCard({
    super.key,
    required this.segment,
    required this.index,
    required this.color,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final m = segment.seconds ~/ 60;
    final s = segment.seconds % 60;
    final timeStr = m > 0 ? '${m}분 ${s}초' : '${s}초';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: color.withOpacity(0.25),
          child: Text(
            '${index + 1}',
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14),
          ),
        ),
        title: Text(
          segment.label,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15),
        ),
        subtitle: Text(
          timeStr,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Colors.white38, size: 20),
              onPressed: onDelete,
              tooltip: '삭제',
            ),
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.drag_handle_rounded,
                    color: Colors.white30, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 구간 추가 다이얼로그 ─────────────────────────────────────

class _AddSegmentDialog extends ConsumerWidget {
  final void Function(String label, int seconds) onAdd;

  const _AddSegmentDialog({required this.onAdd});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = ref.watch(newSegmentLabelProvider);
    final seconds = ref.watch(newSegmentSecondsProvider);
    final canAdd = label.trim().isNotEmpty;

    return AlertDialog(
      backgroundColor: const Color(0xFF1C1C2E),
      title: const Text('구간 추가',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 구간 이름 입력
          TextField(
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: '구간 이름',
              labelStyle: const TextStyle(color: Colors.white54),
              hintText: '예: 달리기, 휴식, 인터벌',
              hintStyle: const TextStyle(color: Colors.white24),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white24),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xFFE53935)),
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.white10,
            ),
            onChanged: (v) =>
                ref.read(newSegmentLabelProvider.notifier).state = v,
          ),
          const SizedBox(height: 16),
          // 시간 설정
          NumberStepper(
            label: '시간',
            value: seconds,
            unit: '초',
            min: 5,
            max: 3600,
            step: 5,
            onChanged: (v) =>
                ref.read(newSegmentSecondsProvider.notifier).state = v,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소',
              style: TextStyle(color: Colors.white54)),
        ),
        FilledButton(
          onPressed: canAdd
              ? () {
                  onAdd(label.trim(), seconds);
                  Navigator.pop(context);
                }
              : null,
          style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE53935)),
          child: const Text('추가'),
        ),
      ],
    );
  }
}
