pkgs <- c("fs", "futile.logger", "configr", "stringr", "ggpubr", "ggthemes", "imcRtools",
          "jhtools", "glue", "ggsci", "patchwork", "tidyverse", "dplyr", "ggplot2")
for (pkg in pkgs){
  suppressPackageStartupMessages(library(pkg, character.only = T))
}

color <- c("#56b8b7", "#8cb2d4", "#6a76b6", "#e39d97","#e34e68")

merge_anno <- readRDS("/cluster/home/jhuang/projects/hyperion/analysis/qzhang/human/steinbock/rds/anno100kcells_fil35.rds") %>%
  colData() %>% as.data.frame() %>% dplyr::mutate(ROI_area = width_px*height_px) %>% group_by(sample_tiff_id) %>%
  dplyr::mutate(cell_num = n(), ROI_area = ROI_area) %>% mutate(cell_density = 100*cell_num/ROI_area)
merge_anno$stype[merge_anno$stype == "puncture"] <- unlist(lapply(strsplit(subset(merge_anno, stype=="puncture")$sample_id, "_"), '[', 2))
merge_anno$brief_anno <- gsub("\\s*\\([^\\)]+\\)\\s*$","", merge_anno$cell_type)

# This is down-sampled so the density is not high.
my_comparisons <- list( c("normal", "para"), c("normal", "puncture"), c("normal", "tumor"))
merge_anno$stype <- factor(merge_anno$stype, levels=c("normal", "paracancerous", "pdac", "liver", "tumor"))

ggplot(data = merge_anno, aes(x=stype, y=cell_density, fill = stype)) + geom_boxplot() +
scale_fill_manual(values=color) + theme_minimal() + facet_wrap(~brief_anno) +
theme(axis.title.x=element_blank(), axis.text.x=element_blank(), axis.ticks.x=element_blank()) +
ylab(expression(Cells~per~mm^2~(x100))) + stat_compare_means(label = "p.signif", method = "t.test",
                                                             ref.group = "normal")

ggsave("/cluster/home/flora_jh/projects/hyperion/output/rujia/dens_stype_per_celltype.pdf", width = 10, height = 10)

markers <- c("Vista", "Arginase_1", "B7_H4", "LAG_3", "PD1", "PD_L1", "Ki67", "Caspase3")
rds <- readRDS("/cluster/home/jhuang/projects/hyperion/analysis/qzhang/human/steinbock/rds/anno100kcells_fil35.rds")
intensity <- t(assay(rds, "logcounts")) %>% as.data.frame()
sample_tiff_id <- unlist(lapply(strsplit(rownames(intensity), "@"), '[', 2)) %>% as.vector()
intensity$sample_tiff_id <- sample_tiff_id
intensity <- intensity %>% dplyr::select(c(markers, 'sample_tiff_id'))
narrow_merge_anno <- merge_anno %>% dplyr::select(sample_tiff_id, stype)
intensity <- left_join(intensity, narrow_merge_anno, by = "sample_tiff_id")
violin_df <- pivot_longer(intensity, cols = markers, names_to = "markers", values_to = "intensity")

ggplot(violin_df, aes(x=stype, y=intensity)) + geom_violin() + facet_wrap(~markers) +
  scale_fill_manual(values=color) + theme_minimal() + theme(axis.title.x=element_blank(),
  axis.text.x=element_blank(), axis.ticks.x=element_blank()) + ylab(intensity)



  stat_compare_means(label = "p.signif", method = "t.test", ref.group = "normal")



ggplot(intensity, aes(x=dose, y=len)) + geom_violin()

