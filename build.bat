@echo off
echo Cleaning project...
flutter clean

echo Getting dependencies...
flutter pub get

echo Building APK (split per ABI, no shrink)...
flutter build apk --split-per-abi --no-shrink

echo Done! Check the build in: build\app\outputs\apk\
pause
