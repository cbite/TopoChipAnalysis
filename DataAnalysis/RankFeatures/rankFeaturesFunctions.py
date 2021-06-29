########################################################################################################
###################### Functions used in the 3_Rank_Features_TopoChip        ###########################
########################################################################################################
import pandas as pd
import matplotlib.pyplot as plt
from scipy.stats import ks_2samp, anderson_ksamp
import numpy as np
import seaborn as sns

def calculateRank(ScreenData, featureOfInterest):#add rnking based on the locational effect
          
    def calculateKSpvalue(subgroup):
        sg1 = subgroup.loc[subgroup.Metadata_Duplicate==0,featureOfInterest]                 
        sg2 = subgroup.loc[subgroup.Metadata_Duplicate==1,featureOfInterest]
        _, pvalue=ks_2samp(sg1, sg2)
        # define filter based on the quantile Interquantile range
        return(pvalue)
    
    def calculateADpvalue(subgroup):
        sg1 = subgroup.loc[subgroup.Metadata_Duplicate==0,featureOfInterest]                 
        sg2 = subgroup.loc[subgroup.Metadata_Duplicate==1,featureOfInterest]
        # Check sg1 unequal to sg2
        if np.array_equal(np.unique(sg1),np.unique(sg2)):
            pvalue=1
        else:
            _,_,pvalue=anderson_ksamp([sg1, sg2])
        
        # define filter based on the quantile Interquantile range
        return(pvalue)
    
    KSpvalue=ScreenData.groupby(["FeatureIdx"])[["Metadata_Duplicate",featureOfInterest]].apply(calculateKSpvalue)
    ADpvalue=ScreenData.groupby(["FeatureIdx"])[["Metadata_Duplicate",featureOfInterest]].apply(calculateADpvalue)
    mean = ScreenData.groupby("FeatureIdx")[featureOfInterest].mean()                 
    std = ScreenData.groupby("FeatureIdx")[featureOfInterest].std()
    snrscore = mean/std
    median = ScreenData.groupby("FeatureIdx")[featureOfInterest].median()
    data={"Screen_ADpvalue_%s"%featureOfInterest:ADpvalue,
        "Screen_KSpvalue_%s"%featureOfInterest:KSpvalue,
          "Screen_SNR_%s"%featureOfInterest:snrscore,
        "Screen_Mean_%s"%featureOfInterest:mean,
         "Screen_SD_%s"%featureOfInterest:std,
         "Screen_Median_%s"%featureOfInterest:median}
    rank=pd.DataFrame(data).reset_index()
    
    return rank

def plotSurfaceRankMeasurements(rankObject):
    fig, axs = plt.subplots(3,2, figsize=(15, 10), facecolor='w', edgecolor='k')
    fig.subplots_adjust(hspace = 0.5, wspace=1.25)
    axs = axs.ravel()
    index=0
    for x in rankObject.columns:
        if(x!='FeatureIdx'):
            axs[index].hist(rankObject[x])
            axs[index].set_title(x)
            index=index+1
    plt.show()
    
def makePairPlot(rank):
    rank=rank.copy()
    rank.columns=rank.columns.str.strip().str.replace('Screen_', '').str[0:10]+"..."#shorten column names
    sns.pairplot(rank)# make a pairplot

def filterRank(rank, filterMetric, valuesRangeToInclude):
    left=valuesRangeToInclude[0]
    right=valuesRangeToInclude[1]
    filteredRank=rank.loc[rank[filterMetric].between(left, right)]
    if (not any(filteredRank.FeatureIdx==2177)):
        print("Flat was removed during filtering, but we will fix it now for you")
        filteredRank=filteredRank.append(rank.loc[rank.FeatureIdx==2177])
    
    excludedSurf=rank.loc[~rank.FeatureIdx.isin(filteredRank.FeatureIdx)]
    print("%d unique surafces were excluded from the analysis"%(len(excludedSurf.index)))
    print("The following FeatureIdx were excluded based on the %s"%(filterMetric))
    for surf in excludedSurf.FeatureIdx: print(surf)
    return(filteredRank)

def sortRanked(rank, featureOfInterest):
    RankSorted=rank.sort_values(by=[featureOfInterest],ascending=False)
    rankSize=len(rank.index)
    RankSorted["Rank"]=np.linspace(1, rankSize, num=rankSize)
    return RankSorted.reset_index(drop=True)

