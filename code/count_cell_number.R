#puncture
puncture_path <- "/cluster/home/jhuang/projects/hyperion/analysis/qzhang/human/steinbock/puncture/measure"
puncture_pid <- dir_ls(puncture_path)
i=1
cell_number_sum <- vector(mode = "numeric", length = length(puncture_pid))
for (p in puncture_pid){
 csvs <- dir_ls(glue("{p}/intensities")) %>% map(read_csv)
 cell_number_sum[i] <- csvs %>% sapply(nrow) %>% Reduce(f= "+")
 i=i+1
}

cell_number_sum
[1] 13870 30778 57106 19660 16119 27779 20933 16931 28447 25379 70186 31824
[13] 17869 35436 40754 13246  8202 46780 12138 32267 33539

puncture_sum <- cell_number_sum %>% Reduce(f= "+")
puncture_sum
[1] 599243


#normal
normal_path <- "/cluster/home/jhuang/projects/hyperion/analysis/qzhang/human/steinbock/normal/measure"
noraml_pid <- dir_ls(normal_path)
i=1
normal_cell_sum <- vector(mode = "numeric", length = length(noraml_pid))
for (p in noraml_pid){
  csvs <- dir_ls(glue("{p}/intensities")) %>% map(read_csv)
  normal_cell_sum[i] <- csvs %>% sapply(nrow) %>% Reduce(f= "+")
  i=i+1
}

normal_cell_sum
[1] 27189 29375 40722 32430 27837 35367 33349 39602 31420
normal_sum <- normal_cell_sum %>% Reduce(f= "+")
normal_sum
[1] 297291

# tumor
tumor_path <- "/cluster/home/jhuang/projects/hyperion/analysis/qzhang/human/steinbock/tumor/measure"
tumor_pid <- dir_ls(tumor_path)
i=1
tumor_cell_sum <- vector(mode = "numeric", length = length(tumor_pid))
for (p in tumor_pid){
  csvs <- dir_ls(glue("{p}/intensities")) %>% map(read_csv)
  tumor_cell_sum[i] <- csvs %>% sapply(nrow) %>% Reduce(f= "+")
  i=i+1
}

tumor_cell_sum
[1]  10309   5357   1722   3180   3122   7085   3253   5633   6017   2996
[11]   3961   5843   3205   2286  17007   4681   5423   8959   2390   6450
[21]   5762   8356   6753   3362  48248   4869  22704   3143   3385  27702
[31]  24242   2812   3141   7226   4336  32284   4701   7529   5691   1488
[41]   7912   3311   4264   4446   7562  39446   5045   3228 146392  14035
[51]   7027   4792  28308   2807   3632   7120  27290   8481   1042   5919
[61]   4769   4458   5814   6399   5638   3111   1192   3658   6543   3552
[71]  69003   6886   3231   4954   8885   4281   6364   2829   1624   3467
[81]  14962   4021   4529   2938  24263   5459  38351   4306   2787   4257
[91]   4972   5237   2472   8521   6531   3457   4422   6553   3377   6798
[101]   5192   9093   3253   3310   5169   2561   9983  10274   4312   2328
[111]   4200   1723   3186   1987  48248  33593   1554   2192   2801  35274
[121]  24668  36058  30898  16098  15383  23163  41470  25860  28589  45599
[131]  40413  10698   5822   2879   4730   3331  39887   5843   3921   3598
[141]   5826   2939   8846   4794   2936   4242  12330  30748   4980   6534
[151]   3963  18239   4104   7125   4681   6073   4810   5548   8903   5597
[161]  34956   5251  20324   2574   5118   5080   2427   6020   5590   8777
[171]   4616   1731   2470   5428   1895   3639   5465   6301   2269   4627
[181]   4954   7241   2561   4010   7326   5653   5635
tumor_sum <- tumor_cell_sum %>% Reduce(f= "+")
tumor_sum
[1] 1907840

# para
para_path <- "/cluster/home/jhuang/projects/hyperion/analysis/qzhang/human/steinbock/paracancerous/measure"
para_pid <- dir_ls(para_path)
i=1
para_cell_sum <- vector(mode = "numeric", length = length(para_pid))
for (p in para_pid){
  csvs <- dir_ls(glue("{p}/intensities")) %>% map(read_csv)
  para_cell_sum[i] <- csvs %>% sapply(nrow) %>% Reduce(f= "+")
  i=i+1
}

para_cell_sum
[1] 20062 13749 13913 15663 13261 20990 17501 18298 15952 16867 11501 16921
[13] 18306 18885 16309 15127 12712 25448 12504 26499 15754
para_sum <- para_cell_sum %>% Reduce(f= "+")
para_sum
[1] 356222

# chemotherapy
chemo_path <- "/cluster/home/jhuang/projects/hyperion/analysis/qzhang/human/steinbock/chemotherapy/measure"
chemo_pid <- dir_ls(chemo_path)
i=1
chemo_cell_sum <- vector(mode = "numeric", length = length(chemo_pid))
for (p in chemo_pid){
  csvs <- dir_ls(glue("{p}/intensities")) %>% map(read_csv)
  chemo_cell_sum[i] <- csvs %>% sapply(nrow) %>% Reduce(f= "+")
  i=i+1
}

chemo_cell_sum

chemo_sum <- chemo_cell_sum %>% Reduce(f= "+")
chemo_sum

# for loop
stypes <- c("puncture", "tumor", "paracancerous", "chemotherapy", "normal")
j=1
sum <- vector("numeric", length = length(stypes))
for (stype in stypes){
path <- glue("/cluster/home/jhuang/projects/hyperion/analysis/qzhang/human/steinbock/{stype}/measure")
pid <- dir_ls(path)
i=1
cell_sum <- vector(mode = "numeric", length = length(pid))
  for (p in pid){
    csvs <- dir_ls(glue("{p}/intensities")) %>% map(read_csv)
    cell_sum[i] <- csvs %>% sapply(nrow) %>% Reduce(f= "+")
    i=i+1
  }
sum[j] <- cell_sum %>% Reduce(f= "+")
j=j+1
}
names(sum) <- stypes

# ROI area
stypes <- c("puncture", "tumor", "paracancerous", "chemotherapy", "normal")
j=1
area_sum <- vector("numeric", length = length(stypes))
for (stype in stypes){
path <- glue("/cluster/home/jhuang/projects/hyperion/analysis/qzhang/human/steinbock/{stype}/measure")
pid <- dir_ls(path)
images <- vector(mode = "list", length = length(pid))
i=1
for (p in pid){
  images[[i]] <- glue("{p}/images.csv") %>% read_csv() %>%
    dplyr::mutate(ROI_area = width_px*height_px/1000000)
  i=i+1
}
area_sum[j] <- images %>% sapply('[',16) %>% sapply(sum) %>% Reduce(f = '+')
j = j + 1
}
names(area_sum) <- stypes


