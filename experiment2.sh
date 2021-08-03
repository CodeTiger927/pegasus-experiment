#!/bin/bash

set -ex

secondaryip=$1

ssh -i ~/.ssh/id_rsa alexfan@"$secondaryip" "sh -c 'nohup taskset -ac 0 /home/alexfan/deadloop > /dev/null 2>&1 &'"
deadlooppid=$(ssh -i ~/.ssh/id_rsa alexfan@"$secondaryip" "sh -c 'pgrep deadloop'")
ssh -i ~/.ssh/id_rsa alexfan@"$secondaryip" "sudo sh -c 'sudo mkdir /sys/fs/cgroup/cpu/cpulow /sys/fs/cgroup/cpu/cpuhigh'"
ssh -i ~/.ssh/id_rsa alexfan@"$secondaryip" "sudo sh -c 'sudo echo 64 > /sys/fs/cgroup/cpu/cpulow/cpu.shares'"
ssh -i ~/.ssh/id_rsa alexfan@"$secondaryip" "sudo sh -c 'sudo echo $deadlooppid > /sys/fs/cgroup/cpu/cpuhigh/cgroup.procs'"
ssh -i ~/.ssh/id_rsa alexfan@"$secondaryip" "ps -ef | awk '/[p]egasus/{print \$2}'>tmpoutput"
ssh -i ~/.ssh/id_rsa alexfan@"$secondaryip" "sudo sh -c 'while IFS= read -r line; do sudo echo \$line>>/sys/fs/cgroup/cpu/cpulow/cgroup.procs; done<tmpoutput'"