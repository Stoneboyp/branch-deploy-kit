# Список ID приложений для Winget
$apps = @(
    "Google.Chrome",
    "Microsoft.Office",
    "NAPS2.NAPS2",
    "AnyDesk.AnyDesk",
    "Telegram.TelegramDesktop"
)

write-host "Запуск установки типового ПО..." -ForegroundColor Cyan

foreach ($app in $apps) {
    write-host "Установка: $app" -ForegroundColor Yellow
    winget install --id $app --silent --accept-package-agreements --accept-source-agreements
}

write-host "Все задачи выполнены!" -ForegroundColor Green