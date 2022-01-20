<h3> Description </h3>
The purpose of this jupyter notebook is to identify different types of errors and outliers in the TopoChip screening data, and to exclude them in the downstream analysis.  Many systematic and stochastic errors can occur in a TopoChip screen such as, image artificats, inhomogeneous cell seeding, dust particles, miss-segmentation, or out of focus images (to name a few). <br>
<br>
The SOP describes the following steps:
<ol>
  <li>Statistical calculation of outlier TopoUnits</li>
  <li>Checking the images of the proposed outliers to verify the nature of the outliers</li>
  <li>Excluding outliers from downstream analysis</li>
</ol>

<h3> Requirements </h3>
<h5> Software </h5>
Python 3.8.5 <br>
Pandas (version 1.1.3) <br>
Matplotlib (version 3.3.2) <br>

<h5> Basic knowledge of the following definitions:</h5>
<ol>
  <li> Mean </li>
  <li> Standard deviation </li>
  <li> Median </li>
  <li> Interquartile Range (IQR) </li>
</ol>

<h5> Finished the following steps:</h5>
<ol>
  <li>Image cropping </li>
  <li>Align TopoMap</li>
 </ol>

<h3> How to start? </h3>
An extensive manual is provided that will guide you through each step (SOP 4.4). 

