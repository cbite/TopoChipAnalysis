import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import seaborn as sns
import seaborn as sns
import os
import cv2

def read_text_file(file_name=None,seperator=None):
    filename=pd.read_csv(os.getcwd()+file_name,sep=seperator)
    return filename

def set_working_directory(location_screen):
    old_directory=os.getcwd()
    os.chdir(location_screen)
    # Check if folder contains the chip folder structure
    subfolders=os.listdir()
    if '02_CroppedImages' in subfolders:
        print('Path to folder is set')
    else:
        print('Please check if path is correct')
        os.chdir(old_directory)

def retrieve_name_images_selected_features(selected_features=None,data_images=None,image_column=None):
    image_file_names=data_images.loc[data_images['FeatureIdx'].isin(selected_features),:]
    image_file_names=data_images.loc[:,['FeatureIdx','Metadata_Quadrant','Metadata_Duplicate',image_column]]
    return image_file_names

def plot_the_images(image_data=None,features_to_plot=None,image_type=None,image_mode='png',folder_to_select=None,number_of_rows=2,number_of_columns=10):
    chip_folders=os.listdir(os.getcwd()+folder_to_select)
    for feat in features_to_plot:
        image_data_feature=image_data.loc[image_data['FeatureIdx']==int(feat),:]
        figure,ax = plt.subplots(nrows=number_of_rows,ncols=number_of_columns,figsize=(25,7.5)) 
        images_top=image_data_feature.loc[image_data_feature['Metadata_Duplicate']==0,:]
        images_bottom=image_data_feature.loc[image_data_feature['Metadata_Duplicate']==1,:]
        indexTop=0
        indexBottom=10
        for chip in chip_folders:
            image_top_to_plot=images_top[image_type]
            image_top_to_plot=image_top_to_plot[image_top_to_plot.str.contains(chip)]
            image_top_to_plot=image_top_to_plot.astype(str)
            tmp_folder=os.getcwd()+folder_to_select+chip+'/'
            image_location_top=tmp_folder+image_top_to_plot
            if image_mode=='png':
                imgTop=mpimg.imread(image_location_top.item())
            if image_mode=='tif':
                # plot the TIF image with PIL
                imgTop=cv2.imread(image_location_top.item())
                imgTop = cv2.cvtColor(imgTop, cv2.COLOR_BGR2RGB)
            ax.ravel()[indexTop].imshow(imgTop,aspect='auto')
            ax.ravel()[indexTop].set_title(chip)
            ax.ravel()[indexTop].set_axis_off()
            
            image_bottom_to_plot=images_bottom[image_type]
            image_bottom_to_plot=image_bottom_to_plot[image_bottom_to_plot.str.contains(chip)]
            image_bottom_to_plot=image_bottom_to_plot.astype(str)
            tmp_folder=os.getcwd()+folder_to_select+chip+'/'
            image_location_bottom=tmp_folder+image_bottom_to_plot
            if image_mode=='png':
                imgBottom=mpimg.imread(image_location_bottom.item())

            if image_mode=='tif':
                # plot the tif image with PIL
                imgBottom=cv2.imread(image_location_bottom.item())
                imgBottom = cv2.cvtColor(imgBottom, cv2.COLOR_BGR2RGB)
            ax.ravel()[indexBottom].imshow(imgBottom,aspect='auto')
            ax.ravel()[indexBottom].set_title(chip)
            ax.ravel()[indexBottom].set_axis_off()
            
            figure.suptitle(feat,fontsize=24)
            indexTop=indexTop+1
            indexBottom=indexBottom+1


                                                
