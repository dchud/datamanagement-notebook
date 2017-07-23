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
RUN conda install jupyter
RUN conda install --quiet --yes -c conda-forge nbgrader \
    && conda clean -tipsy

# Postgresql 9.6 server, client, and library
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main" \
    > /etc/apt/sources.list.d/postgresql.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc \
    | sudo apt-key add -
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    postgresql-9.6 postgresql-client-9.6 libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN echo "local all all trust" > /etc/postgresql/9.6/main/pg_hba.conf
RUN echo "host all all ::1/128 trust" >> /etc/postgresql/9.6/main/pg_hba.conf
RUN chown -R postgres:postgres /var/run/postgresql
RUN echo "jovyan ALL=(ALL)   ALL" >> /etc/sudoers
RUN echo "jovyan:redspot" | chpasswd

USER postgres
RUN service postgresql restart \
    && createuser --superuser dbuser


USER $NB_USER
# run sudo a first time so students don't see the sudo "usual lecture"
RUN echo 'redspot' | sudo -S ls

# "secure" the notebook
RUN jupyter notebook -y --generate-config
ARG passwd
RUN python -c "from IPython.lib import passwd; p=passwd('$passwd'); open('/home/jovyan/.jupyter/jupyter_notebook_config.py', 'a').write('\nc.NotebookApp.password = u\'%s\'\n' % p)"

# Postgresql python library
RUN conda install --quiet --yes psycopg2 \
    && conda clean -tipsy

# CSVKit
RUN conda install --quiet --yes \
    'csvkit=1.*' \
    && conda clean -tipsy

# SQL support for ipython
RUN pip install ipython-sql
