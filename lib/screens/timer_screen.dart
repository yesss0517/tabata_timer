import 'dart:math';
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

    // 완료 감지
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
                Expanded(flex: 2, child: _TopInfo(state: state)),
                Expanded(flex: 5, child: Center(child: _CircularTimer(state: state))),
                Expanded(flex: 2, child: _Controls(
                  state: state,
                  onPauseToggle: () => ref.read(timerProvider.notifier).togglePause(),
                  onStop: () => _handleBackPress(context, ref),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleBackPress(BuildContext context, WidgetRef ref) async {
    final shouldStop = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C2E),
        title: const Text('타이머 중단', style: TextStyle(color: Colors.white)),
        content: const Text('타이머를 중단하고 처음으로 돌아갈까요?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('계속하기', style: TextStyle(color: Colors.white54)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
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

  void _showCompletionDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C2E),
        title: const Text('🎉 완료!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('모든 라운드를 완료했습니다!',
            style: TextStyle(color: Colors.white70)),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(timerProvider.notifier).stop();
              if (context.mounted) Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF43A047)),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

// ─── 상단 라운드 정보 ─────────────────────────────────────────

class _TopInfo extends StatelessWidget {
  final TimerState state;
  const _TopInfo({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          state.progressLabel,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 18,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
            ),
          ),
        ),
      ],
    );
  }
}

// ─── 원형 프로그래스바 + 시간 ─────────────────────────────────

class _CircularTimer extends StatelessWidget {
  final TimerState state;
  const _CircularTimer({required this.state});

  @override
  Widget build(BuildContext context) {
    final size = min(MediaQuery.of(context).size.width * 0.78, 300.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── 원형 프로그래스바 (부드러운 애니메이션) ──────────
          // key: 단계가 바뀔 때마다 새로 시작 (0에서 채워지도록)
          TweenAnimationBuilder<double>(
            key: ValueKey('${state.currentRound}_${state.phase.name}'),
            tween: Tween<double>(begin: 0.0, end: state.progress),
            // 1초 틱 사이를 보간 → 스타카토 없이 부드럽게
            duration: const Duration(milliseconds: 950),
            curve: Curves.linear,
            builder: (context, animatedProgress, _) {
              return CustomPaint(
                size: Size(size, size),
                painter: _ArcPainter(progress: animatedProgress),
              );
            },
          ),
          // ── 시간 텍스트 ───────────────────────────────────────
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: EdgeInsets.all(size * 0.18),
              child: Text(
                state.formattedTime,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  static const double _stroke = 10.0;

  const _ArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - _stroke;

    // 배경 원
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.black26
        ..strokeWidth = _stroke
        ..style = PaintingStyle.stroke,
    );

    if (progress <= 0) return;

    // 진행 arc (12시 방향에서 시계방향)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress.clamp(0.0, 1.0),
      false,
      Paint()
        ..color = Colors.white.withOpacity(0.90)
        ..strokeWidth = _stroke
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}

// ─── 컨트롤 버튼 ─────────────────────────────────────────────

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
        _CircleBtn(
          icon: state.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
          label: state.isPaused ? '재개' : '일시정지',
          size: 72,
          iconSize: 36,
          onPressed: state.isCompleted ? null : onPauseToggle,
        ),
        const SizedBox(width: 40),
        _CircleBtn(
          icon: Icons.stop_rounded,
          label: '중단',
          size: 60,
          iconSize: 28,
          faded: true,
          onPressed: onStop,
        ),
      ],
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final double size;
  final double iconSize;
  final bool faded;
  final VoidCallback? onPressed;

  const _CircleBtn({
    required this.icon,
    required this.label,
    required this.size,
    required this.iconSize,
    required this.onPressed,
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
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: enabled ? (faded ? Colors.black26 : Colors.black38) : Colors.black12,
              border: Border.all(
                color: enabled ? (faded ? Colors.white30 : Colors.white60) : Colors.white12,
                width: 1.5,
              ),
            ),
            child: Icon(icon,
                size: iconSize, color: enabled ? Colors.white : Colors.white30),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
              color: enabled ? Colors.white70 : Colors.white30, fontSize: 12),
        ),
      ],
    );
  }
}
