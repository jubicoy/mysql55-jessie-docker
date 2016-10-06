#!/bin/bash
#source /workdir/environment.sh
datadir='/volume/mysql_data/backups/'
while [ 1 ]
do
    #sleep $[ ( $RANDOM % 24 )  + 1 ]h
    sleep 5s
    backups=`ls -1 $datadir |wc -l`
    echo $backups
    echo $DATABASE_BACKUPS_MAX
    if [ "$backups" -gt "$DATABASE_BACKUPS_MAX" ]; then
      echo "deleting"
      find $datadir -mmin "+$DATABASE_BACKUPS_MAX" -type f -delete
      # Poistetaan vanhin
      #declare -a FILELIST
      #echo $datadir
      #backup_files=$datadir*
      #for f in $datadir*; do
        #echo $f
        #filedate=${f:0:16}
        #if [ -z "$oldest_backup"]; then
        #  oldest_backup=filedate
        #else
        #  if [ $oldest_backup \> $filedate ]; then
        #    oldest_backup=$filedate
        ##  fi
        #  echo "else"
        #fi
      #done
      #echo "delete $(oldest_backup)"
      #rm -fv $oldest_backup
    fi
    mysqldump -uroot -p$MYSQL_ROOT_PASSWORD --all-databases > /volume/mysql_data/backups/$(date +%y%m%d%s)-mysql-backup.sql
done
