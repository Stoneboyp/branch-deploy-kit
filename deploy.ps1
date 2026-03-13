# 1. Проверка прав администратора
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "!!! ЗАПУСТИТЕ ОТ ИМЕНИ АДМИНИСТРАТОРА !!!"
    Break
}

# ВКЛЮЧАЕМ прогресс-бары (убираем SilentlyContinue)
$ProgressPreference = 'Continue'

Write-Host "--- IT-ASSISTANT: START DEPLOY ---" -ForegroundColor Green

# 2. Настройка Winget
Write-Host "[1/3] Сброс и обновление источников..." -ForegroundColor Cyan
winget source reset --force
winget source update

# 3. Список софта и установка
$apps = @(
    "Google.Chrome", 
    "Microsoft.Office", 
    "NAPS2.NAPS2", 
    "AnyDesk.AnyDesk", 
    "Telegram.TelegramDesktop"
)

Write-Host "[2/3] Установка ПО..." -ForegroundColor Cyan
foreach ($app in $apps) { 
    Write-Host "------------------------------------" -ForegroundColor Yellow
    Write-Host "УСТАНОВКА: $app" -ForegroundColor Yellow
    # Убрали | Out-Null, теперь весь процесс будет на экране
    winget install --id $app --source winget --silent --accept-package-agreements --accept-source-agreements --force
}

# 4. Активация
Write-Host "------------------------------------" -ForegroundColor Green
Write-Host "[3/3] Запуск активации..." -ForegroundColor Cyan
$MAS_URL = "https://get.activated.win"
$params = "/HWID /Ohook /S"

# Выполняем и видим вывод активатора
iex "& { $(irm $MAS_URL) } $params"

Write-Host "--- ВСЕ ЗАДАЧИ ВЫПОЛНЕНЫ! ---" -ForegroundColor Green
