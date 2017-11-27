# MySQL Database Container

The MySQL (which, actually, is MariaDB) container provides database storage for
the other services.

## WARNING

**The container was recently upgraded to MariaDB on an Alpine image. Innodb
databases might not get converted automatically. If this is the case, use
_mysqldump_ on the old container to export the databases and import them on a
clean MariaDB configuration.**

## Usage

Add the following to your *docker-compose.yml* file:

```yaml
services:
  mysql:
    image: nicloud/mysql:latest
    volumes:
      - mysql:/var/lib/mysql/
```

And declare the *mysql* volume (in this example, we're using the *local-persist* driver):

```yaml
volumes:
  mysql:
    driver: local-persist
    driver_opts: { mountpoint: /var/nas-data/mysql }
```

## Initialization

The MySQL server needs to be initialized before using it.
To do this, just run it inside an interactive session:

```bash
docker-compose run mysql
```

This will ask you for a root password and create the required databases.

Note that you only need to do this once (if your data directory is mounted as a
volume).

If you ever need a MySQL console, you can use an exec:

```bash
docker-compose exec mysql mysql -u root -p
```

## Automatic Backup

The container supports automatic backup & rotation via mysqldump / logrotate.

To enable it, you need to:

- open a mysql console and create a MySQL user for backups:
  `GRANT LOCK TABLES, SELECT ON *.* TO 'backup'@'localhost' IDENTIFIED BY 'PASSWORD';`
  (you could also use root, but it's not recommended for security reasons)
- define the _MYSQL_BACKUP_USER_ and _MYSQL_BACKUP_PASSWORD_ environment variables on your docker-compose file;
- use a volume / external mountpoint for _/var/backup_.

The default cron job runs each day at 22:00. If you want to modify it, read below.

## Customization

If you need to edit any configuration file, either mount a volume in its place
or inherit this image.