def filterRank(rank, filterMetric, valuesRangeToInclude):
    left=valuesRangeToInclude[0]
    right=valuesRangeToInclude[1]
    filteredRank=rank.loc[rank[filterMetric].between(left, right)]
    if (not any(filteredRank.FeatureIdx==2177)):
        print("Flat was removed during filtering, but we will fix it now for you")
        filteredRank=filteredRank.append(rank.loc[rank.FeatureIdx==2177])
    
    excludedSurf=rank.loc[~rank.FeatureIdx.isin(filteredRank.FeatureIdx)]
    print("%d unique surafces were excluded from the analysis"%(len(excludedSurf.index)))
    print("The following FeatureIdx were excluded based on the %s"%(filterMetric))
    for surf in excludedSurf.FeatureIdx: print(surf)
    return(filteredRank)

def plotRank(rank, featureOfInterest):
    
    RankSorted=sortRanked(rank, featureOfInterest)
    
    ax = RankSorted.plot.scatter(y=featureOfInterest,
                      x="Rank", c=featureOfInterest,
                           colormap='viridis')
    RankSorted.loc[RankSorted.FeatureIdx==2177].plot.scatter(x="Rank", 
    y=featureOfInterest, ax=ax, s=200)
    
def boxPlotTopAndBottom(screenData,rank, featureOfInterest, numberOfSurfaces):
    
    RankSorted=sortRanked(rank, featureOfInterest)
    flatIndex=RankSorted.index[RankSorted.FeatureIdx == 2177].tolist()
    screenData_filtered=pd.merge(left=screenData, 
                    right=RankSorted.iloc[np.r_[0:numberOfSurfaces,flatIndex, -numberOfSurfaces:0]],
                      how='left', left_on="FeatureIdx", 
                      right_on="FeatureIdx")
    
    plt.figure(figsize=(20,5))
    ax = sns.boxplot(y=featureOfInterest.partition("_")[2].partition("_")[2],
                x='Rank', 
                data=screenData_filtered)
    plt.setp(ax.get_xticklabels(), rotation=45)
    
    labels = [item.get_text() for item in ax.get_xticklabels()]
    labels = RankSorted.FeatureIdx.iloc[np.r_[0:numberOfSurfaces,flatIndex, -numberOfSurfaces:0]]

    ax.set_xticklabels(labels)

    #plt.setp(ax.get_xticklabels(),text=data.FeatureIdx)
    plt.show()
    
    
def showImagesFlat(ScreenData, featureOfInterest, stainingFile, mode="raw" ):
    
      
    folderNameRaw=path_to_screen+"3_imaging//cropped//Chip_%d//"
    folderNameOverlay=path_to_screen+"4_analysis//imageAnalysis//results//segmentationResults//Chip_%d//"
        
        
    
    listOfFiles=ScreenData.loc[ScreenData["FeatureIdx"]==2177]#.fillna(0)
    
      
    if(len(listOfFiles.index)>100):
        rows=listOfFiles.sample(n=100).reset_index()
    else:
        rows=listOfFiles.reset_index()
    
    #FeatImg = PIL.Image.open('Surface_Images/Pattern_FeatureIdx_{}.bmp'.format(i)).convert("L")
    
   
    plt.figure(figsize=(20,4*len(rows.index)))
    
        
    
    for i, row in rows.iterrows():
        
        if(mode=="overlay"):
            
            folderName=folderNameOverlay            
                      
            fileName=row[stainingFile].replace(".tiff","actinOverlay.png")
            
            #fileName="Row1_Col1_c1_actinOverlay.png"
            
            cmap="cividis"
            
        else:
            
            folderName=folderNameRaw
            fileName=row[stainingFile]
            
            #fileName="Row1_Col1_c1.tiff"
            
            cmap='gray'
        
        featureValue=row[featureOfInterest]
        chip=row["Metadata_Chip"]
        chipRow=row["Metadata_Row"]
        chipCol=row["Metadata_Col"]
        imageFolder=folderName%chip
                                                                        
        s_image=PIL.Image.open(imageFolder+fileName)#.convert("L")
                      
        plt.subplot(math.ceil(len(rows.index)/3),3,i+1)
        plt.xticks([])
        plt.yticks([])
        plt.grid(False)
        plt.imshow(s_image,cmap=cmap)
        plt.xlabel("Chip-%d Row-%d Col-%d \n %s = %s"%(chip, chipRow, chipCol, featureOfInterest, featureValue))
    
    plt.tight_layout()
    plt.show()
    
