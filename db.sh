#!/bin/bash

# Устанавливаем пароль для подключения к базе данных
export PGPASSWORD="password"

# Путь к директориям резервного копирования
BACK_PATH=/BACKUP
DB_BACK_PATH=${BACK_PATH}/DB
LAST_DB_BACK_PATH=${DB_BACK_PATH}/LAST
ARCHIVE_DB_BACK_PATH=${DB_BACK_PATH}/ARCHIVE

# Создаем директории для хранения резервных копий, если они не существуют
mkdir -p ${LAST_DB_BACK_PATH}
mkdir ${ARCHIVE_DB_BACK_PATH}

# Получаем текущую дату и время
DATE=$(date +%Y-%m-%d)
DATETIME=$(date '+%Y-%m-%d %H:%M:%S')

# Удаляем старые файлы дампов и логов из последнего резервного копирования
rm -f ${LAST_DB_BACK_PATH}/*.dump
rm -f ${LAST_DB_BACK_PATH}/pg_dump.log

# Выполняем резервное копирование базы данных с временными метками в логе
pg_dump -Fc -b -h 127.0.0.1 -p 5432 -U postgres -d database_name -f ${LAST_DB_BACK_PATH}/database_name.dump -v 2>&1 | while IFS= read -r line; do 
  echo "$DATETIME $line"
done | tee -a ${LAST_DB_BACK_PATH}/pg_dump.log

# Проверяем статус выполнения команды pg_dump и записываем результат в лог
if [ ${PIPESTATUS[0]} -eq 0 ]; then
  echo "$DATETIME successfully!" | tee -a ${LAST_DB_BACK_PATH}/pg_dump.log
else
  echo "$DATETIME failed!" | tee -a ${LAST_DB_BACK_PATH}/pg_dump.log
fi

# Архивируем последние резервные копии
tar -czf ${ARCHIVE_DB_BACK_PATH}/last.tar.gz ${LAST_DB_BACK_PATH}

# Удаляем архивы старше одного дня из архива
find ${ARCHIVE_DB_BACK_PATH}/*.tar.gz -mtime +1 -delete

# Копируем последний архив с датой создания в имени файла
cp ${ARCHIVE_DB_BACK_PATH}/last.tar.gz ${ARCHIVE_DB_BACK_PATH}/${DATE}.tar.gz

# Удаляем архивы старше пяти дней из другой директории резервного копирования
find /BACKUP142/*.tar.gz -mtime +5 -delete

# Копируем последний архив с датой создания в имени файла в другую директорию резервного копирования
cp ${ARCHIVE_DB_BACK_PATH}/last.tar.gz /BACKUP142/${DATE}.tar.gz
