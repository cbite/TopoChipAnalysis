# -*- coding: utf-8 -*-
"""
Created on Thu Jun 10 16:48:31 2021

@author: tkuijpe1
"""
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import seaborn as sns
import pandas as pd
import os

def createDisplot(inputDF):
    tmpDF=pd.melt(inputDF)
    plt.figure()
    g=sns.FacetGrid(tmpDF,col='variable',col_wrap=3,aspect=1.5,sharex=False)
    g.map(sns.histplot,'value',bins=50)
    plt.subplots_adjust(hspace=0.3, wspace=0.8)

def extractFileNamesLowQuality(inputDF,thresholdKey,thresholdValue,option='smaller'):
    columnsToSelect=inputDF.columns[inputDF.columns.str.contains('FileName')]
    if option=='smaller':
            lowQualityImages=inputDF.loc[inputDF[thresholdKey]<thresholdValue,columnsToSelect]
    if option=='greater':
        lowQualityImages=inputDF.loc[inputDF[thresholdKey]>thresholdValue,columnsToSelect]
    return lowQualityImages

def plotSelectedImages(filteredImagesLocation,inputFolder):
    fig=plt.figure()
    i=1
    for x in filteredImagesLocation.columns:
        image=filteredImagesLocation.loc[:,x]
 
        for y in image:
            image2=y
            image2=image2.replace('.tif','.png')
            imageLocation=inputFolder+image2
            if os.path.isfile(imageLocation):
               im=mpimg.imread(imageLocation)
               ax=plt.subplot(3,1,i)
               ax.imshow(im,aspect=0.9)
               ax.set_title(image2, size=8)
               i=i+1
               plt.subplots_adjust(hspace = 1,wspace=.001)
            else:
                print("Image not found")
    plt.show()