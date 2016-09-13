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

USER $NB_USER

# CSVKit
RUN conda install --quiet --yes \
    'csvkit=0.9*' \
    && conda clean -tipsy

# SQL support for ipython
RUN pip install ipython-sql
