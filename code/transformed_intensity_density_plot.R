pkgs <- c("fs", "futile.logger", "configr", "stringr", "ggpubr", "ggthemes",
          "jhtools", "glue", "ggsci", "patchwork", "tidyverse", "dplyr", "flowCore",
          "Rcpp", "cytofkit", "igraph", "ggplot2", "ggthemes", "ggthemes", "Rtsne",
          "cytofexplorer", "Rmisc", "stringi", "RColorBrewer", "FlowSOM", "reshape2",
          "pheatmap", "uwot", "scales", "imcExperiment", "ComplexHeatmap")
for (pkg in pkgs){
  suppressPackageStartupMessages(library(pkg, character.only = T))
}
workdir <- glue("/cluster/home/zrj_jh/projects/hyperion/data/zq")
setwd(workdir)

source(glue("/cluster/home/zrj_jh/projects/hyperion/code/FlowSOM_4_metaClustering.R"))

# cluster_color <- c("#F08080", "#1E90FF", "#47A890", "#FFFF00", "#808000", "#B85CB8",
#                    "#FA8072", "#7B68EE", "#FFB5C5", "#D1EEEE", "#A0522D", "#CDC5BF",
#                    "#87CEEB", "#DC143C", "#0000FF", "#20B2AA", "#FFA500", "#9370DB",
#                    "#F0E68C", "#FFFFE0", "#EE82EE", "#FF6347", "#6A5ACD", "#9932CC")

cluster_color <- c("#DC143C","#0000FF","#20B2AA","#FFA500","#9370DB","#98FB98","#F08080","#1E90FF","#7CFC00","#FFFF00",
                   "#808000","#FF00FF","#FA8072","#7B68EE","#9400D3","#800080","#A0522D","#D2B48C","#D2691E","#87CEEB",
                   "#40E0D0","#5F9EA0","#FF1493","#0000CD","#008B8B","#FFE4B5","#8A2BE2","#228B22","#E9967A","#4682B4",
                   "#32CD32","#F0E68C","#FFFFE0","#EE82EE","#DEB887","#FF6347")


df_para <- dir_ls(glue("paracancerous/measure"), glob = "*/intensities/*.csv", recurse = T) %>%
  read_csv(col_select = -c("80ArAr", "120Sn", "127I", "134Xe", "138Ba", "DNA1", "DNA2", "Histone3", "208Pb"), id = "sample_id")
df_tumor <- dir_ls(glue("tumor/measure"), glob = "*/intensities/*.csv", recurse = T) %>%
  read_csv(col_select = -c("80ArAr", "120Sn", "127I", "134Xe", "138Ba", "DNA1", "DNA2", "Histone3", "208Pb"), id = "sample_id")
df_normal <- dir_ls(glue("normal/measure"), glob = "*/intensities/*.csv", recurse = T) %>%
  read_csv(col_select = -c("80ArAr", "120Sn", "127I", "134Xe", "138Ba", "DNA1", "DNA2", "Histone3", "208Pb"), id = "sample_id")
df_liver <- dir_ls(glue("puncture/measure"), glob = "*_liver/intensities/*.csv", recurse = T) %>%
  read_csv(col_select = -c("80ArAr", "120Sn", "127I", "134Xe", "138Ba", "DNA1", "DNA2", "Histone3", "208Pb"), id = "sample_id")
df_pdac <- dir_ls("puncture/measure/", glob = "*_pdac/intensities/*.csv", recurse = T) %>%
  read_csv(col_select = -c("80ArAr", "120Sn", "127I", "134Xe", "138Ba", "DNA1", "DNA2", "Histone3", "208Pb"), id = "sample_id")

set.seed(2021)
df_para <- df_para %>% mutate(sample_id = str_replace_all(sample_id , c("paracancerous/measure/" = "", "intensities/" = "", "/" = "_", ".csv" = "", "_LTB" = "@LTB"))) %>%
  mutate(rowname = str_c(sample_id, Object, sep = "@")) %>% as.data.frame()
df_para_downsample <- df_para[sample(nrow(df_para), 20000), ]
df_tumor <- df_tumor %>% mutate(sample_id = str_replace_all(sample_id , c("tumor/measure/" = "", "intensities/" = "", "/" = "_", ".csv" = "", "_LTB" = "@LTB"))) %>%
  mutate(rowname = str_c(sample_id, Object, sep = "@")) %>% as.data.frame()
