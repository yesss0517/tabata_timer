import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/timer_mode.dart';
import '../providers/providers.dart';
import '../providers/timer_state.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timerProvider);

    // 완료 감지 → 완료 다이얼로그 표시
    ref.listen<TimerState>(timerProvider, (prev, next) {
      if (!(prev?.isCompleted ?? false) && next.isCompleted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) _showCompletionDialog(context, ref);
        });
      }
    });

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _handleBackPress(context, ref);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          width: double.infinity,
          height: double.infinity,
          color: state.backgroundColor,
          child: SafeArea(
            child: Column(
              children: [
                // ── 상단: 구간 정보 ────────────────────────
                Expanded(
                  flex: 2,
                  child: _TopInfo(state: state),
                ),

                // ── 중앙: 남은 시간 (최대한 크게) ─────────
                Expanded(
                  flex: 5,
                  child: _TimerDisplay(seconds: state.remainingSeconds),
                ),

                // ── 하단: 컨트롤 버튼 ─────────────────────
                Expanded(
                  flex: 2,
                  child: _Controls(
                    state: state,
                    onPauseToggle: () =>
                        ref.read(timerProvider.notifier).togglePause(),
                    onStop: () => _handleBackPress(context, ref),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── 뒤로 가기 처리 ─────────────────────────────────────

  Future<void> _handleBackPress(
      BuildContext context, WidgetRef ref) async {
    final shouldStop = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C2E),
        title: const Text('타이머 중단',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          '타이머를 중단하고 처음으로 돌아갈까요?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('계속하기',
                style: TextStyle(color: Colors.white54)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700),
            child: const Text('중단'),
          ),
        ],
      ),
    );

    if (shouldStop == true && context.mounted) {
      ref.read(timerProvider.notifier).stop();
      Navigator.of(context).pop();
    }
  }

  // ─── 완료 다이얼로그 ─────────────────────────────────────

  void _showCompletionDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C2E),
        title: const Text('🎉 완료!',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          '모든 구간을 성공적으로 마쳤습니다!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(timerProvider.notifier).stop();
              if (context.mounted) Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF43A047)),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

// ─── 상단 구간 정보 ──────────────────────────────────────────

class _TopInfo extends StatelessWidget {
  final TimerState state;
  const _TopInfo({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 라운드 / 전체
        Text(
          state.progressLabel,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 18,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        // 현재 단계 라벨
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            state.phaseLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── 남은 시간 표시 ─────────────────────────────────────────

class _TimerDisplay extends StatelessWidget {
  final int seconds;
  const _TimerDisplay({required this.seconds});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          _format(seconds),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 200,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  String _format(int total) {
    if (total < 60) return '$total';
    final m = total ~/ 60;
    final s = total % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

// ─── 컨트롤 버튼 영역 ────────────────────────────────────────

class _Controls extends StatelessWidget {
  final TimerState state;
  final VoidCallback onPauseToggle;
  final VoidCallback onStop;

  const _Controls({
    required this.state,
    required this.onPauseToggle,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 일시정지 / 재개
        _CircleBtn(
          icon: state.isPaused
              ? Icons.play_arrow_rounded
              : Icons.pause_rounded,
          label: state.isPaused ? '재개' : '일시정지',
          onPressed: state.isCompleted ? null : onPauseToggle,
          size: 72,
          iconSize: 36,
        ),
        const SizedBox(width: 40),
        // 중단 (처음으로)
        _CircleBtn(
          icon: Icons.stop_rounded,
          label: '중단',
          onPressed: onStop,
          size: 60,
          iconSize: 28,
          faded: true,
        ),
      ],
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final bool faded;

  const _CircleBtn({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.size,
    required this.iconSize,
    this.faded = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: enabled
                  ? (faded ? Colors.black26 : Colors.black38)
                  : Colors.black12,
              border: Border.all(
                color: enabled
                    ? (faded ? Colors.white30 : Colors.white60)
                    : Colors.white12,
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: enabled ? Colors.white : Colors.white30,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: enabled ? Colors.white70 : Colors.white30,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
