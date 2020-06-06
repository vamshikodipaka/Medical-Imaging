function varargout = main(varargin)
% MAIN MATLAB code for main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main

% Last Modified by GUIDE v2.5 19-May-2019 18:37:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_OpeningFcn, ...
                   'gui_OutputFcn',  @main_OutputFcn, ...
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


% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main (see VARARGIN)

% Choose default command line output for main
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes main wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% choose the image from the path
[filename, pathname] = uigetfile({'*.nii'},'Select file');
Image = strcat(pathname, filename);

% load input image
P = load_nii(Image);
img = P.img;

handles.P = P;
guidata(hObject, handles);

% size of the input image
O = size(img); 

% show the size of the image into axis
set(handles.listbox2,'string',O)      


    
     
% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

P = handles.P;

% get the value of the slider
NewVal = round(get(hObject,'Value'));

% Read a certain slice image
img = P.img;      
img = img(:,:,NewVal);

% Show it on the window
axes(handles.axes1)
imshow(img, [])  

% set pointer for select the area
[y1,x1] = getpts; 
x1 = round(x1(1));
y1 = round(y1(1));

% Crope the image 
Image_Crope = uint8(img(x1-40:x1+40,y1-40:y1+40,:));

% call the function Epicardium segmentation
[~,Epicardium] = Epicardium_Segmentation(Image_Crope);

Image = double(Image_Crope);   
n_I= Image/255;    

% moving average filtering
filter_img = movmean(n_I,5);
filter_img = 255*imadjust(filter_img);
[filter_img] = round(filter_img);  

% call the k_means(image, number_of_classes)
[~, mask_image] = k_means(filter_img,2);
mask_image = mask_image-1;
Im_mask_smoothed = smooth_convexhull(mask_image) ;

axes(handles.axes5)
imagesc(mask_image);colormap gray;

% Create mask of the endocardium
Mask_logical = logical(Im_mask_smoothed);
Mask_size = size(Mask_logical);
Mask = zeros(Mask_size(1),Mask_size(2));
Mask(:,:) = Mask_logical(:,:);

% Parameter of the object
bound1 = bwperim(Mask(:,:));

% Co-ordinates of the Endocardium
location_P = bwboundaries(bound1);
x_endocard = location_P{1}(:,2);
y_endocard = location_P{1}(:,1);

% Co-ordinates of the Epicardium
x_epicard = Epicardium(:,1);
y_epicard = Epicardium(:,2);

% Draw contours of endocardium and epicardium on the image
axes(handles.axes3) 
imagesc(Image_Crope),axis off,colormap gray;
hold on;

% For the Endocardium
plot(x_endocard,y_endocard,'r-','Linewidth', 2);

% For the Epicardium
plot(x_epicard,y_epicard, 'g-', 'Linewidth', 2);
hold off;

       
% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

        
% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2
P = handles.P;
img = P.img;
O = size(img); 

n_im1 = O(1);
z1 = n_im1;
a1=1:z1;
b1=num2cell(a1);

n_im2 = O(2);
z2 = n_im2;
a2=1:z2;
b2=num2cell(a2);

n_im3 = O(3);
z3 = n_im3;
a3=1:z3;
b3=num2cell(a3);
 
selection = get(handles.listbox2, 'Value');
if selection == 1
    set(handles.listbox1,'string',b1)
elseif selection == 2
    set(handles.listbox1,'string',b2)
else 
    set(handles.listbox1,'string',b3)
end

if O(4)
    n_im4 = O(4);
    z4 = n_im4;
    a4=1:z4;
    b4=num2cell(a4);
    selection = get(handles.listbox2, 'Value');
    if selection == 4
        set(handles.listbox1,'string',b4)
    end

end
    


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