def showImagesTopAndBottom(rank, ScreenData, featureOfInterest,numberOfSurfaces, 
                           stainingFile, mode="raw",surfPerRow=6):
#    MetadatPixel5020_3=list(MetadatPixel5020_2[125])
#    individual=MetadatPixel5020_3[0]

    RankSorted=sortRanked(rank, featureOfInterest)
    
    top=RankSorted.iloc[np.r_[0:numberOfSurfaces]].reset_index(drop=True)
    
    bottom=RankSorted.iloc[np.r_[-numberOfSurfaces:0]].reset_index(drop=True)
    bottom.reindex(index=bottom.index[::-1]).reset_index(drop=True)
    
    
    folderNameRaw=path_to_screen+"3_imaging//cropped//Chip_%d//"
    folderNameOverlay=path_to_screen+"4_analysis//imageAnalysis//results//segmentationResults//Chip_%d//"
        
    listOfFilesTop=ScreenData.loc[ScreenData["FeatureIdx"].isin(top.FeatureIdx)].reset_index(drop=True)
      
    listOfFilesBottom=ScreenData.loc[ScreenData["FeatureIdx"].isin(bottom.FeatureIdx)].reset_index(drop=True)
    
    numberOfRawImages=len(listOfFilesTop.index)+len(listOfFilesBottom.index)
    
    ncols=np.int(surfPerRow/2)
    nrows=math.ceil((numberOfRawImages)/surfPerRow)
        
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
    for r in range(nrows):
        for c in range(ncols):
            if(mode=="overlay"):

                folderName=folderNameOverlay            

                fileName=listOfFilesTop.at[i, stainingFile].replace(".tiff","actinOverlay.png")

                #fileName="Row1_Col1_c1_actinOverlay.png"

                cmap="cividis"

            else:

                folderName=folderNameRaw

                fileName=listOfFilesTop.at[i,stainingFile]


                #fileName="Row1_Col1_c1.tiff"

                cmap='gray'

            featureIdx=listOfFilesTop.at[i,"FeatureIdx"]

            featureValue=listOfFilesTop.at[i,featureOfInterest.partition("_")[2].partition("_")[2]]

            chip=listOfFilesTop.at[i,"Metadata_Chip"]

            imageFolder=folderName%chip

            s_image=np.array(PIL.Image.open(imageFolder+fileName).convert("L"))


            axes.append(fig.add_subplot(gs1[r,c]))
            axes[-1].imshow(s_image,cmap=cmap)
            axes[-1].set_xticks([])
            axes[-1].set_yticks([])
            axes[-1].set_title("Chip_%d, Feature_%d \n value=%f"%(chip, featureIdx,featureValue))

            i+=1
            if (i == len(listOfFilesTop.index)):
                break
        
        if (i == len(listOfFilesTop.index)):
            break
                    
    j=0
    for r in range(nrows):
        for c in range(ncols):
            if(mode=="overlay"):
                folderName=folderNameOverlay            

                fileName=listOfFilesBottom.at[j,stainingFile].replace(".tiff","actinOverlay.png")
                #fileName="Row1_Col1_c1_actinOverlay.png"

                cmap="cividis"

            else:

                folderName=folderNameRaw
                fileName=listOfFilesBottom.at[j, stainingFile]

                #fileName="Row1_Col1_c1.tiff"

                cmap='gray'

            featureIdx=listOfFilesBottom.at[j,"FeatureIdx"]

            chip=listOfFilesBottom.at[j,"Metadata_Chip"]

            imageFolder=folderName%chip

            featureValue=listOfFilesBottom.at[j,featureOfInterest.partition("_")[2].partition("_")[2]]

            s_image=np.array(PIL.Image.open(imageFolder+fileName).convert("L"))


            axes.append(fig.add_subplot(gs2[r,c]))
            axes[-1].imshow(s_image,cmap=cmap)
            axes[-1].set_xticks([])
            axes[-1].set_yticks([])
            axes[-1].set_title("Chip_%d, Feature_%d \n value=%f"%(chip, featureIdx,featureValue))

            j+=1

            if j == len(listOfFilesBottom.index):
                break
        if j == len(listOfFilesBottom.index):
                break
    
    plt.show()