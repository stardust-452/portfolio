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
