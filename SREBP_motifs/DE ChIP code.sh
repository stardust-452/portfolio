#download GENCODE GTF 

#get only genes
awk '$3=="gene"' gencode.v49.basic.annotation.gtf > genes.gtf

#get gene lists from DE data
#get gene coor for those genes
grep -F -f SREBF2_genes.txt genes.gtf > SREBF2_genes_coor.gtf

#get their promoters (-2000 to +500)
awk 'BEGIN{OFS="\t"}
$3=="gene"{
 if($7=="+")
  print $1,$4-2001,$4+500,$10,".",$7;
 else
  print $1,$5-500,$5+2000,$10,".",$7;
}' genes.gtf > SREBF2_promoters.bed

#get ChIP-Seq IDR data as BED from ENCODE
gunzip file.bed.gz 

#intersect with promoter coor
bedtools intersect -a SREBF2_promoters.bed -b SREBF2_ChIP-Seq.bed -wa -u > SREBF2_bound_genes.bed

#SREBF1 - A549 line
#SREBF2 - Hela S3

#genes bound to SREBF1 and 2 both
bedtools intersect -a SREBF1-2_all_promoters.bed -b SREBF1_ChIP-Seq.bed -u | bedtools intersect -a - -b SREBF2_ChIP-Seq.bed -u > SREBF1-2_all_bound_genes.bed

#genes only DE in both did not overlap with both peaks
#thus all DE for both were taken
#as genes from both 1 and 2 were used, subtract these from 1 only and 2 only
awk 'NR==FNR{genes[$4]; next} !($4 in genes)' SREBF1-2_all_bound_genes.bed SREBF1_bound_genes.bed > SREBF1_only_genes.bed
awk 'NR==FNR{genes[$4]; next} !($4 in genes)' SREBF1-2_all_bound_genes.bed SREBF2_bound_genes.bed > SREBF2_only_genes.bed

#get motifs from JASPAR for SREBF1,2 and SP1 -  newest versions
#2 motifs for SRE - compare using tomtom
tomtom SREBF2_MA0596.1.meme SREBF2_MA0828.3.meme
tomtom SREBF1_MA0595.1.meme SREBF1_MA0829.3.meme

#motifs are similar
#compare SREBF1 and 2 motifs
tomtom SREBF1_keep_MA0595.1.meme SREBF2_keep_MA0828.3.meme
#motifs similar

#combine SRE and SP1 motifs
cat SREBF1_keep_MA0595.1.meme SREBF2_keep_MA0828.3.meme > SRE_SP1.meme

#remove chr before no in promoter files as genome does not have those 
sed 's/^chr//' SREBF1_only_genes.bed > SREBF1_only_genes_nochr.bed
sed 's/^chr//' SREBF2_only_genes.bed > SREBF2_only_genes_nochr.bed
sed 's/^chr//' SREBF1-2_all_bound_genes.bed > SREBF1-2_all_bound_genes_nochr.bed

#extract promoter seq from coordinates
bedtools getfasta -fi /STORAGE/AC16_ribo_deplete_transcriptome/genome/Homo_sapiens.GRCh38.dna.primary_assembly.fa -bed  SREBF1_only_genes_nochr.bed -fo SREBF1_only_promoter_seq.fa -s -nameOnly
bedtools getfasta -fi /STORAGE/AC16_ribo_deplete_transcriptome/genome/Homo_sapiens.GRCh38.dna.primary_assembly.fa -bed  SREBF1-2_all_bound_genes_nochr.bed -fo SREBF1-2_both_promoter_seq.fa -s -nameOnly
bedtools getfasta -fi /STORAGE/AC16_ribo_deplete_transcriptome/genome/Homo_sapiens.GRCh38.dna.primary_assembly.fa -bed  SREBF2_only_genes_nochr.bed -fo SREBF2_only_promoter_seq.fa -s -nameOnly

#FIMO
fimo --oc fimo_out --thresh 1e-4 SRE_SP1.meme SREBF1_only_promoter_seq.fa
fimo --oc fimo_out --thresh 1e-4 SRE_SP1.meme SREBF2_only_promoter_seq.fa
fimo --oc fimo_out --thresh 1e-4 SRE_SP1.meme SREBF1-2_both_promoter_seq.fa

#novel motifs using STREME
#background to be expressed genes non-DE promoters

