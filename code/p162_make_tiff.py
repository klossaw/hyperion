from imctools.io.mcd.mcdparser import McdParser

parser = McdParser("/cluster/home/jhuang/projects/hyperion/data/qzhang/human/hyperion/array/mcd/tumor/1T芯片（1T_ROI_7）/LTB_LY_20200524_PDAC_1T_01.mcd")
xml = parser.get_mcd_xml()
session = parser.session
ids = parser.session.acquisition_ids

for i in ids:
	ac_data = parser.get_acquisition_data(int(i))
	ac_data.save_ome_tiff("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/p162_pdac"+"/ROI_"+str(i)+".ome.tiff")
	ac_data.save_tiffs("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/p162_pdac", compression=0, bigtiff=False)

parser.close()

parser = McdParser("/cluster/home/jhuang/projects/hyperion/data/qzhang/human/hyperion/array/mcd/tumor/1T芯片（1T_ROI_补充）/LTB_LY_20200608_PDAC_1T_02.mcd")
xml = parser.get_mcd_xml()
session = parser.session
ids = parser.session.acquisition_ids
for i in ids:
	ac_data = parser.get_acquisition_data(int(i))
	ac_data.save_ome_tiff("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/p162_7_split"+"/ROI_"+str(i)+".ome.tiff")
	ac_data.save_tiffs("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/p162_7_split", compression=0, bigtiff=False)

parser.close()
 



