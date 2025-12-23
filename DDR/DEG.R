# Differential Gene Expression analysis of count matrices using DESeq2 package

#package install using Bioconductor
if (!require("BiocManager", quietly = TRUE)) install.packages("BiocManager")
BiocManager::install("DESeq2")

#load the library
library(DESeq2)

#count matrix input
sampleFiles<- c("count1.counts","count2.counts",...) #... represents other files
sampleNames <- c("untreated_1","untreated_rep2",...)
sampleCondition <- c("untreated","untreated",...)
sampleTable <- data.frame(sampleName = sampleNames, fileName = sampleFiles, condition = sampleCondition)
treatments = c("untreated","treated")
ddsHTSeq <- DESeqDataSetFromHTSeqCount(sampleTable = sampleTable,design= ~condition)
colData(ddsHTSeq)$condition <- factor(colData(ddsHTSeq)$condition, levels = treatments)

# pre-filtering data to only keep genes with more than 10 counts across the samples
smallestGroupSize <- 4
keep <- rowSums(counts(ddsHTSeq) >= 10) >= smallestGroupSize
ddsHTSeq <- ddsHTSeq[keep,]

#DEG analysis
dds <- DESeq(ddsHTSeq)
res <- results(dds)
resdata <- merge(as.data.frame(res), as.data.frame(counts(dds,normalized =TRUE)), by = 'row.names', sort = FALSE)
names(resdata)[1] <- 'gene'

#saving the output file as csv
outprefix <- "DESeq2_out"
write.csv(resdata, file = paste0(outprefix, "-results.csv"))


