import os
import matplotlib.image as mpig
import matplotlib.pyplot as plt
import xlrd
import cv2
import datetime
from datetime import date
from PIL import Image
from pylab import *
from PIL import Image
import matplotlib.pyplot as plt
from itertools import product
import numbers
import numpy as np


output_path = ''
#excel path
excel_path = '\\reconstruction_data.xls'
excel_path_c = '/reconstruction_data.xls'
book = xlrd.open_workbook(excel_path)
sheet1 = book.sheets()[0]
col1_values = sheet1.col_values(0)[1:]#name
col2_values = sheet1.col_values(1)[1:]#wide
col3_values = sheet1.col_values(2)[1:]#length
col6_values = sheet1.col_values(5)[1:]#numw

col9_values = sheet1.col_values(3)[1:]#wide stride
col10_values = sheet1.col_values(4)[1:]#height stride
#height num
col7_values = sheet1.col_values(6)[1:]
#path for local testing
prediction_path = ''
#path for HPC
temp_path = ''
files = os.listdir(prediction_path)
filelist = []
#list with path directory
biglist = []
idlist = []
for x in files:
    filelist.append(x)
    biglist.append(x)
    idlist.append(x)
#rename the files
for i in range(len(filelist)):
    #delete .bmp
    filelist[i] = filelist[i][0:-4]
    #
    if filelist[i].find('NIOS') == -1:
        filelist[i] = filelist[i].replace('  ', ' ')
        filelist[i] = filelist[i].replace('-', '',1)
        filelist[i] = filelist[i].replace(' ', '_')
        filelist[i] = filelist[i] + '_NIOS'
    filelist[i] = filelist[i][0:-5]
    filelist[i] = filelist[i] + '.bmp'
    biglist[i] = filelist[i] + temp_path
    idlist[i] = filelist[i][0:-7]
#identify each patient and clasify them to patches
cooo = 0
coo = 0
actual=list(set(idlist))
actual.sort()
#list of files for failed reconstruction
fail = []
#list of black images
black = []
#list of successful output
succ = 0

def reconstruction(xiaozu,numofpatcheswide,numofpatchesheight,weightstride,heightstride,h,w):
    coo = 0
    image_size= int(h*w)
    zeroes = np.zeros((h,w))

    heightp = [0]
    widthp = [0]
    numofpatches = numofpatcheswide*numofpatchesheight
    for j in range(1,int(numofpatchesheight)):
        heightp.append(j*(256 - heightstride))

    for i in range(1,int(numofpatcheswide)):
        widthp.append(i*(256 - weightstride))

    for jj in range(0,int(numofpatchesheight)):
        for ii in range(0,int(numofpatcheswide)):
            tempzeros = np.zeros((h,w))
            try:
                tempk = array(cv2.imread(xiaozu[jj][ii],0))
                tempzeros[int(heightp[jj]):int(heightp[jj]+256),int(widthp[ii]):int(widthp[ii]+256)] = tempk
                zeroes = zeroes + tempzeros
            except:

                pass

    #balance the illumination
    for kk in range(1,int(numofpatchesheight)):
        zeroes[int(heightp[kk]):int(heightp[kk] + heightstride),0:w] = 0.5*(zeroes[int(heightp[kk]):int(heightp[kk] + heightstride),0:w] )
    for qq in range(1,int(numofpatcheswide)):
        zeroes[0:h,int(widthp[qq]):int(widthp[qq] + weightstride)] = 0.5*(zeroes[0:h,int(widthp[qq]):int(widthp[qq] + weightstride)] )


    return zeroes




for i in range(len(actual)):

    #collect everything needed for the reconstruct 2d function
    #at this place i both represent the index of excel or the index of filelist
    #number of current file
    namef = col1_values[i]
    print('combining current file :' + namef)
    path = prediction_path + namef
    #number of patches
    numwidth = col6_values[i]
    numheight = col7_values[i]
    #the width of final image
    w = int(col2_values[i])
    #the height f the final image
    h = int(col3_values[i])
    #get the tuple
    tuple =(h,w)
    #load the patches
    ndarray = []
    #for my method
    xiaozu = [[0 for kk in range (int(numwidth))] for qq in range (int(numheight))]
    #wide stride
    widestride = col9_values[i]
    heightstride = col10_values[i]
    for ww in range(int(numheight)):
        for jj in range(int(numwidth)):
            str_path = path + '_' + str(ww + 1) + str(jj + 1) + '.bmp'
            # print(str_path)
            try:
                currentpatches = mpig.imread(str_path)
                ndarray.append(currentpatches)
                xiaozu[ww][jj] = str_path
            except:
                print('patches for ' + namef + '_' + str(ww + 1) + str(jj + 1)+ ' is loss for reconstruction')
                fail.append(namef)
                pass



    result = reconstruction(xiaozu,numwidth,numheight,widestride,heightstride,h,w)

    #ndarray = np.array(ndarray)
    #result = reconstruct_from_patches_2d(ndarray,tuple)
    if cv2.countNonZero(result) == 0:
        black.append(namef)
    else:
        #now that we have the tuple, than we can reconstruct the array using
        final_path = output_path + namef + '_combined_' + str(i+1) + '.bmp'
        print('successfully output: '+ final_path)
        succ = succ + 1
        #save the results
        cv2.imwrite(final_path,result)
#output the fail files
print('there are ' + str(len(fail)) + ' files are failed to be reconstructed as follow: ')
print(fail)
print('there are ' + str(len(black)) + ' files are black as follow: ')
print(black)
print('there are in all ' + str((succ))+ ' files are successfully outputted')