df_tumor_downsample <- df_tumor[sample(nrow(df_tumor), 20000), ]
df_normal <- df_normal %>% mutate(sample_id = str_replace_all(sample_id , c("normal/measure/" = "", "intensities/" = "", "/" = "_", ".csv" = "", "_LTB" = "@LTB"))) %>%
  mutate(rowname = str_c(sample_id, Object, sep = "@")) %>% as.data.frame()
df_normal_downsample <- df_normal[sample(nrow(df_normal), 20000), ]
df_liver <- df_liver %>% mutate(sample_id = str_replace_all(sample_id , c("puncture/measure/" = "", "intensities/" = "", "/" = "_", ".csv" = "", "_LTB" = "@LTB"))) %>%
  mutate(rowname = str_c(sample_id, Object, sep = "@")) %>% as.data.frame()
df_liver_downsample <- df_liver[sample(nrow(df_liver), 20000), ]
df_pdac <- df_pdac %>% mutate(sample_id = str_replace_all(sample_id , c("puncture/measure/" = "", "intensities/" = "", "/" = "_", ".csv" = "", "_LTB" = "@LTB"))) %>%
  mutate(rowname = str_c(sample_id, Object, sep = "@")) %>% as.data.frame()
df_pdac_downsample <- df_pdac[sample(nrow(df_pdac), 20000), ]
row.names(df_para_downsample) <- df_para_downsample$rowname
row.names(df_tumor_downsample) <- df_tumor_downsample$rowname
row.names(df_normal_downsample) <- df_normal_downsample$rowname
row.names(df_liver_downsample) <- df_liver_downsample$rowname
row.names(df_pdac_downsample) <- df_pdac_downsample$rowname
cb_para_tumor <- rbind(df_para_downsample, df_tumor_downsample, df_normal_downsample)
cb_liver_pdac <- rbind(df_liver_downsample, df_pdac_downsample)

###group dataframe
grouplist1 <- dir_ls(glue("paracancerous/measure"), glob = "*/intensities/*.csv", recurse = T) %>%
  append(dir_ls(glue("tumor/measure"), glob = "*/intensities/*.csv", recurse = T)) %>%
  append(dir_ls(glue("normal/measure"), glob = "*/intensities/*.csv", recurse = T)) %>%
  str_replace_all(c(".csv" = "")) %>% as.data.frame() %>% setNames("file_path") %>%
  separate(file_path, c("a", "b", "c", "d", "e"), sep = "/")
groups1 <- data.frame(File_ID = glue("{grouplist1$e}"), Patient_ID = glue("{grouplist1$c}"),
                      Treatment = glue("{grouplist1$a}"))

grouplist2 <- dir_ls("puncture/measure", glob = "*intensities/*.csv", recurse = T) %>%
  str_replace_all(c(".csv" = "")) %>% as.data.frame() %>% setNames("file_path") %>%
  separate(file_path, c("a", "b", "c", "d", "e"), sep = "/")
groups2 <- data.frame(File_ID = glue("{grouplist2$e}"), Patient_ID = glue("{grouplist2$c}"),
                      Treatment = str_split(glue("{grouplist2$c}"), "_",simplify = TRUE)[,2])


###transform
simpleAsinh <- function(value, cofactor = 5){
  value <- value / cofactor
  value <- asinh(value)
  return(value)
}

simpleAsinh_Zero_Max<-function(value, cofactor = 5, b=0) {
  value <- value / cofactor
  value <- asinh(value)
  if(!all(value==0)){
    value<-value/max(value,b)
  }
  return(value)
}

imcAsinh <- function (value, cofactor = 5){
  value <- value - 0.05
  loID <- which(value <= 0)
  if (length(loID) > 0) {
    value[loID] <- rnorm(length(loID), mean = 0, sd = 0.01)
  }
  value <- value/cofactor
  value <- asinh(value)
  return(value)
}
cb_df_trans1 <- apply(cb_para_tumor[, !colnames(cb_para_tumor) %in% c("rowname", "Object", "sample_id")], 2, imcAsinh) %>%
  as.data.frame()
