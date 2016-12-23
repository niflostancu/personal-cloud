# TinyTinyRSS Container

[TinyTinyRSS](https://tt-rss.org) is a open-source, self-hosted, web-based news feed reader.

## Usage

Add the following to your *docker-compose.yml* file:

```yaml
services:
  ttrss:
    build: images/ttrss-nginx/
    volumes:
      - ttrss:/var/www/
    links:
      - mysql
```

Note that it depends on the [MySQL container](MySQL.md), so make sure to include it too.

It also requires a persistent volume for storing the *.php* files and its configuration:
```yaml
volumes:
  ttrss:
    driver: local-persist
    driver_opts: { mountpoint: /var/nas-data/ttrss }
```

You will also probably want to reverse-proxy it using the [Frontend container](Frontend.md).
Don't forget to activate the *ttrss* snippet and add it as link dependency:

```yaml
services:
  frontend:
    links:
     - ttrss
    environment:
     - "DEFAULT_SNIPPETS=... ttrss"
```

## Initialization

TinyTinyRSS needs to be installed (it also needs its database initialized, a MySQL account configured
etc.). For this, follow the steps:

1. Run bash inside a clean *ttrss* container (as www-data):
```bash
docker-compose run -u www-data ttrss bash
```

2. Inside the container, run the following commands:
```bash
ttrss-update-git.sh  # downloads and installs TTRSS
cd /var/www/rss/     # go to the install location
# clone the default config
cp config.php-dist config.php
# edit it and enter database credentials (user/db will be created automatically)
vim config.php
# run the installation script (which will create the required user / database / tables)
DB_SU_PASS="YOUR MYSQL ROOT PASSWORD" ttrss-install-db.php
```

## Customization

Since TinyTinyRSS is installed persistenly inside a volume, you can freely edit any files in
`/var/www` (e.g. install plugins / themes).

You may also want to periodically upgrade the installation.
The official way to do this is by using git:
```bash
git fetch
git merge origin/master  # or rebase
```

