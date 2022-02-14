<h2> Data visualization </h2>

This repository will contain the different jupyter notebooks which can be used to visualize your data in different manners. <br>
Data visualization is useful for data cleaning, exploring data structure, detecting outliers, identifying trends/patterns, and presenting results. It is essential for exploratory data analysis and data mining to check data quality and to help analysts become familiar with the structure and features of the data before them.

<h4> Software requirements </h4>
<ul>
  <li>Python</li>
  <li>Pandas</li>
  <li>Seaborn</li>
</ul>

<br>
<h3> Set up the environment in Anaconda </h3>
The folder <i>Environments </i> contains an environment (Python3_8_BIS.yml) file to build the python environment needed to run this notebook. Download the yml file and import the environment to anaconda. <br>
<br>
<h2> Interactive Scatterplot </h2><br>
This jupyter notebook contains a dynamic scatterplot for which the user can change the x or y parameter by using a dropdown menu. The position of each dot on the horizontal axis and vertical axis indicates values for an individual data point. Scatter plots are used to oserve relationships between variables. <br>
<u> Important: this notebook only works in jupyter Notebook and not in JupyterLab (both are available in Anaconda).</u>
<br>
<br>
<h3> Input data format </h3> <br>
This notebook takes a txt file as input, with at least three columns: id | column A | column B. Column A and B can be any parameter, as long as the values are numerical (type float64).
<br>

<h3> How to visualize your data </h3> <br>
Place the text file in the same folder as this jupyter notebook. Now, specify the filename in the following line of code (between parenthesis):<br>

```python
input_data=pd.read_csv(filename,sep='\t')
```
After you run every cell (with the play button) the scatterplot will appear.
