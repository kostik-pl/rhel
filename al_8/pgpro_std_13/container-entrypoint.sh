#!/usr/bin/env bash

set -e

chmod 700 $PGDATA
chmod 700 /_data/pg_backup

if [ ! -s "$PGDATA/PG_VERSION" ]; then
    pg_ctl initdb -D $PGDATA -o "--locale=$LANG --lc-collate=$LANG"
    printf "host    all             all             all                     md5\n" >> $PGDATA/pg_hba.conf
fi

exec "$@"
