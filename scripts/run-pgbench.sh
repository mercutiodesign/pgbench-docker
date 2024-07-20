#!/bin/sh
export PGHOST=postgres
export PGUSER="$POSTGRES_USER"
export PGPASSWORD="$POSTGRES_PASSWORD"
export PGDATABASE="$POSTGRES_DB"

echo "Blocking until postgres accepts connections"

until pg_isready > /dev/null; do
  printf .
  sleep 1
done
echo

set -ex
pgbench -i -s "$PGBENCH_SCALE"
pgbench -c "$PGBENCH_CLIENTS" -j "$PGBENCH_THREADS" -T "$PGBENCH_DURATION" -b "$PGBENCH_SCRIPT" -P 1
