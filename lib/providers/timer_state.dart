import 'package:flutter/material.dart';
import '../models/timer_mode.dart';

class TimerState {
  final bool isRunning;
  final bool isPaused;
  final bool isCompleted;
  final int remainingSeconds;
  final int currentPhaseTotal; // 현재 구간 전체 시간 (프로그래스바용)

  // Tabata
  final int currentRound;
  final int totalRounds;
  final TimerPhase phase;

  // Visual
  final Color backgroundColor;

  const TimerState({
    required this.isRunning,
    required this.isPaused,
    required this.isCompleted,
    required this.remainingSeconds,
    required this.currentPhaseTotal,
    required this.currentRound,
    required this.totalRounds,
    required this.phase,
    required this.backgroundColor,
  });

  factory TimerState.initial() => const TimerState(
        isRunning: false,
        isPaused: false,
        isCompleted: false,
        remainingSeconds: 0,
        currentPhaseTotal: 0,
        currentRound: 1,
        totalRounds: 0,
        phase: TimerPhase.exercise,
        backgroundColor: Color(0xFFE53935),
      );

  TimerState copyWith({
    bool? isRunning,
    bool? isPaused,
    bool? isCompleted,
    int? remainingSeconds,
    int? currentPhaseTotal,
    int? currentRound,
    int? totalRounds,
    TimerPhase? phase,
    Color? backgroundColor,
  }) =>
      TimerState(
        isRunning: isRunning ?? this.isRunning,
        isPaused: isPaused ?? this.isPaused,
        isCompleted: isCompleted ?? this.isCompleted,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        currentPhaseTotal: currentPhaseTotal ?? this.currentPhaseTotal,
        currentRound: currentRound ?? this.currentRound,
        totalRounds: totalRounds ?? this.totalRounds,
        phase: phase ?? this.phase,
        backgroundColor: backgroundColor ?? this.backgroundColor,
      );

  // ─── Computed ────────────────────────────────────────

  /// 현재 구간 진행률 0.0 ~ 1.0
  double get progress => currentPhaseTotal > 0
      ? (currentPhaseTotal - remainingSeconds) / currentPhaseTotal
      : 0.0;

  /// 항상 MM:SS 포맷
  String get formattedTime {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get phaseLabel => phase == TimerPhase.exercise ? '운동' : '휴식';

  String get progressLabel => '$currentRound / $totalRounds';

  bool get isActive => isRunning || isPaused;
}
