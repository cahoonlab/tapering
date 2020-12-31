function varargout = SigmaExtract(varargin)
% SIGMAEXTRACT MATLAB code for SigmaExtract.fig
%      This code was adapted from nanoWireDiamter written by Joseph
%      Christesen and reported in his PhD dissertation at UNC-Chapel
%      Hill in 2016.
%      Adapted by Jonathan K. Meyers, UNC-Chapel Hill, August 2017
%      http://orcid.org/0000-0002-6698-3420
%      Written for MATLAB R016a
% 
%      I removed the binning features to convert the image to black and
%      white and adjust the brightness and contrast. I found that it 
%      wasn't reliable enough. Now what you must do is copy your SEM 
%      image, edit it in Photoshop (change it to black and white, then 
%      adjust the levels to create the most contast, and you can do spot 
%      cleaning if the middle of the nanowire didn't become white), and 
%      then load it into this program. I find it's more reliable this 
%      way.
% 
%      In addition to that change, I also added code to calculate the
%      tapering parameter based on the measured diameter profile.
% 
% 
%
%      SIGMAEXTRACT, by itself, creates a new SIGMAEXTRACT or raises 
%      the existing singleton*.
%
%      H = SIGMAEXTRACT returns the handle to a new SIGMAEXTRACT or the 
%      handle to the existing singleton*.
%
%      SIGMAEXTRACT('CALLBACK',hObject,eventData,handles,...) calls the 
%      local function named CALLBACK in SIGMAEXTRACT.M with the given 
%      input arguments.
%
%      SIGMAEXTRACT('Property','Value',...) creates a new SIGMAEXTRACT 
%      or raises the existing singleton*.  Starting from the left, 
%      property value pairs are applied to the GUI before 
%      SigmaExtract_OpeningFcn gets called.  An unrecognized property 
%      name or invalid value makes property application stop.  All 
%      inputs are passed to SigmaExtract_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only 
%      one instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SigmaExtract

% Last Modified by GUIDE v2.5 12-Sep-2017 11:23:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SigmaExtract_OpeningFcn, ...
                   'gui_OutputFcn',  @SigmaExtract_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end %varargout = SigmaExtract

% --- Executes just before SigmaExtract is made visible.
function SigmaExtract_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SigmaExtract (see VARARGIN)


% default path for open function
handles.filePath = 'D:\Users\Jon Meyers\Images\FIB\'; 


% initialize the handles used throughout the program
handles.original_pic = [0,0];
handles.original_rot_pic = [0,0];
handles.nmPerPixel = 1; %default scale
set(handles.scaleBar, 'String', handles.nmPerPixel);
handles.current_pic = [0,0];
handles.rot_pic = [0,0];
handles.diameters = [0,0];
handles.horz_pic = [0,0];
handles.originalx = 0;
handles.originaly = 0;
handles.data = 0;
handles.transitions = 0;
handles.fileName = 0;
handles.nm = 0;
handles.threshold_value = .4;
handles.range_value = 8;
handles.gaussSpace = [0,0];


% create the data variables that get updated
% generate the initial plot in axes1
handles.current_datax = 0;
handles.current_datay = 0;

% initialize the filter value variable
% controls the size of the window for 1D Median Filter
handles.current_filter_value = 3;

% initialize the number of times run
handles.num_times_run = 1;

% initialize minmax function
% minmax is a vector of 1's and 0's used to represent the x-value of
% transitions. 1 = transition.
handles.minmax = 0;

% initialize minmaxIdx 
% used in conjuction with find() to extract the x values of detected
% transitions
handles.minmaxIdx = 1;

% initialize tranRad
% number of points to ignore on either side of transition point when
% calculating average diameter/stdev
handles.tranRad = 10;

% program output
handles.realOutput = [1 1 1];


% Choose default command line output for SigmaExtract
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SigmaExtract wait for user response (see UIRESUME)
% uiwait(handles.figure1);

end %end of SigmaExtract_OpeningFcn



% --- Outputs from this function are returned to the command line.
function varargout = SigmaExtract_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

end %end of SigmaExtract_OutputFcn


function fileNameString_Callback(hObject, eventdata, handles)
% hObject    handle to fileNameString (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fileNameString as 
%        text str2double(get(hObject,'String')) returns contents of 
%        fileNameString as a double
end %end fileNameString_Callback


% --- Executes during object creation, after setting all properties.
function fileNameString_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileNameString (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns 
%            called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(...
        get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor')...
        )
    set(hObject,'BackgroundColor','white');
end
end %end fileNameString_CreateFcn


function scaleBarLength_Callback(hObject, eventdata, handles)
% hObject    handle to scaleBarLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scaleBarLength 
%        as text str2double(get(hObject,'String')) returns contents 
%        of  scaleBarLength as a double
    handles.nm = get(hObject,'String');
    
    % Choose default command line output for slider_gui
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);
    
end %end scaleBarLength_Callback


% --- Executes during object creation, after setting all properties.
function scaleBarLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scaleBarLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns
%            called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(...
        get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor')...
        )
    set(hObject,'BackgroundColor','white');
end

end %end scaleBarLength_CreateFcn


% --- Executes during object creation, after setting all properties.
function scaleBar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scaleBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns 
%            called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(...
        get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor')...
        )
    set(hObject,'BackgroundColor','white');
end

end %end scaleBar_CreateFcn


function scaleBar_Callback(hObject, eventdata, handles)
% hObject    handle to scaleBar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scaleBar as text
%        str2double(get(hObject,'String')) returns contents of scaleBar 
%        as a double
end %end scaleBar_Callback


% click open in menu bar
function open_ClickedCallback(hObject, eventdata, handles)
    % hObject    handle to open (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    [fileName, filePath, filterIndex] = ...
        uigetfile(strcat(handles.filePath, '*.tif'));
    
    %skips opening if cancel is clicked
    if fileName == 0
        return
    end
    
    handles.filePath = filePath;
    handles.fileName = fileName;
    set(handles.fileNameString, 'String', strcat(filePath, fileName));
    pic = imread(strcat(filePath, fileName), 'tiff');
    if numel(pic(1,1,:)) == 3,
        pic = rgb2gray(pic);
    end
    handles.original_pic = im2double(pic);
    handles.current_pic = handles.original_pic;
    
    showPic_Callback(hObject, eventdata, handles);
    
    % Choose default command line output for slider_gui
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);    
end %end open_ClickedCallback


% --- Executes on button press in showPic.
function showPic_Callback(hObject, eventdata, handles)
    % hObject    handle to showPic (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    imshow(handles.current_pic, 'Parent', handles.largePic);
    %set(handles.largePic, 'Visible', 'on');
    set(handles.horizontalPic, 'Visible', 'off');
    cla(handles.horizontalPic);
    set(handles.widthPlot, 'Visible', 'off');
    cla(handles.widthPlot);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%initialization functions that set the scale of the image and rotate
%the wire to the correct orientation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes on button press in setScale.
function setScale_Callback(hObject, eventdata, handles)
% hObject    handle to setScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
%This function finds the scale bar for images taken on the FEI Helios 
%600 Nanolab Dual Beam System (FIB) at the Chapel Hill Analytical  
%and Nanofabrication Laboratory (CHANL) at UNC - Chapel Hill

    %gets a row and column along far right side and bottom of the image
    subWidth = length(handles.original_pic(1,:)) - 1;
    subHeight = length(handles.original_pic(:,1)) - 1;
    
    %finds the white boxes from the SEM image
    whiteHeight = find(handles.original_pic(subHeight,:) >= .9);
    whiteWidth = find(handles.original_pic(:,subWidth) >= .9);
    
    %finds the midPoint of the white box that contains the scale bar
    midPoint = ceil((whiteWidth(end - 1) - whiteWidth(end - 2)) / 2 ...
        + whiteWidth(end - 2));
    consec = false;
    endColumn = subWidth;
    startColumn = whiteHeight(end - 1);
    
    %scans until the columns from right to left, starting at the 
    %midPoint, until the pixels are consecutive white points
    while ~consec
       if  endColumn < numel(handles.original_pic(midPoint, :)) && ...
               endColumn >= 1
           if handles.original_pic(midPoint, endColumn) >= 0.9 && ...
                   handles.original_pic(midPoint, endColumn - 1) >= 0.9
               consec = true;
           end
       end
       
       if endColumn > numel(handles.original_pic(midPoint,:))
           exception = MException('Outside of picture limits',...
               ['Could not find consecuative points to '...
               'locate the scale bar']); 
           throw(exception);
       end
       
       if ~consec
           endColumn = endColumn - 1;
       end
    end %end while
    
    consec = false;
    
    %scans the columns from left to right, starting at the midPoint
    %until the pixels are consecutive white points
    while ~consec
       if  startColumn < numel(handles.original_pic(midPoint, :)) && ...
               startColumn >= 1
           if handles.original_pic(midPoint, startColumn) >= 0.9 && ...
                   handles.original_pic(midPoint, startColumn + 1) ...
                   >= 0.9
               consec = true;
           end
       end
       
       if startColumn > numel(handles.original_pic(midPoint,:))
           exception = MException('Outside of picture limits',...
               ['Could not find consecutive points to '...
               'locate the scale bar']); 
           throw(exception);
       end
       
       if ~consec
           startColumn = startColumn + 1;
       end
    end %end while
    
    
    %get number of pixels in the scale bar and output the actual scale
    temp = str2double(handles.nm); %gets scale bar value from user
    handles.nmPerPixel = temp / (endColumn - startColumn);
    set(handles.scaleBar, 'String', handles.nmPerPixel);
    set(handles.scaleBar, 'Visible', 'on');
    set(handles.text3, 'Visible', 'on');

    % Choose default command line output for slider_gui
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);     
end %setScale_Callback




% --- Executes on button press in setRotate.
function setRotate_Callback(hObject, eventdata, handles)
% hObject    handle to setRotate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    %user draws a line with two left clicks -- first should be just 
    %before the base of the NW and second (double click) should be just 
    %beyond the catalyst tip
    [x,y] = getline(handles.largePic);
    newPic = handles.current_pic;

    %Gets 4 points around the starting point and makes them a value of
    %21 or 22 (for end points). Uses 4 points in case during rotation 
    %point is lost
    newPic(floor(y(1)), floor(x(1))) = 21;
    newPic(ceil(y(1)), floor(x(1))) = 21;
    newPic(floor(y(1)), ceil(x(1))) = 21;
    newPic(ceil(y(1)), ceil(x(1))) = 21;
    newPic(floor(y(2)), floor(x(2))) = 22;
    newPic(ceil(y(2)), floor(x(2))) = 22;
    newPic(floor(y(2)), ceil(x(2))) = 22;
    newPic(ceil(y(2)), ceil(x(2))) = 22;

    %calculates the length of the line segment
    lineSegLength = sqrt((x(1)-x(2))^2+(y(1)-y(2))^2);

    %vector of the line
    vec_x = x(2)-x(1);
    vec_y = y(2)-y(1);

    %angle between the line and vertical
    theta = radtodeg(acos(vec_y/lineSegLength));

    %rotates the picture and determines whether to use a
    %negative or positive angle
    if vec_x > 0
       rotPic = imrotate(newPic, -theta, 'loose');
       angle = -theta + 90;
    else
       rotPic = imrotate(newPic, theta, 'loose');
       angle = theta + 90;
    end       
    handles.angle = angle; %store the angle so it's easier to rotate the
    %actual image in Illustrator/Photoshop. Note that theta is the angle 
    %to get it to have the tip on the bottom. I want the tip on the 
    %right, so I add 90 degrees.

    %finds the starting and ending points
    [new_y, new_x] = find(rotPic == 21);
    [new_y2, new_x2] = find(rotPic == 22);

    %picks the line going from top to bottom and takes the subPic area
    x1 = new_x(1) - 500;
    x2 = new_x2(1) + 500;
    if x1 <= 0
        x1 = 1;
    elseif x1 >= length(rotPic(1,:))
        x1 = length(rotPic(1,:));
    end
    
    if x2 <= 0
        x2 = 1;
    elseif x2 >= length(rotPic(1,:))
        x2 = length(rotPic(1,:));
    end
    
    if new_y(1) < new_y2(1)
      subPic = rotPic(new_y(1):new_y2(1),x1:x2);
    else
      subPic = rotPic(new_y2(1):new_y(1),x1:x2);
    end
    
    handles.current_pic = subPic;
    handles.original_rot_pic = handles.current_pic;
    handles.rot_pic = subPic;
    cla(handles.largePic);
    imshow(handles.current_pic, 'Parent', handles.largePic);
    
    % Choose default command line output for slider_gui
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);   
end %end setRotate_Callback



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%image processing functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes on button press in calcDiameter.
function calcDiameter_Callback(hObject, eventdata, handles)
% hObject    handle to calcDiameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


    %Uses the handles to make a picture based on the bins and then 
    %returns the picture
        
    %creates a matrix to put the diameters for each row it scans 
    diameters = zeros(size(handles.current_pic,1),2);
    currentRow = 1;
  
    bins = handles.current_pic;
   
%     assignin('base', 'vert_plot', bins); %for debugging
    left_side = [];
    right_side = [];
    
    %Loops over all the lines in the picture
    for k = 1:size(bins,1)

       %Sets variables for each line
       started = false;
       bin2Count = 0;
       startPos = 0;
       bin3Count = 0;
       blankCount = 0;
       endPos = 0;
       crossSec = 0;
       tempArray = [];

       %Loops over all the columns/pixels in the current line (k)
       for j = 1:size(bins,2)

           %If the bin contains a 1 start the diameter count or reset
           %all of the other counts
           if bins(k,j) == 1
               if ~started
                   started = true;
                   startPos = j;
               else
                   endPos = j; 
                   bin2Count = 0; 
                   bin3Count = 0; 
                   blankCount = 0;
               end    
               
           %bin2 count, will start the count if it reaches 10 then it
           %will stop the count
           elseif bins(k,j) > 0.6
               bin2Count = bin2Count + 1;
               if ~started
                   started = true;
                   startPos = j;
               elseif bin2Count < 11
                   endPos = j; 
                   blankCount = 0;
               else
                   started = false; 
                   bin2Count = 0; 
                   bin3Count = 0; 
                   blankCount = 0; 
                   crossSec = endPos - startPos;
                   tempArray = [tempArray; crossSec, startPos, endPos];
               end  
               
           %bin3 count, will start the count till it reaches 5, then it
           %will stop the count
           elseif bins(k,j) > 0.3
               bin3Count = bin3Count + 1;
               if ~started
                   started = true;
                   startPos = j;
               elseif bin3Count < 6
                   endPos = j;
                   blankCount = 0;
               else
                   started = false; 
                   bin2Count = 0; 
                   bin3Count = 0; 
                   blankCount = 0; 
                   crossSec = endPos - startPos;
                   tempArray = [tempArray; crossSec, startPos, endPos];
               end 
               
           %Can only have 2 blank spaces in a row before count stops
           elseif bins(k,j) < 1
               blankCount = blankCount + 1;
               if blankCount > 3 
                   started = false; 
                   bin2Count = 0; 
                   bin3Count = 0; 
                   blankCount = 0; 
                   crossSec = endPos - startPos;
                   tempArray = [tempArray; crossSec, startPos, endPos];
               end
           end %end if-else statements for determining the bins
       end %end loop over columns

       
       %determines the max diameter for the current row
       [M, I] = max(tempArray(:,1));
       diameters(currentRow, 2) = M;
       diameters(currentRow,1) = k;
       currentRow = currentRow + 1; 
       left_side(k) = tempArray(I,2);
       right_side(k) = tempArray(I,3);
       
    end %end loop over rows


%     assignin('base', 'left_side', left_side); %for debugging
%     assignin('base', 'right_side', right_side); %for debugging
%     assignin('base', 'scale', handles.nmPerPixel); %for debugging
    handles.diameters = diameters .* handles.nmPerPixel;
    
    handles.current_datax = handles.diameters(:,1);
    handles.current_datay = handles.diameters(:,2);
    
    handles.originalx = handles.diameters(:,1);
    handles.originaly = handles.diameters(:,2);
    
    handles.horz_pic = imcrop(imrotate(handles.original_rot_pic,90),...
        [0,350, length(handles.original_rot_pic(:,2)),400]);
    imshow(handles.horz_pic, 'Parent', handles.horizontalPic);
    plot(handles.diameters(:,1), handles.diameters(:,2), ...
        'Parent', handles.widthPlot);
    set(handles.widthPlot, 'XLim', [0 handles.diameters(end,1)]);
    set(handles.widthPlot, 'YLim', ...
        [min(handles.diameters(:,2))-5 max(handles.diameters(:,2))+5]);

    
    % Choose default command line output for slider_gui
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);
    
    showGraphs_Callback(hObject, eventdata, handles);
    
    % Choose default command line output for slider_gui
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);
end %end calcDiameter_Callback



