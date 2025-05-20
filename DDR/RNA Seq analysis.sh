# Following are the commands used for the RNA Seq analysis.
# The code shows analysis for one pair of paired-end fastqc files.

#quality check using fastQC for all the files
fastqc file_name.fastq.gz

#adapter trimming using fastp 
fastp -i file_read_1.fastq.gz -I file_read_2.fastq.gz -o out.read_1.fastq.gz -O out.read_2.fastq.gz --detect_adapter_for_pe --failed_out failed_reads.fastq.gz 

# genome indexing

# genome retrieval
#Genome and GTF download (from Ensembl, genome build hg38)
wget 'ftp://hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/genes/hg38.ensGene.gtf.gz'
wget 'ftp://hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz'

#gunzip
gunzip hg38.fa.gz
gunzip hg38.ensGene.gtf.gz

#Indexing
STAR --runThreadsN 22 --runMode genomeGenerate --genomeFastaFiles hg38.fa --sjdbGTFfile hg38.ensGene.gtf

#aligning the reads to genome using STAR aligner
STAR --runThreadN 20 \ 
     --readFilesIn "out.read_1.fastq.gz" "out.read_2.fastq.gz" \
     --genomeDir indexed_genome \
     --outSAMtype BAM SortedByCoordinate \ 
     --outFileNamePrefix aligned \
     --readFilesCommand zcat

#BAM to counts using HTSeq 
htseq-count -s no -r pos —t exon -i gene_id -f bam Aligned.sortedByCoord.out.bam /home/genome/gtf file > outname.counts

#This will generate count matrices for all the genes which then can be analysed by a suitable package like edgeR or DESeq2 in R.


