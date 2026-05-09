#!/bin/bash
# =============================================
# Автоустановщик cron для apt update + upgrade + autoremove
# Репозиторий: https://github.com/Bl4ck-K1ng/ubuntu-auto-upd
# Запускать: curl ... | sudo bash
# =============================================

set -euo pipefail

LOGFILE="/var/log/upd.log"
CRON_COMMENT="# auto-upd-by-github-install-upd.sh"
CRON_JOB="0 6,18 * * * DEBIAN_FRONTEND=noninteractive apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq && DEBIAN_FRONTEND=noninteractive apt-get autoremove -y -qq >> ${LOGFILE} 2>&1 ${CRON_COMMENT}"

echo "=== Автоматическое обновление Ubuntu 24.04 ==="

# Проверка, запущен ли скрипт с sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "Ошибка: Скрипт нужно запускать с sudo!"
    echo "Правильная команда: sudo bash install-upd.sh"
    exit 1
fi

echo "Скрипт запущен от root"

# 1. Создаём лог-файл
if [ ! -f "$LOGFILE" ]; then
    touch "$LOGFILE"
    chmod 640 "$LOGFILE"
    echo "✓ Лог-файл создан: $LOGFILE"
else
    echo "✓ Лог-файл уже существует: $LOGFILE"
fi

# 2. Добавляем задачу в cron (только если ещё нет)
if crontab -l 2>/dev/null | grep -q "$CRON_COMMENT"; then
    echo "✓ Задача в cron уже существует — ничего не меняем"
else
    (crontab -l 2>/dev/null || true; echo "$CRON_JOB") | crontab -
    echo "✓ Задача в cron УСПЕШНО добавлена (6:00 и 18:00 каждый день)"
fi

echo ""
echo "Готово!"
echo "Проверить cron:      crontab -l"
echo "Посмотреть логи:    tail -n 50 $LOGFILE"
echo "Удалить задачу:     crontab -l | grep -v '$CRON_COMMENT' | crontab -"echo "Удалить задачу:   sudo crontab -l | grep -v '$CRON_COMMENT' | sudo crontab -"
