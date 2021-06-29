import numpy as np
import seaborn as sns
import math
import matplotlib.pyplot as plt
import PIL
import pandas as pd
import shap
from sklearn.preprocessing import StandardScaler
import sklearn
from xgboost import XGBClassifier, plot_importance

def surfaceDesignTopAndBottom(SortedRank,folderName, featureOfInterest, number, surfPerRow=6):
#    MetadatPixel5020_3=list(MetadatPixel5020_2[125])
#    individual=MetadatPixel5020_3[0]
    top=SortedRank.iloc[np.r_[0:number]].reset_index(drop=True)
    bottom=SortedRank.iloc[np.r_[-number:0]].reset_index(drop=True)
    bottom.reindex(index=bottom.index[::-1]).reset_index(drop=True)
    ncols=np.int(surfPerRow/2)
    nrows=math.ceil((number*2)/surfPerRow)   
    
    fig =plt.figure(constrained_layout=False)
    axes=[]
    fig.set_figwidth(20)
    fig.set_figheight(4*nrows)
    
    
    gs1 = fig.add_gridspec(nrows=nrows, 
                           ncols=ncols, 
                           left=0.01, 
                           right=0.49,
                            wspace=0.01)
    
    
    
    gs2 = fig.add_gridspec(nrows=nrows, 
                           ncols=ncols,
                            left=0.51, 
                            right=1,
                            wspace=0.01)
    
    
    
    fig.suptitle("%s \n \n \n Top                          Bottom"%featureOfInterest)
    
    i=0
    
    while i< len(top.index):
        
        
        for r in range(nrows):
            for c in range(ncols):
                
               
                       
                featureIdx=top.at[i,"FeatureIdx"]
            
                fileName="Pattern_FeatureIdx_%d.png"%featureIdx


                featureValue=top.at[i,featureOfInterest]
                
                s_image=np.array(PIL.Image.open(folderName+fileName).convert("L"))

                imagesize=np.shape(s_image)[0]

                tilenumber=math.ceil(560/imagesize)

                geneimagetiled=PIL.Image.fromarray(np.tile(s_image.astype(np.uint8),
                                                       (tilenumber,tilenumber))[0:560,0:560]).resize([100,100])
                
                axes.append(fig.add_subplot(gs1[r,c]))
                axes[-1].imshow(geneimagetiled,cmap="gray")
                axes[-1].set_xticks([])
                axes[-1].set_yticks([])
                axes[-1].set_title("Feature_%d \n value=%f"%(featureIdx,featureValue))
                
                i+=1
                if i == len(top.index):
                    break

        
    j=0
    
    while j< len(bottom.index):
        
        
        for r in range(nrows):
            for c in range(ncols):
                
        
                featureIdx=bottom.at[j,"FeatureIdx"]
            
                fileName="Pattern_FeatureIdx_%d.png"%featureIdx


                featureValue=bottom.at[j,featureOfInterest]
                
                s_image=np.array(PIL.Image.open(folderName+fileName).convert("L"))

                imagesize=np.shape(s_image)[0]

                tilenumber=math.ceil(560/imagesize)

                geneimagetiled=PIL.Image.fromarray(np.tile(s_image.astype(np.uint8),
                                                       (tilenumber,tilenumber))[0:560,0:560]).resize([100,100])
                
                axes.append(fig.add_subplot(gs2[r,c]))
                axes[-1].imshow(geneimagetiled,cmap="gray")
                axes[-1].set_xticks([])
                axes[-1].set_yticks([])
                axes[-1].set_title("Feature_%d \n value=%f"%(featureIdx,featureValue))
                
                j+=1
                if j == len(bottom.index):
                    break
    
    plt.show()

def selectDescriptors(allDescriptors, keywordsToInclude=None, keywordsToExclude=None):
    
    if(not keywordsToInclude==None):
        
        keywordsToInclude.append("FeatureIdx")
        
        filteredDescriptorspos=allDescriptors.loc[:,allDescriptors.columns.str.contains(
        "|".join(keywordsToInclude))]
          
    else:
        filteredDescriptorspos=allDescriptors
    
    if(not keywordsToExclude==None):
        
        if(keywordsToExclude==1):
            filteredDescriptorsposneg=filteredDescriptorspos.loc[:,~filteredDescriptorspos.columns.str.contains(
                keywordsToExclude)]
        else:
            filteredDescriptorsposneg=filteredDescriptorspos.loc[:,~filteredDescriptorspos.columns.str.contains(
                    '|'.join(keywordsToExclude))]
    else:
        filteredDescriptorsposneg=filteredDescriptorspos
        
    return filteredDescriptorsposneg

def combineRankAndDescriptorsClassyfication(SortedRank, 
                                            Descriptors, 
                                            numberPerClass, 
                                            scaleFeatures=True):
    
    topoformodel=pd.merge(left=SortedRank, right=Descriptors,
                      how='left', left_on="FeatureIdx", 
                      right_on="FeatureIdx")# Merge 2 datasets
    
    topoformodel["Class"]=-1#cretae column Class
    topoformodel.loc[topoformodel.Rank<=numberPerClass,"Class"]=1 #assign 1 to the surfaces at the top of the rank
    topoformodel.loc[topoformodel.Rank>(max(topoformodel.Rank)-numberPerClass),"Class"]=0 #assign 0 to the surfaces at the bottom of the rank
    
    dataForModel=topoformodel.loc[topoformodel["Class"]>-1,:]#remove rows that were not selected 
    
    dataForModel=dataForModel.loc[:,~topoformodel.columns.str.contains(
                    '|'.join(SortedRank.columns))].reset_index(drop=True)#remove column names thata are in ranking dataframe, 
    
    
    X_temp=dataForModel[dataForModel.columns[~dataForModel.columns.str.contains(pat="Class")]]#select values for X
    Y=dataForModel["Class"]#select values for Y
    
    if(scaleFeatures):
        X=pd.DataFrame(data=StandardScaler().fit_transform(X_temp),  columns=X_temp.columns)
    else:
        X=X_temp
    
    return (X,Y)


def explainer(dataForModel, model,hit):         
    showSurf=dataForModel.iloc[[hit]]
    showSurf_predicted = model.predict(showSurf)
    showSurf_probability = model.predict_proba(showSurf)

    print(f'Predicted Probability (Bottom, Top): {showSurf_probability}')
    print(f'Predicted Rank (0 = Bottom, 1 = Top): {showSurf_predicted}','\n')
   
    #define explainer form the shap package
    explainer = shap.TreeExplainer(model, model_output='probability', 
                                   feature_dependence='interventional', 
                                   data=dataForModel)
    shap_values = explainer.shap_values(showSurf)
    shap.initjs()
    display(shap.force_plot(explainer.expected_value, shap_values, showSurf))
    
    return  explainer