% --- Executes on button press in showGraphs.
function showGraphs_Callback(hObject, eventdata, handles)
    % hObject    handle to showGraphs (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    cla(handles.largePic);
    set(handles.largePic, 'Visible', 'off');
    %set(handles.horizontalPic, 'Visible', 'on');
    imshow(handles.horz_pic, 'Parent', handles.horizontalPic);
    set(handles.widthPlot, 'Visible', 'on');
    plot(handles.current_datax, handles.current_datay, ...
        'Parent', handles.widthPlot);
    set(handles.widthPlot, 'xlim', [min(handles.diameters(:,1))...
        max(handles.diameters(:,1))]);
    set(handles.widthPlot, 'ylim', [min(handles.diameters(:,2))-20 ...
        max(handles.diameters(:,2))+20]);
    set(get(handles.widthPlot, 'xlabel'), 'string', 'Length (nm)')
    set(get(handles.widthPlot, 'ylabel'), 'string', 'Diameter (nm)')
    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%functions that create transition lines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes on button press in dispTrans.
function dispTrans_Callback(hObject, eventdata, handles)
% hObject    handle to dispTrans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    calcTrans(hObject, eventdata, handles);
    handles = guidata(handles.output); %ensure handles get updated
    
    plotLines(hObject, eventdata, handles);    
    handles = guidata(handles.output); %ensure handles get updated
    
    %n by 2 array with the xlocations of transitions in column 1 and 
    %1's in the second
    handles.minmaxIdx = find(handles.minmax);
    
    vect(:,1) = handles.minmaxIdx;
    vect(:,2) = 1;
    
    tempminmax = handles.minmax; %create temp copy of minmax to edit
    entriesToKeep = find(vect(:,2)); %find the x-values to keep
%     assignin('base','entriesToKeep',entriesToKeep); %for debugging
%     assignin('base','tempminmax',tempminmax); %for debugging
    tempminmax = zeros(length(tempminmax),1);
   
    for m = 1:size(entriesToKeep)
        tempminmax(vect(entriesToKeep(m)),1) = 1;
    end
    
    %replace the old x-values with the new ones
    handles.minmaxIdx = vect(entriesToKeep,1);
    %assignin('base','minmaxIdx', handles.minmaxIdx) %for testing
    handles.minmax = tempminmax;
    
    handles = guidata(handles.output); %ensure handles get updated
    
    % Choose default command line output for slider_gui
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);   
end %end dispTrans_Callback


