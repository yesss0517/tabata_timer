import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  /// 카운트다운 비프 (마지막 3초, 매초)
  Future<void> playCountdown() async {
    try {
      await _player.play(AssetSource('sounds/beep_short.wav'));
    } catch (_) {}
  }

  /// 구간 전환 비프 (2회)
  Future<void> playTransition() async {
    try {
      await _player.play(AssetSource('sounds/beep_transition.wav'));
    } catch (_) {}
  }

  /// 타이머 완료 사운드
  Future<void> playComplete() async {
    try {
      await _player.play(AssetSource('sounds/beep_complete.wav'));
    } catch (_) {}
  }

  void dispose() {
    _player.dispose();
  }
}