cb_df_trans2 <- apply(cb_liver_pdac[, !colnames(cb_liver_pdac) %in% c("rowname", "Object", "sample_id")], 2, imcAsinh) %>%
  as.data.frame()

cb_df_trans1_longer <- cb_df_trans1 %>% pivot_longer(cols = everything(),names_to = "marker", values_to = "intensity")
cb_df_trans2_longer <- cb_df_trans2 %>% pivot_longer(cols = everything(),names_to = "marker", values_to = "intensity")
markers <- unique(cb_df_trans1_longer$marker)
page_num <- round(length(markers)/4)

# Transform 1
for (i in 1:page_num){
  print(i)
  selected <- markers[(4*(i-1)+1):(4*i)]
  print(selected)
  p <- ggdensity(cb_df_trans1_longer[cb_df_trans1_longer$marker %in% selected,],
              x = "intensity", color = "marker", add = "mean", rug = F)
  ggsave(glue("/cluster/home/flora_jh/projects/hyperion/output/trans1_{i}.pdf"), width=6, height=4)
}

left_num <- length(markers) - page_num*4
selected <- markers[(length(markers) - left_num + 1):length(markers)]
p <- ggdensity(cb_df_trans1_longer[cb_df_trans1_longer$marker %in% selected,],
               x = "intensity", color = "marker", add = "mean", rug = F)
ggsave(glue("/cluster/home/flora_jh/projects/hyperion/output/trans1_{page_num+1}.pdf"), width=6, height=4)

# Transform 2
for (i in 1:page_num){
  print(i)
  selected <- markers[(4*(i-1)+1):(4*i)]
  print(selected)
  p <- ggdensity(cb_df_trans2_longer[cb_df_trans2_longer$marker %in% selected,],
                 x = "intensity", color = "marker", add = "mean", rug = F)
  ggsave(glue("/cluster/home/flora_jh/projects/hyperion/output/trans2_{i}.pdf"), width=6, height=4)
}

left_num <- length(markers) - page_num*4
selected <- markers[(length(markers) - left_num + 1):length(markers)]
p <- ggdensity(cb_df_trans2_longer[cb_df_trans2_longer$marker %in% selected,],
               x = "intensity", color = "marker", add = "mean", rug = F)
ggsave(glue("/cluster/home/flora_jh/projects/hyperion/output/trans2_{page_num+1}.pdf"), width=6, height=4)





cb_plot_trans1 <- apply(cb_para_tumor[, !colnames(cb_para_tumor) %in% c("rowname", "Object", "sample_id")], 2, simpleAsinh) %>%
  as.data.frame()
cb_plot_trans2 <- apply(cb_liver_pdac[, !colnames(cb_liver_pdac) %in% c("rowname", "Object", "sample_id")], 2, simpleAsinh) %>%
  as.data.frame()
cb_plot_trans_heatmap1 <- apply(cb_para_tumor[, !colnames(cb_para_tumor) %in% c("rowname", "Object", "sample_id")], 2, simpleAsinh_Zero_Max, b = 1.2) %>%
  as.data.frame()
cb_plot_trans_heatmap2 <- apply(cb_liver_pdac[, !colnames(cb_liver_pdac) %in% c("rowname", "Object", "sample_id")], 2, simpleAsinh_Zero_Max, b = 1.2) %>%
  as.data.frame()

###PhenoGraph
k = 40
PhenoGraph_result1 <- as.numeric(membership(cytofkit::Rphenograph(data = cb_df_trans1,k=k)))
PhenoGraph_result2 <- as.numeric(membership(cytofkit::Rphenograph(data = cb_df_trans2,k=k)))

#  Checkpoint:
hist(PhenoGraph_result1,unique(PhenoGraph_result1))
hist(PhenoGraph_result2,unique(PhenoGraph_result2))


###Flowsom
xdim=40
ydim=40

map1 <- FlowSOM::SOM(data= as.matrix(cb_df_trans1),
           xdim=xdim,
           ydim=ydim,
           silent = F)

FlowSOM_combined1 <- data.frame(FlowSOM=map1$mapping[,1],
                                cb_df_trans1)

metacluster_result1 <- metaClustering(FlowSOM_combined1,
                                      clustername = "FlowSOM",
                                      metaClustering_method = "metaClustering_PhenoGraph",
                                      k_value=5,
                                      elbow_test=F,
                                      seed=123)

