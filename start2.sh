#!/bin/sh
# Experiments for asynchronous

set -ex

cd ~

# Server specific configs
##########################
s1="10.3.0.5"
s2="10.3.0.6"
s3="10.3.0.7"

s1name="pegasus-server-1"
s2name="pegasus-server-2"
s3name="pegasus-server-3"

username="alexfan"
###########################

slowdownip=$s2

export M2_HOME=/usr/local/maven
export PATH=${M2_HOME}/bin:${PATH}

# Start servers (Dockers locally, azure servers remotely)
# az vm start --resource-group DepFast --subscription "Microsoft Azure Sponsorship 2" --name "$s1name"
# az vm start --resource-group DepFast --subscription "Microsoft Azure Sponsorship 2" --name "$s2name"
# az vm start --resource-group DepFast --subscription "Microsoft Azure Sponsorship 2" --name "$s3name"


# Run pegasus
# get essential.tar.gz and pegasus.tar.gz

#date=$(date +"%Y%m%d%s")
#exec > "$date"_experiment.log
#exec 2>&1


if [ "$#" -ne 4 ]; then
    echo "Wrong number of parameters"
    echo "1st arg - number of iterations"
    echo "2nd arg - workload path"
    echo "3rd arg - experiment to run(1, 2, 3, 4)"
    echo "4th arg - the ith iteration"
    exit 1
fi

iterations=$1
workload=$2
expno=$3
iteration=$4

function start_servers {
  az vm start --resource-group DepFast --subscription "Microsoft Azure Sponsorship 2" --name "$s1name"
  az vm start --resource-group DepFast --subscription "Microsoft Azure Sponsorship 2" --name "$s2name"
  az vm start --resource-group DepFast --subscription "Microsoft Azure Sponsorship 2" --name "$s3name"
  sleep 30
}

# start_db starts the database instances on each of the server
function start_db {

}


# ycsb_load is used to run the ycsb load and wait until it completes.
function ycsb_load {
  cd ~/pegasus-YCSB
  ./bin/ycsb load pegasus -s -P "$workload" > ~/pegasus-experiment/results/outputLoad2_"$expno"_"$iteration".txt
}

# ycsb run exectues the given workload and waits for it to complete
function ycsb_run {
  cd ~/pegasus-YCSB
  ./bin/ycsb run pegasus -s -P "$workload" > ~/pegasus-experiment/results/outputRun2_"$expno"_"$iteration".txt
}

function node_cleanup {
  ssh -i ~/.ssh/id_rsa $username@"$s1" "sudo pkill -f deadloop"
  ssh -i ~/.ssh/id_rsa $username@"$s1" "sudo cgdelete cpu:db cpu:cpulow cpu:cpuhigh blkio:db memory:db ; true"
  ssh -i ~/.ssh/id_rsa $username@"$s1" "sudo /sbin/tc qdisc del dev eth0 root ; true"
  sleep 5
  ssh -i ~/.ssh/id_rsa $username@"$s2" "sudo pkill -f deadloop"
  ssh -i ~/.ssh/id_rsa $username@"$s2" "sudo cgdelete cpu:db cpu:cpulow cpu:cpuhigh blkio:db memory:db ; true"
  ssh -i ~/.ssh/id_rsa $username@"$s2" "sudo /sbin/tc qdisc del dev eth0 root ; true"
  sleep 5
  ssh -i ~/.ssh/id_rsa $username@"$s3" "sudo pkill -f deadloop"
  ssh -i ~/.ssh/id_rsa $username@"$s3" "sudo cgdelete cpu:db cpu:cpulow cpu:cpuhigh blkio:db memory:db ; true"
  ssh -i ~/.ssh/id_rsa $username@"$s3" "sudo /sbin/tc qdisc del dev eth0 root ; true"
  sleep 5
}

# stop_servers turns off the VM instances
function stop_servers {
  az vm deallocate --resource-group DepFast --subscription "Microsoft Azure Sponsorship 2" --name "$s1name"
  az vm deallocate --resource-group DepFast --subscription "Microsoft Azure Sponsorship 2" --name "$s2name"
  az vm deallocate --resource-group DepFast --subscription "Microsoft Azure Sponsorship 2" --name "$s3name"
}

# run_experiment executes the given experiment
function run_experiment {
  /home/alexfan/pegasus-experiment/experiment$expno.sh "$slowdownip"
}

# test_run is the main driver function
function test_run {
  for (( i=1; i<=$iterations; i++ ))
  do
    echo "Running experiment $expno - Trial $i"
    # 1. start servers
    #start_servers

    # 2. Cleanup first
    #data_cleanup  
    node_cleanup

    # 3. SSH to all the machines and start db
    start_db

    # 4. ycsb load
    ycsb_load

    # 5. Run experiment if this is not a no slow
    if [ "$expno" -ne 0 ]; then
      run_experiment
    fi

    # 6. ycsb run
    ycsb_run

    # 7. cleanup
    # node_cleanup

    # 8. Power off all the VMs
    #stop_servers
  done
}

test_run

# Make sure either shutdown is executed after you run this script or uncomment the last line
# sudo shutdown -h now