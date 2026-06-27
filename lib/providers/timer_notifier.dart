import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/tabata_config.dart';
import '../models/timer_mode.dart';
import '../services/audio_service.dart';
import '../services/vibration_service.dart';
import 'timer_state.dart';

class TimerNotifier extends StateNotifier<TimerState> {
  final AudioService _audio;
  final VibrationService _vibration;

  Timer? _timer;
  Timer? _transitionTimer; // remaining=0 후 단계 전환 전 잠시 대기용
  TabataConfig? _config;

  TimerNotifier({required AudioService audio, required VibrationService vibration})
      : _audio = audio,
        _vibration = vibration,
        super(TimerState.initial());

  // ─── Public ────────────────────────────────────────────

  void startTabata(TabataConfig config) {
    _cancelAll();
    _config = config;
    state = TimerState.initial().copyWith(
      isRunning: true,
      remainingSeconds: config.exerciseSeconds,
      currentPhaseTotal: config.exerciseSeconds,
      currentRound: 1,
      totalRounds: config.rounds,
      phase: TimerPhase.exercise,
      backgroundColor: const Color(0xFFE53935),
    );
    WakelockPlus.enable();
    _startTick();
  }

  void togglePause() {
    if (state.isPaused) {
      // 재개
      state = state.copyWith(isRunning: true, isPaused: false);
      // remaining=0 상태에서 재개 → 즉시 전환
      if (state.remainingSeconds == 0) {
        _handlePhaseEnd();
      } else {
        _startTick();
      }
    } else if (state.isRunning) {
      // 일시정지: pending 전환도 함께 취소
      _stopTimer();
      _transitionTimer?.cancel();
      _transitionTimer = null;
      state = state.copyWith(isRunning: false, isPaused: true);
    }
  }

  void stop() {
    _cancelAll();
    WakelockPlus.disable();
    state = TimerState.initial();
  }

  // ─── Internal ──────────────────────────────────────────

  void _startTick() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _cancelAll() {
    _stopTimer();
    _transitionTimer?.cancel();
    _transitionTimer = null;
  }

  void _onTick(Timer _) {
    if (!state.isRunning) return;
    final next = state.remainingSeconds - 1;

    // 마지막 3초 카운트다운 사운드 (0은 전환 사운드로 대체)
    if (next <= 3 && next > 0) {
      _audio.playCountdown();
      _vibration.vibrateCountdown();
    }

    // 먼저 상태 업데이트 (remaining=0 포함)
    state = state.copyWith(remainingSeconds: next);

    if (next == 0) {
      // 프로그래스바가 100%로 채워진 후 전환
      // → 타이머를 멈추고 1초 후 다음 단계로 넘어감
      _stopTimer();
      _transitionTimer?.cancel();
      _transitionTimer = Timer(const Duration(milliseconds: 1000), () {
        // mounted 체크: notifier가 dispose되지 않았는지 확인
        if (!mounted) return;
        // isRunning이 여전히 true여야 함 (일시정지/중단 안 된 경우)
        if (state.isRunning) _handlePhaseEnd();
      });
    }
  }

  void _handlePhaseEnd() {
    _cancelAll();
    final cfg = _config;
    if (cfg == null) return;

    if (state.phase == TimerPhase.exercise) {
      if (cfg.restSeconds == 0) {
        _nextRoundOrComplete(cfg);
      } else {
        _audio.playTransition();
        _vibration.vibrateTransition();
        state = state.copyWith(
          phase: TimerPhase.rest,
          remainingSeconds: cfg.restSeconds,
          currentPhaseTotal: cfg.restSeconds,
          backgroundColor: const Color(0xFF1E88E5),
        );
        _startTick();
      }
    } else {
      _nextRoundOrComplete(cfg);
    }
  }

  void _nextRoundOrComplete(TabataConfig cfg) {
    if (state.currentRound >= state.totalRounds) {
      _complete();
    } else {
      _audio.playTransition();
      _vibration.vibrateTransition();
      state = state.copyWith(
        phase: TimerPhase.exercise,
        remainingSeconds: cfg.exerciseSeconds,
        currentPhaseTotal: cfg.exerciseSeconds,
        currentRound: state.currentRound + 1,
        backgroundColor: const Color(0xFFE53935),
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
    _cancelAll();
    WakelockPlus.disable();
    super.dispose();
  }
}
