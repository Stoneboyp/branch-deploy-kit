# 1. Проверка прав администратора
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Запустите консоль от имени администратора!"
    Break
}

# Скрываем прогресс-бары для скорости
$ProgressPreference = 'SilentlyContinue'

Write-Host "--- IT-ASSISTANT: START DEPLOY ---" -ForegroundColor Green

# 2. Обновление репозиториев Winget
Write-Host "[1/3] Обновление базы приложений..." -ForegroundColor Cyan
winget source update | Out-Null

# 3. Список софта и установка
$apps = @(
    "Google.Chrome", 
    "Microsoft.Office", 
    "NAPS2.NAPS2", 
    "AnyDesk.AnyDesk", 
    "Telegram.TelegramDesktop"
)

Write-Host "[2/3] Установка ПО (это займет время)..." -ForegroundColor Cyan
foreach ($app in $apps) { 
    Write-Host " -> Установка: $app" -ForegroundColor Gray
    winget install --id $app --silent --accept-package-agreements --accept-source-agreements --force | Out-Null
}

# 4. Полная автоматическая активация (Windows + Office)
Write-Host "[3/3] Активация системы и Office..." -ForegroundColor Cyan
# Вызов скрипта MAS с параметрами для тихой работы
$MAS_URL = "https://get.activated.win"
$params = "/HWID /Ohook /S"
iex "& { $(irm $MAS_URL) } $params"

Write-Host "--- ВСЕ ЗАДАЧИ ВЫПОЛНЕНЫ! ---" -ForegroundColor Green
