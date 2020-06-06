function [Patient_Name, Patient_ID, Patient_BirthDate, Study_ID, Study_Date, Slice_Location, Instance_Number] = Information_DICOMimages(info)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function shows the information of DICOM images 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% First name of patient 
PatientNamefirst = info.PatientName.GivenName;

% Last name of patient
patientNameLast = info.PatientName.FamilyName;

Patient_Name = strcat(PatientNamefirst,{' '},patientNameLast);

% ID of patient
Patient_ID = info.PatientID;

% Birthday of patient
Patient_BirthDate = info.PatientBirthDate;

% studyID
Study_ID = info.StudyID;

% studyDATE
Study_Date = info.StudyDate;

% sliceLocation
Slice_Location = info.SliceLocation;

% instanceNumber
Instance_Number = info.InstanceNumber;