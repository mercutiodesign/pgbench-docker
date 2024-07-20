#!/bin/sh
set -ex
docker compose up -d postgres
docker compose exec postgres sh /scripts/run-pgbench.sh
