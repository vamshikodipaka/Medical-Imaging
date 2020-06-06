function [Filtered_Seed] = zhenzhou_shape_filtering(bobC,T_shape,Band_Width)

% This program is written by Zhenzhou Wang, for more information please
% contact: zzwangsia@yahoo.com or wangzhenzhou@sia.cn
% This program is free for academic use only.
% Please reference and acknowledge the following paper:
% papers to be published

% T_shape is the threshold to distinguish the noise shape and the cell shape
% Band_Width is the band width of the Fourier filter

% shape filtering by boundary

% Trace region boundaries in binary image

temp = bwboundaries(bobC);
tempCell=[];

for i=1:length(temp)
     if max(size(temp{i}))>T_shape
        tempCell{i}=temp{i};
     end
end

NS=size(bobC);
ROI=zeros(NS(1),NS(2));
Filtered_Seed=zeros(NS(1),NS(2));

for i=1:max(size(tempCell))
    if max(size(tempCell{i}))>0
        xb = tempCell{i}(:,2);
        yb = tempCell{i}(:,1);
       
        % perform fft transform
        fhist=fft(xb);
        
        % zero-centered, circular shift on the transform
        fhist1=abs(fftshift(fhist));
        fhist(Band_Width:(length(fhist1)-Band_Width))=0;
        
        % inverse transform
        xb1=ifft(fhist);
        
        fhist=fft(yb);
        fhist1=abs(fftshift(fhist));
        fhist(Band_Width:(length(fhist1)-Band_Width))=0;
        yb1=ifft(fhist);
        
        % Convert region of interest (ROI) polygon to region mask
        ROI = poly2mask(abs(xb1),abs(yb1),size(ROI,1),size(ROI,2));
        Filtered_Seed=Filtered_Seed+ROI;
    end
end