# bioinfo project
# data download for M. tuberculosis
 wget "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR119/022/SRR11998322/SRR11998322.fastq.gz"
 wget "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR119/023/SRR11998323/SRR11998323.fastq.gz"
 wget "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR119/047/SRR11998347/SRR11998347.fastq.gz"
 wget "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR119/046/SRR11998346/SRR11998346.fastq.gz"

# Genome download
 wget "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/001/938/725/GCF_001938725.1_ASM193872v1/GCF_001938725.1_ASM193872v1_genomic.fna.gz"
 wget "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/001/938/725/GCF_001938725.1_ASM193872v1/GCF_001938725.1_ASM193872v1_genomic.gff.gz"

#gunzip
 gunzip GCF_001938725.1_ASM193872v1_genomic.fna.gz
 gunzip GCF_001938725.1_ASM193872v1_genomic.gff.gz

#genome indexing using STAR
 STAR --runMode genomeGenerate --genomeFastaFiles GCF_001938725.1_ASM193872v1_genomic.fna --sjdbGTFfile GCF_001938725.1_ASM193872v1_genomic.gff  --genomeSAindexNbases 10

#fatsqc
fastqc SRR11998322.fastq.gz -o fastqc
fastqc SRR11998323.fastq.gz -o fastqc
fastqc SRR11998346.fastq.gz -o fastqc
fastqc SRR11998347.fastq.gz -o fastqc

#alignment
STAR --readFilesCommand zcat --readFilesIn "SRR11998322.fastq.gz" --genomeDir GenomeDir --outSAMtype BAM SortedByCoordinate --outFileNamePrefix tb_control_1
STAR --readFilesCommand zcat --readFilesIn "SRR11998323.fastq.gz" --genomeDir GenomeDir --outSAMtype BAM SortedByCoordinate --outFileNamePrefix tb_control_2
STAR --readFilesCommand zcat --readFilesIn "SRR11998346.fastq.gz" --genomeDir GenomeDir --outSAMtype BAM SortedByCoordinate --outFileNamePrefix tb_temp_1
STAR --readFilesCommand zcat --readFilesIn "SRR11998347.fastq.gz" --genomeDir GenomeDir --outSAMtype BAM SortedByCoordinate --outFileNamePrefix tb_temp_2

#counts
 htseq-count -s no -r pos -t exon -i ID -f bam tb_control_1Aligned.sortedByCoord.out.bam GCF_001938725.1_ASM193872v1_genomic.gff > tb_control_1.counts
 htseq-count -s no -r pos -t exon -i ID -f bam tb_control_2Aligned.sortedByCoord.out.bam GCF_001938725.1_ASM193872v1_genomic.gff > tb_control_2.counts
 htseq-count -s no -r pos -t exon -i ID -f bam tb_temp_1Aligned.sortedByCoord.out.bam GCF_001938725.1_ASM193872v1_genomic.gff > tb_temp_1.counts
 htseq-count -s no -r pos -t exon -i ID -f bam tb_temp_2Aligned.sortedByCoord.out.bam GCF_001938725.1_ASM193872v1_genomic.gff > tb_temp_2.counts

