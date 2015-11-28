#!/bin/bash
source /workdir/environment.sh
while [ 1 ]
do
    sleep $[ ( $RANDOM % 24 )  + 1 ]h
    mysqldump -uroot -p$MYSQL_ROOT_PASSWORD --all-databases > /volume/mysql_data/mysql-backup.sql
done
