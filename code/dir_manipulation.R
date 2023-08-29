pkgs <- c("fs", "futile.logger", "configr", "stringr", "ggpubr", "ggthemes",
          "jhtools", "glue", "ggsci", "patchwork", "tidyverse", "dplyr", "hash",
          "fs")
for (pkg in pkgs){
  suppressPackageStartupMessages(library(pkg, character.only = T))
}
project <- "hyperion"
dataset <- "imctools"
workdir <- glue::glue("~/projects/{project}/analysis/{dataset}/")
setwd(workdir)

sampleinfo <- read_excel("/cluster/home/flora_jh/projects/hyperion/docs/sampleinfo_hyperion_yemao.xlsx")

# 1. tumor/
h <- hash(keys = sampleinfo$cn_name, values = sampleinfo$p_id)
cn_name_fil <- list.dirs("/cluster/home/jhuang/projects/hyperion/data/qzhang/human/hyperion/array/mcd/tumor",
                            full.names = F) %in% sampleinfo$cn_name
cn_name <- list.dirs("/cluster/home/jhuang/projects/hyperion/data/qzhang/human/hyperion/array/mcd/tumor",
                     full.names = F)[cn_name_fil]

# Mask Chinese names with p_id.
setwd("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor")
for (name in cn_name){
  p_id <- h[[name]]
  file_move(name, glue::glue("{p_id}_pdac"))
}

# Make directories in chips folder.
chips_folder <- list.dirs("/cluster/home/jhuang/projects/hyperion/data/qzhang/human/hyperion/array/mcd/tumor",
                          full.names = F)[!cn_name_fil][-1]
chips_folder_fil <- chips_folder %in% sampleinfo$raw_id
chips_folder <- chips_folder[chips_folder_fil]

for (folder in chips_folder){
  sample_ids <- sampleinfo[sampleinfo$raw_id == folder,]$sample_id
  dir_create(glue::glue("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/{folder}/{sample_ids}"))
}

# Move tiffs to corresponding directories.
sampleinfo$position_id[is.na(sampleinfo$position_id)] <- "ROI0"
sampleinfo <- sampleinfo %>% dplyr::mutate(ROI = str_split(str_subset(position_id, "ROI"),
                                                           " ", simplify = T)[,2]) %>% dplyr::mutate(ROI = glue::glue("{ROI}_"))

for (folder in chips_folder){
  setwd(glue::glue("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/{folder}"))
  ROI_barcode <- sampleinfo$ROI[sampleinfo$raw_id == folder]
  for (ROI in ROI_barcode){
    files <- dir_ls(glob = glue::glue("{ROI}*"))
    file_move(files, glue::glue("{sampleinfo$p_id[sampleinfo$raw_id == folder & sampleinfo$ROI == ROI]}_pdac"))
  }
}

# Note:
# Move "ROI_7_1_split*" files to /1T芯片（1T_ROI_补充）folder.
file_move(dir_ls("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/1T芯片（1T_ROI_7）",
                 glob = "*spl*"), "/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/1T芯片（1T_ROI_补充）/p162_pdac" )

# Move "ROI_4_7(a,b)_*" files to /p227_pdac folder.
file_move(dir_ls("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/2T芯片（2T_ROI_4）",
                 glob = "*ROI_4_7*"), "/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/2T芯片（2T_ROI_4）/p227_pdac")

# Move "ROI_7_6r_*" files to /p183_pdac folder.
file_move(dir_ls("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/2T芯片（2T_ROI_7）",
                 glob = "*ROI_7_6r*"), "/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/2T芯片（2T_ROI_7）/p183_pdac")

# Move "ROI_2_6b*" files to /p95_pdac folder.
file_move(dir_ls("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/2T芯片（2T_ROI_2）",
                 glob = "*ROI_2_6b*"), "/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/2T芯片（2T_ROI_2）/p95_pdac")

# Move "ROI_3_8*" files from 2T芯片（2T_ROI_4）to 2T芯片（2T_ROI_3）
file_move(dir_ls("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/2T芯片（2T_ROI_4）",
                 glob = "*ROI_3_8_*"), "/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/2T芯片（2T_ROI_3）/p203_pdac")

