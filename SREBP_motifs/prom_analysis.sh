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
awk '/^>/{n++; file="sequence" n ".fa"} {print > file}' seq_prom2.fa

#rename files
mv sequence1.fa LGALS3BP.fa
mv sequence2.fa PCSK2.fa

#pick a random gene from the background set to use as a control
seqkit sample -n 1 -s 100 bg_genes_promoter_seq.fa -o control_prom.fa

#get the filtered motif meme files for SREBP1 and SREBP2
conda activate meme

#motif analysis using FIMO (looping)
#SREBP1
for f in LGALS3BP.fa PCSK2.fa control_prom.fa
do
    name=$(basename "$f" .fa)
    fimo --thresh 1e-4 --oc "SREBP1_${name}" SREBF1_filtered.meme "$f"
done

#SREBP2
for f in LGALS3BP.fa PCSK2.fa control_prom.fa
do
    name=$(basename "$f" .fa)
    fimo --thresh 1e-4 --oc "SREBP2_${name}" SREBF2_filtered.meme "$f"
done