function calcTrans(hObject, eventdata, handles)

    %the list of scales at which to perform the analysis
    scales = [1, 2, 4, 8];
    
    %a list of numbers between 0 and 1 indicating how obvious a step has 
    %to be at each scale in order to be considered a transition. 
    %Do Not Edit unless you know what the values mean
    thresholds = [.1, .2, .3, .4];

    % Create the derivative scale space--
    % minima and maxima of the derivative correspond to transitions
    data = CreateGaussScaleSpace(handles.current_datay, 1, scales);

    %Find position of local minima and maxima of the most coarse scale
    handles = guidata(handles.output); %ensure handles get updated
    handles.minmax = FindLocalExtrema(data(:, end), ...
        thresholds(end), scales(end));
    guidata(handles.output,handles); %ensure handles get updated
    
    %Place x-coordinate of transitions into a list
    handles = guidata(handles.output); %ensure handles get updated
    handles.minmaxIdx = find(handles.minmax);  
    guidata(handles.output,handles); %ensure handles get updated
    
    % Refine min/max positions through scale space
    for i = size(scales)-1:-1:1
        %ensure handles get updated throughout the for loop
        handles = guidata(handles.output);
        
        handles.minmax = FindLocalExtrema(data(:,i), thresholds(i), ...
            scales(i), handles.minmaxIdx);
        handles.minmaxIdx = find(handles.minmax);
    end

    % Choose default command line output for slider_gui
    handles.output = hObject;
    
    % Update handles structure
    guidata(hObject, handles);
