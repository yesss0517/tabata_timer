import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tabata_config.dart';
import '../services/audio_service.dart';
import '../services/vibration_service.dart';
import 'timer_notifier.dart';
import 'timer_state.dart';

// ─── 서비스 ─────────────────────────────────────────────────

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});

final vibrationServiceProvider = Provider<VibrationService>((ref) {
  return VibrationService();
});

// ─── 타이머 ─────────────────────────────────────────────────

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier(
    audio: ref.watch(audioServiceProvider),
    vibration: ref.watch(vibrationServiceProvider),
  );
});

// ─── 타바타 설정 ─────────────────────────────────────────────

class TabataConfigNotifier extends StateNotifier<TabataConfig> {
  TabataConfigNotifier() : super(TabataConfig.defaults());

  void setExerciseSeconds(int v) =>
      state = state.copyWith(exerciseSeconds: v);
  void setRestSeconds(int v) =>
      state = state.copyWith(restSeconds: v);
  void setRounds(int v) =>
      state = state.copyWith(rounds: v);
}

final tabataConfigProvider =
    StateNotifierProvider<TabataConfigNotifier, TabataConfig>(
  (ref) => TabataConfigNotifier(),
);
