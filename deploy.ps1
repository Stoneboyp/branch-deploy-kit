# 1. Проверка прав администратора
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Запустите консоль от имени администратора!"
    Break
}

# Настройка окружения
$ProgressPreference = 'SilentlyContinue'
Write-Host "--- IT-ASSISTANT: START DEPLOY ---" -ForegroundColor Green

# 2. Лечим Winget (сброс источников и игнорирование ошибок сертификатов)
Write-Host "[1/3] Настройка и обновление Winget..." -ForegroundColor Cyan
winget source reset --force | Out-Null
winget source update | Out-Null

# 3. Список софта и установка
# Добавлен флаг --source winget, чтобы не зависеть от MS Store
$apps = @(
    "Google.Chrome", 
    "Microsoft.Office", 
    "NAPS2.NAPS2", 
    "AnyDesk.AnyDesk", 
    "Telegram.TelegramDesktop"
)

Write-Host "[2/3] Установка ПО через репозиторий Winget..." -ForegroundColor Cyan
foreach ($app in $apps) { 
    Write-Host " -> Установка: $app" -ForegroundColor Gray
    # --source winget обходит ошибку сертификата магазина (0x8a15005e)
    winget install --id $app --source winget --silent --accept-package-agreements --accept-source-agreements --force | Out-Null
}

# 4. Полная автоматическая активация (Windows + Office)
Write-Host "[3/3] Активация системы и Office..." -ForegroundColor Cyan
$MAS_URL = "https://get.activated.win"
$params = "/HWID /Ohook /S"
try {
    iex "& { $(irm $MAS_URL) } $params"
} catch {
    Write-Host "Ошибка активации, проверьте интернет" -ForegroundColor Red
}

Write-Host "--- ВСЕ ЗАДАЧИ ВЫПОЛНЕНЫ! ---" -ForegroundColor Green
