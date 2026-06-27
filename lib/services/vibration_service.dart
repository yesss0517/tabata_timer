import 'package:vibration/vibration.dart';

class VibrationService {
  bool? _hasVibrator;

  Future<bool> _canVibrate() async {
    _hasVibrator ??= await Vibration.hasVibrator();
    return _hasVibrator ?? false;
  }

  /// 구간 전환 진동 (200ms)
  Future<void> vibrateTransition() async {
    try {
      if (await _canVibrate()) {
        await Vibration.vibrate(duration: 200);
      }
    } catch (_) {}
  }

  /// 카운트다운 진동 (100ms)
  Future<void> vibrateCountdown() async {
    try {
      if (await _canVibrate()) {
        await Vibration.vibrate(duration: 100);
      }
    } catch (_) {}
  }

  /// 완료 진동 패턴 [300, 100, 300]
  Future<void> vibrateComplete() async {
    try {
      if (await _canVibrate()) {
        await Vibration.vibrate(pattern: [0, 300, 100, 300]);
      }
    } catch (_) {}
  }
}
