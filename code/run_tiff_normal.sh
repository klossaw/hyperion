raw_data_dir="/cluster/home/jhuang/projects/hyperion/data/qzhang/human/hyperion/array/mcd/normal/"

mcds=$(find ${raw_data_dir} -type f)

for mcd in ${mcds[@]} 
do
  echo ${mcd}
  donor=$(find ${mcd} -type f -printf "%f\n") 
  donor=${donor::-4}
  echo ${donor}
  mkdir -p "/cluster/home/flora_jh/projects/hyperion/analysis/imctools/normal/${donor}"
  python /cluster/home/flora_jh/projects/hyperion/code/make_tiff.py \
  -m ${mcd} -o "/cluster/home/flora_jh/projects/hyperion/analysis/imctools/normal/${donor}"
done
