library(imcRtools)
library(CATALYST)

pkgs <- c("fs", "futile.logger", "configr", "stringr", "ggpubr", "ggthemes", "ggplot2",
          "cytomapper","jhuanglabscell","vroom", "jhtools", "glue", "openxlsx", "ggraph",
          "ggsci", "patchwork", "cytomapper", "tidyverse", "dplyr","imcRtools")

for (pkg in pkgs){
  suppressPackageStartupMessages(library(pkg, character.only = T))
}
project <- "hyperion"
dataset <- "yemao/human/steinbock/puncture/"
workdir <- glue::glue("~/projects/{project}/analysis/{dataset}")
setwd(workdir)

punctur_samples <- fs::dir_ls(path = "/cluster/home/ylxie_jh/projects/hyperion/analysis/yemao/human/steinbock/puncture/measure/intensities",
                              recurse = F) %>% str_replace_all("^.*/", "")

imc_path <- "/cluster/home/flora_jh/projects/hyperion/analysis/imcRtools/puncture" # Change it to your working directory
setwd(imc_path)
for (i in 1:length(punctur_samples)) {
  dir_create(glue::glue("{punctur_samples[i]}/intensities"))
  dir_create(glue::glue("{punctur_samples[i]}/regionprops"))
  dir_create(glue::glue("{punctur_samples[i]}/neighbors"))
  cmd1 <- glue::glue("cd {imc_path}{punctur_samples[i]}/intensities && ln -s /cluster/home/jhuang/projects/hyperion/analysis/qzhang/human/steinbock/puncture/measure/intensit
ies/{punctur_samples[i]}/* .")
  cmd2 <- glue::glue("cd {imc_path}{punctur_samples[i]}/regionprops && ln -s /cluster/home/jhuang/projects/hyperion/analysis/qzhang/human/steinbock/puncture/measure/regionpr
ops/{punctur_samples[i]}/* .")
  cmd3 <- glue::glue("cd {imc_path}{punctur_samples[i]}/neighbors && ln -s /cluster/home/jhuang/projects/hyperion/analysis/qzhang/human/steinbock/puncture/measure/neighbors_
centroids/{punctur_samples[i]}/* .")
  cmd4 <- glue::glue("cd {imc_path}{punctur_samples[i]} && ln -s /cluster/home/jhuang/projects/hyperion/analysis/qzhang/human/steinbock/puncture/img/{punctur_samples[i]}/ima
ges.csv .")
  cmd5 <- glue::glue("cd {imc_path}{punctur_samples[i]} && ln -s /cluster/home/jhuang/projects/hyperion/data/qzhang/human/hyperion/array/img/panel.csv .")
  cmds <- c(cmd1, cmd2, cmd3, cmd4, cmd5)
  jhtools::run_cmds(cmds)
}
punctur_spe <- 1:length(punctur_samples) %>% map(~read_steinbock(glue::glue("{imc_path}{punctur_samples[.x]}")))
punctur_sce <- 1:length(punctur_samples) %>% map(~read_steinbock(glue::glue("{imc_path}{punctur_samples[.x]}"), return_as = "sce"))

#p107_liver_spe <- read_steinbock("/cluster/home/flora_jh/projects/hyperion/analysis/imcRtools/puncture/p107_liver")

#p107_liver_sce <- read_steinbock("/cluster/home/flora_jh/projects/hyperion/analysis/imcRtools/puncture/p107_liver",
                                 #return_as = "sce")

#plotSpatial(p107_liver_sce, img_id = "ObjectNumber", node_color_by = "sample_id",
            #node_shape_by = "ObjectNumber", node_size_by = "area", draw_edges = TRUE,
            #colPairName = "delaunay_interaction_graph", directed = FALSE)


