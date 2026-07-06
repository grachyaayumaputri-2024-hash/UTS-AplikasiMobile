# Jalankan di PowerShell dari root folder project Flutter
# Klik kanan folder project → "Open in Terminal"

Write-Host "Membuat folder assets\fonts..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path "assets\fonts" | Out-Null

$fonts = @(
    @{ name="Poppins-Regular";   url="https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Regular.ttf" },
    @{ name="Poppins-Medium";    url="https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Medium.ttf" },
    @{ name="Poppins-SemiBold";  url="https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-SemiBold.ttf" },
    @{ name="Poppins-Bold";      url="https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Bold.ttf" }
)

foreach ($font in $fonts) {
    $outPath = "assets\fonts\$($font.name).ttf"
    Write-Host "Downloading $($font.name)..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $font.url -OutFile $outPath -UseBasicParsing
        $size = (Get-Item $outPath).Length
        Write-Host "  OK - $([math]::Round($size/1KB)) KB" -ForegroundColor Green
    } catch {
        Write-Host "  GAGAL: $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Hasil:" -ForegroundColor Cyan
Get-ChildItem "assets\fonts\" | Format-Table Name, @{L='Size(KB)';E={[math]::Round($_.Length/1KB)}}

Write-Host "Selesai! Jalankan: flutter pub get && flutter run -d chrome" -ForegroundColor Green
