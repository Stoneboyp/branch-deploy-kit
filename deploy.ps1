# 1. Проверка прав администратора
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "!!! ЗАПУСТИТЕ КОНСОЛЬ ОТ ИМЕНИ АДМИНИСТРАТОРА !!!"
    Break
}

Write-Host "--- IT-ASSISTANT: HYBRID DEPLOY (USB + CLOUD) ---" -ForegroundColor Green

# 2. Поиск флешки с папкой 'soft'
$ventoyDrive = Get-PSDrive -PSProvider FileSystem | Where-Object { Test-Path (Join-Path $_.Root "soft") } | Select-Object -First 1

if ($ventoyDrive) {
    $softPath = Join-Path $ventoyDrive.Root "soft"
    Write-Host "[USB] Найдена папка с софтом: $softPath" -ForegroundColor Cyan

    # --- УСТАНОВКА CHROME С ФЛЕШКИ ---
    $chromePath = Join-Path $softPath "ChromeStandaloneSetup64.exe"
    if (Test-Path $chromePath) {
        Write-Host ">>> Установка Chrome..." -ForegroundColor Yellow
        Start-Process -FilePath $chromePath -ArgumentList "/silent /install" -Wait
        Write-Host "[OK] Chrome установлен (или уже был)." -ForegroundColor Green
    }

    # --- УСТАНОВКА OFFICE 2024 (ISO) ---
    $isoPath = Join-Path $softPath "ProPlus2024Retail.iso"
    if (Test-Path $isoPath) {
        Write-Host ">>> Монтирую Office 2024 ISO..." -ForegroundColor Cyan
        $mount = Mount-DiskImage -ImagePath $isoPath -PassThru
        $driveLetter = ($mount | Get-Volume).DriveLetter
        
        $setupPath = "${driveLetter}:\setup.exe"
        if (Test-Path $setupPath) {
            Write-Host ">>> Запуск Setup Office... ЖДИТЕ ЗАВЕРШЕНИЯ!" -ForegroundColor Yellow
            # Запускаем и жестко ждем закрытия процесса установки
            $officeProc = Start-Process -FilePath $setupPath -PassThru
            $officeProc | Wait-Process
            Write-Host "[OK] Установка Office завершена." -ForegroundColor Green
        }
        
        Write-Host ">>> Размонтирую ISO..." -ForegroundColor Gray
        Dismount-DiskImage -ImagePath $isoPath
    }
} else {
    Write-Warning "Флешка с папкой 'soft' не найдена! Пропускаю USB-этап."
}

# 3. Установка дополнительного ПО через Winget с ПРОВЕРКОЙ
Write-Host "`n--- ПРОВЕРКА ДОПОЛНИТЕЛЬНОГО ПО ---" -ForegroundColor Cyan

$apps = @(
    @{ID="NAPS2.NAPS2"; Name="NAPS2"},
    @{ID="AnyDesk.AnyDesk"; Name="AnyDesk"},
    @{ID="Telegram.TelegramDesktop"; Name="Telegram"}
)

foreach ($app in $apps) {
    # Получаем список установленного софта в виде строки (Out-String лечит пустые ответы)
    $check = winget list --id $($app.ID) --source winget 2>$null | Out-String
    
    if ($check -match [regex]::Escape($app.ID)) {
        Write-Host "[OK] $($app.Name) уже установлен. Пропускаю." -ForegroundColor Green
    } else {
        Write-Host "[...] Установка $($app.Name)..." -ForegroundColor Yellow
        winget install --id $($app.ID) --source winget --silent --accept-package-agreements --accept-source-agreements --force
    }
}

# 4. Активация (Windows + Office 2024)
Write-Host "`n--- АКТИВАЦИЯ СИСТЕМЫ И OFFICE ---" -ForegroundColor Cyan
$MAS_URL = "https://get.activated.win"
# /HWID - Windows, /Ohook - Office 2024, /S - Silent
try {
    iex "& { $(irm $MAS_URL) } /HWID /Ohook /S"
    Write-Host "[OK] Запрос на активацию отправлен." -ForegroundColor Green
} catch {
    Write-Host "[!] Ошибка активации. Проверьте интернет." -ForegroundColor Red
}

Write-Host "`n--- ВСЕ ЗАДАЧИ ВЫПОЛНЕНЫ! МОЖНО ВЫНИМАТЬ ФЛЕШКУ ---" -ForegroundColor Green
