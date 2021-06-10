<h1> Batch processing of images in CellProfiler </h1>


There are a few steps to take before you can run your CellProfiler on a cluster. (for BioInterface Science group members: we use cluster to refer to the windows server desktop). 

<h2> Step 1: build, test, and validate the CellProfiler pipeline </h2>
It is advised to build the CellProfiler pipeline on your local machine and to use the cluster only for calculations. Once you have build the pipeline, it is important to test and validate if it is working like you intended. The cluster will not continue with a batch once an error occurred, so test and validate with at least 10 random images if everything works fine. 

Once you have validated the pipeline, add the createBatchFiles module ( Edit --> Add Module --> File Processing ) to the end of your pipeline. This module is needed to resolve the pathnames to your files with respect to your local machine and the cluster computers. If you are processing large batches of images, you may also consider adding ExportToDatabase to your pipeline, after your measurement modules but before the CreateBatchFiles module. 

Run the pipeline on your laptop to create a batch file. Click the Analyze images button and the analysis will begin processing locally. This will take some time but is needed because CellProfiler must  create the entire image set list. However, once the batch file is created, it captures all of the data needed to run the analysis. You are now ready to submit this batch file to the cluster to run each of the batches of images on different computers on the cluster.

<h2> Step 2: batch processing of CellProfiler Pipeline </h2>
Transfer the pipeline and data to the cluster and create your own project folder. This project folder should contain the following subfolders:

1. InputData: to store your input data (i.e. cropped images).
2. OutputData: this will be an empty folder which will be filled once CellProfiler is running.

This folder can be filled with two subfolders: input and output data.
There are a number of paths you  have to specify in the shell script, which will not working without them, so be careful.
In notepad++ open the file "batchRunCellProfiler.sh" and change the following parameters:
1. Location input data: this is the folder where you will put the cropped images
2. Location output data: segmentation images and csv objects will be written to this folder
3. Location of the batch_data.hd5 file

Once you have set the paths, save the file and open the git bash terminal (windows search for 'Git Bash').
A terminal window will open and, by default, the working directory will be in the root folder set for the user. 
Type the following command to change the working directory ( for example to "c:\Users\Me\Documents\Project1")
```
cd "c:\Users\Me\Documents\Project1"
```
To run the bash script (located in c:\Users\Me\Documents\Project1), type the following command:
```
bash batchRunCellProfiler.sh
```
Now, the script will call the CellProfiler pipeline n times, with n equal to the number of batches.
