#!/bin/bash
#source /workdir/environment.sh
datadir='/volume/mysql_data/backups/'
while [ 1 ]
do
    sleep $[ ( $RANDOM % 24 )  + 1 ]h
    backups=`ls -1 $datadir |wc -l`
    echo $DATABASE_BACKUPS_MAX
    if [ "$backups" -gt "$DATABASE_BACKUPS_MAX" ]; then
      echo "deleting"
      find $datadir -mmin "+$DATABASE_BACKUPS_MAX" -type f -delete
    fi
    if []
    mysqldump -uroot -p$MYSQL_ROOT_PASSWORD --all-databases > /volume/mysql_data/backups/$(date +%y%m%d)-mysql-backup.sql
done
