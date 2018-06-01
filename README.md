# MyelinQ

This is the program of the method proposed in *A Novel Image Segmentation Method for the Evaluation of Inflammation-induced Cortical and Hippocampal White Matter Injury in Neonates* submitted to Journal of Chemical Neuroanatomy.

This Matlab program (**MyelinQ**) can be used to quantify myelin in DAB-stained sections of neonatal mouse brain. The area of myelin is quantified in the whole image (brain/hemisphere) or in an ROI (if provided).

Directions to use the program
* Step 0: You can download and run the program in two ways: 1) Download all files in the *matlab* folder and double click or open **MyelinQ.m** in Matlab (you need to have Matlab installed), and click on Run (or press F5 to run); 2) Download and install the standalone program in the *standalone* folder (it will need you to download and install MATLAB Runtime for R2016a from http://www.mathworks.com/products/compiler/mcr/index.html).
* Step 1: Select the image folder and select images on the left pane to be analyzed.
* Step 2: Choose whether you want to quantify myelin in an ROI or not. If yes, you should specify the ROI folder. The ROI folder can have as many subfolders as you wish. The name of each subfolder should be the name of the ROI (for example, *Cortical*, *Striatal*, etc.). In each subfolder you should put image(s) that has outlined *closed* ROI with *red* marker. The name of the files should be the same as the name of the original images. An example is included in the *sample* directory and can be downloaded.
* Step 3: Choose whether to save the segmentation results. If you select to do so, you should specify a folder that the images will be saved into. The results are saved in *PNG* format and include the mask and also the outlined segmented area on the original image.
* Step 4: Select whether you want the results to be saved in an excel. If checked, the results will be saved in an excel file in the image folder.
* Step 5: Analyze!

Note that two parameters are set based on the image resolution in metadata. Therefore, if image metadata information does not exist or is incorrect, the parameters may not be set correctly! That is the main reason that only *tif* or *tiff* images are considered in this version. Also, provide the original images through *Image Folder*. Feel free to modify the code to use other images or set the parameters manually!

If you select to use this program in your research please consider citing the article mentioned above.

If you have any questions, you can contact me directly at parham.ap@gmail.com.