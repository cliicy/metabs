#!/bin/bash

usage="Usage:\n\t1_prep_dev cfg_file\n\tExample: ./1_prep_dev.sh sysbench.cfg"
if [ "$1" == "" ]; then echo -e ${usage}; exit 1; fi
if [ ! -e $1 ]; then echo "can't find configuration file [$1]", exit 2; fi

# read in configurations
source $1

lsblk ${disk}
if [ "$?" -ne 0 ]; then echo "cannot find disk [${disk}]"; exit 3; fi

# stop mysql service first, since it my occupy the disk
./stop.sh

# prepare the mount point and other folders
if [ ! -e ${mnt_point_data} ]; then sudo mkdir -p ${mnt_point_data}; fi

sudo umount ${disk}

echo ${disk} | grep sfd

if [ $? -eq 0 ];
then
    cur_cap=$(sudo ${css_status} ${disk} | grep -i "disk capacity" | sed -r "s/\s+/,/g" | cut -d, -f3)
    echo ${cur_cap} " --> " ${capacity_gb}
    if [ ${cur_cap} -ne ${capacity_gb} ];
    then
        echo y | sudo sfx-nvme sfx format ${disk} --capacity=${capacity_gb}
    fi

    echo y | sudo sfx-nvme format ${disk} -s 1
fi

sleep 10

sudo mkfs -t ${fs_type} -f ${disk}
sudo mount ${disk} ${mnt_opt} ${mnt_point_data}