# Move "ROI_2_1*" files from 2T芯片（2T_ROI_2）to 2T芯片（2T_ROI_1-2）
file_move(dir_ls("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/2T芯片（2T_ROI_2）",
                 glob = "*ROI_2_1_*"), "/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/2T芯片（2T_ROI_1-2）/p196_pdac")

# Move "ROI_4_4*" files from 2T芯片（2T_ROI_4-5）to 2T芯片（2T_ROI_3-4）
file_move(dir_ls("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/2T芯片（2T_ROI_4-5）",
                 glob = "*ROI_4_4_*"), "/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/2T芯片（2T_ROI_3-4）/p40_pdac")

# Move "ROI_4_3_split*" files from 2T芯片（2T_ROI_4-5）to 2T芯片（2T_ROI_4）
file_move(dir_ls("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/2T芯片（2T_ROI_4-5）",
                 glob = "*spl*"), "/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/2T芯片（2T_ROI_4）/p198_pdac")

# Lastly, move the duplicated files into a "dup" folder under tumor/.
dir_create("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/dup")
for(folder in chips_folder){
  setwd(glue::glue("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/{folder}"))
  dup_files <- dir_ls(glob = "*tiff")
  file_move(dup_files, "../dup")
}

# !REMEMBER to move "ROI_4_4B_*", "ROI_6_11B_*" from dup to p40_pdac in linux

# Linux codes have been tried to test whether ROI_7_9b* files were produced successfully and the fact is no.

# 2. puncture/
# Mask Chinese names and change sub-directory names from "liver" or "pancreas" to "p_id_liver"
# or "p_id_pdac".
cn_name_fil <- list.dirs("/cluster/home/jhuang/projects/hyperion/data/qzhang/human/hyperion/array/mcd/puncture",
                         full.names = F) %in% sampleinfo$cn_name
cn_name <- list.dirs("/cluster/home/jhuang/projects/hyperion/data/qzhang/human/hyperion/array/mcd/puncture",
                     full.names = F)[cn_name_fil]

setwd("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/puncture")
for (name in cn_name){
  p_id <- h[[name]]
  file_move(name, glue::glue("{p_id}"))
  setwd(glue::glue("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/puncture/{p_id}"))
  file_move("liver", glue::glue("{p_id}_liver"))
  file_move("pancreas", glue::glue("{p_id}_pdac"))
}

# Release subfolders.
puncture_folder <- list.dirs("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/puncture",
                             full.names = F, recursive = F)

for (folder in puncture_folder){
  setwd(glue::glue("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/puncture/{folder}"))
  file_move(dir_ls(), "/cluster/home/flora_jh/projects/hyperion/analysis/imctools/puncture/")
}

dir_delete(glue::glue("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/puncture/{puncture_folder}"))

# 孙柏春 (p58) has 2 liver mcd files: LTB_LY_20210616_PUNCTURE_2019075719_2_02.mcd & LTB_LY_20210616_PUNCTURE_2019075719_2.mcd
# LTB_LY_20210616_PUNCTURE_2019075719_2_02.mcd will not be used.Tiff files generated from this mcd are stored in back_up/ folder.

dir_create("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/puncture/p58/p58_liver/back_up")
file_move(dir_ls("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/puncture/p58/p58_pdac/"),
          "/cluster/home/flora_jh/projects/hyperion/analysis/imctools/puncture/p58/p58_liver/back_up")
file_move(dir_ls("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/puncture/p58",
                 glob = "*tiff"), "/cluster/home/flora_jh/projects/hyperion/analysis/imctools/puncture/p58/p58_pdac")

# 3. normal/
# Chang e directory names to sample ids.
key <- hash(keys = sampleinfo$raw_id, values = sampleinfo$sample_id)
dir_names <- list.dirs("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/normal", full.names = F)[-1]
setwd("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/normal")
for (dir in dir_names){
  rename <- key[[dir]]
  file_move(dir, rename)
}

