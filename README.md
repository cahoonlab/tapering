# tapering
MATLAB script to measure tapering of nanowires



This code includes a user interface modified from one originally built by Joseph Christesen in our laboratory (http://dx.doi.org/10.17615/76g6-rq73). A typical use of the program is as follows:

Load the program by running the SigmaExtract.m file in MATLAB. A graphical user interface (GUI) will appear.
    
Open an image with the button in the upper left corner. The image will appear in the GUI window.
    
Type the scale bar value in nanometers in the text box in the upper right. Click the "Set Scale" button. This assumes that the image was taken on the Helios 600 Nanolab Dual Beam instrument and has a scale bar in the bottom right corner.
    
Click the "Rotate" button. The cursor changes to a line tool. Click in the radial center of the NW near the base. While aligning the dashed line to the NW, double-click beyond the NW tip (to avoid unintentional cropping).
    
Click the "Calculate Diameter" button. The GUI changes to show the NW on bottom and the diameter profile on top. 
    
Click the "Display Beg/End" button. This will likely cause >2 vertical red lines to appear. The excess are a remnant of the old interface and will be deleted.
    
Click the "Edit Beg/End" button. A new figure window appears. By clicking and dragging, move one red line to the beginning of the desired measurement and one to the end. The others can be remove by a click-and-hold while pressing the "d" key. A new line can be created with a right-click. When the measurement area is marked with two lines, push the space bar to return to the GUI. The lines will be updated in the GUI.
    
Click the "Calculate Sigma" button.A new figure window will appear with a summary of the data from the GUI including a linear interpolation of the region between the two markers positioned earlier. The value for sigma is burned onto the image. This figure is easily saved or copied for future reference.
    
Note that the results are also saved in a workspace struct variable called "extracted".
