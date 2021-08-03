#!/bin/bash

set -ex

secondaryip=$1

ssh -i ~/.ssh/id_rsa alexfan@"$secondaryip" "sudo sh -c 'sudo /sbin/tc qdisc add dev eth0 root netem delay 40ms'"