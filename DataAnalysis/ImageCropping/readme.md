## Description
The MATLAB script TopoCropper.m is used to crop the full TopoChip image into single TopoUnit images. The single TopoUnit images can be used as an input data set for CellProfiler to analyze cell reponse on single TopoUnits.

## Requirements
MATLAB R2021a 64-bit version

## preparations to run the program
The MATLAB script will look for the raw input images (three channels) in the folder /RawImages/. Before you start the cropping procedure, create a Chip## folder (with ** being the chip number in the format 01-99) in the /RawImages/ folder and place the single channel tiff images in the designated folder.
