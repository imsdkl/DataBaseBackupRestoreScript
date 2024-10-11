#!/bin/bash

# Параметры подключения к PostgreSQL
PGHOST="127.0.0.1"
PGPORT="5432"
PGUSER="postgres"
PGDATABASE="postgres"

# Файл резервной копии и файлы логов
RESTORE_DB_SRC_PATH="/data"
FILE_NAME="filename.dump"
PG_RESTORE_LOG="${RESTORE_DB_SRC_PATH}/pg_restore.log"

# Начало времени для подсчета продолжительности
START_TIME=$(date +%s)

# Процесс восстановления
pg_restore -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" "$RESTORE_DB_SRC_PATH/$FILE_NAME" &>> "$PG_RESTORE_LOG"

# Проверка успешности восстановления
if [ $? -eq 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') pg_restore successfully!" | tee -a "$PG_RESTORE_LOG"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') pg_restore failed!" | tee -a "$PG_RESTORE_LOG"
fi

# Подсчет времени завершения и продолжительности
END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))
echo "Restore process completed at: $((ELAPSED_TIME / 60)) minutes и $((ELAPSED_TIME % 60)) seconds." | tee -a "$PG_RESTORE_LOG"
