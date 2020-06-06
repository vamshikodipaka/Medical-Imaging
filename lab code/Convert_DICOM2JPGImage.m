function Convert_DICOM2JPGImage(dicomFilePath, newFileName, path)
% This funciton will take Dicom images as input
% and as outpout it will save image as jpeg format to the specified path

% Read the DICOM
[Dicom_data] = dicomread(dicomFilePath);

name = strcat(newFileName, '.jpg');
new_name = fullfile(path, name);
Y = Dicom_data;

% convert to a double positive image
P = im2double(Y);

% save adjusted posative as jpg
imwrite(imadjust(P), new_name, 'jpg');

% Help taken from
% http://www.mathworks.fr/matlabcentral/newsreader/view_thread/172321