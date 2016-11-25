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

# Postgresql 9.5 server, client, and library
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main" \
    > /etc/apt/sources.list.d/postgresql.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc \
    | sudo apt-key add -
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    postgresql-9.5 postgresql-client-9.5 libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN echo "local all all trust" > /etc/postgresql/9.5/main/pg_hba.conf
RUN echo "host all all ::1/128 trust" >> /etc/postgresql/9.5/main/pg_hba.conf
RUN chown -R postgres:postgres /var/run/postgresql
RUN echo "jovyan ALL=(ALL)   ALL" >> /etc/sudoers
RUN echo "jovyan:redspot" | chpasswd

USER postgres
RUN service postgresql restart \
    && createuser --superuser dbuser

# Spark install and config from pyspark-notebook
ENV APACHE_SPARK_VERSION 2.0.2
ENV APACHE_HADOOP_VERSION 2.7
RUN apt-get -y update && \
    apt-get install -y --no-install-recommends openjdk-7-jre-headless && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN cd /tmp && \
    wget -q http://d3kbcqa49mib13.cloudfront.net/spark-${APACHE_SPARK_VERSION}-bin-hadoop${APACHE_HADOOP_VERSION}.tgz && \
    echo "09f3b50676abc9b3d1895773d18976953ee76945afa72fa57e6473ce4e215970 *spark-${APACHE_SPARK_VERSION}-bin-hadoop${APACHE_HADOOP_VERSION}.tgz" | sha256sum -c - && \
    tar xzf spark-${APACHE_SPARK_VERSION}-bin-hadoop${APACHE_HADOOP_VERSION}.tgz -C /usr/local && \
    rm spark-${APACHE_SPARK_VERSION}-bin-hadoop${APACHE_HADOOP_VERSION}.tgz
RUN cd /usr/local && ln -s spark-${APACHE_SPARK_VERSION}-bin-hadoop${APACHE_HADOOP_VERSION} spark
ENV SPARK_HOME /usr/local/spark
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.3-src.zip
ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info

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
    'csvkit=0.9*' \
    && conda clean -tipsy

# SQL support for ipython
RUN pip install ipython-sql
