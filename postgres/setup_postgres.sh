#!/bin/bash

# Copy pg_hba.conf to PG_CONF directory without throwing errors if it doesn't exist
if [ -f /workspaces/rax/pg_hba.conf ]; then
    cp /workspaces/rax/pg_hba.conf $PG_CONF/pg_hba.conf
fi

# Initialize the database if it hasn't been initialized
if [ ! -d $PG_DATA/pg_version ]; then
    sudo -u ubuntu initdb -D $PG_DATA
fi

# Write server.key and server.crt for SSL
openssl req -nodes -new -x509 -keyout $PGDATA/server.key -out $PGDATA/server.crt -subj '/C=US/L=Chicago/O=AptSaaS/OU=Dev/CN=localhost'
chmod 400 $PGDATA/server.crt
chmod 400 $PGDATA/server.key

# Set password for the 'ubuntu' superuser
sudo -u ubuntu psql -c "ALTER USER ubuntu WITH PASSWORD '$PASSWORD';"

# Load the 'plpython' extension
sudo -u ubuntu psql -c "CREATE EXTENSION IF NOT EXISTS plpython;"