# -*- coding: utf-8 -*-
"""
Created on Fri Apr 30 14:58:25 2021

@author: tkuijpe1
"""
import matplotlib.pyplot as plt
import pandas as pd

def removeOutliersWithIQR(ScreenData, featureOfInterest, perTopoFeature=True):
    def filterIQR(ScreenData, featureOfInterest):
        q1 = ScreenData[featureOfInterest].quantile(0.25)                 
        q3 = ScreenData[featureOfInterest].quantile(0.75)
        iqr = q3 - q1
        # define filter based on the quantile Interquantile range
        return(ScreenData.loc[ScreenData[featureOfInterest].between(q1 - 1.5*iqr,q3 + 1.5*iqr)])
        
        
    
    if(perTopoFeature):        
        ScreenData_filtered=ScreenData.groupby("FeatureIdx").apply(lambda x: filterIQR(x, featureOfInterest))        
    else:
        ScreenData_filtered=filterIQR(ScreenData, featureOfInterest)
        
    plt.boxplot([ScreenData_filtered[featureOfInterest],ScreenData[featureOfInterest]],
                labels=["After Outliers Removal", "Original Data"])
    return ScreenData_filtered   

