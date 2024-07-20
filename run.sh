#!/bin/sh
DOCKER_IMAGE=postgres:16.3-alpine3.20
CONTAINER_NAME=pgbench

# DB initialization parameters
export POSTGRES_USER=admin
export POSTGRES_PASSWORD=Mrh8cFldzONEt0y5
export POSTGRES_DB=pgbench

# pgbench parameters
PGBENCH_SCALE=5     # scale factor (keep it higher or equal to concurrent clients)
PGBENCH_CLIENTS=5   # clients or concurrent db sessions
PGBENCH_THREADS=2   # number of threads to run to manage connections
PGBENCH_DURATION=10 # test duration

# script to use, one of tpcb-like, simple-update, select-only with optional weight
PGBENCH_SCRIPT=tpcb-like

set -x
docker start "$CONTAINER_NAME" || docker run -d --rm --name "$CONTAINER_NAME" -e POSTGRES_USER -e POSTGRES_PASSWORD -e POSTGRES_DB "$DOCKER_IMAGE"

docker exec "$CONTAINER_NAME" sh -c "$(cat <<EOF
#!/bin/sh
export PGHOST=localhost
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
EOF
)"

docker rm -f "$CONTAINER_NAME"
