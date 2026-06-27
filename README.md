# 타바타 & 인터벌 타이머

Flutter로 제작된 운동용 타이머 앱입니다.

---

## 📱 기능

| 모드 | 설명 |
|------|------|
| **타바타** | 운동/휴식 시간과 반복 횟수를 설정해 [운동→휴식]×N 반복 |
| **인터벌** | 여러 구간(라벨+시간)을 자유롭게 구성해 순차 진행 |

- 배경 색상으로 현재 단계를 직관적으로 표시 (AnimatedContainer)
- 마지막 3초 카운트다운 비프 + 진동
- 구간 전환 시 더블 비프 + 진동
- 완료 시 상승 음계 + 패턴 진동
- 화면 꺼짐 방지 (wakelock_plus)
- 인터벌 구간 드래그로 순서 변경 (ReorderableListView)

---

## 🚀 빠른 시작

### 1. 베이스 Flutter 프로젝트 생성

```bash
flutter create --org com.example --project-name tabata_timer tabata_timer_base
```

### 2. 이 저장소의 파일로 교체

```bash
# 기존 lib/, assets/, pubspec.yaml 삭제 후 이 파일들로 교체
cp -r lib/ assets/ pubspec.yaml android/app/build.gradle \
       android/app/src/ <프로젝트_경로>/
```

### 3. 패키지 설치 및 실행

```bash
flutter pub get
flutter run
```

---

## 🏗️ 아키텍처

```
lib/
├── main.dart
├── models/
│   ├── timer_mode.dart          # TimerMode / TimerPhase 열거형
│   ├── tabata_config.dart       # 타바타 설정 데이터 클래스
│   └── interval_segment.dart    # 인터벌 구간 데이터 클래스
├── providers/
│   ├── timer_state.dart         # 불변 타이머 상태 클래스
│   ├── timer_notifier.dart      # StateNotifier: 타이머 핵심 로직
│   └── providers.dart           # 모든 Riverpod Provider 정의
├── services/
│   ├── audio_service.dart       # 사운드 재생 (audioplayers)
│   └── vibration_service.dart   # 진동 제어 (vibration)
├── screens/
│   ├── setup_screen.dart        # 설정 화면 (TabBar)
│   └── timer_screen.dart        # 타이머 화면 (전체화면)
└── widgets/
    ├── number_stepper.dart      # +/- 숫자 입력 위젯
    ├── tabata_setup_tab.dart    # 타바타 설정 탭
    └── interval_setup_tab.dart  # 인터벌 설정 탭
```

### 아키텍처 원칙
- **UI**: `ConsumerWidget` + `StatelessWidget`만 사용 (StatefulWidget 없음)
- **상태**: `StateNotifier` → `StateNotifierProvider` → `ref.watch()`
- **타이머**: `Timer.periodic(Duration(seconds: 1), callback)`
- **화면 전환**: `Navigator.push / pop` (2화면이므로 go_router 불필요)

---

## 🎨 색상 명세

| 상태 | 색상 | 코드 |
|------|------|------|
| 타바타 운동 | 붉은색 | `#E53935` |
| 타바타 휴식 | 파란색 | `#1E88E5` |
| 인터벌 구간 1 | 붉은색 | `#E53935` |
| 인터벌 구간 2 | 주황색 | `#FB8C00` |
| 인터벌 구간 3 | 초록색 | `#43A047` |
| 인터벌 구간 4 | 파란색 | `#1E88E5` |
| 인터벌 구간 5 | 보라색 | `#8E24AA` |

---

## 🔊 오디오 파일

`assets/sounds/` 경로에 위치:

| 파일 | 용도 |
|------|------|
| `beep_short.wav` | 카운트다운 매초 비프 (880Hz, 0.12s) |
| `beep_transition.wav` | 구간 전환 이중 비프 |
| `beep_complete.wav` | 완료 상승음 (도-미-솔) |

> 파일이 이미 포함되어 있습니다. 다른 소리로 교체하려면 같은 파일명으로 덮어쓰세요.

---

## 📦 사용 패키지

| 패키지 | 버전 | 용도 |
|--------|------|------|
| flutter_riverpod | ^2.5.1 | 상태 관리 |
| audioplayers | ^6.0.0 | 소리 알림 |
| vibration | ^2.0.0 | 진동 알림 |
| wakelock_plus | ^1.2.0 | 화면 꺼짐 방지 |
| shared_preferences | ^2.2.3 | 설정값 저장 |

---

## 📋 iOS 설정

`ios/Runner/Info.plist`에 다음 키 추가 (권한 설명):

```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```

---

## 🛠️ 최소 요구사항

- **Android**: SDK 26 (Android 8.0 Oreo) 이상
- **iOS**: 13.0 이상
- **Flutter**: 3.13.0 이상
- **Dart**: 3.0.0 이상
