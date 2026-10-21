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

