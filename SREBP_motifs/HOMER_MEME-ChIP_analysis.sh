#HOMER analysis for SREBF project
#used SREBF1_ChIP-Seq.bed files 
#downloaded IDR peaks from ENCODE

#HOMER installation
conda create -n homer_env -c conda-forge -c bioconda homer -y

#activate
conda activate homer_env

#install hg38 genome
find "$CONDA_PREFIX" -name configureHomer.pl
perl "$CONDA_PREFIX/share/homer/configureHomer.pl" -install hg38 #replace the path with original

#annotate using HOMER
annotatePeaks.pl SREBF1_ChIP-Seq.bed hg38 > SREBF1_annot.txt 
annotatePeaks.pl SREBF2_ChIP-Seq.bed hg38 > SREBF2_annot.txt 

#center the peaks around summit (300bp window)
./peak_center.sh SREBF1_ChIP-Seq.bed
./peak_center.sh SREBF2_ChIP-Seq.bed

#motif discovery using HOMER
findMotifsGenome.pl SREBF1_ChIP-Seq_centered_300bp.bed hg38 motif_dicovery_SREBF1_homer/ -size 300 -mask
findMotifsGenome.pl SREBF2_ChIP-Seq_centered_300bp.bed hg38 motif_dicovery_SREBF2_homer/ -size 300 -mask

#MEME-ChIP
#dir MEME-ChIP_analysis

#Center peaks to 500bp
./peak_center_meme.sh /STORAGE/NUPUR/SREBF_project/HOMER_analysis/SREBF1_ChIP-Seq.bed 
./peak_center_meme.sh /STORAGE/NUPUR/SREBF_project/HOMER_analysis/SREBF2_ChIP-Seq.bed 

#extract seq as fasta
homerTools extract SREBF2_ChIP-Seq_centered_500bp.bed /home/iisertvm/anaconda3/envs/homer_env/share/homer/data/genomes/hg38 -fa > SREBF2_ChIP_500bp_fasta.fa
homerTools extract SREBF1_ChIP-Seq_centered_500bp.bed /home/iisertvm/anaconda3/envs/homer_env/share/homer/data/genomes/hg38 -fa > SREBF1_ChIP_500bp_fasta.fa

#resolve the path issue with perl
export PERL5LIB="$CONDA_PREFIX/lib/perl5/site_perl:$CONDA_PREFIX/lib/perl5/5.32/site_perl"

#check if treebuilder is working
perl -MHTML::TreeBuilder -e 'print "HTML::TreeBuilder working successfully!\n"'

#meme-chip
meme-chip SREBF1_ChIP_500bp_fasta.fa -oc motif_discovery_SREBF1_meme
meme-chip SREBF2_ChIP_500bp_fasta.fa -oc motif_discovery_SREBF2_meme
