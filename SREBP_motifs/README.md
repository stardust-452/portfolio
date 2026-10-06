## motif discovery and comparison for SREBP1 and SREBP2 [![Ongoing](https://img.shields.io/badge/Ongoing-1E850F.svg)]()

[![ClusterProfiler](https://img.shields.io/badge/ClusterProfiler-Functional%20Enrichment-9B59B6.svg)]()
[![FIMO](https://img.shields.io/badge/FIMO-Motif%20Scanning-E67E22.svg)]()
[![STREME](https://img.shields.io/badge/STREME-Motif%20Discovery-E74C3C.svg)]()
[![Tomtom](https://img.shields.io/badge/Tomtom-Motif%20Comparison-194209.svg)]()
[![R](https://img.shields.io/badge/R-Statistical%20Computing-276DC3.svg)]()


### Research question: Is there a sequence that determines whether a gene is controlled by the sterol regulatory element binding proteins, SREBP1 or SREBP2?
While the motifs that SREBP proteins bind to are known but how are some genes controlled by SREBP1 and some by SREBP2, given that their known motifs are similar, is not known yet. This project aims to find the subsequences/motifs that determine the control and then predict the genes controlled by SREBP1,
SREBP2, or both SREBP1 and 2.

- Analyzed public available SREBP 1 & 2 knockout RNA-seq data (n=9)
- Performed Over representation analysis (ORA) in R using ClusterProfiler.
- Extracted peaks for SREBP 1 & 2  ChIP-Seq data from ENCODE and intersect the positions with the promoters of DEGs from the RNA-seq analysis and split them into groups based on peak binding.
- Scanned the promoters for SREBP motifs using FIMO.
- Used STREME (from MEME suite) for novel motif discovery and compared the novel motifs with existing motifs from the JASPAR database using Tomtom.


This project is a part of my master's thesis at IISER TVM, India.
