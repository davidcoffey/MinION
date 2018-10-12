#!/bin/bash

# MinIon pipeline for structural variant calls v1.1

# Merge fastq files in each barcode folder and run alignment for fastq file within each barcode
# Yuexin Xu 2018/10/11

#Define Variables
cd $DEMULTIPLEXED_DIRECTORY/workspace/pass
export SAMPLES=$(ls)

for S in ${SAMPLES}; do
  echo ${S}
  export SAMPLE=${S}
  sbatch -n 1 -c 4 -t 3-0 --job-name="minION_ALIGNMENT" --output=$ROOT/Logs/Alignment.${S}.log $ROOT/Scripts/MinION.sh
done








