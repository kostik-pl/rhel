FROM almalinux/10-base

#Locales
RUN dnf install -y glibc-langpack-uk glibc-langpack-ru
ENV LANG=ru_RU.UTF-8

#Postgres variables
ENV PGDATA=/_data/pg_data

#Create postgres user and dirs
RUN groupadd -r postgres --gid=9999 && \
    useradd -r -g postgres --uid=9999 postgres && \
    mkdir -p $PGDATA && \
    chown -R postgres:postgres $PGDATA && \
    chmod 700 $PGDATA

#AlmaLinux 10: NO MODULES → remove this step
#RUN dnf -qy module disable postgresql

#Install wget
RUN dnf install -y wget

#Install PostgresPRO repo
RUN curl -o /opt/pgpro-repo-add.sh https://repo.postgrespro.ru/1c/1c-18/keys/pgpro-repo-add.sh && \
    chmod +x /opt/pgpro-repo-add.sh && \
    /opt/pgpro-repo-add.sh

#Install PostgresPRO 1C-18
RUN dnf install -y postgrespro-1c-18-server postgrespro-1c-18-contrib && \
    dnf clean all

#Fix config
RUN sed -ri "s!^#?(listen_addresses)\s*=.*!\1 = '*'!" /opt/pgpro/1c-18/share/postgresql.conf.sample && \
    sed -ri "s!^#?(logging_collector)\s*=.*!\1 = on!" /opt/pgpro/1c-18/share/postgresql.conf.sample && \
    sed -ri "s!^#?(log_directory)\s*=.*!\1 = 'log'!" /opt/pgpro/1c-18/share/postgresql.conf.sample && \
    sed -ri "s!^#?(lc_messages)\s*=.*!\1 = 'C.UTF-8'!" /opt/pgpro/1c-18/share/postgresql.conf.sample

#Correct PATH for 1C-18 (your Dockerfile had 1c-14 → wrong)
ENV PATH=$PATH:/opt/pgpro/1c-18/bin

COPY container-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/container-entrypoint.sh

USER postgres

EXPOSE 5432

ENTRYPOINT ["container-entrypoint.sh"]
CMD ["postgres"]
