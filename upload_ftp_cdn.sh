#!/bin/bash
cd /var/www/www-root/data/www
if [ -e start_admin.txt ]
then
# если файл существует удалить
rm start_admin.txt
fi
list_all='content/list_all_'$(date +%Y)'.txt'
list_cdn='content/list_cdn_'$(date +%Y)'.txt'
list_all1='list_all_'$(date +%Y)'.txt'
list_cdn1='list_cdn_'$(date +%Y)'.txt'
find content -type f -name "*.mp4" > content/list.txt
# find content -type f -name "*.mp4" >> content/list_all.txt
find content -type f -name "*.mp4" -printf "%TY-%Tm-%Td %TH:%TM:%.2TS %Tz %p\n" >> $list_all
find content -type f -name "*.mp4" -printf "%TY-%Tm-%Td %TH:%TM:%.2TS %Tz %p\n" >> $list_all1
# Read the file in parameter and fill the array named "array"
getArray() {
    array=() # Create array
    while IFS= read -r line # Read a line
    do
        array+=("$line") # Append line to the array
    done < "$1"
}
trim() {
    local var="$*"
    # удаляем пробелы
    var="${var#"${var%%[![:space:]]*}"}"
    # удалить прбелы в конце строки
    var="${var%"${var##*[![:space:]]}"}"   
    echo "$var"
}
getArray "content/list.txt"
# Print the file (print each element of the array)
# getArray "file.txt"
for FILE in "${array[@]}"
do
    # получаем токен
    # TOKEN=$(curl "https://api.cdnvideo.ru/app/oauth/v1/token/" --data-urlencode 'username=parfenov@1med.tv' --data-urlencode 'password=######');
    TOKEN=$(curl "https://api.cdnvideo.ru/app/oauth/v1/token/" --data-urlencode 'username=parfenov@1med.tv' --data-urlencode 'password=######' | jq '.token');
    echo $TOKEN
    TOKEN=$TOKEN | sed 's/\"//g'
    TOKEN=${TOKEN/\"/ }
    TOKEN=${TOKEN/\"/ }
    echo $TOKEN
    
    SIZE_TOKEN=${#TOKEN}
    # проверяем получен ли токен
    if [[ "$SIZE_TOKEN" > 3 ]]; then 
        CDN="CDN-AUTH-TOKEN: "
        CDN+=$TOKEN
        # получаем путь кого качать из файла ср списком путей
        filename=$(basename -- "$FILE")
        #echo $filename
        extension="${filename##*.}" # расширение файла
        filename="${filename%.*}" # имя файла без расширения
        DIR=$(dirname -- "$FILE")
        #echo $DIR
        echo $FILE
        CDNPATH='https://api.cdnvideo.ru/app/storage/v1/ribokuju57/files/'
        CDNPATHS='http://api.cdnvideo.ru/app/storage/v1/ribokuju57/files/'
        CDNPATH+=$FILE
        CDNPATHS+=$FILE
        #echo $CDNPATH
        CDNPATH=$(trim $CDNPATH)
        CDNPATHS=$(trim $CDNPATHS)
        # определите символ конца строки.  Для возврата каретки замените его на $'\r' 
        character=$'\n'
        # удалить символ новой строки
        CDNPATH=${CDNPATH%$character}
        CDNPATHS=${CDNPATHS%$character}
        CDNPATH=$(trim $CDNPATH)
        CDNPATHS=$(trim $CDNPATHS)

        # загружаем файл в Хранилище
        #echo "https://api.cdnvideo.ru/app/storage/v1/ribokuju57/files/$FILE" -F "file=@$filename" -H "$CDN"

        # отправляем файл в CDN и получаем ответ от CDN
        RESULT=$(curl "$CDNPATH" -F "file=@$FILE" -H "$CDN" | jq '.status');
        RESULT=$RESULT | sed 's/\"//g'
        RESULT=${RESULT/\"/ }
        RESULT=${RESULT/\"/ }

        # проверяем успешна ли загрузка в CDN
        if [[ "$RESULT" == *"Completed"* ]]; then 
            DIR+='/'$filename
            #echo $DIR
            echo $FILE
            DIR+='.txt'
            SPACE_CDN=' '
            #echo $DIR
            echo $CDNPATHS > $DIR
            echo $(date +%Y-%m-%d';'%k:%M:%S)$SPACE_CDN$CDNPATHS >> $list_cdn
            echo $(date +%Y-%m-%d';'%k:%M:%S)$SPACE_CDN$CDNPATHS >> $list_cdn1
            # удаляем файл из локального места
            rm $FILE
        else 
            # echo $RESULT
            SPACE_CDN=' '
            echo $(date +%Y-%m-%d_%k:%M:%S)$SPACE_CDN$RESULT >> content/error_cdn.log
            echo $(date +%Y-%m-%d_%k:%M:%S)$SPACE_CDN$RESULT >> error_cdn.log
        fi
    fi
done

if [ -e cron_stop.txt ]
then
# если файл существует удалить
rm cron_stop.txt
fi

exit 0
