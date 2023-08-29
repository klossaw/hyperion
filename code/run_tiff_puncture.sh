#!/bin/sh

raw_data_dir="/cluster/home/jhuang/projects/hyperion/data/qzhang/human/hyperion/array/mcd/puncture/"

patient_name=$(find ${raw_data_dir} -type d -maxdepth 1 -mindepth 1)

for patient in ${patient_name[@]} 
do
  echo ${patient}
  mcds=$(find ${patient} -type f)
  i=0
  disease=("liver" "pancreas") 
  for mcd in ${mcds[@]}
  do 
    cd ${patient}
    mkdir -p "/cluster/home/flora_jh/projects/hyperion/analysis/imctools/puncture/${PWD##*/}/${disease[i]}"
    python /cluster/home/flora_jh/projects/hyperion/code/make_tiff.py \
    -m ${mcd} -o "/cluster/home/flora_jh/projects/hyperion/analysis/imctools/puncture/${PWD##*/}/${disease[i]}"    
    i=`expr ${i} + 1`
    echo ${i}
  done

done

