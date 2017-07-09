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

## Customization

If you need to edit _my.cnf_, either mount a volume to _/etc/mysql_ or inherit
this image.

If you need to administrate the database, just use *docker-compose exec* on the
container and use the mysql client from there.

