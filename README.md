[![](https://images.microbadger.com/badges/version/dchud/datamanagement-notebook.svg)](http://microbadger.com/images/dchud/datamanagement-notebook "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/dchud/datamanagement-notebook.svg)](http://microbadger.com/images/dchud/datamanagement-notebook "Get your own image badge on microbadger.com")

# Data Management for Analytics notebook stack

This docker stack provides everything in Jupyter's
[datascience-notebook](https://github.com/jupyter/docker-stacks/tree/master/datascience-notebook)
with some additional tools students will use in a Data Management
for Analytics course (GWU ISTM 6212).


## Instructions

Please visit [docker-stacks](https://github.com/jupyter/docker-stacks) for
detailed instructions.


## Additions to datascience-notebook

These additional tools have been installed.  See the Dockerfile for
details.

 * [csvkit](https://csvkit.readthedocs.io/)
 * [ipython-sql](https://github.com/catherinedevlin/ipython-sql)
 * [nbgrader](https://nbgrader.readthedocs.io/en/stable/)
 * [GNU Parallel](https://www.gnu.org/software/parallel/)
 * [PostgreSQL 9.5](https://www.postgresql.org/)
 * [Psycopg2](http://initd.org/psycopg/)
