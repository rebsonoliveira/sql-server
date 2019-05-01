#!/bin/bash -e

# num of persistent volumes
PV_COUNT=25

for i in $(seq 1 $PV_COUNT); do
  vol="vol$i"
  
  mkdir -p /mnt/local-storage/$vol
  mount --bind /mnt/local-storage/$vol /mnt/local-storage/$vol
done
