#!/bin/bash

set -ex

secondaryip=$1

ssh -i ~/.ssh/id_rsa alexfan@"$secondaryip" "sudo sh -c 'sudo mkdir /sys/fs/cgroup/blkio/db'"
ssh -i ~/.ssh/id_rsa alexfan@"$secondaryip" "sudo sh -c 'sync; echo 3 > /proc/sys/vm/drop_caches'"
lsblkcmd="8:32 65536"
ssh -i ~/.ssh/id_rsa alexfan@"$secondaryip" "sudo sh -c 'sudo echo $lsblkcmd > /sys/fs/cgroup/blkio/db/blkio.throttle.read_bps_device'"                 
ssh -i ~/.ssh/id_rsa alexfan@"$secondaryip" "sudo sh -c 'sudo echo $lsblkcmd > /sys/fs/cgroup/blkio/db/blkio.throttle.write_bps_device'"                                                                                                                         
ssh -i ~/.ssh/id_rsa alexfan@"$secondaryip" "ps -ef | awk '/[p]egasus/{print \$2}'>tmpoutput"
ssh -i ~/.ssh/id_rsa alexfan@"$secondaryip" "sudo sh -c 'while IFS= read -r line; do sudo echo \$line>>/sys/fs/cgroup/blkio/db/cgroup.procs; done<tmpoutput'"