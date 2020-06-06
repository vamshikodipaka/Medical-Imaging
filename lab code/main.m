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

% Last Modified by GUIDE v2.5 09-May-2019 05:45:22

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

handles.manuelSegmentationHandle = [];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes main wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global dicomFolderPath;
dicomFolderPath = '';


emptyImage = ones(308, 384);
axes(handles.Inputimage);
imshow(emptyImage);

% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     1st Stage : DICOM Management
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%                         Load DICOM Images

function LoadDICOMImages_Callback(hObject, eventdata, handles)

% hObject    handle to LoadDICOMImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Load DICOM Images from the path
global dicomFolderPath;
dicomFolderPath = uigetdir;

if isequal(dicomFolderPath, 0)
    return;
end

dicomFolderList = dir(dicomFolderPath);

dicomFolderList = dicomFolderList(arrayfun(@(x) ~strcmp(x.name(1),'.'), dicomFolderList));

dicomFileNameList = {dicomFolderList(~[dicomFolderList.isdir]).name}';

set(handles.DICOMImagelist, 'String', dicomFileNameList, 'Value', 1);


%%                      Play DICOM Images

function PlayDICOMImages_Callback(hObject, eventdata, handles)
% hObject    handle to PlayDICOMImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Select the listbox which has DICOM Images for play
index_selected = get(handles.DICOMImagelist, 'Value');
file_list = get(handles.DICOMImagelist, 'String');

fileListCount = numel(file_list);

if fileListCount < 1
    return;
end

% selectedFile = file_list(index_selected);
% 
% 
% 
% selectedFile = cellstr(selectedFile);
% selectedFile = selectedFile{1};
% 
% if isempty(selectedFile)
%     return;
% end

global dicomFolderPath;

axes(handles.Inputimage);

% Create a loop to show images one by one
for ii = 1 : fileListCount
    
    selectedFile = file_list(ii);
    selectedFile = cellstr(selectedFile);
    selectedFile = selectedFile{1};
    
    filePath = [dicomFolderPath '/' selectedFile];
    
    info = dicominfo(filePath);

    Y = dicomread(info);

    imshow(Y, []);
    
    pause(0.1);
    
end

%%                    DICOM Image List

function DICOMImagelist_Callback(hObject, eventdata, handles)

% hObject    handle to DICOMImagelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DICOMImagelist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DICOMImagelist
% When user clicks list items


index_selected = get(handles.DICOMImagelist, 'Value');
file_list = get(handles.DICOMImagelist, 'String');
selectedFile = file_list(index_selected);
selectedFile = cellstr(selectedFile);
selectedFile = selectedFile{1};

if isempty(selectedFile)
    return;
end

global dicomFolderPath;

file = [dicomFolderPath '/' selectedFile];

info = dicominfo(file);

Y = dicomread(info);

axes(handles.Inputimage);
imshow(Y, []);

% call the function which shows the information of DICOM images 
[Patient_Name, Patient_ID, Patient_BirthDate, Study_ID, Study_Date, Slice_Location, Instance_Number] = Information_DICOMimages(info);

set(handles.Patientname, 'String', Patient_Name);
set(handles.PatientID, 'String', Patient_ID);
set(handles.PatientBirthDate, 'String', Patient_BirthDate);
set(handles.StudyID, 'String', Study_ID);
set(handles.StudyDate, 'String', Study_Date);
set(handles.SliceLocate, 'String', Slice_Location);
set(handles.InstanceNumber, 'String', Instance_Number);

% --- Executes during object creation, after setting all properties.
function DICOMImagelist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DICOMImagelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on mouse press over axes background.
function Inputimage_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Inputimage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




%%                       Convert JPG to DICOM 

function JPG2DICOM_Callback(hObject, eventdata, handles)

% hObject    handle to JPG2DICOM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[jpgFileName, jpgPathName] = uigetfile({'*.jpg';'*.jpeg'},'Choose Path for JPG to DICOM Conversion');

if isequal(jpgPathName, 0)
    return;
end

jpgFullPath = fullfile(jpgPathName, jpgFileName);

jpgImage = imread(jpgFullPath);

jpgNameWithoutExtension = strsplit(jpgFileName, '.');
jpgNameWithoutExtension = jpgNameWithoutExtension{1};

jpgDICOMInfoPath = char(strcat(jpgNameWithoutExtension, '.mat'));

display(jpgDICOMInfoPath);

if  exist(jpgDICOMInfoPath, 'file')

    jpgDICOMInfo = importdata(jpgDICOMInfoPath);
    
    fullPathNewDICOM = fullfile(jpgPathName, jpgNameWithoutExtension);
    
    dicomwrite(jpgImage, fullPathNewDICOM, jpgDICOMInfo);
    
else
    msgbox('JPG file not found... please select JPG file');
end


%%                      Convert DICOM to JPG

function DICOM2JPG_Callback(hObject, eventdata, handles)

% hObject    handle to DICOM2JPG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% choose path
dicomToJPGPath = uigetdir('.', 'Choose Path for DICOM to JPG Conversion');

if isequal(dicomToJPGPath, 0)
    return;
end

index_selected = get(handles.DICOMImagelist, 'Value');
file_list = get(handles.DICOMImagelist, 'String');
selectedFile = file_list(index_selected);
selectedFile = cellstr(selectedFile);
selectedFile = selectedFile{1};

global dicomFolderPath;
path = char(strcat(dicomFolderPath, '/', selectedFile));

Convert_DICOM2JPGImage(path, selectedFile, dicomToJPGPath);

dicomInfo = dicominfo(path);

% Save the file
save(char(strcat(selectedFile, '.mat')),'dicomInfo');


%%                      Anonymize DICOM Images

function AnonymizeDICOMImages_Callback(hObject, eventdata, handles)

% hObject    handle to AnonymizeDICOMImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Select the path
anonymDICOMFolderPath = uigetdir('.', 'Select Path for Anonym DICOM Images');

file_list = get(handles.DICOMImagelist, 'String');
fileListCount = numel(file_list);

global dicomFolderPath;

for ii = 1 : fileListCount
    inputPath = char(strcat(dicomFolderPath, '/', file_list(ii)));
    display(inputPath);
    outputPath = char(strcat(anonymDICOMFolderPath, '/', file_list(ii)));
    display(outputPath);
    Anonymize_DICOMImages(inputPath, outputPath);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 2nd Stage : Segmentation and Visualization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ManualSegmentation_Callback(hObject, eventdata, handles)

% hObject    handle to ManualSegmentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

index_selected = get(handles.DICOMImagelist, 'Value');

file_list = get(handles.DICOMImagelist, 'String');

fileListCount = numel(file_list);
if fileListCount < 1
    return;
end

selectedFile = file_list(index_selected);
selectedFile = cellstr(selectedFile);
selectedFile = selectedFile{1};

if isempty(selectedFile)
    return;
end

global dicomFolderPath;

file = [dicomFolderPath '/' selectedFile];

dicomInfo = dicominfo(file);

dicomImage = dicomread(dicomInfo);

if isempty(handles.manuelSegmentationHandle)
   handles.manuelSegmentationHandle  = Segmentation;
end

if ~isempty(handles.manuelSegmentationHandle)
    
    manuelSegmentationData = guidata(handles.manuelSegmentationHandle);
    manuelSegmentationData.dicomInfo = dicomInfo;
    guidata(handles.manuelSegmentationHandle, manuelSegmentationData);
    
    axes(manuelSegmentationData.axes1);
    imshow(dicomImage, []);
    %h = imfreehand;
end
