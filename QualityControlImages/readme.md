<h1> Quality control images based on CellProfiler's MeasureImageQuality moduel </h1>

The MeasureImageQuality module collects measurements indicating possible image aberrations, e.g., blur (poor focus), intensity, and saturation. These measurements can be used
to exclude images during post-processing. 

<h2> Blur metrics </h2>
- Focus Score: A measure of the intensity variance across the image. Higher focus scores indicate lower bluriness. It is usefull to distinguish extremely blurry images.
- LocalFocusScore: A measure of the intensity variance between image sub-regions. t can be useful in differentiating good versus badly segmented images in the cases when badly segmented images usually contain no cell objects with high background noise.

<h2> Saturation metrics </h2>
- PercentMaximal: Percent of pixels at the maximum intensity value of the image.
- PercentMinimal: Percent of pixels at the minimum intensity value of the image.


<h2> Exlude images based on quality criteria </h2>
Based on the quality metrics, you can plot the distribution of the blur and saturation metrics. based on this distribution, you can select images based on a seletion threshold and 
identify if the quality of those images is too low.
