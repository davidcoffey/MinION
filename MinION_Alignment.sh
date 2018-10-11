#!/bin/bash

# MinIon pipeline for structural variant calls v1.1

#The following is the minNION_Alignment.sh script

# Merge fastq files 
echo "Merge fastq files"
find $DEMULTIPLEXED_DIRECTORY/workspace/pass/$SAMPLE -name '*.fastq' -exec cat {} + > $DEMULTIPLEXED_DIRECTORY/workspace/pass/$SAMPLE/merged_$SAMPLE.fastq

# Create NanoStats report
echo "Create NanoStats report"
module load Python/3.6.5-foss-2016b-fh3
NanoStat \
--fastq $DEMULTIPLEXED_DIRECTORY/workspace/pass/$SAMPLE/merged_$SAMPLE.fastq \
--name $NANOSTAT/NanoStatsReport.$SAMPLE.txt \
--outdir $NANOSTAT

# Align to human genome using MiniMap2 
echo "Align to human genome using MiniMap2"
module load minimap2/2.10-foss-2016b
minimap2 -ax map-ont $REFERENCE/hg19.mmi $DEMULTIPLEXED_DIRECTORY/workspace/pass/$SAMPLE/merged_$SAMPLE.fastq > $ALIGNMENT_DIRECTORY/minimap.alignment.$SAMPLE.sam

# Sort SAM file, convert to BAM and create index
echo "Sort SAM file, convert to BAM and create index"
module load samtools/1.0
samtools view -bS $ALIGNMENT_DIRECTORY/minimap.alignment.$SAMPLE.sam | samtools sort - $ALIGNMENT_DIRECTORY/minimap.alignment.sorted.$SAMPLE
samtools index $ALIGNMENT_DIRECTORY/minimap.alignment.sorted.$SAMPLE.bam

# Align to human genome using LAST
echo "Align to human genome using LAST"
module load LAST/926-foss-2016b
last-train -Q1 $REFERENCE/hg19.lastdb $DEMULTIPLEXED_DIRECTORY/workspace/pass/$SAMPLE/merged_$SAMPLE.fastq > $ALIGNMENT_DIRECTORY/last.parameters.$SAMPLE
lastal -Q1 -p $ALIGNMENT_DIRECTORY/last.parameters.$SAMPLE $REFERENCE/hg19.lastdb $DEMULTIPLEXED_DIRECTORY/workspace/pass/$SAMPLE/merged_$SAMPLE.fastq | last-split > $ALIGNMENT_DIRECTORY/last.alignment.$SAMPLE.maf
maf-convert -f $REFERENCE/hg19.dict sam -r 'ID:$ID PL:nanopore SM:$SAMPLE' $ALIGNMENT_DIRECTORY/last.alignment.$SAMPLE.maf > $ALIGNMENT_DIRECTORY/last.alignment.$SAMPLE.sam

# Sort SAM file, convert to BAM and create index
echo "Sort SAM file, convert to BAM and create index"
samtools view -bS $ALIGNMENT_DIRECTORY/last.alignment.$SAMPLE.sam | samtools sort - $ALIGNMENT_DIRECTORY/last.alignment.sorted.$SAMPLE
samtools index $ALIGNMENT_DIRECTORY/last.alignment.sorted.$SAMPLE.bam

# Call structural variants
echo "Call structural variants"
module load NanoSV/1.1.2-foss-2016b-Python-3.6.4
NanoSV $ALIGNMENT_DIRECTORY/last.alignment.sorted.$SAMPLE.bam -c $NANOSV_DIRECTORY/config.ini -o $NANOSV_DIRECTORY/NanoSV.$SAMPLE.vcf