map2 <- FlowSOM::SOM(data= as.matrix(cb_df_trans2),
                     xdim=xdim,
                     ydim=ydim,
                     silent = F)

FlowSOM_combined2 <- data.frame(FlowSOM=map2$mapping[,1],
                                cb_df_trans2)

metacluster_result2 <- metaClustering(FlowSOM_combined2,
                                      clustername = "FlowSOM",
                                      metaClustering_method = "metaClustering_PhenoGraph",
                                      k_value=6,
                                      elbow_test=F,
                                      seed=123)

###marker_preview
cb_trans_pheno1 <- data.frame(cb_plot_trans1, phenocluster=PhenoGraph_result1)
cb_trans_som1 <- data.frame(cb_plot_trans1, somcluster=metacluster_result1)

cb_trans_pheno_heatmap1 <- data.frame(cb_plot_trans_heatmap1, phenocluster=PhenoGraph_result1)
cb_trans_som_heatmap1 <- data.frame(cb_plot_trans_heatmap1, somcluster=metacluster_result1)

cb_trans_pheno2 <- data.frame(cb_plot_trans2, phenocluster=PhenoGraph_result2)
cb_trans_som2 <- data.frame(cb_plot_trans2, somcluster=metacluster_result2)

cb_trans_pheno_heatmap2 <- data.frame(cb_plot_trans_heatmap2, phenocluster=PhenoGraph_result2)
cb_trans_som_heatmap2 <- data.frame(cb_plot_trans_heatmap2, somcluster=metacluster_result2)

heatmap_data_pheno1 <- cb_trans_pheno1 %>% group_by(phenocluster) %>%
  summarise_if(is.numeric, mean, na.rm = TRUE) %>% select (-phenocluster)

heatmap_data_som1 <- cb_trans_som1 %>% group_by(somcluster) %>%
  summarise_if(is.numeric, mean, na.rm = TRUE) %>% select (-somcluster)

heatmap_data_som_heatmap1 <- cb_trans_som_heatmap1 %>% group_by(somcluster) %>%
  summarise_if(is.numeric, mean, na.rm = TRUE) %>% select (-somcluster)

heatmap_data_pheno2 <- cb_trans_pheno2 %>% group_by(phenocluster) %>%
  summarise_if(is.numeric, mean, na.rm = TRUE) %>% select (-phenocluster)

heatmap_data_som2 <- cb_trans_som2 %>% group_by(somcluster) %>%
  summarise_if(is.numeric, mean, na.rm = TRUE) %>% select (-somcluster)

heatmap_data_som_heatmap2 <- cb_trans_som_heatmap2 %>% group_by(somcluster) %>%
  summarise_if(is.numeric, mean, na.rm = TRUE) %>% select (-somcluster)


#输出heatmap
# pdf("~/projects/hyperion/analysis/heatmap_tsne/40000pheno_combined_heatmap.pdf", width = 7, height = 7)
#   Heatmap(heatmap_data_pheno, row_labels = rownames(heatmap_data_pheno))
# dev.off()

# pdf("~/projects/hyperion/analysis/heatmap_tsne/60000pheno_combined_heatmap.pdf", width = 7, height = 7)
#   Heatmap(heatmap_data_pheno, row_labels = rownames(heatmap_data_pheno))
# dev.off()
#
# pdf("~/projects/hyperion/analysis/heatmap_tsne/60000pheno_combined_heatmap1.pdf", width = 7, height = 7)
#   Heatmap(heatmap_data_pheno_htm, row_labels = rownames(heatmap_data_pheno_htm))
# dev.off()
# pdf("~/projects/hyperion/analysis/heatmap_tsne/40000som_combined_heatmap.pdf", width = 8, height = 6)
#   Heatmap(heatmap_data_som, row_labels = rownames(heatmap_data_som))
# dev.off()

pdf("~/projects/hyperion/analysis/figures/heatmap_tsne/goroup1_som_raw_heatmap.pdf", width = 8, height = 6)
  Heatmap(heatmap_data_som1, row_labels = rownames(heatmap_data_som1))
dev.off()

pdf("~/projects/hyperion/analysis/figures/heatmap_tsne/goroup2_som_raw_heatmap.pdf", width = 8, height = 6)
  Heatmap(heatmap_data_som2, row_labels = rownames(heatmap_data_som2))
