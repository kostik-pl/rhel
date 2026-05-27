FROM postgres:17-bookworm

#Set POSTGRES variables
ENV PGDATA=/_data/pg_data2

#Explicitly set user/group IDs and data dir
RUN apt-get update \
 && apt-get install -y --no-install-recommends postgresql-17-wal2json \
 && rm -rf /var/lib/apt/lists/*
RUN groupmod -g 9999 postgres ; \
    usermod -u 9999 -g 9999 postgres ; \
    mkdir -p $PGDATA ; \
    chown -R postgres:postgres $PGDATA ; \
    chmod 700 $PGDATA ; \
    mkdir -p /_data/pg_backup ; \
    chown -R postgres:postgres /_data/pg_backup ; \
    chmod 700 /_data/pg_backup

#Change settings
RUN sed -ri "s!^#?(wal_level)\s*=.*!\1 = logical!" /usr/share/postgresql/17/postgresql.conf.sample ; \
    sed -ri "s!^#?(max_replication_slots)\s*=.*!\1 = 10!" /usr/share/postgresql/17/postgresql.conf.sample ; \
    sed -ri "s!^#?(max_wal_senders)\s*=.*!\1 = 10!" /usr/share/postgresql/17/postgresql.conf.sample ; \
    sed -ri "s!^#?(standard_conforming_strings)\s*=.*!\1 = off!" /usr/share/postgresql/17/postgresql.conf.sample ; \
    sed -ri "s!^#?(escape_string_warning)\s*=.*!\1 = off!" /usr/share/postgresql/17/postgresql.conf.sample

#Setup for start
COPY container-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/container-entrypoint.sh

USER postgres

ENTRYPOINT ["container-entrypoint.sh"]
CMD ["postgres"]