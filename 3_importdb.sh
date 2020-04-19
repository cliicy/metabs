#!/bin/bash

usage="Usage:\n\t1_prep_dev cfg_file\n\tExample: ./1_prep_dev.sh sysbench.cfg"
if [ "$1" == "" ]; then echo -e ${usage}; exit 1; fi
if [ ! -e $1 ]; then echo "can't find configuration file [$1]", exit 2; fi

# read in configurations
source $1

# create table
${app_basedir}/bin/psql ${dbname}  -f ${crtbsql}

# import data from csv to pgsql
${app_basedir}/bin/psql ${dbname} -c "\copy ${tbname} from '${datafile}' WITH CSV HEADER"

