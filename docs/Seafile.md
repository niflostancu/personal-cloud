# Seafile Container

[Seafile](https://seafile.com) is a open-source, self-hosted file syncing software suite
(e.g. Dropbox alternative).

## WARNING

**The container code was rewritten to use Alpine Linux. Make sure to backup the
old installation before upgrading!**

The recommended way to upgrade to the new Alpine version is start with a new
Seafile configuration, edit it using the old values then re-import the SQL
database and data directory on the new container.

Further upgrades to the Seafile container will be automatic.

## Usage

Add the following to your *docker-compose.yml* file:

```yaml
services:
  seafile:
    image: nicloud/seafile:latest
    environment:
      - FASTCGI=true  # if you want to use a frontend / reverse-proxy
    volumes:
      - seafile:/home/seafile/
      - seafile-data:/var/lib/seafile/
    links:
      - mysql
```

Note that it depends on the [MySQL service](MySQL.md), so make sure to include it too.

You will probably want to reverse-proxy it using the [Frontend container](Frontend.md).
To do this, set the "FASTCGI=true" environment variable and link it to the _frontend_ container:

```yaml
services:
  frontend:  
    # add the following extra entries to your frontend config
    links:
     - seafile
    environment:
     - "DEFAULT_SNIPPETS=... seafile" # or seafile_nr (for non-root path)
    volumes:
      # seahub's media needs to be served by nginx
      - seafile:/home/seafile/
```

Note that Frontend also needs to access the *seafile* installation volume
because it contains static files, which Seahub in FastCGI mode will refuse to
serve, so nginx must do it.

## Initialization

Seafile needs to be properly set up before being able to use it.

In order to do that, just run the container using an interactive session:

```bash
docker-compose run -e "FASTCGI=false" -p 8000:8000 seafile
```

The container will detect this is a new installation and a script will ask you
several questions like site info and database credentials.

You can then test it right away, by going to _localhost:8000_.

## Customization

To customize Seafile, just edit the required files inside the _/home/seafile_
volume.

## Administration

To administrate your Seafile installation, make sure to run the container as
the _seafile_ user so the permissions are left correct:

```bash
docker-compose run -u seafile seafile bash
```

