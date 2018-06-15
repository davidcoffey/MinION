# Software installation

### Software required for pipeline

#### Hg19 genome file from Gencode
http://www.gencodegenes.org/releases/19.html

#### Picard
https://broadinstitute.github.io/picard/
```
# Build reference dictionary using picard
java -jar picard.jar CreateSequenceDictionary REFERENCE=hg19.fasta OUTPUT=hg19.dict
```

#### Albacore
https://nanoporetech.com

#### Porechop 
https://github.com/rrwick/Porechop

#### NanoStat
https://github.com/wdecoster/nanostat

#### NanoPlot
https://github.com/wdecoster/NanoPlot

#### MiniMap2 aligner
https://github.com/lh3/minimap2
```
# Index reference genome for MiniMap2
minimap2 -d hg19.mmi hg19.fasta 
```

#### LAST aligner
http://last.cbrc.jp
```
# Build reference genome database for LAST
lastdb hg19.lastdb hg19.fasta
```

#### Samtools
http://www.htslib.org/download/

#### NanoSVN
https://github.com/mroosmalen/nanosv