#background
#extract genes and keep only those non-significant in all 3 DE

#make bg_genes.txt

#get gene coor for those genes
grep -F -f bg_genes.txt genes.gtf > bg_gene_coor.gtf

#get their promoters (-2000 to +500)
awk 'BEGIN{OFS="\t"}
$3=="gene"{
 if($7=="+")
  print $1,$4-2001,$4+500,$10,".",$7;
 else
  print $1,$5-500,$5+2000,$10,".",$7;
}' bg_gene_coor.gtf > bg_gene_promoters.bed

#remove chr
sed 's/^chr//' bg_gene_promoters.bed > bg_genes_nochr.bed

#extract seq
bedtools getfasta -fi /STORAGE/AC16_ribo_deplete_transcriptome/genome/Homo_sapiens.GRCh38.dna.primary_assembly.fa -bed  bg_genes_nochr.bed -fo bg_genes_promoter_seq.fa -s -nameOnly

#remove duplicates
awk '/^>/ {if(seen[$0]++) skip=1; else skip=0} !skip' SREBF1_only_promoter_seq.fa > SREBF1_only_promoter_seq_nodup.fa
awk '/^>/ {if(seen[$0]++) skip=1; else skip=0} !skip' SREBF2_only_promoter_seq.fa > SREBF2_only_promoter_seq_nodup.fa
awk '/^>/ {if(seen[$0]++) skip=1; else skip=0} !skip' SREBF1-2_both_promoter_seq.fa > SREBF1-2_both_promoter_seq_nodup.fa
awk '/^>/ {if(seen[$0]++) skip=1; else skip=0} !skip' bg_genes_promoter_seq.fa > bg_genes_promoter_seq_nodup.fa

#use without bg in web version

#CLI for bg
conda install -c bioconda meme

#install XML::Simple 
cpan XML::Simple

#create markov model of bg to use streme
fasta-get-markov -dna bg_genes_promoter_seq_nodup.fa markov_bg_genes_promoter_seq_nodup.fa

#streme
streme --oc SREBF1_w_cont --p SREBF1_only_promoter_seq_nodup.fa --bfile markov_bg_genes_promoter_seq_nodup.fa --fimo skip
#fimo-skip to save time and --oc to overwrite directory
#fimo-skip was not done and --o for new directory

#final done
streme --oc SREBF1_w_cont --p SREBF1_only_promoter_seq_nodup.fa --bfile markov_bg_genes_promoter_seq_nodup.fa 
streme --oc SREBF2_w_cont --p SREBF2_only_promoter_seq_nodup.fa --bfile markov_bg_genes_promoter_seq_nodup.fa

#get no_control motifs and then see if control motifs are there #nope won't work like this
streme --o SREBF1_no_cont --p SREBF1_only_promoter_seq_nodup.fa --m conly_SRE/SRE_SP1.meme SREBF1_w_cont/combined.meme
streme --o SREBF2_no_cont --p SREBF2_only_promoter_seq_nodup.fa --m /STORAGE/NUPUR/only_SRE/SRE_SP1.meme SREBF2_w_cont/combined.meme
#streme --o SREBF1-2_no_cont --p SREBF1-2_both_promoter_seq_nodup.fa --m /STORAGE/NUPUR/only_SRE/SRE_SP1.meme SREBF1-2_w_cont/combined.meme
#done on web

#overlap SREBF1-2 no-cont and W_cont
tomtom SREBF1_no_cont/combined.meme SREBF1_w_cont/combined.meme

#final new codes
#jaspar motif from https://jaspar.elixir.no/download/data/2026/CORE/JASPAR2026_CORE_non-redundant_pfms_meme.txt
wget https://jaspar.elixir.no/download/data/2026/CORE/JASPAR2026_CORE_non-redundant_pfms_meme.txt -O jaspar.meme

#w_cont
streme --oc SREBF1_w_cont --p SREBF1_only_promoter_seq_nodup.fa --bfile markov_bg_genes_promoter_seq_nodup.fa 
streme --oc SREBF2_w_cont --p SREBF2_only_promoter_seq_nodup.fa --bfile markov_bg_genes_promoter_seq_nodup.fa 
streme --oc SREBF1-2_w_cont --p SREBF1-2_both_promoter_seq_nodup.fa --bfile markov_bg_genes_promoter_seq_nodup.fa 

