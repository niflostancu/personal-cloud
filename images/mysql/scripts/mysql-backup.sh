#!/bin/bash
# automatic backup using mysqldump and logrotate

if [[ -n "$MYSQL_BACKUP_USER" ]]; then
    mysqldump -u "$MYSQL_BACKUP_USER" -p"$MYSQL_BACKUP_PASSWORD" --all-databases \
        --single-transaction | gzip -9 > /var/backup/mysql.sql.gz
    chmod 600 /var/backup/mysql.sql.gz
    cp -a /var/backup/mysql.sql.gz /var/backup/mysql.W.sql.gz
    cp -a /var/backup/mysql.sql.gz /var/backup/mysql.M.sql.gz

    logrotate -s /var/backup/.mysql-rotate.state /etc/logrotate.custom/mysql-backup
fi

