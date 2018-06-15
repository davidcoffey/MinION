#!/bin/bash

# MinIon pipeline for structural variant calls v1.0

# Define variables
export FAST5="/path/to/fast5/pass"
export FASTQ="/path/to/Fastq/Original"
export DEMULTIPLEXED_DIRECTORY="/path/to/Fastq/Demultiplexed"
export ALIGNMENT_DIRECTORY="/path/to/Aligned"
export NANOSV_DIRECTORY="/path/to/NanoSV"
export FLOWCELL="FLO-MIN106"
export KIT="SQK-LSK108"
export NANOSTATS="/path/to/NanoStats"
export NANOPLOT="/path/to/NanoPlot"
export REFERENCE="/path/to/ReferenceGenomes"
export SAMPLE="BL"
export ID="033018"

# Basecall with albacore
mkdir $FASTQ
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

# Merge all fastq files
cat $FASTQ/workspace/pass/*.fastq > $FASTQ/workspace/pass/merged.fastq

# Demultiplex
mkdir $DEMULTIPLEXED_DIRECTORY
module load Python/3.6.4-foss-2016b-fh2
porechop \
--input $FASTQ/workspace/pass/merged.fastq \
--barcode_dir $DEMULTIPLEXED_DIRECTORY \
--format fastq \
--threads 12 \
--barcode_threshold 75 \
--barcode_diff 5

# Create NanoStats report
mkdir $NANOSTATS
module load Python/3.6.5-foss-2016b-fh3
NanoStat \
--fastq $DEMULTIPLEXED_DIRECTORY/none.fastq.gz \
--name $NANOSTATS/NanoStatsReport.txt \
--outdir $NANOSTATS

# Create NanoPlot figures
mkdir $NANOPLOT
module load Python/3.6.5-foss-2016b-fh3
NanoPlot \
--fastq $DEMULTIPLEXED_DIRECTORY/none.fastq.gz \
--outdir $NANOPLOT \
--plots hex dot

# Align to human genome using MiniMap2 
mkdir $ALIGNMENT_DIRECTORY
module load minimap2/2.10-foss-2016b
minimap2 -a $REFERENCE/hg19.mmi $DEMULTIPLEXED_DIRECTORY/none.fastq.gz > $ALIGNMENT_DIRECTORY/minimap.alignment.sam

# Sort SAM file, convert to BAM and create index
samtools view -bS $ALIGNMENT_DIRECTORY/minimap.alignment.sam | samtools sort - $ALIGNMENT_DIRECTORY/minimap.alignment.sorted
samtools index $ALIGNMENT_DIRECTORY/minimap.alignment.sorted.bam

# Align to human genome using LAST
module load LAST/926-foss-2016b
lastdb -uNEAR -R01 humandb $REFERENCE
lastdb hg19.lastdb $REFERENCE

# Align to human genome using LAST
module load LAST/926-foss-2016b
last-train -Q1 $REFERENCE/hg19.lastdb $DEMULTIPLEXED_DIRECTORY/none.fastq.gz > $ALIGNMENT_DIRECTORY/last.parameters
lastal -Q1 -p $ALIGNMENT_DIRECTORY/last.parameters $REFERENCE/hg19.lastdb $DEMULTIPLEXED_DIRECTORY/none.fastq.gz | last-split > $ALIGNMENT_DIRECTORY/last.alignment.maf
maf-convert -f $REFERENCE/hg19.dict sam -r 'ID:$ID PL:nanopore SM:$SAMPLE' $ALIGNMENT_DIRECTORY/last.alignment.maf > $ALIGNMENT_DIRECTORY/last.alignment.sam

# Sort SAM file, convert to BAM and create index
samtools view -bS $ALIGNMENT_DIRECTORY/last.alignment.sam | samtools sort - $ALIGNMENT_DIRECTORY/last.alignment.sorted
samtools index $ALIGNMENT_DIRECTORY/last.alignment.sorted.bam

# Call structural variants
mkdir $NANOSV_DIRECTORY
module load NanoSV/1.1.2-foss-2016b-Python-3.6.4
NanoSV $ALIGNMENT_DIRECTORY/last.alignment.sorted.bam -c $NANOSV_DIRECTORY/config.ini > $NANOSV_DIRECTORY/NanoSV.vcf
