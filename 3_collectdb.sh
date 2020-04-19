#!/bin/bash

usage="Usage:\n\t1_prep_dev cfg_file\n\tExample: ./1_prep_dev.sh sysbench.cfg"
if [ "$1" == "" ]; then echo -e ${usage}; exit 1; fi
if [ ! -e $1 ]; then echo "can't find configuration file [$1]", exit 2; fi

# read in configurations
source $1

# collect data from  summary.csv
echo ${metabase_column[@]} > ${datafile}
csv_list+=`find ${summary_dir} -type f -name summary.csv`
for sv in ${csv_list[@]}
do
    echo ${sv}
    # get fw_version and sw_version
    dir_root=${sv%/*}
    fw_version=`grep -r "FPGA BitStream:" $dir_root | awk -F ':' '{print $NF}' | sed -r 's/ //g'`
    sw_version=`grep -r "Software Revision:" $dir_root | awk -F ':' '{print $NF}' | sed -r 's/ //g' | sed -r 's/(.*-)//g'`

    # get test_case
    test_case=`cat $sv | head -1 | cut -d ',' -f1`

    stime=`find  ${dir_root} -type f -name time_* | head -1`
    tt=`echo ${stime##*time_} | sed -r 's/_/ /g'`
    run_time=`echo "${tt:0:4}-${tt:4:2}-${tt:6:2} ${tt:9:2}:${tt:11:2}:${tt:13}"`
    
    # get test_item and left
    lines=`cat $sv | tail -n +2 | cut -d ',' -f 1,2,4,8,9,10,11,16,17,18`
    IFS=$'\n'
    for perfs in ${lines}
    do
       echo "${test_case},${run_time},${fw_version},${sw_version},${perfs}" >> ${datafile}
    done    
done
# import data from csv to pgsql
