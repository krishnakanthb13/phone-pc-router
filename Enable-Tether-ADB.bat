@echo off
echo Attempting to force USB Tethering via ADB...
adb shell svc usb setFunctions rndis
if %errorlevel% neq 0 (
    echo ADB command failed. Check connection and ensure ADB is enabled!
    pause
) else (
    echo Success! USB Tethering enabled.
    timeout /t 5
)
