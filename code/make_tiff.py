import argparse
from imctools.io.mcd.mcdparser import McdParser
import os
from os import listdir
from os.path import isfile, join

parser = argparse.ArgumentParser(description='manual to this script')
parser.add_argument('-m', '--mcd', type=str, default=None)
parser.add_argument('-o', '--outdir', type=str, default=None)
args = parser.parse_args()

parser = McdParser(args.mcd)
xml = parser.get_mcd_xml()
session = parser.session
ids = parser.session.acquisition_ids
for i in ids:
    ac_data = parser.get_acquisition_data(int(i))
    ac_data.save_ome_tiff(args.outdir+"/ROI_"+str(i)+".ome.tiff")
    ac_data.save_tiffs(args.outdir, compression=0, bigtiff=False)
    
parser.close()
