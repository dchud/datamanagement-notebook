# docker-stacks are Copyright (c) Jupyter Developer Team.
# Distributed under the terms of the Modified BSD License.
FROM jupyter/datascience-notebook

MAINTAINER Daniel Chudnov <dchud@umich.edu>

USER root

# GNU Parallel
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    less \
    nano \
    parallel \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# nbgrader support
RUN conda install --quiet --yes -c jhamrick nbgrader \
    && conda clean -tipsy
RUN nbgrader extension install
RUN nbgrader extension activate

# Postgresql 9.5 server, client, library, and dbuser
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main" \
    > /etc/apt/sources.list.d/postgresql.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc \
    | sudo apt-key add -
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    postgresql-9.5 postgresql-client-9.5 libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN echo "local all all trust" > /etc/postgresql/9.5/main/pg_hba.conf
RUN update-rc.d postgresql defaults
RUN service postgresql restart
RUN chown -R postgres:postgres /var/run/postgresql

USER postgres
RUN createuser --createdb dbuser


USER $NB_USER

# Postgresql python library
RUN conda install --quiet --yes psycopg2 \
    && conda clean -tipsy

# CSVKit
RUN conda install --quiet --yes \
    'csvkit=0.9*' \
    && conda clean -tipsy

# SQL support for ipython
RUN pip install ipython-sql
