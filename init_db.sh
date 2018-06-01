#!/bin/bash

set -ue

# Try to create a DB inside PostgreSQL.
# Helpful for local hacking in Docker Compose.
if psql "${STELLAR_CORE_DATABASE_URL#postgresql://}" -c "\dt"
then
  echo "Database found."
else
  echo -n "No database found, trying to create: "

  _service_db_url=$(echo $STELLAR_CORE_DATABASE_URL | sed -E 's/dbname=[0-9a-zA-Z_\-]+/dbname=postgres/')
  _db_name=$(echo $STELLAR_CORE_DATABASE_URL | sed -E 's/^.*dbname=([0-9a-zA-Z_\-]+).*/\1/')
  psql "${_service_db_url#postgresql://}" -c "CREATE DATABASE $_db_name" && echo "done"
fi

if psql "${STELLAR_CORE_DATABASE_URL#postgresql://}" -c "\dt" | grep -q "No relations"
then
  echo -n "Database is not initialized. Initializing... "
	stellar-core --newdb --conf /etc/stellar/stellar-core.cfg && echo "done!"

  exit $?
fi

echo "Database was already initialized. Skipping."


export _test="postgresql://dbname=test host=postgres user=postgres password=password"

psql "${_test#postgresql://}" -c "\dt"
