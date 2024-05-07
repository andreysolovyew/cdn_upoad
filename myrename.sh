#!/bin/bash
cd /var/www/www-root/data/www
find content -name "* *"| sort -r | while read x; 
do
    mv "${x}" "$(dirname "${x}")/$(basename "${x}" | sed -e 's/ /_/g')";
done