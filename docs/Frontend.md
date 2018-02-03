# Nginx Frontend Container

This file describes the configuration of the Nginx-based frontend container.
It is used as reverse proxy for the other services (e.g. Seafile, TinyTinyRSS).

Features:

- lightweight;
- SSL (optional) with [Let's Encrypt](https://letsencrypt.org);
- fully customizable using environment variables and volumes (or inheritance);

## Usage

Example _docker-compose.yml_ service configuration:

```yaml
services:
  frontend:
    image: nicloud/frontend-nginx:latest
    ports:
     - "80:80"
     - "443:443"  # if you want https, too
    links:  # services to proxy through nginx
     - ttrss
     - seafile
    environment:
     - "SSL_ENABLED=false"  # read on for instructions on how to enable it
     - "DEFAULT_SNIPPETS=seafile ttrss"  # list of configuration snippets to enable
    volumes:
     - nginx-config:/etc/nginx.overrides/   # if you want to override config / add custom snippets
     - nginx-letsencrypt:/etc/letsencrypt/  # if you want to use Let's Encrypt
     # and any other volumes that may be required by other services, e.g.:
     - seafile:/home/seafile/  # seahub's media needs to be served by nginx
```

Don't forget to declare the `nginx-config` and `nginx-letsencrypt` volumes!

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

By default, if SSL is disabled (see below), the _default_ snippets are used.
If SSL is enabled, all default snippets will automatically switch to SSL-only
(except when they are added to _INSECURE_SNIPPETS_).

### Environment Variables

The container can be configured using the following environment variables:

- **_SSL_ENABLED_**: set to *true* to activate the _default-ssl_ configuration (aka
  SSL support); also see the **SSL Configuration** section for how to set up
  domain and certificates;
- **_DEFAULT_SNIPPETS_**: space-separated string containing the snippets to be
  automatically symlinked from _snippets_ into _snippets-enabled_; e.g.:
  `"DEFAULT_SNIPPETS=seafile ttrss"`
- **_INSECURE_SNIPPETS_**: same as above, but used for the insecure HTTP
  protocol when SSL is enabled.

### Volumes

If you need additional vhosts or configuration snippets, you can mount a volume
to _/etc/nginx.overrides/_. Everything found there will automatically be
copied at container startup over _/etc/nginx_, so its structure should be the
same, just containing the files you want added / overridden:

```
/etc/nginx.overrides/       # anything here will be copied over to /etc/nginx/
|-- sites-available/
|-- snippets/
|   |-- default/
|   |-- default-ssl
|-- # other files
```

If you want to add more default snippets, you should enable them using the _DEFAULT_SNIPPETS_ or
_INSECURE_SNIPPETS_ environment variables (see the previous section).

#### SSL configuration

In order to successfully enable SSL support, you must override the
_snippets/default-ssl/server_ configuration file (either using volumes or using
a derived image) and enter the _server_name_ and the full path of the
certificates.

For example, to use Let's Encrypt certificates:
```
server_name mydomain.com www.mydomain.com;
ssl_certificate /etc/letsencrypt/live/www.mydomain.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/www.mydomain.com/privkey.pem;
ssl_trusted_certificate /etc/letsencrypt/live/www.mydomain.com/fullchain.pem;
```

If using LetsEncrypt, also don't forget to mount a volume for _/etc/letsencrypt_!

Full example for installing a certificate using LetsEncrypt:

- Edit _docker-compose.yml_:
  - set `SSL_ENABLED=false`;
  - also make sure to have persistent volumes for _/etc/letsencrypt_ and _/etc/nginx.overrides_:
    ```yaml
    frontend:
      # ...
      volumes:
       - nginx-config:/etc/nginx.overrides/
       - nginx-letsencrypt:/etc/letsencrypt/
    ```
- start the container and exec an interactive bash session:
  ```bash
    docker-compose up &
    docker-compose exec frontend bash
  ```
- run _certbot_ to generate the certificates:
  ```bash
  certbot certonly --webroot -w /var/www/letsencrypt -d www.domain.com -d domain.com --email MY@EMAIL.COM
  ```
- also create _/etc/nginx.overrides/snippets/default-ssl/server_ and enter SSL certificate details:
  ```bash
  mkdir -p /etc/nginx.overrides/snippets/default-ssl/
  cp /etc/nginx/snippets/default-ssl/server /etc/nginx.overrides/snippets/default-ssl/
  vi /etc/nginx.overrides/snippets/default-ssl/server
  ```
- edit again _docker-compose.yml_ and set `SSL_ENABLED=true`
- restart the server and test it:
  ```bash
  docker-compose stop
  docker-compose up
  ```

To renew your certificate, just connect to the nginx container while running
and issue the `certbot renew` command:
```bash
docker-compose exec frontend bash
# on the container:
certbot renew
# then restart container
```

