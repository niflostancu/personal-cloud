# MySQL Database Container

The MySQL (which is, actually, MariaDB) container provides database storage for
the other services.

It provides easy to use setup scripts and supports automatic, rotating backup
(daily, monthly and yearly).

## WARNING

**You may want to have database dumps / backups before upgrading this container.
Usually, nothing goes wrong, but just in case...**

## Usage

Add the following to your *docker-compose.yml* file:

```yaml
services:
  mysql:
    image: nicloud/mysql:latest
    volumes:
      - mysql:/var/lib/mysql/
```

And map the **mysql** volume to a persistent location (feel free to use bind
mounts).

## Initialization

The MySQL server needs to be initialized before using it.
To do this, just run it inside an interactive session:

```bash
docker-compose run mysql mysql-init.sh
```

It will then ask you for a root password and create the required databases.

Note that you only need to do this once (it will be saved inside your data
volume).

## Accessing the MySQL Console

If you ever need a MySQL console, you can use docker-compose exec:

```bash
# the service needs to be up!
docker-compose up mysql
# open the MySQL console
docker-compose exec mysql mysql -u root -p
```

## Automatic Backup

The container supports automatic backup with daily / monthly / yearly rotation
via mysqldump / logrotate.

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

