pkgs <- c("fs", "futile.logger", "configr", "stringr", "ggpubr", "ggthemes",
          "jhtools", "glue", "ggsci", "patchwork", "tidyverse", "dplyr")
for (pkg in pkgs){
  suppressPackageStartupMessages(library(pkg, character.only = T))
}

score <- readRDS("/cluster/home/yjliu_jh/share/scores.rds")
score$Type[score$Type == "paracancerous"] <- "para"
score$Type[score$Type == "puncture_liver"] <- "liver"
score$Type[score$Type == "puncture_pdac"] <- "pdac"

score$Type <- factor(score$Type, levels = c("normal", "para", "liver", "pdac", "tumor"))
colors <- show_me_the_colors("hyperion")
my_comparisons <- list( c("normal", "para"), c("normal", "liver"), c("normal", "pdac"),
                        c("normal", "tumor"))
p <- ggboxplot(score, x = "Type", y = "SparseScore", fill = c("#56b8b7",
      "#8cb2d4", "#6a76b6", "#e39d97", "#e34e68")) + stat_compare_means(label = "p.signif", comparisons = my_comparisons)
ggpar(p, xlab = "", ylab = "Sparse Score")
ggsave("/cluster/home/flora_jh/projects/hyperion/output/liuyongjing/sparsescore_box.pdf",
       width = 3, height = 2)

fibscore <- readRDS("/cluster/home/yjliu_jh/share/fibscore.rds")
fibscore$Type[fibscore$Type == "paracancerous"] <- "para"
fibscore$Type[fibscore$Type == "puncture_liver"] <- "liver"
fibscore$Type[fibscore$Type == "puncture_pdac"] <- "pdac"

fibscore$Type <- factor(fibscore$Type, levels = c("normal", "para", "liver", "pdac", "tumor"))
fibscore <- fibscore[fibscore$score_all <= 10,]
p <- ggboxplot(fibscore, x = "Type", y = "score_all", fill = c("#56b8b7", "#8cb2d4",
                                                              "#6a76b6", "#e39d97", "#e34e68")) +
  stat_compare_means(label = "p.signif", comparisons = my_comparisons)
ggpar(p, xlab = "", ylab = "Fibrosis Score", ylim = c(-2, 8))
ggsave("/cluster/home/flora_jh/projects/hyperion/output/liuyongjing/fibscore_box.svg",
       width = 3, height = 2)

