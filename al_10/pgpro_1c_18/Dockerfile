FROM almalinux/10-base

#Update from repository
#RUN dnf update -y

#Add locales
RUN dnf install -y glibc-langpack-uk glibc-langpack-ru
#Set locales
ENV LANG=ru_RU.UTF-8

#Set POSTGRES variables
ENV PGDATA=/_data/pg_data

#Explicitly set user/group IDs and data dir
RUN groupadd -r postgres --gid=9999 ; \
    useradd -r -g postgres --uid=9999 postgres ; \
    mkdir -p $PGDATA ; \
    chown -R postgres:postgres $PGDATA ; \
    chmod 700 $PGDATA

#Disable the built-in PostgreSQL module
RUN dnf -qy module disable postgresql
#Install WGET
RUN dnf install -y wget
#Install the repository PosrgesPRO-1c-14
RUN curl -o /opt/pgpro-repo-add.sh https://repo.postgrespro.ru/1c/1c-18/keys/pgpro-repo-add.sh
#COPY pgpro-repo-add.sh /opt
RUN chmod +x /opt/pgpro-repo-add.sh
RUN /opt/pgpro-repo-add.sh
RUN dnf install -y postgrespro-1c-18-server postgrespro-1c-18-contrib
RUN dnf clean all

#Change settings
RUN sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /opt/pgpro/1c-18/share/postgresql.conf.sample ; \
    sed -ri "s!^#?(logging_collector)\s*=\s*\S+.*!\1 = on!" /opt/pgpro/1c-18/share/postgresql.conf.sample ; \
    sed -ri "s!^#?(log_directory)\s*=\s*\S+.*!\1 = 'log'!" /opt/pgpro/1c-18/share/postgresql.conf.sample ; \
    sed -ri "s!^#?(lc_messages)\s*=\s*\S+.*!\1 = 'C.UTF-8'!" /opt/pgpro/1c-18/share/postgresql.conf.sample

#Setup for start
ENV PATH $PATH:/opt/pgpro/1c-14/bin
COPY container-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/container-entrypoint.sh

#Change user
USER postgres

EXPOSE 5432

ENTRYPOINT ["container-entrypoint.sh"]

CMD ["postgres"]