# 1. Права админа
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "!!! ЗАПУСТИ ОТ ИМЕНИ АДМИНИСТРАТОРА !!!"
    Break
}

Write-Host "--- СТАРТ РАЗВЕРТЫВАНИЯ: ФИЛИАЛ (БЕЗ OFFICE) ---" -ForegroundColor Green

# 2. Настройка Winget
Write-Host "[1/3] Подготовка Winget..." -ForegroundColor Cyan
winget source reset --force
winget source update

# 3. Список софта (Офис удален)
$apps = @(
    "Google.Chrome", 
    "NAPS2.NAPS2", 
    "AnyDesk.AnyDesk", 
    "Telegram.TelegramDesktop"
)

# 4. Цикл установки
Write-Host "[2/3] Установка приложений..." -ForegroundColor Cyan
foreach ($app in $apps) { 
    Write-Host "`n>>> Проверка: $app" -ForegroundColor Yellow
    $status = winget list --id $app --source winget 2>$null
    if ($status -match $app) {
        Write-Host "--- $app уже установлена. Пропускаю. ---" -ForegroundColor Green
    } else {
        Write-Host "--- Качаю и ставлю $app... ---" -ForegroundColor Gray
        winget install --id $app --source winget --silent --accept-package-agreements --accept-source-agreements --force
    }
}

# 5. Активация Windows (флаг /Ohook для офиса можно оставить на будущее или убрать)
Write-Host "`n[3/3] Активация системы..." -ForegroundColor Cyan
# Оставил /HWID (Windows). /Ohook не помешает, если Офис поставишь позже вручную.
iex "& { $(irm https://get.activated.win) } /HWID /S"

Write-Host "`n--- ВСЕ ГОТОВО! ---" -ForegroundColor Green
