#!/usr/bin/env bash

set -e

chown -R postgres:postgres $PGDATA ; \
chmod -R 700 $PGDATA ; \
chown -R postgres:postgres /_data/pg_backup ; \
chmod 777 /_data/pg_backup

if [ ! -s "$PGDATA/PG_VERSION" ]; then
    pg_ctl initdb -D $PGDATA -o "--locale=$LANG --lc-collate=$LANG"
    printf "host    all             all             all                     md5\n" >> $PGDATA/pg_hba.conf
fi

exec "$@"
