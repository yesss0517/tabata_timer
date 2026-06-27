@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title 타바타 타이머 셋업

echo.
echo  ████████████████████████████████████████
echo     타바타 타이머 - 자동 셋업 (Windows)
echo  ████████████████████████████████████████
echo.

REM ── [1] Flutter 확인 ──────────────────────────────────────
echo  [1/4] Flutter 설치 확인 중...
where flutter >nul 2>&1
if errorlevel 1 (
    echo.
    echo  [오류] Flutter 를 찾을 수 없습니다.
    echo         PATH 에 Flutter 가 등록되어 있는지 확인해주세요.
    echo         https://flutter.dev/docs/get-started/install/windows
    echo.
    pause & exit /b 1
)
echo         OK

REM ── 경로 설정 ─────────────────────────────────────────────
REM %~dp0 = 이 bat 파일이 있는 폴더 (trailing backslash 포함)
set "SRC=%~dp0"
REM 부모 폴더 구하기
for %%I in ("%SRC:~0,-1%") do set "PARENT=%%~dpI"
REM 완성 프로젝트는 옆에 tabata_timer_project 폴더로
set "OUT=%PARENT%tabata_timer_project"

REM ── [2] Flutter 프로젝트 생성 ─────────────────────────────
echo.
echo  [2/4] Flutter 프로젝트 생성 중...
echo         위치: %OUT%
echo.

if exist "%OUT%" (
    echo         기존 폴더 삭제 중...
    rd /s /q "%OUT%"
)

cd /d "%PARENT%"
call flutter create --org com.example --project-name tabata_timer "%OUT%"
if errorlevel 1 (
    echo.
    echo  [오류] flutter create 실패
    pause & exit /b 1
)

REM ── [3] 소스 파일 교체 ────────────────────────────────────
echo.
echo  [3/4] 소스 파일 교체 중...

REM lib/ 전체 교체
rd /s /q "%OUT%\lib" 2>nul
xcopy /e /i /h /y /q "%SRC%lib" "%OUT%\lib\" >nul

REM assets/ 복사
if exist "%OUT%\assets" rd /s /q "%OUT%\assets"
xcopy /e /i /h /y /q "%SRC%assets" "%OUT%\assets\" >nul

REM pubspec.yaml
copy /y "%SRC%pubspec.yaml" "%OUT%\pubspec.yaml" >nul

REM android build 파일
copy /y "%SRC%android\app\build.gradle"                              "%OUT%\android\app\build.gradle" >nul
copy /y "%SRC%android\app\src\main\AndroidManifest.xml"             "%OUT%\android\app\src\main\AndroidManifest.xml" >nul
copy /y "%SRC%android\app\src\main\res\values\styles.xml"           "%OUT%\android\app\src\main\res\values\styles.xml" >nul

REM MainActivity.kt — 올바른 패키지 경로에 복사
set "KT_OUT=%OUT%\android\app\src\main\kotlin\com\example\tabatatimer"
if not exist "%KT_OUT%" mkdir "%KT_OUT%"
copy /y "%SRC%android\app\src\main\kotlin\com\example\tabatatimer\MainActivity.kt" "%KT_OUT%\MainActivity.kt" >nul

REM flutter create 가 만든 기존 MainActivity.kt 삭제 (패키지명 다름)
set "KT_OLD=%OUT%\android\app\src\main\kotlin\com\example\tabata_timer"
if exist "%KT_OLD%" rd /s /q "%KT_OLD%"

echo         완료

REM ── [4] 패키지 설치 ──────────────────────────────────────
echo.
echo  [4/4] 패키지 설치 중 (flutter pub get)...
cd /d "%OUT%"
call flutter pub get
if errorlevel 1 (
    echo  [경고] pub get 실패. Android Studio 에서 수동으로 실행해주세요.
)

REM ── Android Studio 찾아서 열기 ───────────────────────────
echo.
echo  ✅ 셋업 완료!
echo     프로젝트 위치: %OUT%
echo.
echo  Android Studio 실행 중...

set "STUDIO="

REM 일반 설치 경로
if exist "%LOCALAPPDATA%\Programs\Android Studio\bin\studio64.exe" (
    set "STUDIO=%LOCALAPPDATA%\Programs\Android Studio\bin\studio64.exe"
    goto :OPEN_AS
)
if exist "C:\Program Files\Android\Android Studio\bin\studio64.exe" (
    set "STUDIO=C:\Program Files\Android\Android Studio\bin\studio64.exe"
    goto :OPEN_AS
)

REM JetBrains Toolbox 설치 (버전 폴더가 달라서 와일드카드 검색)
for /f "delims=" %%A in ('dir /b /s "%LOCALAPPDATA%\JetBrains\Toolbox\apps\AndroidStudio\*.exe" 2^>nul ^| findstr /i "studio64.exe"') do (
    set "STUDIO=%%A"
    goto :OPEN_AS
)
for /f "delims=" %%A in ('dir /b /s "%APPDATA%\JetBrains\Toolbox\apps\AndroidStudio\*.exe" 2^>nul ^| findstr /i "studio64.exe"') do (
    set "STUDIO=%%A"
    goto :OPEN_AS
)

REM 못 찾은 경우
echo  [안내] Android Studio 를 자동으로 찾지 못했습니다.
echo         Android Studio 를 직접 열고 아래 폴더를 여세요:
echo.
echo         %OUT%
echo.
goto :END

:OPEN_AS
start "" "%STUDIO%" "%OUT%"
echo         실행됨: %STUDIO%

:END
echo.
pause
