pkgs <- c("fs", "futile.logger", "configr", "stringr", "ggpubr", "ggthemes", "imcRtools",
          "jhtools", "glue", "ggsci", "patchwork", "tidyverse", "dplyr", "CATALYST",
          "cytomapper", "ggraph", "ggplot2", "Rtsne", "jhuanglabHyperion")
for (pkg in pkgs){
  suppressPackageStartupMessages(library(pkg, character.only = T))
}



panel_fn <- glue("/cluster/home/jhuang/projects/{project}/data/{dataset}/{species}/hyperion/panel.csv")
analysis_dir <- glue("/cluster/home/jhuang/projects/{project}/analysis/{dataset}/{species}/steinbock")

punc_samples <- dir_ls("/cluster/home/jhuang/projects/hyperion/analysis/qzhang/human/steinbock/puncture/measure") %>% path_file()
liver_samples <- punc_samples[str_detect(punc_samples, "liver")][-c(3,16)]
pdac_samples <- punc_samples[str_detect(punc_samples, "pdac")][-30]
normal_samples <- dir_ls("/cluster/home/jhuang/projects/hyperion/analysis/qzhang/human/steinbock/normal/measure") %>% path_file()
para_samples <- dir_ls("/cluster/home/jhuang/projects/hyperion/analysis/qzhang/human/steinbock/paracancerous/measure") %>% path_file()
tumor_samples <- dir_ls("/cluster/home/jhuang/projects/hyperion/analysis/qzhang/human/steinbock/tumor/measure") %>% path_file()
tumor_samples <- tumor_samples[!(tumor_samples %in% c("p128_pdac", "p15_pdac", "p167_pdac", "p198_pdac",
                                                      "p223_pdac", "p237_pdac", "p3_pdac"))]

liver_sce <- 1:length(liver_samples) %>%
  map( ~ read_steinbock(glue("{analysis_dir}/puncture/measure/{liver_samples[.x]}"), return_as = "sce"))
pdac_sce <-  1:length(pdac_samples) %>%
  map( ~ read_steinbock(glue("{analysis_dir}/puncture/measure/{pdac_samples[.x]}"), return_as = "sce"))
normal_sce <- 1:length(normal_samples) %>%
  map( ~ read_steinbock(glue("{analysis_dir}/normal/measure/{normal_samples[.x]}"), return_as = "sce"))
para_sce <- 1:length(para_samples) %>%
  map( ~ read_steinbock(glue("{analysis_dir}/paracancerous/measure/{para_samples[.x]}"), return_as = "sce"))
tumor_sce <- 1:length(tumor_samples) %>%
  map( ~ read_steinbock(glue("{analysis_dir}/tumor/measure/{tumor_samples[.x]}"), return_as = "sce"))

stypes <- c("normal", "para", "liver", "pdac", "tumor")
samples <- c(normal_samples, para_samples, liver_samples, pdac_samples, tumor_samples)
sces <- c(normal_sce, para_sce, liver_sce, pdac_sce, tumor_sce)

# Check which samples have less than 2000 cells if performing downsample == 2000 cells.
#for (i in 1:length(sces)){
  #if(ncol(sces[[i]]) < 2000){
    #print(i)
  #}
#}
# i = 124, 160, 168, 185, 198, 280

# Do not downsample.
for (i in 1:length(sces)){
  sces[[i]] <- sces[[i]] %>% filter_makers()
  sces[[i]] <- init_metadata(sces[[i]], samples[i], stype = rep(stypes, c(30, 31, 9, 50, 175))[i])
}

#for (i in 2:length(sces)){
  #if (!(identical(rownames(sces[[1]]), rownames(sces[[i]])))) {
   # print(i)
 # }
#}
# i = 124, 160, 168, 185, 198, 280
colData(sces[[124]])$sample_id <- "p103_pdac"
colData(sces[[160]])$sample_id <- "p150_pdac"
colData(sces[[168]])$sample_id <- "p162_pdac"
colData(sces[[185]])$sample_id <- "p180_pdac"
colData(sces[[198]])$sample_id <- "p197_pdac"
colData(sces[[280]])$sample_id <- "p7_pdac"

#for (i in c(124, 160, 168, 185, 198, 280)){
#sces[[i]] <- sces[[i]] %>% filter_makers()
#sces[[i]] <- init_metadata(sces[[i]], samples[i], stype = rep(stypes, c(30, 31, 9, 50, 175))[i])
#}


# Extract colData of sces to speed up.
coldata <- 1:length(sces) %>% map(~as.data.frame(colData(sces[[.x]])))
coldata_merge <- Reduce(rbind, coldata)
#saveRDS(coldata_merge, file = "/cluster/home/flora_jh/projects/hyperion/output/coldata_merge.rds")
coldata_merge <- readRDS("/cluster/home/flora_jh/projects/hyperion/output/coldata_merge.rds")
coldata_merge <- coldata_merge %>% dplyr::mutate(ROI_area = width_px*height_px) %>% group_by(sample_tiff_id) %>%
  dplyr::mutate(cell_num = n(), ROI_area = ROI_area) %>% mutate(cell_density = 100*cell_num/ROI_area)
coldata_merge$log2area <- log2(coldata_merge$area)
coldata_merge$area_scale <- (coldata_merge$area - min(coldata_merge$area))/(max(coldata_merge$area)-min(coldata_merge$area))
coldata_merge <- coldata_merge %>% dplyr::arrange(area)

