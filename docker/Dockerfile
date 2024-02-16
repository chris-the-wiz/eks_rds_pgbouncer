FROM alpine:3.18
# Arguement for Password
ARG PASSWORD=password
# Argument for pgbouncer version
ARG VERSION=1.21.0




# Installing the openssh and bash package, removing the apk cache
RUN apk --update add --no-cache \
  openssh \
  bash \
  && sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
  && echo "root:${PASSWORD}" | chpasswd \
  && rm -rf /var/cache/apk/*
# Defining the Port 22 for service
RUN sed -ie 's/#Port 22/Port 22/g' /etc/ssh/sshd_config
RUN /usr/bin/ssh-keygen -A
RUN ssh-keygen -t rsa -b 4096 -f  /etc/ssh/ssh_host_key
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
EXPOSE 22



#################################################
#                      pgbouncer                #
#################################################

RUN apk add --no-cache --virtual .build-deps \
    gcc \
    libc-dev \
    libevent-dev \
    libtool \
    udns-dev \
    make \
    openssl-dev \
    pkgconf \
    readline-dev \
    tar \
    wget \
    zlib-dev \
    && apk add --no-cache \
    bash \
    udns \
    libevent \
    openssh-server \
    && wget -O - "https://pgbouncer.github.io/downloads/files/${VERSION}/pgbouncer-${VERSION}.tar.gz" | tar xz \
    && cd "pgbouncer-${VERSION}" \
    && ./configure --prefix=/usr --with-udns \
    && make \
    && make install \
    && cp pgbouncer /usr/bin \
    && mkdir -p /etc/pgbouncer /var/log/pgbouncer \
    && touch /etc/pgbouncer/userlist.txt \
    && cd .. \
    # Cleanup
    && rm -rf "pgbouncer-${VERSION}" \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/* 


# Fix permissions
RUN addgroup -S pgbouncer \
    && adduser -S -G pgbouncer pgbouncer \
    && chown -R pgbouncer:pgbouncer /etc/pgbouncer /var/log/pgbouncer



# Add scripts to bin
COPY scripts/* /usr/local/bin/
RUN chmod +x /usr/local/bin/*






RUN apk --update add --no-cache \
  openrc









# ENV DATABASE_URL=postgres://postgres:securepassword@localhost:5432/db
#ENV DB_USER=postgres 
#ENV DB_PASSWORD=postgres
ENV USER_POSTGRES=postgres 
ENV DB_POSTGRES="host=localhost port=5432 dbname=postgres"
#ENV DB_HOST=localhost
#ENV DB_PORT=5432
#ENV DB_NAME=postgres
#RUN echo "DB_USER=$DB_USER, DB_PASSWORD=$DB_PASSWORD, DB_HOST=$DB_HOST, DB_PORT=$DB_PORT, DB_NAME=$DB_NAME"


EXPOSE 7432


###### postgres for debugging #######

RUN apk update && \
    apk add --no-cache su-exec tzdata libpq postgresql15 postgresql-url_encode




RUN mkdir /var/lib/postgresql/data \
 && chmod 0700 /var/lib/postgresql/data \
 && chown postgres:postgres /var/lib/postgresql/data  \
 && su postgres -c "initdb -D /var/lib/postgresql/data" 
RUN echo "host all all 0.0.0.0/0 scram-sha-256" >> /var/lib/postgresql/data/pg_hba.conf \
 &&  echo "listen_addresses='*'" >> /var/lib/postgresql/data/postgresql.conf \
 && sed -i '/unix_socket_directories = \/tmp/d' /var/lib/postgresql/data/postgresql.conf  \
 && mkdir /run/postgresql \
 && chown postgres:postgres /run/postgresql \
 && echo -e "#!/bin/sh\nsu postgres -c 'pg_ctl start -D /var/lib/postgresql/data'" | tee /etc/local.d/postgres_custom.start >/dev/null \
 && chmod 764 /etc/local.d/postgres_custom.start \
 &&  rc-update add local default  
  

# logging options on
COPY ./configs/postgresql.conf /var/lib/postgresql/data  
 









EXPOSE 5432





#######################################



USER root

# Setup entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]



CMD ["/usr/bin/pgbouncer", "/etc/pgbouncer/pgbouncer.ini"]















#docker run -d -p 2222:22 -p 7432:5432 pgbouncer:latest


# zmien /var/lib/postgresql/data/pg_hba.conf
#      host all all 0.0.0.0/0 scram-sha-256
#

# powinno dzialac z localhosta 
# psql postgres://postgres@localhost:5432/postgres 
# psql -h localhost -p 7432 -U postgres -d postgres
# psql -p 7432 -h localhost -U postgres

# z kontenera do kontenera trzeba podac ip
# CZEMU NA LOCALHOSCIE LACZYMY SIE DO LOCALHOSTA i TYLKO ZMIENIAMY PORT

# docker run -d -p 2222:22 -p 7433:7432 -p 5433:5432  bounce:0.0.1


#docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container_name_or_id
# usually 172.17.0.2



# inside docker
#/etc/pgbouncer/pgbouncer.ini
# rds = host=assdb.cl6e8c4auopw.eu-west-1.rds.amazonaws.com port=5432 dbname=postgres
# #
# psql -Upostgres -p7432 -hlocalhost -drds