# 4. parapancreas/
# Chang e directory names to sample ids.
key2 <- hash(keys = str_remove(sampleinfo$mcd_fn, ".mcd"), values = sampleinfo$raw_id)
dir_names <- list.dirs("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/paracancerous", full.names = F)[-1]
setwd("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/paracancerous")
for (dir in dir_names){
  rename <- key2[[dir]]
  file_move(dir, rename)
}

chip_folder <- list.dirs("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/paracancerous",
          full.names = F, recursive = F)
for (folder in chip_folder){
  sample_ids <- sampleinfo$sample_id[sampleinfo$raw_id == folder]
  dir_create(glue::glue("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/paracancerous/{folder}/{sample_ids}"))
}

for (folder in chip_folder[c(1, 10, 11, 12, 14)]){
  setwd(glue::glue("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/paracancerous/{folder}"))
  ROI_barcode <- sampleinfo$ROI[sampleinfo$raw_id == folder]
  for (ROI in ROI_barcode){
    files <- dir_ls(glob = glue::glue("{ROI}*"))
    file_move(files, glue::glue("{sampleinfo$p_id[sampleinfo$raw_id == folder & sampleinfo$ROI == ROI]}_para"))
  }
}

for (folder in chip_folder[c(2:9, 13)]){
  setwd(glue::glue("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/paracancerous/{folder}"))
  ROI_barcode <- sampleinfo$ROI[sampleinfo$raw_id == folder]
  for (ROI in ROI_barcode){
    ROI_num <- str_remove(ROI, "ROI")
    files <- dir_ls(regexp = glue::glue("ROI_PDAC[0-9]*_N1[0-9]{ROI_num}*"))
    file_move(files, sampleinfo$sample_id[sampleinfo$raw_id == folder & sampleinfo$ROI == ROI])
  }
}

# For unknown reason, LTB_LY_20200601_PDAC_1N_1B is generated under 1N芯片_ROI_1N_1 folder.
files_1 <- dir_ls("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/paracancerous/1N芯片_ROI_1N_1/LTB_LY_20200601_PDAC_1N_1B",
                glob = "*ROI_3_*")
file_move(files_1, "/cluster/home/flora_jh/projects/hyperion/analysis/imctools/paracancerous/1N芯片_ROI_1N_1/p91_para")

files_2 <- dir_ls("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/paracancerous/1N芯片_ROI_1N_1/LTB_LY_20200601_PDAC_1N_1B",
                  glob = "*ROI_1_2*")

file_move(files_2, "/cluster/home/flora_jh/projects/hyperion/analysis/imctools/paracancerous/1N芯片_ROI_1N_1/p117_para")

files_3 <- dir_ls("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/paracancerous/1N芯片_ROI_1N_1/LTB_LY_20200601_PDAC_1N_1B",
                  glob = "*ROI_2-1*")

file_move(files_3, "/cluster/home/flora_jh/projects/hyperion/analysis/imctools/paracancerous/1N芯片_ROI_1N_1/p86_para")

dir_delete("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/paracancerous/1N芯片_ROI_1N_1/LTB_LY_20200601_PDAC_1N_1B")

files_4 <- dir_ls("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/paracancerous/1N芯片_ROI_1N_1",
                  glob = "*ROI_1_1*")
file_move(files_4, "/cluster/home/flora_jh/projects/hyperion/analysis/imctools/paracancerous/1N芯片_ROI_1N_1/p117_para")

# Release subfolders and delete para_chip_folders.

para_chip_folders <- list.dirs("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/paracancerous",
                               full.names = F, recursive = F)
for (folder in para_chip_folders){
  setwd(glue::glue("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/paracancerous/{folder}"))
  file_move(dir_ls(glob = "*_para"), "..")
}

setwd("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/paracancerous")
dir_delete(para_chip_folders)
# Check whether sample_id folders exist in different chips in tumor/.

dir <- list()
i = 1
for (folder in chips_folder){
  setwd(glue::glue("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/{folder}"))
  dir[[i]] <- list.dirs(full.names = F)
  i = i+1
}

dir <- unlist(dir)
dir <- dir[!(dir == "")]
length(dir) #154
length(unique(dir)) #132

duplicated_dirs <- unique(dir[duplicated(dir)])

