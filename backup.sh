#!/bin/bash
source /mysql-vars.sh
sleep $[ ( $RANDOM % 14400 )  + 1 ]s
mysqldump -uroot -p$MYSQL_ROOT_PASSWORD --all-databases > /var/lib/mysql/mysql-backup.sql
