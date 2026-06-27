import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';

// ── 다이얼로그 전용 private 프로바이더 ──────────────────────────

// 시간 피커 (분/초)
final _dlgMinProvider = StateProvider.autoDispose<int>((ref) => 0);
final _dlgSecProvider = StateProvider.autoDispose<int>((ref) => 0);
final _dlgSecFocusProvider = Provider.autoDispose<FocusNode>((ref) {
  final node = FocusNode();
  ref.onDispose(node.dispose);
  return node;
});
final _dlgMinCtrlProvider =
    Provider.autoDispose<TextEditingController>((ref) {
  final ctrl = TextEditingController();
  ref.onDispose(ctrl.dispose);
  return ctrl;
});
final _dlgSecCtrlProvider =
    Provider.autoDispose<TextEditingController>((ref) {
  final ctrl = TextEditingController();
  ref.onDispose(ctrl.dispose);
  return ctrl;
});

// 횟수 휠 피커
final _dlgRoundsProvider = StateProvider.autoDispose<int>((ref) => 1);
final _dlgWheelCtrlProvider =
    Provider.autoDispose<FixedExtentScrollController>((ref) {
  final ctrl = FixedExtentScrollController();
  ref.onDispose(ctrl.dispose);
  return ctrl;
});

// ── 메인 설정 탭 ──────────────────────────────────────────────

class TabataSetupTab extends ConsumerWidget {
  const TabataSetupTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(tabataConfigProvider);
    final notifier = ref.read(tabataConfigProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('운동 시간'),
          const SizedBox(height: 8),
          _TouchableTimeCard(
            seconds: config.exerciseSeconds,
            onTap: () => _showTimeDialog(
              context, ref,
              title: '운동 시간',
              currentSeconds: config.exerciseSeconds,
              allowZero: false,
              onSave: notifier.setExerciseSeconds,
            ),
          ),

          const SizedBox(height: 16),
          const _SectionLabel('휴식 시간'),
          const SizedBox(height: 8),
          _TouchableTimeCard(
            seconds: config.restSeconds,
            onTap: () => _showTimeDialog(
              context, ref,
              title: '휴식 시간',
              currentSeconds: config.restSeconds,
              allowZero: true, // 0초 허용
              onSave: notifier.setRestSeconds,
            ),
          ),

          const SizedBox(height: 16),
          const _SectionLabel('반복 횟수'),
          const SizedBox(height: 8),
          _TouchableRoundsCard(
            rounds: config.rounds,
            onTap: () => _showRoundsDialog(context, ref, config.rounds),
          ),

          const SizedBox(height: 20),
          _TotalTimeCard(config: config),
        ],
      ),
    );
  }

  // ── 시간 다이얼로그 ──────────────────────────────────────────
  void _showTimeDialog(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required int currentSeconds,
    required bool allowZero,
    required void Function(int) onSave,
  }) {
    final initMin = currentSeconds ~/ 60;
    final initSec = currentSeconds % 60;

    showDialog<void>(
      context: context,
      builder: (_) => ProviderScope(
        parent: ProviderScope.containerOf(context),
        overrides: [
          _dlgMinProvider.overrideWith((ref) => initMin),
          _dlgSecProvider.overrideWith((ref) => initSec),
          _dlgMinCtrlProvider.overrideWith((ref) {
            final ctrl = TextEditingController(
                text: initMin.toString().padLeft(2, '0'));
            ref.onDispose(ctrl.dispose);
            return ctrl;
          }),
          _dlgSecCtrlProvider.overrideWith((ref) {
            final ctrl = TextEditingController(
                text: initSec.toString().padLeft(2, '0'));
            ref.onDispose(ctrl.dispose);
            return ctrl;
          }),
          _dlgSecFocusProvider.overrideWith((ref) {
            final node = FocusNode();
            ref.onDispose(node.dispose);
            return node;
          }),
        ],
        child: _TimeDialog(
          title: title,
          allowZero: allowZero,
          onSave: onSave,
        ),
      ),
    );
  }

  // ── 횟수 다이얼로그 ──────────────────────────────────────────
  void _showRoundsDialog(
      BuildContext context, WidgetRef ref, int currentRounds) {
    showDialog<void>(
      context: context,
      builder: (_) => ProviderScope(
        parent: ProviderScope.containerOf(context),
        overrides: [
          _dlgRoundsProvider.overrideWith((ref) => currentRounds),
          _dlgWheelCtrlProvider.overrideWith((ref) {
            final ctrl = FixedExtentScrollController(
                initialItem: currentRounds - 1);
            ref.onDispose(ctrl.dispose);
            return ctrl;
          }),
        ],
        child: _RoundsDialog(
          onSave: (rounds) =>
              ref.read(tabataConfigProvider.notifier).setRounds(rounds),
        ),
      ),
    );
  }
}

// ── 터치 가능한 시간 카드 ─────────────────────────────────────

class _TouchableTimeCard extends StatelessWidget {
  final int seconds;
  final VoidCallback onTap;

