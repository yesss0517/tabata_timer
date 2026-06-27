import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../widgets/interval_setup_tab.dart';
import '../widgets/tabata_setup_tab.dart';
import 'timer_screen.dart';

class SetupScreen extends ConsumerWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabataConfig = ref.watch(tabataConfigProvider);
    final segments = ref.watch(intervalSegmentsProvider);
    final currentTab = ref.watch(currentTabProvider);
    final isTabata = currentTab == 0;
    final canStart = isTabata || segments.isNotEmpty;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer_rounded,
                  color: Color(0xFFE53935), size: 22),
              const SizedBox(width: 8),
              const Text('타바타 타이머'),
            ],
          ),
          bottom: TabBar(
            onTap: (i) =>
                ref.read(currentTabProvider.notifier).state = i,
            tabs: const [
              Tab(text: '🔥  타바타'),
              Tab(text: '🏃  인터벌'),
            ],
          ),
        ),
        body: Column(
          children: [
            // ── 탭 콘텐츠 ───────────────────────────────────
            Expanded(
              child: TabBarView(
                // 스와이프도 탭 인덱스와 동기화되도록 NeverScrollable 사용
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  TabataSetupTab(config: tabataConfig),
                  IntervalSetupTab(segments: segments),
                ],
              ),
            ),
            // ── 시작 버튼 ────────────────────────────────────
            _StartButton(
              canStart: canStart,
              isTabata: isTabata,
              onStart: () => _startTimer(context, ref, isTabata),
            ),
          ],
        ),
      ),
    );
  }

  void _startTimer(
      BuildContext context, WidgetRef ref, bool isTabata) {
    final tabataConfig = ref.read(tabataConfigProvider);
    final segments = ref.read(intervalSegmentsProvider);

    if (isTabata) {
      ref.read(timerProvider.notifier).startTabata(tabataConfig);
    } else {
      ref.read(timerProvider.notifier).startInterval(segments);
    }

    // 타이머 화면 진입 시 전체화면 모드 활성화
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TimerScreen()),
    ).then((_) {
      // 돌아올 때 시스템 UI 복원
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    });
  }
}

// ─── 시작 버튼 위젯 ───────────────────────────────────────────

class _StartButton extends StatelessWidget {
  final bool canStart;
  final bool isTabata;
  final VoidCallback onStart;

  const _StartButton({
    required this.canStart,
    required this.isTabata,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: canStart ? onStart : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isTabata
                ? const Color(0xFFE53935)
                : const Color(0xFF1E88E5),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.white12,
            disabledForegroundColor: Colors.white30,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_arrow_rounded, size: 26),
              const SizedBox(width: 6),
              Text(
                canStart ? '시작' : '구간을 추가해주세요',
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
