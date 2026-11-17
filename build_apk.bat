@echo off
chcp 65001 > nul
echo ====================================================
echo   بناء تطبيق إتقان للأندرويد (Generate APK)
echo ====================================================
echo 1. جاري فحص وتحديث المكتبات وحزم ZegoCloud و Supabase...
call flutter pub get
echo.
echo 2. جاري تجميع ملف الـ APK النهائي (Release APK)...
call flutter build apk --release
echo.
echo ====================================================
echo ✓ تم بناء التطبيق بنجاح!
echo ستجد ملف التطبيق جاهزاً للتثبيت في المسار:
echo build\app\outputs\flutter-apk\app-release.apk
echo ====================================================
pause
