import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/interval_segment.dart';
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

// ─── 타바타 설정 ────────────────────────────────────────────

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

// ─── 인터벌 구간 목록 ────────────────────────────────────────

class IntervalSegmentsNotifier extends StateNotifier<List<IntervalSegment>> {
  IntervalSegmentsNotifier()
      : super([
          IntervalSegment(label: '속보', seconds: 180),
          IntervalSegment(label: '달리기', seconds: 120),
          IntervalSegment(label: '전력질주', seconds: 60),
        ]);

  void addSegment(IntervalSegment segment) {
    if (state.length < 10) {
      state = [...state, segment];
    }
  }

  void removeSegment(String id) {
    state = state.where((s) => s.id != id).toList();
  }

  void reorder(int oldIndex, int newIndex) {
    final list = [...state];
    if (newIndex > oldIndex) newIndex--;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = list;
  }
}

final intervalSegmentsProvider =
    StateNotifierProvider<IntervalSegmentsNotifier, List<IntervalSegment>>(
  (ref) => IntervalSegmentsNotifier(),
);

// ─── 설정 화면 현재 탭 ─────────────────────────────────────

final currentTabProvider = StateProvider<int>((ref) => 0);

// ─── 구간 추가 다이얼로그 임시 상태 ────────────────────────

final newSegmentLabelProvider = StateProvider.autoDispose<String>((ref) => '');
final newSegmentSecondsProvider = StateProvider.autoDispose<int>((ref) => 60);
