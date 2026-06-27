import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tabata_config.dart';
import '../providers/providers.dart';
import 'number_stepper.dart';

class TabataSetupTab extends ConsumerWidget {
  final TabataConfig config;

  const TabataSetupTab({super.key, required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(tabataConfigProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('타바타 설정'),
          const SizedBox(height: 12),
          _Card(
            children: [
              NumberStepper(
                label: '운동 시간',
                value: config.exerciseSeconds,
                unit: '초',
                min: 5,
                max: 300,
                step: 5,
                onChanged: notifier.setExerciseSeconds,
              ),
              _divider(),
              NumberStepper(
                label: '휴식 시간',
                value: config.restSeconds,
                unit: '초',
                min: 5,
                max: 300,
                step: 5,
                onChanged: notifier.setRestSeconds,
              ),
              _divider(),
              NumberStepper(
                label: '반복 횟수',
                value: config.rounds,
                unit: '회',
                min: 1,
                max: 20,
                step: 1,
                onChanged: notifier.setRounds,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _TotalTimeCard(config: config),
          const SizedBox(height: 16),
          _PreviewCard(config: config),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(color: Colors.white10, height: 1);
}

// ─── 보조 위젯 ────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      );
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C2E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(children: children),
      );
}

class _TotalTimeCard extends StatelessWidget {
  final TabataConfig config;
  const _TotalTimeCard({required this.config});

  @override
  Widget build(BuildContext context) {
    final total = config.totalSeconds;
    final m = total ~/ 60;
    final s = total % 60;
    final text = m > 0 ? '${m}분 ${s}초' : '${s}초';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          const Text('총 운동 시간',
              style: TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final TabataConfig config;
  const _PreviewCard({required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('구성 미리보기',
              style: TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 10),
          Row(
            children: [
              _PhaseChip(
                label: '운동 ${config.exerciseSeconds}초',
                color: const Color(0xFFE53935),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward,
                  size: 14, color: Colors.white38),
              const SizedBox(width: 8),
              _PhaseChip(
                label: '휴식 ${config.restSeconds}초',
                color: const Color(0xFF1E88E5),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '× ${config.rounds}회 반복',
            style:
                const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _PhaseChip extends StatelessWidget {
  final String label;
  final Color color;
  const _PhaseChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Text(label,
            style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      );
}
