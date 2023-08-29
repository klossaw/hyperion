raw_data_dir="/cluster/home/jhuang/projects/hyperion/data/qzhang/human/hyperion/array/mcd/paracancerous/"

mcds=$(find ${raw_data_dir} -type f -name "*.mcd")

for mcd in ${mcds[@]} 
do
  echo ${mcd}
  chip=$(find ${mcd} -type f -printf "%f\n") 
  chip=${chip::-4}
  echo ${chip}
  mkdir -p "/cluster/home/flora_jh/projects/hyperion/analysis/imctools/paracancerous/${chip}/"
  python /cluster/home/flora_jh/projects/hyperion/code/make_tiff.py \
  -m ${mcd} -o "/cluster/home/flora_jh/projects/hyperion/analysis/imctools/paracancerous/${chip}/"
done

