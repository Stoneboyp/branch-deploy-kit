# 1. Права админа
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "!!! ЗАПУСТИ ОТ ИМЕНИ АДМИНИСТРАТОРА !!!"
    Break
}

Write-Host "--- IT-DEPLOY: VENTOY + OFFICE 2024 ---" -ForegroundColor Green

# Ищем букву диска флешки (где лежит папка soft)
$ventoyDrive = Get-PSDrive -PSProvider FileSystem | Where-Object { Test-Path (Join-Path $_.Root "soft") } | Select-Object -First 1

if ($ventoyDrive) {
    $softPath = Join-Path $ventoyDrive.Root "soft"
    
    # --- УСТАНОВКА CHROME ---
    $chromePath = Join-Path $softPath "ChromeStandaloneSetup64.exe"
    if (Test-Path $chromePath) {
        Write-Host ">>> Ставлю Chrome с флешки..." -ForegroundColor Green
        Start-Process -FilePath $chromePath -ArgumentList "/silent /install" -Wait
    }

    # --- УСТАНОВКА OFFICE 2024 (ISO) ---
    $isoPath = Join-Path $softPath "ProPlus2024Retail.iso"
    if (Test-Path $isoPath) {
        Write-Host ">>> Монтирую Office 2024 ISO..." -ForegroundColor Cyan
        $mount = Mount-DiskImage -ImagePath $isoPath -PassThru
        $driveLetter = ($mount | Get-Volume).DriveLetter
        
        Write-Host ">>> Запуск Setup Office..." -ForegroundColor Yellow
        # Запускаем setup.exe и ждем завершения
        Start-Process -FilePath "${driveLetter}:\setup.exe" -Wait
        
        Write-Host ">>> Размонтирую ISO..." -ForegroundColor Gray
        Dismount-DiskImage -ImagePath $isoPath
    }
} else {
    Write-Warning "Флешка с папкой 'soft' не найдена! Пропускаю офлайн-установку."
}

# 2. Установка остального через интернет
$apps = @("NAPS2", "AnyDesk.AnyDesk", "Telegram.TelegramDesktop")
foreach ($app in $apps) {
    Write-Host ">>> Установка $app..." -ForegroundColor Yellow
    winget install --id $app --source winget --silent --accept-package-agreements --force
}

# 3. Активация (Теперь с /Ohook для Office 2024)
Write-Host ">>> Активация Windows и Office 2024..." -ForegroundColor Cyan
# /HWID для Windows, /Ohook для Office 2024
iex "& { $(irm https://get.activated.win) } /HWID /Ohook /S"

Write-Host "--- ВСЁ ГОТОВО! ---" -ForegroundColor Green
