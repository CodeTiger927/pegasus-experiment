#!/bin/bash

set -ex

secondaryip=$1

ssh -i ~/.ssh/id_rsa alexfan@"$secondaryip" "sudo sh -c 'sudo mkdir /sys/fs/cgroup/cpu/db'"
ssh -i ~/.ssh/id_rsa alexfan@"$secondaryip" "sudo sh -c 'sudo echo 500000 > /sys/fs/cgroup/cpu/db/cpu.cfs_quota_us'"
ssh -i ~/.ssh/id_rsa alexfan@"$secondaryip" "sudo sh -c 'sudo echo 1000000 > /sys/fs/cgroup/cpu/db/cpu.cfs_period_us'"
ssh -i ~/.ssh/id_rsa alexfan@"$secondaryip" "ps -ef | awk '/[p]egasus/{print \$2}'>tmpoutput"
ssh -i ~/.ssh/id_rsa alexfan@"$secondaryip" "sudo sh -c 'while IFS= read -r line; do sudo echo \$line>>/sys/fs/cgroup/cpu/db/cgroup.procs; done<tmpoutput'"
