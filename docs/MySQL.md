# MySQL Database Container

The MySQL container provides database storage for the other services.

## Usage

Add the following to your *docker-compose.yml* file:

```yaml
services:
  mysql:
    build: images/mysql/
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

The MySQL data directory must be initialized prior to being able to run the server.

This image provides an interactive script that can be used for this:
```bash
docker-compose run mysql mysql-init.sh
```

It will properly initialize the MySQL container, creating the required databases and users.
It will also ask for a password for MySQL's root user.

Note that you only need to do this once (the data directory is mounted as a volume).
If you run this script again, it will ask whether you want to delete and re-create it.
In this case, you will lose all databases (so make sure that's what you want)!

## Customization

There is nothing else to configure for the container.

The default username and passwords are already configured at initialization time.
If you need to change them, just use *docker-compose exec* on the container and use the mysql
client from there.

