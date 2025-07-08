## INDEXING
bwa index -p prefix_output file.fa
#indexes the genome file and thus makes it ready for aligning

## Trimming 
fastqc --noextract R1.fastq R2.fastq
./fastp -i R1.fastq -I R2.fastq -o out_R1.fastq -O out_R2.fastq 
#Trims any adapters present in the sequenced reads

## Aligning
bwa mem -t thread ref.fa R1.fa R2.fa > out.sam

## SAM to BAM
samtools view -h -b -o out.bam input.sam
# h retains header b specifies bam 

## Filter
bamtools filter -in input.bam -mapQuality ">=n" -isMapped true -isMateMapped true -out out.bam
# keeps only reads with map quality higher than n (n can be decided from QC) and reads with mapped mates

samtools fixmate input.bam out.bam
# marks all bases

samtools rmdup input.bam out.bam
# marks duplicates 

#peak calling
macs2 callpeak -t treatment.bam -c control.bam -f BAMPE -g hs -n out_prefix -q 0.01 --broad 
#broad for histones and other similar proteins 
#q value to be adjusted as needed
