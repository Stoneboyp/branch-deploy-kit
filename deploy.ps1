# 1. Проверка прав администратора
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "!!! ЗАПУСТИТЕ КОНСОЛЬ ОТ ИМЕНИ АДМИНИСТРАТОРА !!!"
    Break
}

Write-Host "--- IT-ASSISTANT: HYBRID DEPLOY (FIXED CHECK) ---" -ForegroundColor Green

# 2. Поиск флешки с папкой 'soft'
$ventoyDrive = Get-PSDrive -PSProvider FileSystem | Where-Object { Test-Path (Join-Path $_.Root "soft") } | Select-Object -First 1

if ($ventoyDrive) {
    $softPath = Join-Path $ventoyDrive.Root "soft"
    
    # --- УСТАНОВКА CHROME С ФЛЕШКИ ---
    $chromePath = Join-Path $softPath "ChromeStandaloneSetup64.exe"
    if (Test-Path $chromePath) {
        Write-Host ">>> Проверка Chrome..." -ForegroundColor Yellow
        # Простая проверка: если папка Google Chrome уже существует в Program Files
        if (Test-Path "C:\Program Files\Google\Chrome\Application\chrome.exe") {
            Write-Host "[OK] Chrome уже установлен." -ForegroundColor Green
        } else {
            Write-Host "[...] Установка Chrome с флешки..." -ForegroundColor Cyan
            Start-Process -FilePath $chromePath -ArgumentList "/silent /install" -Wait
        }
    }

    # --- УСТАНОВКА OFFICE 2024 (ISO) ---
    $isoPath = Join-Path $softPath "ProPlus2024Retail.iso"
    if (Test-Path $isoPath) {
        Write-Host ">>> Проверка Office..." -ForegroundColor Yellow
        # Проверяем наличие папки Office 16 (для 2024 это стандарт)
        if (Test-Path "C:\Program Files\Microsoft Office\Office16") {
            Write-Host "[OK] Office уже установлен." -ForegroundColor Green
        } else {
            Write-Host "[...] Монтирую и ставлю Office 2024 ISO..." -ForegroundColor Cyan
            $mount = Mount-DiskImage -ImagePath $isoPath -PassThru
            $driveLetter = ($mount | Get-Volume).DriveLetter
            $officeProc = Start-Process -FilePath "${driveLetter}:\setup.exe" -PassThru
            $officeProc | Wait-Process
            Dismount-DiskImage -ImagePath $isoPath
        }
    }
}

# --- 3. УСТАНОВКА ЧЕРЕЗ WINGET С ГАРАНТИРОВАННОЙ ПРОВЕРКОЙ ---
Write-Host "`n--- ПРОВЕРКА ДОПОЛНИТЕЛЬНОГО ПО ---" -ForegroundColor Cyan

# Получаем ВЕСЬ список установленного софта в одну текстовую переменную
$installedSoftware = winget list --source winget 2>$null | Out-String

$apps = @(
    @{ID="NAPS2"; Name="NAPS2"},
    @{ID="AnyDesk.AnyDesk"; Name="AnyDesk"},
    @{ID="Telegram.TelegramDesktop"; Name="Telegram"}
)

foreach ($app in $apps) {
    # Ищем ID приложения в общем списке (без учета регистра)
    if ($installedSoftware -match [regex]::Escape($app.ID)) {
        Write-Host "[OK] $($app.Name) найден в системе. Пропускаю." -ForegroundColor Green
    } else {
        Write-Host "[!] $($app.Name) не найден. Качаю и ставлю..." -ForegroundColor Yellow
        winget install --id $($app.ID) --source winget --silent --accept-package-agreements --accept-source-agreements --force
    }
}

# 4. Активация
Write-Host "`n--- АКТИВАЦИЯ СИСТЕМЫ И OFFICE ---" -ForegroundColor Cyan
iex "& { $(irm https://get.activated.win) } /HWID /Ohook /S"

Write-Host "`n--- ВСЕ ГОТОВО! МОЖНО ВЫНИМАТЬ ФЛЕШКУ ---" -ForegroundColor Green
