#!/bin/bash
# =============================================
# Автоустановщик cron для apt update + upgrade
# Запускать: curl ... | sudo bash
# =============================================

set -euo pipefail

LOGFILE="/var/log/upd.log"
CRON_COMMENT="# auto-upd-by-github-install-upd.sh"
CRON_JOB="0 6,18 * * * DEBIAN_FRONTEND=noninteractive apt update -qq && DEBIAN_FRONTEND=noninteractive apt upgrade -y -qq >> ${LOGFILE} 2>&1 ${CRON_COMMENT}"

echo "=== Автоматическое обновление Ubuntu 24.04 ==="
echo "Скрипт запущен от $(whoami) ($(id -u))"

# 1. Создаём лог-файл
if [ ! -f "$LOGFILE" ]; then
    sudo touch "$LOGFILE"
    sudo chmod 640 "$LOGFILE"
    echo "✓ Лог-файл создан: $LOGFILE"
else
    echo "✓ Лог-файл уже существует: $LOGFILE"
fi

# 2. Добавляем задачу в cron (только если ещё нет)
if sudo crontab -l 2>/dev/null | grep -q "$CRON_COMMENT"; then
    echo "✓ Задача в cron уже существует — ничего не меняем"
else
    (sudo crontab -l 2>/dev/null || true; echo "$CRON_JOB") | sudo crontab -
    echo "✓ Задача в cron УСПЕШНО добавлена (6:00 и 18:00 каждый день)"
fi

echo ""
echo "Готово!"
echo "Проверить cron:   sudo crontab -l"
echo "Посмотреть логи:  sudo tail -n 50 $LOGFILE"
echo "Удалить задачу:   sudo crontab -l | grep -v '$CRON_COMMENT' | sudo crontab -"
