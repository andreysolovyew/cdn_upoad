#!/bin/bash
#проверка существования файла
cd /var/www/www-root/data/www
source myrename.sh;
if [ -e start_admin.txt ]
then
#если файл существует то выполняем загрузку
source upload_ftp_cdn.sh;
else
exit 0;
fi