  const _TouchableTimeCard({
    required this.seconds,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    final display =
        '${m.toString().padLeft(2, '0')} : ${s.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C2E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              display,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const Icon(Icons.edit_rounded,
                color: Colors.white30, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── 터치 가능한 횟수 카드 ─────────────────────────────────────

class _TouchableRoundsCard extends StatelessWidget {
  final int rounds;
  final VoidCallback onTap;

  const _TouchableRoundsCard(
      {required this.rounds, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C2E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$rounds 회',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(Icons.expand_more_rounded,
                color: Colors.white30, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── 총 시간 카드 ─────────────────────────────────────────────

class _TotalTimeCard extends StatelessWidget {
  final dynamic config;
  const _TotalTimeCard({required this.config});

  @override
  Widget build(BuildContext context) {
    final total = config.totalSeconds as int;
    final m = total ~/ 60;
    final s = total % 60;
    final text = m > 0 ? '${m}분 ${s}초' : '${s}초';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Text('총 운동 시간',
              style: TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 4),
          Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ── 섹션 라벨 ────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            color: Colors.white54,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6),
      );
}

// ══════════════════════════════════════════════════════════════
//  시간 입력 다이얼로그 (분 : 초)
// ══════════════════════════════════════════════════════════════

class _TimeDialog extends ConsumerWidget {
  final String title;
  final bool allowZero;
  final void Function(int) onSave;

  const _TimeDialog({
    required this.title,
    required this.allowZero,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minutes = ref.watch(_dlgMinProvider);
    final seconds = ref.watch(_dlgSecProvider);
    final minCtrl = ref.watch(_dlgMinCtrlProvider);
    final secCtrl = ref.watch(_dlgSecCtrlProvider);
    final secFocus = ref.watch(_dlgSecFocusProvider);

    final total = minutes * 60 + seconds;
    final isValid = allowZero ? true : total > 0;

    return AlertDialog(
      backgroundColor: const Color(0xFF1C1C2E),
      title: Text(title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // 분 입력
              Expanded(
                child: _NumField(
                  controller: minCtrl,
                  label: '분',
                  autofocus: true,
                  onChanged: (v) {
                    final val = int.tryParse(v) ?? 0;
                    ref.read(_dlgMinProvider.notifier).state =
                        val.clamp(0, 99);
                    // 2자리 입력 시 초 필드로 포커스 이동
                    if (v.length >= 2) secFocus.requestFocus();
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 0, 8, 16),
                child: Text(':',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold)),
              ),
              // 초 입력
              Expanded(
                child: _NumField(
                  controller: secCtrl,
                  label: '초',
                  focusNode: secFocus,
                  onChanged: (v) {
                    final val = int.tryParse(v) ?? 0;
                    ref.read(_dlgSecProvider.notifier).state =
                        val.clamp(0, 59);
                  },
                ),
              ),
            ],
          ),
          if (!isValid)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('최소 1초 이상 입력하세요',
                  style: TextStyle(
                      color: Color(0xFFEF5350), fontSize: 12)),
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
          onPressed: isValid
              ? () {
                  onSave(total);
                  Navigator.pop(context);
                }
              : null,
          style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE53935)),
          child: const Text('확인'),
        ),
      ],
    );
  }
}

class _NumField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool autofocus;
  final FocusNode? focusNode;
  final void Function(String) onChanged;

  const _NumField({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 2,
      style: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38),
        counterText: '',
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFFE53935), width: 2),
        ),
      ),
      onChanged: onChanged,
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  횟수 휠 피커 다이얼로그 (1 ~ 50회)
// ══════════════════════════════════════════════════════════════

class _RoundsDialog extends ConsumerWidget {
  final void Function(int) onSave;

  const _RoundsDialog({required this.onSave});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(_dlgRoundsProvider);
    final ctrl = ref.watch(_dlgWheelCtrlProvider);

    return AlertDialog(
      backgroundColor: const Color(0xFF1C1C2E),
      title: const Text('반복 횟수',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
      content: SizedBox(
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 선택 영역 하이라이트
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // 휠 피커
            ListWheelScrollView.useDelegate(
              controller: ctrl,
              itemExtent: 52,
              physics: const FixedExtentScrollPhysics(),
              perspective: 0.003,
              onSelectedItemChanged: (index) {
                ref.read(_dlgRoundsProvider.notifier).state =
                    index + 1;
              },
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (ctx, index) {
                  if (index < 0 || index >= 50) return null;
                  final round = index + 1;
                  final isSelected = selected == round;
                  return Center(
                    child: Text(
                      '$round 회',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.white30,
                        fontSize: isSelected ? 26 : 20,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                },
                childCount: 50,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소',
              style: TextStyle(color: Colors.white54)),
        ),
        FilledButton(
          onPressed: () {
            onSave(selected);
            Navigator.pop(context);
          },
          style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE53935)),
          child: const Text('확인'),
        ),
      ],
    );
  }
}