# Combine files from duplicated sample_id folders into one.
i = 1
from = to = list()
for (dir in duplicated_dirs){
  from <- sampleinfo$raw_id[which(sampleinfo$sample_id == dir)][2]
  to <- sampleinfo$raw_id[which(sampleinfo$sample_id == dir)][1]
  file_move(dir_ls(glue::glue("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/{from}/{dir}")),
            glue::glue("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/{to}/{dir}"))
  message(glue("move {dir} from {from} to {to}"))
  dir_delete(glue::glue("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/{from}/{dir}"))
}

#move p121_pdac from 1T芯片（1T_ROI_补充） to 1T芯片（1T_ROI_3-4）
#move p129_pdac from 1T芯片（1T_ROI_补充） to 1T芯片（1T_ROI_3-4）
#move p162_pdac from 1T芯片（1T_ROI_补充） to 1T芯片（1T_ROI_7）
#move p164_pdac from 1T芯片（1T_ROI_补充） to 1T芯片（1T_ROI_3-4）
#move p190_pdac from 1T芯片（1T_ROI_补充） to 1T芯片（1T_ROI_1、6、7、8）
#move p222_pdac from 1T芯片（1T_ROI_补充） to 1T芯片（1T_ROI_3-4）
#move p228_pdac from 1T芯片（1T_ROI_补充） to 1T芯片（1T_ROI_5）
#move p234_pdac from 1T芯片（1T_ROI_补充） to 1T芯片（1T_ROI_5）
#move p64_pdac from 1T芯片（1T_ROI_补充） to 1T芯片（1T_ROI_3-4）
#move p11_pdac from 2T芯片（2T_ROI_4） to 2T芯片（2T_ROI_3-4）
#move p148_pdac from 2T芯片（2T_ROI_4） to 2T芯片（2T_ROI_3-4）
#move p40_pdac from 2T芯片（2T_ROI_4） to 2T芯片（2T_ROI_3-4）
#move p40_pdac from 2T芯片（2T_ROI_补充） to 2T芯片（2T_ROI_3-4）
#move p209_pdac from 2T芯片（2T_ROI_5） to 2T芯片（2T_ROI_4-5）
#move p154_pdac from 2T芯片（2T_ROI_补充） to 2T芯片（2T_ROI_6）
#move p172_pdac from 2T芯片（2T_ROI_补充） to 2T芯片（2T_ROI_5）
#move p44_pdac from 2T芯片（2T_ROI_补充） to 2T芯片（2T_ROI_6）
#move p94_pdac from 2T芯片（2T_ROI_补充） to 2T芯片（2T_ROI_6-7）
#move p16_pdac from 2T芯片（2T_ROI_补充2） to 2T芯片（2T_ROI_6）
#move p211_pdac from 2T芯片（2T_ROI_补充2） to 2T芯片（2T_ROI_4）
#move p213_pdac from 2T芯片（2T_ROI_补充2） to 2T芯片（2T_ROI_4）
#move p22_pdac from 2T芯片（2T_ROI_补充2） to 2T芯片（2T_ROI_4-5）
#move p31_pdac from 2T芯片（2T_ROI_补充2） to 2T芯片（2T_ROI_6）

# Release subfolders.
for (folder in chips_folder[-2]){
  setwd(glue::glue("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/{folder}"))
  file_move(dir_ls(glob = "*_pdac"), "..")
}

# Delete chips folder since they are empty now.
setwd("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/")
dir_delete(chips_folder)

# Why I have 5 less number of subfolders under /tumor than Huang's?

my_folder <- list.dirs("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor", full.names = F)
my_folder_num <- length(my_folder) -3
huang_folder <- list.dirs("/cluster/home/jhuang/projects/hyperion/analysis/qzhang/human/steinbock/tumor/img", full.names = F)
huang_folder_num <- length(huang_folder) -1
huang_more <- huang_folder[!(huang_folder %in% my_folder)]

# As expected, those 5 subfolders all come from 1T芯片（1T_ROI_2、5-6）, which I failed to
# convert into tiff: "p176_pdac" "p221_pdac" "p33_pdac"  "p50_pdac"  "p56_pdac" .

# Convert the subfolder names after /chemotherapy to p_ids MANUALLY!


