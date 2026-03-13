# 1. Права админа
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "!!! ЗАПУСТИ ОТ ИМЕНИ АДМИНИСТРАТОРА !!!"
    Break
}

Write-Host "--- IT-DEPLOY: FINAL EDITION (NAPS2 FIX) ---" -ForegroundColor Green

# 2. Установка Chrome (ищем на флешке Ventoy в папке soft)
if (!(Test-Path "C:\Program Files\Google\Chrome\Application\chrome.exe")) {
    $ventoyDrive = Get-PSDrive -PSProvider FileSystem | Where-Object { Test-Path (Join-Path $_.Root "soft\ChromeStandaloneSetup64.exe") } | Select-Object -First 1
    if ($ventoyDrive) {
        $chromePath = Join-Path $ventoyDrive.Root "soft\ChromeStandaloneSetup64.exe"
        Write-Host ">>> Ставлю Chrome с флешки..." -ForegroundColor Cyan
        Start-Process -FilePath $chromePath -ArgumentList "/silent /install" -Wait
    } else {
        Write-Host ">>> Инсталлятор Chrome на флешке не найден, пропускаю." -ForegroundColor Gray
    }
} else { Write-Host "[OK] Chrome уже установлен." -ForegroundColor Green }

# 3. Установка остального через Winget с проверкой
Write-Host "`n--- ПРОВЕРКА ДОПОЛНИТЕЛЬНОГО ПО ---" -ForegroundColor Cyan

# Получаем список установленного софта один раз для корректной проверки
$installedList = winget list --source winget 2>$null | Out-String

# Список программ: для NAPS2 теперь используем просто "naps2"
$apps = @(
    @{Query="naps2"; Name="NAPS2"},
    @{Query="AnyDesk.AnyDesk"; Name="AnyDesk"},
    @{Query="Telegram.TelegramDesktop"; Name="Telegram"}
)

foreach ($app in $apps) {
    # Проверяем наличие по имени или ID в общем списке
    if ($installedList -match [regex]::Escape($app.Name) -or $installedList -match [regex]::Escape($app.Query)) {
        Write-Host "[OK] $($app.Name) уже на месте." -ForegroundColor Green
    } else {
        Write-Host "[!] $($app.Name) не найден. Устанавливаю..." -ForegroundColor Yellow
        # Для NAPS2 используем просто имя, для остальных — ID
        winget install $($app.Query) --silent --accept-package-agreements --accept-source-agreements --force
    }
}

# 4. Финальная активация
Write-Host "`n--- АКТИВАЦИЯ (WINDOWS + OFFICE) ---" -ForegroundColor Cyan
Write-Host "Запуск скрипта активации (подхватит твой ручной Office)..." -ForegroundColor Gray
# /HWID - Windows 10/11, /Ohook - Office 2024, /S - тихий режим
iex "& { $(irm https://get.activated.win) } /HWID /Ohook /S"

Write-Host "`n--- ВСЁ ГОТОВО! МОЖНО ВЫНИМАТЬ ФЛЕШКУ ---" -ForegroundColor Green
