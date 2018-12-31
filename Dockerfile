FROM secoresearch/apache-varnish:latest

# DEFINE BUILDTIME ENV
ENV FILE_PHP_INI "/etc/php/7.0/apache2/php.ini"
ENV FILE_WP_CONF "$PATH_HTML/wp-config.php"
ENV PATH_WP_INSTALL "/wordpress"
ENV SRC_WP_CONF "/wp-config.php.source"
ENV BIN_SENDMAIL "/usr/sbin/sendmail"
ENV PHP_MAX_EXECUTION_TIME "90"

# DEFINE RUNTIME ENV
ENV WP_SALTS ""
ENV WP_DB_NAME "wp"
ENV WP_DB_USER "root"
ENV WP_DB_PASSWORD "dummypassword"
ENV WP_DB_HOST "localhost"
ENV WP_DB_CHARSET "utf8"
ENV WP_SITEURL "http://localhost:8080"
ENV WP_HOME "$WP_SITEURL"
# Enable WP permalinks (.htaccess)
ENV APACHE_ALLOW_OVERRIDE "All"

# Only variables in VARIABLES_WP_CONF will be substituted in the SRC_WP_CONF file.
ENV VARIABLES_WP_CONF \
        "\$WP_SALTS \
        \$WP_DB_NAME \
        \$WP_DB_USER \
        \$WP_DB_PASSWORD \
        \$WP_DB_HOST \
        \$WP_DB_CHARSET \
        \$WP_HOME \
        \$WP_SITEURL"

# INSTALL PACKAGES
# php-mysql - wordpress
# unzip - unpack wp installation
# gettext-base - envsubst for generating config from .source
# vsftpd - wordpress connects via ftp to install themes etc
RUN apt-get update
RUN apt-get install -y php-mysql unzip gettext-base vsftpd

# SETUP WORDPRESS
WORKDIR /tmp/
RUN wget -O wordpress.zip https://wordpress.org/latest.zip
RUN unzip wordpress.zip 
RUN mv -T wordpress "$PATH_WP_INSTALL"

# CLEANUP
run rm -rf /tmp/*
RUN apt-get purge -y unzip

# COPY FILES / CONFIG / TEMPLATES
COPY "wp-config.php.source" "$SRC_WP_CONF"

# PERMISSIONS
RUN touch "$FILE_WP_CONF" && chmod g=u "$FILE_WP_CONF"
RUN touch "$FILE_PHP_INI" && chmod g=u "$FILE_PHP_INI"

RUN chmod g=u /etc/passwd

# Can be run as non-root
USER 10001

ENV RUN_WORDPRESS "/run-wordpress"
COPY "run" "/run-wordpress"
ENTRYPOINT [ "/run-wordpress" ]


