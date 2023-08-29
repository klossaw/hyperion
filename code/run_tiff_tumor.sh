#!/bin/sh

raw_data_dir="/cluster/home/jhuang/projects/hyperion/data/qzhang/human/hyperion/array/mcd/tumor/"

patient_name=$(find ${raw_data_dir} -type d -maxdepth 1 -mindepth 1)

for patient in ${patient_name[@]} 
do
  echo ${patient}
  mcd=$(find ${patient} -type f -name "*.mcd")
  cd ${patient}
  mkdir -p "/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/${PWD##*/}"
  python /cluster/home/flora_jh/projects/hyperion/code/make_tiff.py \
  -m ${mcd} -o "/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/${PWD##*/}"    
done