# Keep samples with 10%~90% areas.
down <- round(nrow(coldata_merge) * 0.1)
up <- round(nrow(coldata_merge) * 0.9)
coldata_merge_fil <- coldata_merge[down:up, ]
filtered_areas1 <- unique(coldata_merge[-c(down:up), ]$area)

# Find extreme big cells
for (area in filtered_areas1[filtered_areas1 > 600]){
  print(coldata_merge[coldata_merge$area == area,]$sample_id)
}
# "p145_liver", "p117_pdac", "p239_pdac", "p212_para", "p117_pdac"

# Keep samples with mean+-2*sd(area).
down <- mean(coldata_merge$log2area) - 2*sd(coldata_merge$log2area)
up <- mean(coldata_merge$log2area) + 2*sd(coldata_merge$log2area)
coldata_merge_fil2 <- coldata_merge[coldata_merge$log2area < up & coldata_merge$log2area > down,]

# ggboxplot
# colors <- c("#8CB2D5","#54B9B6","#6D76B5","#E19D97","#DF5067")

my_comparisons <- list( c("normal", "para"), c("normal", "liver"), c("normal", "pdac"),
                        c("normal", "tumor"))
#coldata_merge_fil$stype <- factor(coldata_merge_fil$stype, levels = c("normal", "para", "liver", "pdac", "tumor"))
coldata_merge_fil2$stype <- factor(coldata_merge_fil2$stype, levels = c("normal", "para", "liver", "pdac", "tumor"))

# Mean±2*SD

ggboxplot(coldata_merge_fil2, x = "stype", y = "log2area", fill = 'stype', xlab = "",
                        ylab = expression(log[2]*area), palette =  c("#56b8b7", "#8cb2d4",
                                                                 "#6a76b6", "#e39d97", "#e34e68")) +
  rremove("legend") + stat_compare_means(label = "p.signif", comparisons = my_comparisons)
ggsave("/cluster/home/flora_jh/projects/hyperion/output/area_ecce_dens/area_stype2.pdf",
       width = 3, height = 2)
ggboxplot(coldata_merge_fil2, x = "stype", y = "eccentricity", fill = 'stype', xlab = "",
                        ylab = "eccentricity", palette =  c("#56b8b7", "#8cb2d4",
                                                                      "#6a76b6", "#e39d97", "#e34e68")) +
  rremove("legend") + stat_compare_means(label = "p.signif", comparisons = my_comparisons)
ggsave("/cluster/home/flora_jh/projects/hyperion/output/area_ecce_dens/ecce_stype2.pdf",
       width = 3, height = 2)
ggboxplot(coldata_merge_fil2, x = "stype", y = "cell_density", fill = 'stype', xlab = "",
                        ylab = expression(Cells~per~mm^2~(x100)), palette =  c("#56b8b7", "#8cb2d4",
                                                                               "#6a76b6", "#e39d97", "#e34e68")) +
  rremove("legend") + stat_compare_means(label = "p.signif", comparisons = my_comparisons)
ggsave("/cluster/home/flora_jh/projects/hyperion/output/area_ecce_dens/dens_stype2.pdf",
       width = 3, height = 2)
ggdensity(coldata_merge_fil2, x = "area", add = "mean", rug = T, color = "stype",
          palette =  c("#56b8b7", "#8cb2d4", "#6a76b6", "#e39d97", "#e34e68"))
ggsave("/cluster/home/flora_jh/projects/hyperion/output/area_ecce_dens/area_density2.pdf",
       width = 3, height = 2)
p <- ggdensity(coldata_merge_fil2, x = "log2area", add = "mean", rug = T, color = "stype",
               palette =  c("#56b8b7", "#8cb2d4", "#6a76b6", "#e39d97", "#e34e68"))
ggpar(p, legend = "right", font.legend = 8)
ggsave("/cluster/home/flora_jh/projects/hyperion/output/area_ecce_dens/log2area_density2.pdf",
       width = 3, height = 2)

# 10%-90%
ggboxplot(coldata_merge_fil, x = "stype", y = "log2area", fill = 'stype', xlab = "",
          ylab = "log2(area)", palette = colors) + rremove("legend") + stat_compare_means(label = "p.signif", comparisons = my_comparisons)
ggsave("/cluster/home/flora_jh/projects/hyperion/output/area_ecce_dens/area_stype.pdf",
       width = 6, height = 4)
ggboxplot(coldata_merge_fil, x = "stype", y = "eccentricity", fill = 'stype', xlab = "",
          ylab = "eccentricity", palette = colors) + rremove("legend") + stat_compare_means(label = "p.signif", comparisons = my_comparisons)
ggsave("/cluster/home/flora_jh/projects/hyperion/output/area_ecce_dens/ecce_stype.pdf",
       width = 6, height = 4)
ggboxplot(coldata_merge_fil, x = "stype", y = "cell_density", fill = 'stype', xlab = "",
          ylab = "cell density", palette = colors) + rremove("legend") + stat_compare_means(label = "p.signif", comparisons = my_comparisons)
ggsave("/cluster/home/flora_jh/projects/hyperion/output/area_ecce_dens/dens_stype.pdf",
       width = 6, height = 4)
ggdensity(coldata_merge_fil, x = "area", add = "mean", rug = T, color = "stype",
          palette = colors)
ggsave("/cluster/home/flora_jh/projects/hyperion/output/area_ecce_dens/area_density.pdf",
       width = 6, height = 4)
ggdensity(coldata_merge_fil, x = "log2area", add = "mean", rug = T, color = "stype",
          palette = colors)
ggsave("/cluster/home/flora_jh/projects/hyperion/output/area_ecce_dens/log2area_density.pdf",
       width = 6, height = 4)