end %end function calcTrans



function plotLines(hObject, eventdata, handles)

    cla(handles.widthPlot); %clear the diameter plot axes
    plot(handles.originalx,handles.current_datay, 'Parent', ...
        handles.widthPlot); %plot the current data
    hold(handles.widthPlot,'on') 
    
    %plot calculated transition points using minmax
    %(0 everywhere except at transitions, where it is 1)
    set(handles.widthPlot, 'XLim', [0 handles.diameters(end,1)]);

    set(handles.widthPlot, 'YLim', ...
        [min(handles.diameters(:,2))-5 max(handles.diameters(:,2))+5]);
    y = get(handles.widthPlot, 'YLim');
    ydif = y(2) - y(1);
    plot(handles.originalx,(1.0 * handles.minmax * ydif) + y(1)...
        , 'r', 'Parent', handles.widthPlot);
    hold(handles.widthPlot,'off')
    handles.transitions = [handles.originalx, ...
        (1.0 * handles.minmax * ydif) + y(1)];
    %assignin('base','transition',handles.transitions); %for debugging
    
    cla(handles.horizontalPic);
    imshow(handles.horz_pic,'Parent',handles.horizontalPic);
%     assignin('base','horzpic',handles.horz_pic) %for debugging
    hold(handles.horizontalPic,'on') 
    %assignin('base','minmax',handles.minmax) %for debugging
    plot(1.0 * handles.minmax * 401, 'r', ...
        'Parent', handles.horizontalPic);
