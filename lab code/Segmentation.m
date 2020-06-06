function varargout = Segmentation(varargin)
% SEGMENTATION MATLAB code for Segmentation.fig
%      SEGMENTATION, by itself, creates a new SEGMENTATION or raises the existing
%      singleton*.
%
%      H = SEGMENTATION returns the handle to a new SEGMENTATION or the handle to
%      the existing singleton*.
%
%      SEGMENTATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGMENTATION.M with the given input arguments.
%
%      SEGMENTATION('Property','Value',...) creates a new SEGMENTATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Segmentation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Segmentation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Segmentation

% Last Modified by GUIDE v2.5 09-May-2019 04:06:45

% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Segmentation_OpeningFcn, ...
                   'gui_OutputFcn',  @Segmentation_OutputFcn, ...
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


% --- Executes just before Segmentation is made visible.
function Segmentation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Segmentation (see VARARGIN)

% Choose default command line output for Segmentation
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Segmentation wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Segmentation_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           2nd and 3rd Stage
%           
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Segmentationandvisualization_SelectionChangedFcn(hObject, eventdata, handles)

% hObject    handle to the selected object in Segmentationandvisualization 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes1);

h = imfreehand(gca);

% Create a mask
maskImg = h.createMask;

alphaImg(:,:,1) = zeros(size(maskImg));
alphaImg(:,:,2) = zeros(size(maskImg));
alphaImg(:,:,3) = zeros(size(maskImg));

amountIncrease = 255/2;

color = 'blue';
plotText = '';

AreaofRegion_noofpixels = regionprops(maskImg, 'area');

% Spatial Resolution
spatialresultion = 0.7891; % same for all images

% Area of Region
Areaofregion  = (AreaofRegion_noofpixels.Area) .* spatialresultion;

% Thickness of slice
slicethickness = handles.dicomInfo.SliceThickness;

% Volume of region
volumeofregion = Areaofregion * slicethickness;

% display('Surface:');
% display(Areaofregion);
% 
% display('Volume:');
% display(volumeofregion);

% Read the DICOM Image
dicomImage = dicomread(handles.dicomInfo);

ii = uint8(dicomImage); % HERE IS THE ISSUE

ii2(:,:,1) = ii;
ii2(:,:,2) = ii;
ii2(:,:,3) = ii;

%figure, imshow(ii, []);

% figure, imshow(getimage(gca));
% axes(handles.axesImage);

position = wait(h);

% For ZP
if get(handles.ZP, 'Value') == 1
    
    setColor(h, 'red');
    alphaImg(:,:,3) = round(maskImg*(amountIncrease));
    color = 'red';
    plotText = 'ZP';
    
    set(handles.text9, 'String', [num2str(Areaofregion)]);
    set(handles.text10, 'String', [num2str(volumeofregion)]);

% For ZT    
elseif get(handles.ZT, 'Value') == 1
    
    setColor(h, 'blue');
    alphaImg(:,:,2) = round(maskImg*(amountIncrease));
    color = 'blue';
    plotText = 'ZT';
    set(handles.text11, 'String', [num2str(Areaofregion)]);
    set(handles.text12, 'String', [num2str(volumeofregion)]);

% For ZC    
elseif get(handles.ZC, 'Value') == 1
    
    setColor(h, 'green');
    alphaImg(:,:,1) = round(maskImg*(amountIncrease));
    alphaImg(:,:,2) = round(maskImg*(amountIncrease));
    color = 'green';
    plotText = 'ZC';
    set(handles.text13, 'String', [num2str(Areaofregion)]);
    set(handles.text14, 'String', [num2str(volumeofregion)]);

% For Tumor Region
elseif get(handles.TumorRegion, 'Value') == 1
    
    setColor(h, 'yellow');
    alphaImg(:,:,1) = round(maskImg*(amountIncrease));
    color = 'yellow';
    plotText = 'Tumor Region';
    set(handles.text15, 'String', [num2str(Areaofregion)]);
    set(handles.text16, 'String', [num2str(volumeofregion)]);
    
else
    % No button selected
        
end

% alphaImg(:,:,1) = zeros(size(maskImg)); % All zeros.
% alphaImg(:,:,2) = round(maskImg*(amountIncrease)); % Round since we're dealing with integers.
% alphaImg(:,:,3) = zeros(size(maskImg)); % All zeros. 

% Convert alphaImg to have the same range of values (0-255) as the origImg.
alphaImg = uint8(alphaImg);

%alphaImg = double(alphaImg);
%figure, imshow(alphaImg, []);
% alphaImg = rgb2gray(alphaImg);
% 
 blendImg = ii2 + alphaImg;
%blendImg = imadd(ii, alphaImg);
% hold on

axes(handles.axes1);
%imshow(blendImg);

axes(handles.axes2);

rotate3d(gca);

hold on;

axis ij;

% 3D Representation
for k = 1:0.1:64
   plot3(position(:, 1), position(:, 2), ones(size(position, 1), 1) + k, 'Color', color);
end

text(position(1, 1), position(1, 2), [plotText '\downarrow'], 'VerticalAlignment', 'top', 'FontSize', 12);

hold off;

axis([1, 384, 1, 308]);


% --- Executes on button press in ZP.
function ZP_Callback(hObject, eventdata, handles)
% hObject    handle to ZP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ZT.
function ZT_Callback(hObject, eventdata, handles)
% hObject    handle to ZT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ZC.
function ZC_Callback(hObject, eventdata, handles)
% hObject    handle to ZC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in TumorRegion.
function TumorRegion_Callback(hObject, eventdata, handles)
% hObject    handle to TumorRegion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when uipanel1 is resized.
function uipanel1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
