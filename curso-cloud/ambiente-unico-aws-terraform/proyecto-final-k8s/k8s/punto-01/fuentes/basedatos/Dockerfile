FROM mariadb:10.7 
# FROM mysql/mysql-server:8.0

# make the "en_US.UTF-8" locale so ~postgres~ mysql/mariadb will be utf-8 enabled by default
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* $ && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

ENV MARIADB_ROOT_PASSWORD=toor
ENV MARIADB_DATABASE=support
ENV MARIADB_ROOT_HOST=%

COPY ./scripts/ /docker-entrypoint-initdb.d/
CMD ["--default-authentication-plugin=mysql_native_password"]

# FROM mysql:5.7.25
# LABEL maintainer="w.marchanaranda@gmail.com"

# ENV MYSQL_ROOT_PASSWORD=toor
# ENV MYSQL_DATABASE=demobd
# ENV MYSQL_ROOT_HOST=%

# COPY ./scripts/ /docker-entrypoint-initdb.d/
# CMD ["--default-authentication-plugin=mysql_native_password"]