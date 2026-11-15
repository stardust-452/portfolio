#analyzing most signficant DEG for SREBP1 and 2
#SREBP1 - LGALS3BP
#SREBP2 - PCKS2

#make a txt file with gene names

#first extract their coordinates from the genes file
grep -F -f 2_proms.txt genes.gtf > prom_2_coord.gtf

#then get their promoter coord as BED
awk 'BEGIN{OFS="\t"}
$3=="gene"{
 if($7=="+")
  print $1,$4-2001,$4+500,$10,".",$7;
 else
  print $1,$5-500,$5+2000,$10,".",$7;
}' prom_2_coord.gtf > prom_2_prom_coord.bed

#remove chr before no in promoter files as genome does not have those 
sed 's/^chr//' prom_2_prom_coord.bed > nochr_prom_2_prom_coord.bed

#extract sequence from genome FASTA 
bedtools getfasta -fi /STORAGE/AC16_ribo_deplete_transcriptome/genome/Homo_sapiens.GRCh38.dna.primary_assembly.fa -bed  nochr_prom_2_prom_coord.bed -fo seq_prom2.fa -s -nameOnly

#split into individual gene file using seqkit
seqkit grep -p "ENSG00000108679.14" seq_prom2.fa > LGALS3BP.fa
seqkit grep -p "ENSG00000125851.11" seq_prom2.fa > PCSK2.fa

#motif analysis
