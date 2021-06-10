<h1> Batch processing of images in CellProfiler </h1>


There are a few steps to take before you can run your CellProfiler on a cluster. 

<h2> Step 1: build, test, and validate the CellProfiler pipeline </h2>

<h2> Step 2: batch processing of CellProfiler Pipeline </h2>
Transfer the pipeline and data to the cluster (for BioInterface Science group members: we use cluster to refer to the windows server desktop). 
Create your own project folder, with the following subfolders:

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
