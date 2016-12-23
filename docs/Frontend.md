# Nginx Frontend Container

This file describes the configuration of the Nginx-based frontend container.
It serves as reverse proxy for the other services (e.g. Seafile, TinyTinyRSS).

Features:

- lightweight;
- SSL (optional) with [Let's Encrypt](https://letsencrypt.org);
- fully customizable using environment variables and configuration volumes;

## Usage

Add the following to your *docker-compose.yml* file:

```yaml
services:
  frontend:
    build: images/frontend-nginx/
    ports:
     - "80:80"
     - "443:443"  # if you want https, too!
    links:
     - ttrss
     - seafile
    environment:
     - SSL_ENABLED=false  # read on for instructions on how to enable it
     - "DEFAULT_SNIPPETS=seafile ttrss"  # list of containers to be rev-proxied
    volumes:
      - nginx_config:/etc/nginx.overrides/
      - letsencrypt:/etc/letsencrypt/  # if you want to use Let's Encrypt
      # and any other volumes that may be required by other services
```

Don't forget to declare the required volumes:
```yaml
volumes:
  nginx_config:
    driver: local-persist
    driver_opts: { mountpoint: /var/nas-data/nginx-config }
  letsencrypt:
    driver: local-persist
    driver_opts: { mountpoint: /var/nas-data/letsencrypt }
```

## Initialization

This container is ready to run without any prior initialization.

## Customization

In order to customize the container, you must first understand how it's organized.

### Directory Structure

The Nginx configuration uses the following structure:
```
/etc/nginx/
|-- sites-available/      # the available vhosts
|   |-- default           # the default configuration without SSL
|   |-- default-ssl       # the default configuration with SSL enabled
|-- sites-enabled/        # the enabled vhosts (symlinked to sites-available)
|-- snippets/             # contains configuration snippets
|   |-- default/
|   |   |-- *.conf        # to be included for the default server block, e.g.:
|   |   |-- seafile.conf
|   |   |-- ttrss.conf
|   |-- default-ssl/      # snippets for the default-ssl https server block
|   |   |-- insecure/
|   |   |   |-- *.conf    # to be served by both HTTP and HTTP
|   |   |-- *.conf        # stuff to be served only on HTTPS
|   |   |-- server        # stores the server_name and certificate paths
|-- snippets-enabled/     # contains symlinks for snippets to be automatically included
|   |-- default/
|   |-- default-ssl/
|   |   |-- insecure/
|-- # base nginx files
```

There is only one configuration enabled: the default-ssl.

### Environment Variables

The container can be configured using the following environment variables:

- `SSL_ENABLED`: set to *true* to activate the `default-ssl` configuration (aka SSL support);
  also see the **Volumes** section for how to set up domain and certificates;
- `DEFAULT_SNIPPETS`: space-separated string containing the snippets to be automatically symlinked
  from `snippets` into `snippets-enabled`; e.g.: `"seafile ttrss"`
- `INSECURE_SNIPPETS`: same as above, but enabled for `default-ssl`'s insecure HTTP protocol.

### Volumes

If you need additional vhosts or configuration snippets, you can mount a volume to
`/etc/nginx.overrides/`.

Everything found here will automatically be copied at container startup over `/etc/nginx`, so its
structure should be the same, just containing the files you want added / overridden:
```
/etc/nginx.overrides/       # anything here will be copied over to /etc/nginx/
|-- sites-available/
|-- snippets/
|   |-- default/
|   |-- default-ssl
|-- # other files
```

If you want to add more default snippets, you should enable them using the `DEFAULT_SNIPPETS` or
`INSECURE_SNIPPETS` environment variables (see the section above).

#### SSL configuration

In order to successfully enable SSL support, you must override the `snippets/default-ssl/server` 
configuration file (either using volumes or using a derived image) and enter the server_name and 
the full path of the certificates.

For example, to use Let's Encrypt certificates:
```
server_name mydomain.com www.mydomain.com;
ssl_certificate /etc/letsencrypt/live/www.mydomain.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/www.mydomain.com/privkey.pem;
ssl_trusted_certificate /etc/letsencrypt/live/www.mydomain.com/fullchain.pem;
```

If using LetsEncrypt, also don't forget to mount a volume for `/etc/letsencrypt`!

Full example for installing a certificate using LetsEncrypt:
```bash
# edit docker-compose.yml, set SSL_ENABLED=false, mount volumes etc. (see the example)
host$ cat docker-compose.yml
# start the frontend container
host$ docker-compose run frontend &
# enter it using an interactive bash session
host$ docker-compose exec frontend bash
# on the container, request the let's encrypt certificates
frontend$ letsencrypt certonly --webroot -w /var/www/letsencrypt -d www.domain.com -d domain.com --email MY@EMAIL.COM --agree-tos
# also, you need to edit the 'default-ssl/server' snippet
# it is recommended you use a volume mounted on /etc/nginx.overrides and do:
frontend$ mkdir -p /etc/nginx.overrides/snippets/default-ssl/
frontend$ cp /etc/nginx/snippets/default-ssl/default /etc/nginx.overrides/snippets/default-ssl/
# edit the server file with your details
frontend$ vim /etc/nginx.overrides/snippets/default-ssl/
# exit the container and stop it
frontend$ exit
host$ docker-compose stop
# edit again docker-compose.yml, enabling SSL support by setting "SSL_ENABLED=true" envvar
host$ vim docker-compose.yml
# and test it!
host$ docker-compose run frontend
```

