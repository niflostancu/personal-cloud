# Seafile Container

[Seafile](https://seafile.com) is a open-source, self-hosted file syncing software suite
(e.g. Dropbox alternative).

## Usage

Add the following to your *docker-compose.yml* file:

```yaml
services:
  seafile:
    build: images/seafile/
    environment:
      - FASTCGI=true  # if you want to use nginx as reverse-proxy
    volumes:
      - seafile:/opt/seafile/
      - seafile_data:/var/seafile/
    links:
      - mysql
```

Note that it depends on the [MySQL service](MySQL.md), so make sure to include it too.

It also requires several persistent volumes for installation, configuration and storing the data
blocks:
```yaml
volumes:
```

You will probably want to reverse-proxy it using the [Frontend container](Frontend.md).
To do this, set the "FASTCGI=true" environment variable and link it to the *frontend* container:
```yaml
services:
  frontend:  # note:add the following extra entries to your frontend config
    links:
     - seafile
    environment:
     - "DEFAULT_SNIPPETS=... seafile"
    volumes:
      # seahub's media needs to be served by nginx
      - seafile:/opt/seafile/
```

Note that Frontend also needs to access the *seafile* installation volume because it contains static
files which Seahub in FastCGI mode will refuse to serve, so nginx must do it.

## Initialization

Seafile needs to be properly installed before being able to use it.

Note that the container is hardcoded to use the */opt/seafile/* installation path.

Please read [the official documentation](https://manual.seafile.com/deploy/using_mysql.html) on
installing it.

To install it on the container, you can do the following:

1. We need to run bash on a clean container (so no other services are running on it):
```bash
docker-compose run -p 8000:8000 seafile bash
```

The port mapping is used at the final step (for testing purposes).

2. Next, fix the installation's directory permissions (so the *seafile* user owns it) and download
seafile:
```bash
fix-perms.sh
setuser seafile seafile-download.sh
```

3. Inside the container, change the user to seafile:
```bash
setuser seafile bash
```

4. Proceed with the initialization:
```bash
cd /opt/seafile/seafile-server-*
./setup-seafile-mysql.sh
```
The script is an interactive installer, so it will ask you several questions like database credentials etc.
Don't worry, it will ask you for MySQL root password and create the credentials and databases automatically.
Please leave the default ports if you intend to use the Frontend container as reverse proxy.

Note that if you run any seafile-related command as as root, you will need to repair the permissions
for it to work:
```
chown seafile:seafile /opt/seafile -R
```

5. After finishing installation and configuration, time to test it if it's working correctly:
```bash
cd /opt/seafile/seafile-server-*
./seafile.sh start
./seahub.sh start
# and test it!
```

If successful, exit the interactive session, stop the container and run it using its default
command (*/sbin/my_init*).
Seafile services should automatically be started.

If using the Frontend, start it too and check it if properly configured!

## Customization

As the entire Seafile installation and its configuration files are stored inside a persistent volume,
there is no need to modify / rebase this image, simply edit them direcly on the container.

Also, if you want to upgrade Seafile to a new version, you can use the *seafile-download.sh* script
again and then run the [version-specific upgrade scripts](https://manual.seafile.com/deploy/upgrade.html).