dev.off()

pdf("~/projects/hyperion/analysis/figures/heatmap_tsne/goroup1_som_0max_heatmap.pdf", width = 8, height = 6)
  Heatmap(heatmap_data_som1, row_labels = rownames(heatmap_data_som1))
dev.off()

pdf("~/projects/hyperion/analysis/figures/heatmap_tsne/goroup2_som_0max_heatmap.pdf", width = 8, height = 6)
  Heatmap(heatmap_data_som2, row_labels = rownames(heatmap_data_som2))
dev.off()

# pdf("~/projects/hyperion/analysis/heatmap_tsne/60000som_combined_heatmap1.pdf", width = 8, height = 6)
#   Heatmap(heatmap_data_som_htm, row_labels = rownames(heatmap_data_som_htm))
# dev.off()

# pdf("~/projects/hyperion/analysis/heatmap_tsne/60000som_combined_heatmap3.pdf", width = 8, height = 6)
# #dat_som <- t(log(heatmap_data_som+1, 2))
# #colnames(dat_som) <- rownames(heatmap_data_som)
#   dat_plot <- t(apply(dat_som, 2, scale)) %>% as.matrix()
#   rownames(dat_plot) <- rownames(heatmap_data_som)
#   colnames(dat_plot) <- colnames(heatmap_data_som)
#   Heatmap(dat_plot, row_labels = rownames(heatmap_data_som))
# dev.off()

pdf("~/projects/hyperion/analysis/figures/heatmap_tsne/goroup1_som_scale_heatmap.pdf", width = 8, height = 6)
  dat_plot1 <- apply(heatmap_data_som1, 2, scale) %>% as.matrix()
  Heatmap(dat_plot1, row_labels = rownames(heatmap_data_som1))
dev.off()

pdf("~/projects/hyperion/analysis/figures/heatmap_tsne/goroup2_som_scale_heatmap.pdf", width = 8, height = 6)
  dat_plot2 <- apply(heatmap_data_som2, 2, scale) %>% as.matrix()
  Heatmap(dat_plot2, row_labels = rownames(heatmap_data_som2))
dev.off()


# pdf("~/projects/hyperion/analysis/heatmap_tsne/40000som_combined_heatmap3.pdf", width = 8, height = 6)
#   #dat_som <- t(log(heatmap_data_som+1, 2))
#   #colnames(dat_som) <- rownames(heatmap_data_som)
#   dat_plot <- t(apply(dat_som, 2, scale)) %>% as.matrix()
#   rownames(dat_plot) <- rownames(heatmap_data_som)
#   colnames(dat_plot) <- colnames(heatmap_data_som)
#   Heatmap(dat_plot, row_labels = rownames(heatmap_data_som))
# dev.off()
#
# pdf("~/projects/hyperion/analysis/heatmap_tsne/40000som_combined_heatmap2.pdf", width = 8, height = 6)
#   dat_som <- t(log(heatmap_data_som+1, 2))
#   colnames(dat_som) <- rownames(heatmap_data_som)
#   #dat_plot <- t(apply(dat_som, 1, scale)) %>% as.matrix()
#   dat_plot <- dat_som
#   Heatmap(dat_plot, row_labels = rownames(dat_som))
# dev.off()


###tsne
max_iter=3000
perplexity=30
theta=0.5
dims = 2

tsne_result1 <- Rtsne(cb_plot_trans1,
                     initial_dims = ncol(cb_plot_trans1),
                     pca = FALSE,
                     dims = dims,
                     check_duplicates = FALSE,
                     perplexity=perplexity,
                     max_iter=max_iter,
                     theta=theta)$Y
row.names(tsne_result1) <- row.names(cb_plot_trans1)
colnames(tsne_result1) <- c("tsne_1","tsne_2")
plot(tsne_result1)

cb_trans_som1 <- cb_trans_som1 %>% mutate(rownames = rownames(cb_trans_som1))
cb_trans_plot1 <- data.frame(cb_plot_trans1, tsne_result1) %>%
  mutate(rownames = rownames(cb_plot_trans1), File_ID = str_split(rownames(cb_plot_trans1), "@", simplify = TRUE)[,2]) %>%
  left_join(cb_trans_som1[,35:36], by = "rownames") %>% left_join(groups1, by = "File_ID")
