#!/bin/bash

#export FAST5=""
#export FASTQ=""
#export FLOWCELL="FLO-MIN106"
#export KIT="SQK-LSK108"

# Base call
module load Python/3.6.5-foss-2016b-fh3
read_fast5_basecaller.py \
--flowcell $FLOWCELL \
--kit $KIT \
--worker_threads 12 \
--input $FAST5 \
--output_format fastq \
--save_path $FASTQ \
--recursive \
--resume

# Demultiplex: Porechop (https://github.com/rrwick/Porechop)
module purge
module load Python/3.6.4-foss-2016b-fh2
porechop -h