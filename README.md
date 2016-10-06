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
 * [GNU less](https://www.gnu.org/software/less/)
 * [GNU nano](https://www.nano-editor.org/)
 * [nbgrader](https://nbgrader.readthedocs.io/en/stable/)
 * [GNU Parallel](https://www.gnu.org/software/parallel/)
 * [PostgreSQL 9.5](https://www.postgresql.org/) client and library
 * [Psycopg2](http://initd.org/psycopg/)

Note that Docker won't allow a process like the postgresql daemon
to continue running, so the user account `jovyan` is given sudo
rights.  Within a notebook, or in a shell, `jovyan` can restart
postgresql with sudo.  Because of this, a build argument for the
document image allows for a password to be set at build time, on
the commandline, for the case where this environment might be
deployed on a public server.  It's not real security, but it's
better than nothing.

To set the password in a local build:

    % docker build --build-arg passwd=MYPASSWORD -t dchud/datamanagement-notebook .

If you don't specify `passwd` as a `--build-arg`, the password will
be empty.