row.names(cb_trans_plot1) <- cb_trans_plot1$rownames

tsne_result2 <- Rtsne(cb_plot_trans2,
                      initial_dims = ncol(cb_plot_trans2),
                      pca = FALSE,
                      dims = dims,
                      check_duplicates = FALSE,
                      perplexity=perplexity,
                      max_iter=max_iter,
                      theta=theta)$Y
row.names(tsne_result2) <- row.names(cb_plot_trans2)
colnames(tsne_result2) <- c("tsne_1","tsne_2")
plot(tsne_result2)

cb_trans_som2 <- cb_trans_som2 %>% mutate(rownames = rownames(cb_trans_som2))
cb_trans_plot2 <- data.frame(cb_plot_trans2, tsne_result2) %>%
  mutate(rownames = rownames(cb_plot_trans2), File_ID = str_split(rownames(cb_plot_trans2), "@", simplify = TRUE)[,2]) %>%
  left_join(cb_trans_som2[,35:36], by = "rownames") %>% left_join(groups2, by = "File_ID")
row.names(cb_trans_plot2) <- cb_trans_plot2$rownames

write.csv(cb_trans_plot1, file = "~/projects/hyperion/analysis/group1.csv", row.names = TRUE)
write.csv(cb_trans_plot2, file = "~/projects/hyperion/analysis/group2.csv", row.names = TRUE)


###tsne可视化
mytheme <- theme(panel.background = element_rect(fill = "white", colour = "black", size = 0.2),
                 legend.key = element_rect(fill = "white", colour = "white"),
                 legend.background = (element_rect(colour= "white", fill = "white")))

# tsne_umap <- function(input, x_axis, y_axis, subtype, output){
#   outfig <- ggplot(input, aes(x = input[[x_axis]],
#                       y = input[[y_axis]],
#                       color = factor(input[[subtype]]))) +
#     geom_point(size = 0.5) +
#     scale_color_manual(values = cluster_color) + mytheme +
#     theme(legend.title = element_blank()) +
#     xlab(x_axis) + ylab(y_axis)
#   file <- str_c(outdir, output, sep = "/")
#   ggsave(file, width = 180, height = 140, units = "mm", outfig)
# }

# tsne_merge <- tsne_umap(input = combined_trans_plot,
#                   x_axis = "tsne_1",
#                   y_axis = "tsne_2",
#                   subtype = "somcluster",
#                   output = "tSNE_plot_merge.pdf")


tsne_merge1 <- ggplot(cb_trans_plot1,
                      aes(x = tsne_1,
                          y = tsne_2,
                          color = factor(somcluster))) +
  geom_point(size = 0.5) +
  scale_color_manual(values=cluster_color) + mytheme + theme(legend.title = element_blank())

ggsave("~/projects/hyperion/analysis/figures/heatmap_tsne/group1/tSNE_plot_merge.pdf", width = 180, height = 140, units = "mm", tsne_merge1)

tsne_merge2 <- ggplot(cb_trans_plot2,
                      aes(x = tsne_1,
                          y = tsne_2,
                          color = factor(somcluster))) +
  geom_point(size = 0.5) +
  scale_color_manual(values=cluster_color) + mytheme + theme(legend.title = element_blank())

ggsave("~/projects/hyperion/analysis/figures/heatmap_tsne/group2/tSNE_plot_merge.pdf", width = 180, height = 140, units = "mm", tsne_merge2)

tsne_merge_group1 <- ggplot(cb_trans_plot1,
         aes(x = tsne_1,
             y = tsne_2,
             color = Treatment)) +
  geom_point(size = 0.5) +
  scale_color_manual(values=c("#BEB8DC", "#E7DAD2", "#80BFFF")) + mytheme + theme(legend.title = element_blank())

ggsave("~/projects/hyperion/analysis/figures/heatmap_tsne/group1/tSNE_plot_merge_group.pdf", width = 180, height = 140, units = "mm", tsne_merge_group1)


para_trans_plot <- combined_trans_plot[combined_trans_plot$Treatment == "paracancerous",]
pdac_trans_plot <- combined_trans_plot[combined_trans_plot$Treatment == "tumor",]

