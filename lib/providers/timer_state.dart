import 'package:flutter/material.dart';

import '../models/interval_segment.dart';
import '../models/timer_mode.dart';

class TimerState {
  final bool isRunning;
  final bool isPaused;
  final bool isCompleted;
  final int remainingSeconds;
  final TimerMode mode;

  // Tabata
  final int currentRound;
  final int totalRounds;
  final TimerPhase phase;

  // Interval
  final int currentSegmentIndex;
  final List<IntervalSegment> segments;

  // Visual
  final Color backgroundColor;

  const TimerState({
    required this.isRunning,
    required this.isPaused,
    required this.isCompleted,
    required this.remainingSeconds,
    required this.mode,
    required this.currentRound,
    required this.totalRounds,
    required this.phase,
    required this.currentSegmentIndex,
    required this.segments,
    required this.backgroundColor,
  });

  factory TimerState.initial() => const TimerState(
        isRunning: false,
        isPaused: false,
        isCompleted: false,
        remainingSeconds: 0,
        mode: TimerMode.tabata,
        currentRound: 1,
        totalRounds: 0,
        phase: TimerPhase.exercise,
        currentSegmentIndex: 0,
        segments: [],
        backgroundColor: Color(0xFFE53935),
      );

  TimerState copyWith({
    bool? isRunning,
    bool? isPaused,
    bool? isCompleted,
    int? remainingSeconds,
    TimerMode? mode,
    int? currentRound,
    int? totalRounds,
    TimerPhase? phase,
    int? currentSegmentIndex,
    List<IntervalSegment>? segments,
    Color? backgroundColor,
  }) =>
      TimerState(
        isRunning: isRunning ?? this.isRunning,
        isPaused: isPaused ?? this.isPaused,
        isCompleted: isCompleted ?? this.isCompleted,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        mode: mode ?? this.mode,
        currentRound: currentRound ?? this.currentRound,
        totalRounds: totalRounds ?? this.totalRounds,
        phase: phase ?? this.phase,
        currentSegmentIndex: currentSegmentIndex ?? this.currentSegmentIndex,
        segments: segments ?? this.segments,
        backgroundColor: backgroundColor ?? this.backgroundColor,
      );

  // ─── Computed helpers ──────────────────────────────────────

  String get phaseLabel {
    if (mode == TimerMode.tabata) {
      return phase == TimerPhase.exercise ? '운동' : '휴식';
    }
    if (segments.isNotEmpty && currentSegmentIndex < segments.length) {
      return segments[currentSegmentIndex].label;
    }
    return '';
  }

  String get progressLabel {
    if (mode == TimerMode.tabata) return '$currentRound / $totalRounds';
    return '${currentSegmentIndex + 1} / ${segments.length}';
  }

  bool get isActive => isRunning || isPaused;
}
