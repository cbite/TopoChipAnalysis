<h3> Data visualization </h3>

This repository will contain the different jupyter notebooks which can be used to visualize your data in different manners. <br>
Data visualization is useful for data cleaning, exploring data structure, detecting outliers, identifying trends/patterns, and presenting results. It is essential for exploratory data analysis and data mining to check data quality and to help analysts become familiar with the structure and features of the data before them.

<h4> Software requirements </h4>
<ul>
  <li>Python</li>
  <li>Pandas</li>
  <li>Seaborn</li>
</ul>


<h3> Interactive Scatterplot </h3>
This jupyter notebook contains a dynamic scatterplot for which the user can change the x or y parameter by using a dropdown menu. The position of each dot on the horizontal axis and vertical axis indicates values for an individual data point. Scatter plots are used to oserve relationships between variables. <br>

<i> Input data format </i> <br>
This notebook takes a txt file as input, with at least three columns: id | column A | column B. Column A and B can be any parameter, as long as the values are numerical (type float64).

<i> How to visualize your data </i> <br>
Place the text file in the same folder as this jupyter notebook. Now, specify the filename in the following line of code (between parenthesis):<br>

```python
input_data=pd.read_csv(filename,sep='\t')
```