# tsne_para <- tsne_umap(input = para_trans_plot,
#                         x_axis = "tsne_1",
#                         y_axis = "tsne_2",
#                         subtype = "somcluster",
#                         output = "tSNE_plot_para.pdf")
tsne_para <- ggplot(para_trans_plot,
         aes(x = tsne_1,
             y = tsne_2,
             color = factor(somcluster))) +
  geom_point(size = 0.5) +
  scale_color_manual(values=cluster_color) + mytheme + theme(legend.title = element_blank())

ggsave("~/projects/hyperion/analysis/heatmap_tsne/tSNE_plot_para.pdf", width = 180, height = 140, units = "mm", tsne_para)

tsne_pdac <- ggplot(pdac_trans_plot,
         aes(x = tsne_1,
             y = tsne_2,
             color = factor(somcluster))) +
  geom_point(size = 0.5) +
  scale_color_manual(values=cluster_color) + mytheme + theme(legend.title = element_blank())

ggsave("~/projects/hyperion/analysis/heatmap_tsne/tSNE_plot_pdac.pdf", width = 180, height = 140, units = "mm", tsne_pdac)

cluster_abandance_stat<-combined_trans_plot %>%
  dplyr::group_by(somcluster) %>%
  dplyr::summarise(num=n())

cluster_num <- length(unique(combined_trans_plot$somcluster))
cluster_abandance_stat$percentage=cluster_abandance_stat$num/sum(cluster_abandance_stat$num)*100

cluster_abundance_barplot <- ggplot(data = cluster_abandance_stat, aes(x = factor(somcluster), y = percentage, fill = factor(somcluster))) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values=cluster_color) + mytheme + coord_flip()#横向
  ggsave("~/projects/hyperion/analysis/heatmap_tsne/cluster_percentage.pdf", width = 180, height = 140, units = "mm", cluster_abundance_barplot)

marker <- colnames(combined_df_trans)
for(m in 1:34){
    marker_tsne_plot <- ggplot(combined_trans_plot,
           aes(x = tsne_1,
               y = tsne_2,
               color = combined_trans_plot[,m]))+
    geom_point(size = 0.5)+
    scale_color_gradient(low = "#FCFBFD", high = "#480c83") +
    #scale_color_distiller(palette = "Spectral")+
    mytheme + theme(legend.title = element_blank()) + labs(title = marker[m])
  ggsave(glue("~/projects/hyperion/analysis/heatmap_tsne/single_marker_tsne/{marker[m]}.pdf"), width = 180, height = 140, units = "mm", marker_tsne_plot)
}


###umap
umap_result <- umap(combined_plot_trans, n_neighbors = 15, learning_rate =1, min_dist=0.2, init = "random", n_epochs =200)
colnames(umap_result) <- c("UMAP1","UMAP2")
head(umap_result)
plot(umap_result)
combined_trans_plot <- data.frame(combined_trans_plot, umap_result)
# umap_merge <- tsne_umap(input = combined_trans_plot,
#                         x_axis = "UMAP1",
#                         y_axis = "UMAP2",
#                         subtype = "somcluster",
#                         output = "umap_plot_merge.pdf")
umap_merge <- ggplot(combined_trans_plot, aes(x = UMAP1,
             y = UMAP2,
             color = factor(somcluster))) +
  geom_point(size = 0.5) +
  scale_color_manual(values=cluster_color) + mytheme + theme(legend.title = element_blank())

ggsave("~/projects/hyperion/analysis/heatmap_tsne/umap_plot_merge.pdf", width = 180, height = 140, units = "mm", umap_merge)

umap_merge_group <- ggplot(combined_trans_plot,
         aes(x = UMAP1,
             y = UMAP2,
             color = Treatment)) +
  geom_point(size = 0.5) +
  scale_color_manual(values=c("#BEB8DC", "#E7DAD2")) + mytheme + theme(legend.title = element_blank())

ggsave("~/projects/hyperion/analysis/heatmap_tsne/umap_plot_merge_group.pdf", width = 180, height = 140, units = "mm", umap_merge_group)


para_trans_plot <- combined_trans_plot[combined_trans_plot$Treatment == "paracancerous",]
pdac_trans_plot <- combined_trans_plot[combined_trans_plot$Treatment == "tumor",]

umap_para <- ggplot(para_trans_plot,
         aes(x = UMAP1,
             y = UMAP2,
             color = factor(somcluster))) +
  geom_point(size = 0.5) +
  scale_color_manual(values=cluster_color) + mytheme + theme(legend.title = element_blank())

