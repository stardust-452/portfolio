#to be updated

#fastqc
fastqc --no-extract R1.fq.gz R2.fastq.gz

#trimming
fastp -i R1.fastq.gz -I R2.fastq.gz -o R1_trim.fastq.gz -O R2_trim.fastq.gz

#mapping, filtering & BAM conversion
bwa mem -t 50 GRCh38.p14.genome.fa R1.fastq.gz R2.fastq.gz | samtools view -b -q 10 -f 2 \
-F 2304 | samtools sort -o sorted.bam
#optional: nohup to prevent broken pipeline if working on server

#call peak
macs2 callpeak -t sorted.bam -c input_sorted.bam -f BAMPE -g hs -n out_name -q 0.01 --keep-dup all --broad

#visualization
#index bam files
#loop to do it for all files
for file in *_sorted.bam; do samtools index $file; done

#compare treatments
bamCoverage -b sorted.bam --normalizeUsing CPM --binSize 25 --smoothLength 75 -p 6 -o out.bw

