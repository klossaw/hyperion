steinbock_img_path <- "/cluster/home/jhuang/projects/hyperion/analysis/qzhang/human/steinbock/tumor/img"
steinbock_tumor_pid <- dir_ls(steinbock_img_path)
steinbock_tumor <- list.files(steinbock_img_path, full.names = F)

my_img_path <- "~/projects/hyperion/analysis/imctools/tumor/"
my_tumor_pid <- dir_ls(my_img_path)
my_tumor <- list.files(my_img_path, full.names = F)

steinbock_delete_tumor <- steinbock_tumor_pid %in% c(glue::glue("/cluster/home/jhuang/projects/hyperion/analysis/qzhang/human/steinbock/tumor/img/{Imissedtumors}"))
steinbock_tumor_pid <- steinbock_tumor_pid[!steinbock_delete_tumor]

intersect_tumor <- intersect(steinbock_tumor, my_tumor)
steinbock_tumor <- steinbock_tumor[steinbock_tumor %in% intersect_tumor]
my_tumor <- my_tumor[my_tumor %in% intersect_tumor]

steinbock_tumor_pid_fil <- steinbock_tumor_pid %in% c(glue::glue("/cluster/home/jhuang/projects/hyperion/analysis/qzhang/human/steinbock/tumor/img/{steinbock_tumor}"))
steinbock_tumor_pid <- steinbock_tumor_pid[steinbock_tumor_pid_fil]
my_tumor_pid_fil <- my_tumor_pid %in% c(glue::glue("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/{my_tumor}"))
my_tumor_pid <- my_tumor_pid[my_tumor_pid_fil]

steinbock_tiff_number <- vector(mode = "numeric", length = length(steinbock_tumor_pid))
i = 1
for (p in steinbock_tumor_pid){
  steinbock_tiff_number[i] <- length(dir_ls(p, type = "file", glob = "*.tiff"))
  i = i + 1
}
[1]  1  1  1  1  1  1  1  1  1  1  1  1  1  1  8  1  1  2  1  1  1  1  1  1 11
[26]  2  6  1  1  8  8  1  1  1  1 10  1  1  1  1  2  1  1  1  1  9  1  1 37  2
[51]  1  1  7  1  1  2  7  2  2  1  1  1  1  1  1  1  2  1  1 14  7  1  1  2  1
[76]  1  1  1  1  7  1  1  1  7  1 10  1  1  1  2  1  1  1  2  1  1  1  1  1  2
[101]  1  1  1  2  2  2  2  1  1  2  1  1 11 14  1  1  1 14 11  2  1  1  1  9  1
[126]  1  2  1  1  2  1  1  1  6  7  1  1  7  1  1  1  1  1  2  1 10  1 10  3  1
[151]  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  2  2  1  1  1  1

my_tiff_number <- vector(mode = "numeric", length = length(my_tumor_pid))
i = 1
for (p in my_tumor_pid){
  my_tiff_number[i] <- length(dir_ls(p, type = "file", glob = "*120Sn*"))
  i = i + 1
}
[1]  1  1  1  1  1  1  1  1  1  1  1  1  1  1  8  1  0  2  1  1  1  1  1  1  7
[26]  2  6  1  1  8  8  0  1  1  1 10  1  1  0  1  2  1  1  1  1 10  1  1  2  2
[51]  1  1  8  1  1  2  7  2  2  1  1  1  1  1  1  1  2  1  1 14  0  1  1  2  1
[76]  1  1  1  2  7  1  1  1  7  1 10  1  1  1  2  1  2  1  2  1  1  1  1  1  2
[101]  1  1  1  2  2  2  1  1  1  2  1  1  7 14  1  1  1 14 11  2  1  1  1  9  1
[126]  1  2  1  1  2  1  1  1  0  8  1  1  7  1  1  1  1  1  2  1 10  1 10  3  1
[151]  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  2  2  1  1  1  1

diff_tumor_fil <- which(!(steinbock_tiff_number == my_tiff_number))
[1]  17  25  32  39  46  49  53  71  79  92 107 113 134 135
my_tumor_pid[diff_tumor_fil]

# 1. tumor
#/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/p120_pdac empty
/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/p128_pdac # error reading ROI11
#/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/p138_pdac empty
#/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/p14_pdac empty
/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/p15_pdac #no split
/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/p162_pdac #why so many?
/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/p167_pdac #error reading ROI 8
#/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/p188_pdac empty
/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/p198_pdac #no split
/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/p211_pdac #no complimentary
#/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/p230_pdac
#/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/p237_pdac
#/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/p48_pdac empty
/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/p4_pdac #error reading ROI2

