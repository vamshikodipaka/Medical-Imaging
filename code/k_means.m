function [mu, mask] = k_means(image,k)

% This function reprensents the kmeans image segmentation
% where:
%      image: grey color image
%      k: Number of classes
%      mu: vector of class means 
%      mask: clasification image mask
%
% Author: Jose Vicente Manjon Herrera
% Email: jmanjon@fis.upv.es
% Date: 27-08-2005
    
img = image;
    
% check image
image = double(image);

% make a copy
copy = image;

% vectorize image
image = image(:);

% deal with negative
mi = min(image);

image = image-mi+1;     

% create image histogram
m = max(image);
hc = zeros(1,m);

Image(:,:)=img(:,:);

% Absolute maximum intensity value
Ns = max(max(Image));

% Max of absolute minimums of each column
Ns1 = max(min(min(Image)),1);
hist1 = zeros(1,Ns);

% Compute histogram
for h = Ns1:Ns
    for i = 1:size(Image,1)
        for j = 1:size(Image,2)
            if Image(i,j) == h
                hist1(1,h) = hist1(1,h)+1;
            end
        end
    end
    if hist1(1,h) < 1
        hist1(1,h) = 1;
    end
end

h = hist1;

% get indices of nonzero values of histogram 
ind = find(h);
hl = length(ind);

% initiate centroids
mu = (1:k)*m/(k+1);

% start process
while(true)
    oldmu = mu;
    
    % current classification  
    for i = 1:hl
    
        % subtract centroids
        c = abs(ind(i)-mu); 
        
        % find min
        cc = find(c == min(c));
        hc(ind(i)) = cc(1);
    end

    % recalculation of means
    for i = 1:k
        a = find(hc == i);
        mu(i) = sum(a.*h(a))/sum(h(a));
    end

    if(mu == oldmu)
        break;
    end
end

% calculate mask
s = size(copy);
mask = zeros(s);
for i = 1:s(1)
    for j = 1:s(2)
        c = abs(copy(i,j)-mu);
        a = find(c == min(c));
        mask(i,j) = a(1);
    end
end

% recover real range
mu = mu + mi - 1;   
mu = mu - 1;    