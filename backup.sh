#!/bin/bash
#source /workdir/environment.sh
datadir='/var/lib/mysql/'
while [ 1 ]
do
    sleep $[ ( $RANDOM % 24 )  + 1 ]h
    backups=`ls -1 $datadir |wc -l`
    if [ -z $DATABASE_BACKUPS_MAX ]; then
      echo "env not set. Using default"
      DATABASE_BACKUPS_MAX=7
    fi
    if [ "$backups" -gt "$DATABASE_BACKUPS_MAX" ]; then
      echo "deleting oldest backup"
      find $datadir -mmin "+$DATABASE_BACKUPS_MAX" -type f -delete
    fi
    if [ ! -f $datadir$(date +%y%m%d)-mysql-backup.sql ]; then
      mysqldump -uroot -p$MYSQL_ROOT_PASSWORD --all-databases > /var/lib/mysql/$(date +%y%m%d)-mysql-backup.sql
      echo "created backup"
    fi
done
