#!/bin/sh

SHARED_DIR="/shared" # путь к общей папке
LOCK_FILE="${SHARED_DIR}/.lock" # путь к служебному файлу
COUNTER=0 # счётчик созданных файлов этого контейнера

CONTAINER_ID=$(od -An -N3 -tx1 /dev/urandom | tr -d ' \n') # случайный идентификатор контейнера
if [ -z "$CONTAINER_ID" ]; then
    CONTAINER_ID="fallback_$$" # запасное имя
fi
echo "Container ID: $CONTAINER_ID"

while true; do
    COUNTER=$((COUNTER + 1))
    FILENAME=""

    
        exec 9>"$LOCK_FILE"

        flock -x 9

        i=1
        while [ $i -le 999 ]; do
            name=$(printf "%03d" "$i") # число с ведущими нулями
            filepath="${SHARED_DIR}/${name}" # полный путь
            if [ ! -e "$filepath" ]; then # существует ли файл с таким именем
                > "$filepath" # создаём имя
                FILENAME="$filepath" # запоминаем имя
                break
            fi
            i=$((i + 1))
        done
        
    exec 9>&-

    if [ -z "$FILENAME" ]; then
        echo "No free slot available, retrying..."
        sleep 1
        COUNTER=$((COUNTER - 1))
        continue
    fi

    echo "${CONTAINER_ID} ${COUNTER}" > "$FILENAME" # запись в созданный файл

    sleep 0.1

    rm -f "$FILENAME" # удаление файла

    sleep 1 # пауза в одну секунду
done
