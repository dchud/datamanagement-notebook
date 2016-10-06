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
RUN locale-gen --no-purge en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 && \
    echo locales locales/locales_to_be_generated multiselect en_US.UTF-8 UTF-8 \
        | debconf-set-selections && \
    echo locales locales/default_environment_locale select en_US.UTF-8 \
        | debconf-set-selections && \
    dpkg-reconfigure locales
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    postgresql-9.5 postgresql-client-9.5 libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN echo "local all all trust" > /etc/postgresql/9.5/main/pg_hba.conf
RUN echo "host all all 127.0.0.1/32 trust" >> /etc/postgresql/9.5/main/pg_hba.conf
RUN echo "listen_addresses = '*'" >> /etc/postgresql/9.5/main/postgresql.conf
RUN update-rc.d postgresql defaults
RUN service postgresql restart
RUN chmod go+w /var/run/postgresql/.s.PGSQL.5432

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
