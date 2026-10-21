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

#DESeq2
sampleFiles<- c("tb_control_1.counts","tb_control_2.counts","tb_temp_1.counts","tb_temp_2.counts")
sampleNames <- c("control_1","control_2","temp_1","temp_2")
sampleCondition <- c("control","control","high_temp","high_temp")
sampleTable <- data.frame(sampleName = sampleNames, fileName = sampleFiles, condition = sampleCondition)
treatments = c("control","high_temp")
library(DESeq2)
ddsHTSeq <- DESeqDataSetFromHTSeqCount(sampleTable = sampleTable,design= ~condition)
colData(ddsHTSeq)$condition <- factor(colData(ddsHTSeq)$condition, levels = treatments)
dds <- DESeq(ddsHTSeq)
res <- results(dds)
resdata <- merge(as.data.frame(res), as.data.frame(counts(dds,normalized =TRUE)), by = 'row.names', sort = FALSE)
names(resdata)[1] <- 'Name'
write.csv(resdata, file = paste0("bioinfo_tb.csv"))

#visualizing using ViDGER
library(vidger)
vsDEGMatrix(dds, padj= 0.05, d.factor ="condition", type = "deseq",title = TRUE, legend = TRUE, grid =TRUE, data.return =FALSE, grey.scale= FALSE, xaxis.text.size=10,yaxis.text.size=10,main.title.size=15,legend.text.size=10,legend.title.size=10)


