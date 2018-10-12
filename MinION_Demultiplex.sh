#!/bin/bash

# MinIon pipeline for structural variant call v1.1

# Demultiplex reads using barcodes

# Yuexin Xu 2018/10/11

# Define variables
export ROOT="path/to/"
export FAST5="$ROOT/fast5/pass"
export FASTQ="$ROOT/Fastq"
export DEMULTIPLEXED_DIRECTORY="$ROOT/Fastq/Demultiplexed"
export ALIGNMENT_DIRECTORY="$ROOT/Aligned"
export NANOSV_DIRECTORY="$ROOT/NanoSV"
export NANOSTAT="$ROOT/NanoStats"
export NANOPLOT="$ROOT/NanoPlot"
export FLOWCELL="FLO-MIN106"
export KIT="SQK-LSK108"
export REFERENCE="path/to/ReferenceGenomes/Human_genomes"
export ID="033018"

# Basecall and demultiplexing with albacore
mkdir $FASTQ
mkdir $DEMULTIPLEXED_DIRECTORY
mkdir $NANOSTAT
mkdir $NANOPLOT
mkdir $ALIGNMENT_DIRECTORY
mkdir $NANOSV_DIRECTORY
module load Python/3.6.5-foss-2016b-fh3
read_fast5_basecaller.py \
--flowcell $FLOWCELL \
--kit $KIT \
--worker_threads 12 \
--input $FAST5 \
--output_format fastq \
--save_path $DEMULTIPLEXED_DIRECTORY \
--recursive \
--resume \
--barcoding

# Optional: demultiplex using porechop (if not using albacore to demultiplex)
module load Python/3.6.4-foss-2016b-fh2
porechop \
--input $FASTQ/workspace/pass/merged.fastq \
--barcode_dir $DEMULTIPLEXED_DIRECTORY \
--format fastq \
--threads 12 \
--barcode_threshold 75 \
--barcode_diff 5