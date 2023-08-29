from imctools.io.mcd.mcdparser import McdParser

parser = McdParser("/cluster/home/jhuang/projects/hyperion/data/qzhang/human/hyperion/array/mcd/tumor/2T芯片（2T_ROI_5）/LTB_LY_20200701_PDAC_2T_02.mcd")
xml = parser.get_mcd_xml()
session = parser.session
ids = parser.session.acquisition_ids

for i in ids:
    ac_data = parser.get_acquisition_data(int(i))
    ac_data.save_ome_tiff("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/p209_pdac"+"/ROI_"+str(i)+".ome.tiff")
    ac_data.save_tiffs("/cluster/home/flora_jh/projects/hyperion/analysis/imctools/tumor/p209_pdac", compression=0, bigtiff=False)

parser.close()

