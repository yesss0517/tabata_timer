import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/interval_segment.dart';
import '../models/tabata_config.dart';
import '../models/timer_mode.dart';
import '../services/audio_service.dart';
import '../services/vibration_service.dart';
import 'timer_state.dart';

class TimerNotifier extends StateNotifier<TimerState> {
  final AudioService _audio;
  final VibrationService _vibration;

  Timer? _timer;
  TabataConfig? _tabataConfig;

  static const List<Color> _intervalColors = [
    Color(0xFFE53935),
    Color(0xFFFB8C00),
    Color(0xFF43A047),
    Color(0xFF1E88E5),
    Color(0xFF8E24AA),
  ];

  TimerNotifier({
    required AudioService audio,
    required VibrationService vibration,
  })  : _audio = audio,
        _vibration = vibration,
        super(TimerState.initial());

  // ─── Public API ────────────────────────────────────────────

  void startTabata(TabataConfig config) {
    _stopTimer();
    _tabataConfig = config;
    state = TimerState.initial().copyWith(
      mode: TimerMode.tabata,
      isRunning: true,
      remainingSeconds: config.exerciseSeconds,
      currentRound: 1,
      totalRounds: config.rounds,
      phase: TimerPhase.exercise,
      backgroundColor: const Color(0xFFE53935),
    );
    WakelockPlus.enable();
    _startTick();
  }

  void startInterval(List<IntervalSegment> segments) {
    if (segments.isEmpty) return;
    _stopTimer();
    _tabataConfig = null;
    state = TimerState.initial().copyWith(
      mode: TimerMode.interval,
      isRunning: true,
      remainingSeconds: segments.first.seconds,
      currentSegmentIndex: 0,
      segments: List.unmodifiable(segments),
      backgroundColor: _intervalColors[0],
    );
    WakelockPlus.enable();
    _startTick();
  }

  void togglePause() {
    if (state.isPaused) {
      // 재개
      state = state.copyWith(isRunning: true, isPaused: false);
      _startTick();
    } else if (state.isRunning) {
      // 일시정지
      _stopTimer();
      state = state.copyWith(isRunning: false, isPaused: true);
    }
  }

  void stop() {
    _stopTimer();
    WakelockPlus.disable();
    state = TimerState.initial();
  }

  // ─── Internal ──────────────────────────────────────────────

  void _startTick() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _onTick(Timer _) {
    if (!state.isRunning) return;

    final next = state.remainingSeconds - 1;

    if (next == 0) {
      _handlePhaseEnd();
      return;
    }

    // 마지막 3초 카운트다운 알림
    if (next <= 3) {
      _audio.playCountdown();
      _vibration.vibrateCountdown();
    }

    state = state.copyWith(remainingSeconds: next);
  }

  void _handlePhaseEnd() {
    _stopTimer();
    if (state.mode == TimerMode.tabata) {
      _tabataTransition();
    } else {
      _intervalTransition();
    }
  }

  void _tabataTransition() {
    final cfg = _tabataConfig;
    if (cfg == null) return;

    if (state.phase == TimerPhase.exercise) {
      // 운동 → 휴식
      _audio.playTransition();
      _vibration.vibrateTransition();
      state = state.copyWith(
        phase: TimerPhase.rest,
        remainingSeconds: cfg.restSeconds,
        backgroundColor: const Color(0xFF1E88E5),
      );
      _startTick();
    } else {
      // 휴식 종료 → 다음 라운드 또는 완료
      if (state.currentRound >= state.totalRounds) {
        _complete();
      } else {
        _audio.playTransition();
        _vibration.vibrateTransition();
        state = state.copyWith(
          phase: TimerPhase.exercise,
          remainingSeconds: cfg.exerciseSeconds,
          currentRound: state.currentRound + 1,
          backgroundColor: const Color(0xFFE53935),
        );
        _startTick();
      }
    }
  }

  void _intervalTransition() {
    final next = state.currentSegmentIndex + 1;
    if (next >= state.segments.length) {
      _complete();
    } else {
      _audio.playTransition();
      _vibration.vibrateTransition();
      state = state.copyWith(
        currentSegmentIndex: next,
        remainingSeconds: state.segments[next].seconds,
        backgroundColor: _intervalColors[next % _intervalColors.length],
      );
      _startTick();
    }
  }

  void _complete() {
    _audio.playComplete();
    _vibration.vibrateComplete();
    WakelockPlus.disable();
    state = state.copyWith(
      isRunning: false,
      isPaused: false,
      isCompleted: true,
      remainingSeconds: 0,
    );
  }

  @override
  void dispose() {
    _stopTimer();
    WakelockPlus.disable();
    super.dispose();
  }
}
