#!/usr/bin/env bash
# ============================================================
#  타바타 타이머 - 프로젝트 셋업 스크립트
#  사용법: bash setup.sh
#  실행 전 Flutter SDK가 설치되어 있어야 합니다.
# ============================================================
set -e

PROJECT="tabata_timer"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🔍 Flutter 설치 확인..."
if ! command -v flutter &>/dev/null; then
  echo "❌ Flutter가 설치되지 않았습니다. https://flutter.dev/docs/get-started/install"
  exit 1
fi
flutter --version

echo ""
echo "📁 Flutter 기본 프로젝트 생성 (com.example.tabatatimer)..."
flutter create \
  --org com.example \
  --project-name tabata_timer \
  --platforms android,ios \
  "$PROJECT"

echo ""
echo "📋 소스 파일 복사..."
# lib/ 전체 교체
rm -rf "$PROJECT/lib"
cp -r "$SCRIPT_DIR/lib" "$PROJECT/lib"

# assets/ 복사
cp -r "$SCRIPT_DIR/assets" "$PROJECT/assets"

# pubspec.yaml 교체
cp "$SCRIPT_DIR/pubspec.yaml" "$PROJECT/pubspec.yaml"

# Android 커스텀 파일 교체
cp "$SCRIPT_DIR/android/app/build.gradle"      "$PROJECT/android/app/build.gradle"
cp "$SCRIPT_DIR/android/app/src/main/AndroidManifest.xml" \
   "$PROJECT/android/app/src/main/AndroidManifest.xml"

# styles.xml (Launch/NormalTheme 정의)
mkdir -p "$PROJECT/android/app/src/main/res/values"
cp "$SCRIPT_DIR/android/app/src/main/res/values/styles.xml" \
   "$PROJECT/android/app/src/main/res/values/styles.xml"

# MainActivity.kt 패키지명 적용
mkdir -p "$PROJECT/android/app/src/main/kotlin/com/example/tabatatimer"
cp "$SCRIPT_DIR/android/app/src/main/kotlin/com/example/tabatatimer/MainActivity.kt" \
   "$PROJECT/android/app/src/main/kotlin/com/example/tabatatimer/MainActivity.kt"

# 기존 MainActivity.kt (flutter create 가 만든 것) 삭제
ORIG_KT="$PROJECT/android/app/src/main/kotlin/com/example/tabata_timer/MainActivity.kt"
[ -f "$ORIG_KT" ] && rm "$ORIG_KT"

echo ""
echo "📦 패키지 설치..."
cd "$PROJECT"
flutter pub get

echo ""
echo "✅ 완료! 다음 명령어로 실행하세요:"
echo ""
echo "  cd $PROJECT"
echo "  flutter run"
echo ""
