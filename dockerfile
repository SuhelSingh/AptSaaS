ARG TAG=0.1
ARG PASSWORD
FROM ubuntu:jammy 

### Directories
ENV HOME=/home/ubuntu
ENV APP_HOME=$HOME/app
ENV REDIS_HOME=$HOME/redis
ENV POSTGRES_HOME=$HOME/postgres
RUN mkdir -p $HOME $APP_HOME $REDIS_HOME $POSTGRES_HOME

### Users and Groups
RUN groupadd -g 1000 ubuntu && \
    useradd -m -s /bin/bash -g ubuntu -u 1000 ubuntu && \
    chown -R ubuntu:ubuntu $HOME 

### Install Packages
RUN apt-get update && \
    # Install timezone data
    apt-get install -y --no-install-recommends tzdata && \
    # Linux Dev Tools
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    software-properties-common git sudo curl wget ant gettext gcc make zsh libpq-dev && \
    # Setup Node.js
    curl -fsSL https://deb.nodesource.com/setup_current.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest && \
    # Setup Java
    apt-get install -y openjdk-11-jdk-headless ca-certificates-java && \
    # Setup Python
    apt-get install -y python3 python3-pip && \
    # Setup Redis
    apt-get install -y redis-server && \
    # Setup Postgres
    apt-get install -y postgresql-14 postgresql-plpython3-14 && \
    # Clean up
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set up the working user
USER ubuntu

### Postgres
WORKDIR $POSTGRES_HOME
ENV POSTGRES_BIN=/usr/lib/postgresql/14/bin
ENV PGDATA=$POSTGRES_HOME/data
ENV PGCONF=$POSTGRES_HOME/conf
ENV PGLOGS=$POSTGRES_HOME/logs
RUN COPY ./postgres .
RUN mkdir -p $PGDATA $PGCONF $PGLOGS
RUN chown ubuntu:ubuntu -R $PGDATA $PGCONF $PGLOGS

### Redis
WORKDIR $REDIS_HOME
ENV REDIS_CONF=$REDIS_HOME/conf
ENV REDIS_DATA=$REDIS_HOME/data
ENV REDIS_LOGS=$REDIS_HOME/logs
COPY ./redis .

RUN mkdir -p $REDIS_CONF $REDIS_DATA $REDIS_LOGS && \
    chown -R ubuntu:ubuntu $REDIS_HOME

### App
WORKDIR $APP_HOME
COPY ./app .
RUN rm -rf dist && rm -rf ./node_modules && rm -rf ./package-lock.json
RUN mkdir -p $APP_HOME/node_modules
RUN chown ubuntu:ubuntu -R $APP_HOME 
RUN npm i 
