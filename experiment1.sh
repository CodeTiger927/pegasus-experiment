#!/bin/bash

set -ex

secondaryip=$1

ssh -i ~/.ssh/id_rsa alexfan@"$secondaryip" "sudo sh -c 'sudo mkdir /sys/fs/cgroup/cpu/db'"
ssh -i ~/.ssh/id_rsa alexfan@"$secondaryip" "sudo sh -c 'sudo echo 500000 > /sys/fs/cgroup/cpu/db/cpu.cfs_quota_us'"
ssh -i ~/.ssh/id_rsa alexfan@"$secondaryip" "sudo sh -c 'sudo echo 1000000 > /sys/fs/cgroup/cpu/db/cpu.cfs_period_us'"
ssh -i ~/.ssh/id_rsa alexfan@"$secondaryip" sudo sh -c "ps -ef | awk '/[p]egasus/{print \$2}'>/sys/fs/cgroup/cpu/db/cgroup.procs"