%     assignin('base', 'horizontalpic', handles.horizontalPic) %debug
    hold(handles.horizontalPic,'off')
    
    % Choose default command line output for slider_gui
    handles.output = hObject;
    
    % Update handles structure
    guidata(hObject, handles);
end %end function plotLines


% --- Executes on button press in editLines.
function editLines_Callback(hObject, eventdata, handles)
% hObject    handle to editLines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    output = linePlot(handles.diameters,handles.horz_pic(:,:,1), ...
        handles.nmPerPixel, find(handles.minmax==1));
    for i = 1:numel(output(:,2))
        temp(i,1) = find(handles.diameters(:,1) > ...
            output(i,2),1,'first');
    end
    
    handles.minmax(:,1) = 0;
    handles.minmax(temp) = 1;
    handles.minmaxIdx = find(handles.minmax);
    
    plotLines(hObject, eventdata, handles);
    handles=guidata(handles.output); %ensure handles get updated
    
    % Choose default command line output for slider_gui
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles); 
end %end editLines_Callback



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calculate sigma from the extracted data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes on button press in calcSigma.
function calcSigma_Callback(hObject, eventdata, handles)
% hObject    handle to calcSigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%record data and metadata
sigma_extract.filename = handles.fileName;
sigma_extract.pic = handles.horz_pic;
sigma_extract.nmPerPixel = handles.nmPerPixel;
sigma_extract.angle = handles.angle;
sigma_extract.alldata = handles.diameters;
sigma_extract.transitions = find(handles.transitions(:,2) > -5); 
selected = sigma_extract.alldata(sigma_extract.transitions(1):...
    sigma_extract.transitions(2),:); %data between the start/end lines
height = selected(:,1);
diam = selected(:,2);

%do linear regression on selected data to find dD/dL
sigma_extract.lin_reg = fitlm(height, diam);
%now find the tapering parameter, sigma = dr/dL
sigma_extract.sigma = sigma_extract.lin_reg.Coefficients{2,1} / 2; 

%store results in a variable that can be accessed after function closes
assignin('base', 'extracted', sigma_extract);

%plot
taperPlot(sigma_extract)


end %end calcSigma_Callback
