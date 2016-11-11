#!/bin/bash
source /workdir/environment.sh
datadir='/volume/mysql_backups/'
while [ 1 ]
do
    sleep $[ ( $RANDOM % 24 )  + 1 ]h
    backups=`ls -1 $datadir |wc -l`
    if [ -z $DATABASE_BACKUPS_MAX ]; then
      DATABASE_BACKUPS_MAX=7
    fi
    if [ ! -f "${datadir}$(date +%y%m%d)-mysql-backup.sql" ]; then
      mysqldump -uroot -p$MYSQL_ROOT_PASSWORD --all-databases > "${datadir}$(date +%y%m%d)-mysql-backup.sql"
    fi
    if [ "$backups" -gt "$DATABASE_BACKUPS_MAX" ]; then
      find $datadir -mtime +"$DATABASE_BACKUPS_MAX" -type f -delete
    fi

done
