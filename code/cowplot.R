pkgs <- c("fs", "futile.logger", "configr", "stringr", "ggpubr", "ggthemes",
          "jhtools", "glue", "ggsci", "patchwork", "tidyverse", "dplyr", "cowplot")
for (pkg in pkgs){
  suppressPackageStartupMessages(library(pkg, character.only = T))
}

coldata_merge <- readRDS("/cluster/home/flora_jh/projects/hyperion/output/coldata_merge.rds")
coldata_merge <- coldata_merge %>% dplyr::mutate(ROI_area = width_px*height_px) %>% group_by(sample_tiff_id) %>%
  dplyr::mutate(cell_num = n(), ROI_area = ROI_area) %>% mutate(cell_density = 100*cell_num/ROI_area)
coldata_merge$log2area <- log2(coldata_merge$area)
coldata_merge$area_scale <- (coldata_merge$area - min(coldata_merge$area))/(max(coldata_merge$area)-min(coldata_merge$area))
coldata_merge <- coldata_merge %>% dplyr::arrange(area)
down <- mean(coldata_merge$log2area) - 2*sd(coldata_merge$log2area)
up <- mean(coldata_merge$log2area) + 2*sd(coldata_merge$log2area)
coldata_merge_fil2 <- coldata_merge[coldata_merge$log2area < up & coldata_merge$log2area > down,]
my_comparisons <- list( c("normal", "para"), c("normal", "liver"), c("normal", "pdac"),
                        c("normal", "tumor"))
coldata_merge_fil2$stype <- factor(coldata_merge_fil2$stype, levels = c("normal", "para", "liver", "pdac", "tumor"))
p1 <- ggboxplot(coldata_merge_fil2, x = "stype", y = "log2area", fill = 'stype', xlab = "",
                ylab = expression(log[2]*area), palette =  c("#56b8b7", "#8cb2d4",
                                                             "#6a76b6", "#e39d97", "#e34e68")) +
  rremove("legend") + stat_compare_means(label = "p.signif", comparisons = my_comparisons)

p2 <- ggboxplot(coldata_merge_fil2, x = "stype", y = "eccentricity", fill = 'stype', xlab = "",
                ylab = "eccentricity", palette =  c("#56b8b7", "#8cb2d4",
                                                    "#6a76b6", "#e39d97", "#e34e68")) +
  rremove("legend") + stat_compare_means(label = "p.signif", comparisons = my_comparisons)

p3 <- ggboxplot(coldata_merge_fil2, x = "stype", y = "cell_density", fill = 'stype', xlab = "",
                ylab = expression(Cells~per~mm^2~(x100)), palette =  c("#56b8b7", "#8cb2d4",
                                                                       "#6a76b6", "#e39d97", "#e34e68")) +
  rremove("legend") + stat_compare_means(label = "p.signif", comparisons = my_comparisons)

p4 <- ggdensity(coldata_merge_fil2, x = "log2area", add = "mean", rug = T, color = "stype",
                     palette =  c("#56b8b7", "#8cb2d4", "#6a76b6", "#e39d97", "#e34e68"))
p4 <- ggpar(p4, legend = "right", font.legend = 8)

score <- readRDS("/cluster/home/yjliu_jh/share/scores.rds")
score$Type[score$Type == "paracancerous"] <- "para"
score$Type[score$Type == "puncture_liver"] <- "liver"
score$Type[score$Type == "puncture_pdac"] <- "pdac"

score$Type <- factor(score$Type, levels = c("normal", "para", "liver", "pdac", "tumor"))
colors <- show_me_the_colors("hyperion")
my_comparisons <- list( c("normal", "para"), c("normal", "liver"), c("normal", "pdac"),
                        c("normal", "tumor"))
p5 <- ggboxplot(score, x = "Type", y = "SparseScore", fill = c("#56b8b7", "#8cb2d4",
  "#6a76b6", "#e39d97", "#e34e68")) + stat_compare_means(label = "p.signif", comparisons = my_comparisons)
p5 <- ggpar(p5, xlab = "", ylab = "Sparse Score")

fibscore <- readRDS("/cluster/home/yjliu_jh/share/fibscore.rds")
fibscore$Type[fibscore$Type == "paracancerous"] <- "para"
fibscore$Type[fibscore$Type == "puncture_liver"] <- "liver"
fibscore$Type[fibscore$Type == "puncture_pdac"] <- "pdac"

fibscore$Type <- factor(fibscore$Type, levels = c("normal", "para", "liver", "pdac", "tumor"))
fibscore <- fibscore[fibscore$score_all <= 10,]
p6 <- ggboxplot(fibscore, x = "Type", y = "score_all", fill = c("#56b8b7", "#8cb2d4",
                                                               "#6a76b6", "#e39d97", "#e34e68")) +
  stat_compare_means(label = "p.signif", comparisons = my_comparisons)
p6 <- ggpar(p6, xlab = "", ylab = "Fibrosis Score", ylim = c(-2, 8))

plot_grid(p1, p2, p3, p5, p6, p4, ncol = 3)
ggsave("/cluster/home/flora_jh/projects/hyperion/output/cowplot.svg", width = 9, height = 4)
