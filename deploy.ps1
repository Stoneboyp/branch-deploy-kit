# 1. Права админа
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "!!! ЗАПУСТИ ОТ ИМЕНИ АДМИНИСТРАТОРА !!!"
    Break
}

Write-Host "--- IT-DEPLOY: HYBRID MODE ---" -ForegroundColor Green

# 2. Установка Chrome (Сначала ищем на флешке Ventoy)
Write-Host "`n>>> Установка Google Chrome..." -ForegroundColor Yellow

# Ищем букву диска, где лежит папка soft\ChromeStandaloneSetup64.exe
$chromeLocalPath = Get-PSDrive -PSProvider FileSystem | ForEach-Object { 
    $p = Join-Path $_.Root "soft\ChromeStandaloneSetup64.exe"
    if (Test-Path $p) { $p }
} | Select-Object -First 1

if ($chromeLocalPath) {
    Write-Host "[ОФЛАЙН] Нашел инсталлятор на флешке: $chromeLocalPath" -ForegroundColor Green
    Start-Process -FilePath $chromeLocalPath -ArgumentList "/silent /install" -Wait
} else {
    Write-Host "[ОНЛАЙН] Файл на флешке не найден, качаю через Winget (может быть медленно)..." -ForegroundColor Gray
    winget install --id Google.Chrome --source winget --silent --accept-package-agreements --force
}

# 3. Установка остального софта (который качается нормально)
$apps = @("NAPS2.NAPS2", "AnyDesk.AnyDesk", "Telegram.TelegramDesktop")

foreach ($app in $apps) {
    Write-Host "`n>>> Установка $app..." -ForegroundColor Yellow
    winget install --id $app --source winget --silent --accept-package-agreements --force
}

# 4. Активация
Write-Host "`n[3/3] Активация системы..." -ForegroundColor Cyan
iex "& { $(irm https://get.activated.win) } /HWID /S"

Write-Host "`n--- ГОТОВО! МОЖНО ВЫНИМАТЬ ФЛЕШКУ ---" -ForegroundColor Green
