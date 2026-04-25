@echo off
title RecycleMate Launcher
color 0A

set FLUTTER_PREBUILT_ENGINE_VERSION=425cfb54d01a9472b3e81d9e76fd63a4a44cfbcb

echo.
echo  ==========================================
echo    RecycleMate - Auto Launcher
echo  ==========================================
echo.

:: Cek apakah emulator sudah jalan
echo  [1/3] Mengecek emulator Android...
flutter devices 2>nul | findstr /i "emulator" >nul
if %errorlevel% == 0 (
    echo  [OK] Emulator sudah aktif!
    goto :run_app
)

:: Emulator belum jalan, cari AVD yang tersedia
echo  [2/3] Emulator belum aktif. Mencari AVD...
for /f "tokens=*" %%a in ('flutter emulators 2^>nul ^| findstr /v "^$" ^| findstr /v "available" ^| findstr /v "flutter" ^| findstr /v "^-"') do (
    set AVD_LINE=%%a
)

:: Coba launch emulator pertama yang tersedia
echo  [2/3] Menjalankan emulator...
for /f "tokens=2 delims= " %%a in ('flutter emulators 2^>nul ^| findstr "•"') do (
    set EMULATOR_ID=%%a
    goto :launch_emulator
)

:launch_emulator
if defined EMULATOR_ID (
    echo  Launching: %EMULATOR_ID%
    start /b flutter emulators --launch %EMULATOR_ID%
) else (
    echo  Tidak ada AVD ditemukan. Mencoba emulator-5554...
    start /b "" "%LOCALAPPDATA%\Android\Sdk\emulator\emulator.exe" -avd Medium_Phone_API_36 -no-snapshot-load 2>nul
)

echo  Menunggu emulator siap (30 detik)...
timeout /t 30 /nobreak >nul

:run_app
echo.
echo  [3/3] Menjalankan RecycleMate...
echo.
flutter run -d emulator-5554 --android-skip-build-dependency-validation

if %errorlevel% neq 0 (
    echo.
    echo  [!] Gagal di emulator-5554, mencoba device lain...
    flutter run --android-skip-build-dependency-validation
)

pause
