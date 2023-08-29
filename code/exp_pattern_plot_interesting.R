pkgs <- c("fs", "futile.logger", "configr", "stringr", "ggpubr", "ggthemes",
          "jhtools", "glue", "ggsci", "patchwork", "tidyverse", "dplyr", "jhuanglabRNAseq")
for (pkg in pkgs){
  suppressPackageStartupMessages(library(pkg, character.only = T))
}
project <- "pancreatic"
dataset <- "qzhang"
species <- "human"
workdir <- glue("~/projects/{project}/analysis/{dataset}/{species}/rnaseq/figures/diff_exp") %>% checkdir()
setwd(workdir)
doc_dir <- glue("~/projects/{project}/docs/{dataset}/sampleinfo")
dat_fn <- "~/projects/pancreatic/analysis/qzhang/human/rnaseq/exp/tables/qzhang_human.csv"
dat_raw <- read_csv(dat_fn, show_col_types = FALSE)
group_color <- c("#d01910", "#aa5700", "#f48326", "#00ae4c", "#007ddb", "#8538d1")
genes_g1 <- c("FBXW12", "PRSS1", "PRSS2", "PRSS3", "SPINK1", "CFTR", "CTRC")
genes_g2 <- c("SOX14", "VSX2", "GDF2", "PDX1", "MNX1", "GATA6", "HNF1B")
genes_g3 <- c("NKX2-2", "SCG5", "CFC1")
genes_g4 <- c("ZEB2", "TNC", "CD209", "CCN1")
genes_g5 <- c("GJB2", "CD109", "KRT16")
genes_g6 <- c("GPR35", "KLF5", "SOX9", "MTMR11", "MST1R", "BCL2L15", "MYEOV", "SPIRE2")
genes_sela <- c("HOXA7", "RUNX3", "MLF1", "METTL3", "ARID1A", "ARID2", "PBRM1", "MEIS1", "NKX2-3", "FGFR1", "CD38", "SMAD4",
                "CD177", "TCF4", "TNN", "CEBPE", "IL17RE", "MEF2C", "KRAS", "GNAS", "CDKN2A", "TP53",
                "CDKN2B")
genes_selb <- c("HNF1A", "HNF4G", "GATA4", "ONECUT2", "NKX2-2", "KRT5", "KRT6A", "KRT14", "TP63",
                "FOXJ1", "DRC1", "CFAP54", "CST6", "VSIG", "ANXA10",  "LYZ", "SPINK4", "REG4",
                "BTLN8", "KRT20", "BRG1", "RNF43")
genes_selc <- c("PDX1", "MNX1", "HNF4G", "HNF4A", "HNF1B", "HNF1A", "FOXA2", "FOXA3", "HES1", "MUC5AC",
                "MUC1", "MUC2", "MUC6", "CTLA4", " PDCD1")
genes_seld <- c("CTDSPL2", "SCP4", "SOX2", "PTK6", "LAMP2A", "LAMP2B", "LAMP2C",
                "TSC1", "TSC2", "XBP1S", "IL6", "CCL2", "TNFA", "TLR7", "HRD1")

genes <- c(genes_g1, genes_g2, genes_g3, genes_g4, genes_g5, genes_g6, genes_seld,
           genes_sela, genes_selb, genes_selc) %>% unique()

#genes <- c("PCDH17", "CLEC12A",  "PCDH15", "STAP1", "AGAP1", "ERG", "DUX4", "RAG1", "RAG2")
fil <- genes  %in% dat_raw$gene_name
genes <- genes[fil]
metadata <- dat_doc <- glue("{doc_dir}/sampleinfo_{dataset}.xlsx") %>%
  readxl::read_excel(sheet = "sampeinfo") %>% dplyr::arrange(subgroups_index) %>%
  rename("groups" = "subgroups")
my_comparisons <- list( c("G1", "G2"), c("G3", "G4") , c("G5", "G6"))
per_page_num <- 4
numbers <- length(genes)
pdf("genes_violin_interesting.pdf", width = 8, height = 6)
p_list <- list()
for(i in seq(0, numbers-1, by = per_page_num)){
  for(j in 1:per_page_num){
    m <- i + j
    message(m, " : ", numbers)
    if(m > numbers){
      p_list[[j]] <- plot_spacer()
    }else{
      p <- gene_ggviolin_bygroup(dat_raw, metadata, genes[m], group_color) +
        stat_compare_means(comparisons = my_comparisons,  method = "t.test")
      p <- ggpar(p, legend = "none")
      p_list[[j]] <- p
    }
  }
  print(patchwork::wrap_plots(p_list, ncol = 2, nrow = 2) +
          plot_annotation(tag_levels = 'A'))
}
dev.off()

# gene boxplot
my_comparisons <- list( c("G1", "G2"), c("G3", "G4") , c("G5", "G6"))
per_page_num <- 4
numbers <- length(genes)
pdf("gene_boxplot_interesting.pdf", width = 8, height = 6)
p_list <- list()
for(i in seq(0, numbers-1, by = per_page_num)){
  for(j in 1:per_page_num){
    m <- i + j
    message(m, " : ", numbers)
    if(m > numbers){
      p_list[[j]] <- plot_spacer()
    }else{
      p <- gene_boxplot_bygroup(dat_raw, metadata, genes[m], group_color) +
        stat_compare_means(comparisons = my_comparisons,  method = "t.test")
      p <- ggpar(p, legend = "none")
      p_list[[j]] <- p
    }
  }
  print(patchwork::wrap_plots(p_list, ncol = 2, nrow = 2) +
          plot_annotation(tag_levels = 'A'))
}
dev.off()

p <- gene_ggviolin_bygroup(dat_raw, metadata, "PBRM1", group_color) +
  stat_compare_means(comparisons = my_comparisons,  method = "t.test")
p <- ggpar(p, legend = "none")
