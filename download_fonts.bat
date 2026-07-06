@echo off
echo Membuat folder assets\fonts...
if not exist "assets" mkdir assets
if not exist "assets\fonts" mkdir assets\fonts

echo Mendownload Poppins-Regular...
curl -L --retry 3 "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Regular.ttf" -o "assets\fonts\Poppins-Regular.ttf"

echo Mendownload Poppins-Medium...
curl -L --retry 3 "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Medium.ttf" -o "assets\fonts\Poppins-Medium.ttf"

echo Mendownload Poppins-SemiBold...
curl -L --retry 3 "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-SemiBold.ttf" -o "assets\fonts\Poppins-SemiBold.ttf"

echo Mendownload Poppins-Bold...
curl -L --retry 3 "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Bold.ttf" -o "assets\fonts\Poppins-Bold.ttf"

echo.
echo Cek hasil download:
dir assets\fonts\
echo.
echo Selesai! Jalankan: flutter pub get lalu flutter run -d chrome
pause