#no_cont
streme --oc SREBF2_no_cont --p SREBF2_only_promoter_seq_nodup.fa 
streme --oc SREBF1_no_cont --p SREBF1_only_promoter_seq_nodup.fa 
streme --oc SREBF1-2_no_cont --p SREBF1-2_both_promoter_seq_nodup.fa 

#make a folder and save streme.txt outputs as meme
mkdir tom
cp SREBF1_w_cont/streme.txt tom/SREBF1_w_cont.meme

#find overlapping motifs between no_control vs control seq
tomtom SREBF1_no_cont/streme.txt SREBF1_w_cont/streme.txt
tomtom SREBF2_no_cont/streme.txt SREBF2_w_cont/streme.txt
tomtom SREBF1-2_no_cont/streme.txt SREBF1-2_w_cont/cstreme.txt

#motif selection
#didn't work
#motif_sel.sh script
chmod +x motif_sel.sh
./motif_sel.sh SREBF1_w_cont/streme.txt SREBF1_no_cont/streme.txt tom/tomtom_SREBF1/tomtom.tsv SREBF1_motifs
./motif_sel.sh SREBF2_w_cont/streme.txt SREBF2_no_cont/streme.txt tom/tomtom_SREBF2/tomtom.tsv SREBF2_motifs
./motif_sel.sh SREBF1-2_w_cont/streme.txt SREBF1-2_no_cont/streme.txt tom/tomtom_SREBF1-2/tomtom.tsv SREBF1-2_motifs

#plotting
#python script motif_plot.py
python3 motif-plot.py SREBF1_motifs/ranked.tsv
python3 motif-plot.py SREBF2_motifs/ranked.tsv
python3 motif-plot.py SREBF1-2_motifs/ranked.tsv
###

#new py script sel_motifs.py
./sel_motifs.py --tomtom tom/tomtom_SREBF1/tomtom.tsv --meme SREBF1_w_cont/streme.txt --out SREBF1_filtered.meme
./sel_motifs.py --tomtom tom/tomtom_SREBF2/tomtom.tsv --meme SREBF2_w_cont/streme.txt --out SREBF2_filtered.meme
./sel_motifs.py --tomtom tom/tomtom_SREBF1-2/tomtom.tsv --meme SREBF1-2_w_cont/streme.txt --out SREBF1-2_filtered.meme

#tomtom of final meme vs jaspar
tomtom SREBF1_filtered.meme jaspar.meme -o Jaspar_vs1
tomtom SREBF2_filtered.meme jaspar.meme -o Jaspar_vs2
tomtom SREBF1-2_filtered.meme jaspar.meme -o Jaspar_vs1-2

#check if those motifs are unique to one set
tomtom SREBF1_filtered.meme SREBF2_filtered.meme -o filter_1vs2
tomtom SREBF1_filtered.meme SREBF1-2_filtered.meme -o filter_1vs1-2
tomtom SREBF2_filtered.meme SREBF1-2_filtered.meme -o filter_2vs1-2

#unique filter - uni_motif.py
#output files unique_1.txt, _2.txt and 1-2.txt

#check with SP1-SREBF motif?
tomtom prom_seq/SREBF1_filtered.meme SRE_SP1.meme -o 1vsSRE
tomtom prom_seq/SREBF2_filtered.meme SRE_SP1.meme -o 2vsSRE
tomtom prom_seq/SREBF1-2_filtered.meme SRE_SP1.meme -o 1-2vsSRE

#fimo motif scan
fimo --o motif_scan_SREBF1 --bfile markov_bg_genes_promoter_seq_nodup.fa SREBF1_filtered.meme SREBF1_only_promoter_seq_nodup.fa 
fimo --o motif_scan_SREBF2 --bfile markov_bg_genes_promoter_seq_nodup.fa SREBF2_filtered.meme SREBF2_only_promoter_seq_nodup.fa 
fimo --o motif_scan_SREBF1-2 --bfile markov_bg_genes_promoter_seq_nodup.fa SREBF1-2_filtered.meme SREBF1_both_promoter_seq_nodup.fa

#co-occurence matrix and heatmap in python "motif scan.ipynb" in colab
#
#now get the motifs present in more than 80% seq and then scan for them in the genome