ggsave("~/projects/hyperion/analysis/heatmap_tsne/umap_plot_para.pdf", width = 180, height = 140, units = "mm", umap_para)

umap_pdac <- ggplot(pdac_trans_plot, aes(x = UMAP1,
             y = UMAP2,
             color = factor(somcluster))) +
  geom_point(size = 0.5) +
  scale_color_manual(values=cluster_color[-10]) + mytheme + theme(legend.title = element_blank())

ggsave("~/projects/hyperion/analysis/heatmap_tsne/umap_plot_pdac.pdf", width = 180, height = 140, units = "mm", umap_pdac)

for(m in 1:34){
  marker_umap_plot <- ggplot(combined_trans_plot,
           aes(x = UMAP1,
               y = UMAP2,
               color = combined_trans_plot[,m]))+
    geom_point(size = 0.5)+
    scale_color_gradient(low = "#FCFBFD", high = "#480c83") +
    #scale_color_distiller(palette = "Spectral")+
    mytheme + theme(legend.title = element_blank()) + labs(title = marker[m])
  ggsave(glue("~/projects/hyperion/analysis/heatmap_tsne/single_marker_umap/{marker[m]}.pdf"), width = 180, height = 140, units = "mm", marker_umap_plot)
}



#####
cluster_boxplot<-function(cluster_name,show_pvalues=T,Plot_Data,ylab){
  ydata<-Plot_Data %>% dplyr::select(somcluster)
  yrange<-max(ydata)-min(ydata)
  ncolor<-nrow(unique(Plot_Data[,color_cond,drop=F]))
  #ncolor<-nrow(unique(Plot_Data[,color_cond]))
  datacol<-colnames(Plot_Data)
  active_cluster_id=datacol==cluster_name
  datacol[active_cluster_id]<-"act_cluster"
  colnames(Plot_Data)<-datacol

for(cluster in 1:24)
  input_data <- combined_trans_plot[combined_trans_plot$somcluster == cluster,]
  cluster_boxplot<- ggplot(input_data, aes_string(x = major_cond, y="act_cluster", color = Treatment))+
    geom_boxplot(outlier.shape= NA,lwd=border_size_b,width=box_width_b,color = "#000000", fill = c("#BEB8DC", "#E7DAD2"))+
    geom_jitter(shape=16, position=position_jitter(0.2))+
    mytheme+
    labs(title=cluster_name)+
    scale_colour_manual(values=group_colorset(ncolor))+
    #scale_fill_manual(values=group_colorset(ncolor))+
    labs(y=ylab)+
    scale_y_continuous(limits=c((min(ydata)-relative_y_limit_b[1]*yrange),(max(ydata)+relative_y_limit_b[2]*yrange*comparisons_n)))+
    theme(legend.position = "none")+
    #theme(axis.text.x= element_text(angle=label_font_angle,hjust =hjust,vjust = vjust,size=label_font_size))+
    theme(axis.title = element_text(size=axis_font_size))+
    theme(title =element_text(size=title_font_size,face="bold"))


  cluster_boxplot<-cluster_boxplot+
    stat_compare_means(method = comparisons.stat.method,
                       paired=comparisons.stat.paired,
                       comparisons=comparisons,
                       hide.ns = TRUE,
                       #aes(label = paste0("p = ", ..p.format..)))
                       aes(label = ..p.signif..))


  cluster_boxplot_list<-lapply(cluster_names,cluster_boxplot,show_pvalues=show_pvalues,Plot_Data=cluster_percent_data,ylab="Percentage %")
  boxplot_width<-boxplot_ncol*singlewidth*72


  pdf("~/projects/hyperion/analysis/heatmap_tsne/cluster_boxplot.pdf", width=boxplot_width/72*zoom_fig_width_b, height=boxplot_height/72*zoom_fig_height_b)
  multiplot(plotlist=cluster_boxplot_list,cols = boxplot_ncol)
  if(length(heatmap_ctrl)>1){
    multiplot(plotlist=cluster_boxplot_list_dif,cols = boxplot_ncol)
    multiplot(plotlist=cluster_boxplot_list_log_ratio,cols = boxplot_ncol)}
  dev.off()
