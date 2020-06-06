function [SumContHulled, Epicardium] = Epicardium_Segmentation(Crope_Image)

% This function represents the segmentation of epicardium

% Size of the cropped image
[m, n] = size(Crope_Image);

% Watershed
% Mark the foreground objects
struct_element = strel ('disk', 10);

Img_erode = imerode(Crope_Image, struct_element);

% Perform Morphological reconstruction
Img_reconst = imreconstruct (Img_erode, Crope_Image);
Ird = imdilate(Img_reconst, struct_element);
Io = imreconstruct((~Ird),(~Img_reconst));

% Compute the complement of the Io 
Io = ~Io;
binarim = imregionalmax(Io);
Dist = bwdist(binarim,'euclidean');
Watershed_alg = watershed(Dist);

% Elements equal to 0
bgm = Watershed_alg == 0;
Watershed_Im = Crope_Image - 255 * uint8(bgm);

% Threshold 
threshold = graythresh(Watershed_Im);

% Binarize image
Img_binary = imbinarize(Watershed_Im,threshold);

% Remove objects smaller then 20 pixels
Im_new = bwareaopen(Img_binary,20);

% Connected components
Connected_Img = bwconncomp(Im_new);

% Properties
Property = regionprops(Connected_Img,'ConvexArea', 'ConvexHull','ConvexImage','PixelList','Centroid','Eccentricity','Perimeter','Image','FilledImage');

% Choose closest to the choosen point region
Euclidien_di = zeros(Connected_Img.NumObjects,1);

for k = 1:Connected_Img.NumObjects
    Euclidien_di(k) = sqrt(abs((Property(k).Centroid(:,1)-(m/2))^2+(Property(k).Centroid(:,2)-(n/2))^2));
end

% Get the index of the min Euclidean distance
[~, index] = min(Euclidien_di);

Mask = zeros(size(Crope_Image));

% Coordinates of pixels
Im_ind = Property(index).PixelList;

linear_ind = sub2ind(size(Mask), Im_ind(:,2), Im_ind(:,1));
Mask(linear_ind) = 1;
Hulled_Im = bwconvhull(Mask);

% Dilate the hulled mask
struct_element = strel('disk',2);
dilate_Img = imdilate(Hulled_Im, struct_element);
contour = dilate_Img - Hulled_Im;

% Convert image from rectangular domain to polar 
PolarIm = ImToPolar(Crope_Image, 0.1, 0.85, 20, 50);
PolarCont = ImToPolar(contour, 0.1, 0.85, 20, 50);

PI_size = size(PolarIm);
PI_size1 = size(PolarCont,1);
PI_size2 = size(PolarCont,2);

Sum = zeros(PI_size);
for i=1:PI_size1
     for j=1:PI_size2
         if  PolarCont(i,j)>0
             contour = regiongrowing(PolarIm,i,j,2);
             Sum = Sum + contour;
         end
     end
end

% Convert polar image to rectangular domain
Rectangular_Cont = PolarToIm (Sum, 0, 1, n, m);

% Compute convex hull of object
SumContHulled = bwconvhull(Rectangular_Cont);

Connected_Cont = bwconncomp(SumContHulled);
Cont_prop = regionprops(Connected_Cont,'ConvexArea', 'ConvexHull','ConvexImage','PixelList','Centroid','Eccentricity','Perimeter','Image','FilledImage');

% X and Y Coordinates of epicard
Epicardium = [Cont_prop(1).ConvexHull(:,1),Cont_prop(1).ConvexHull(:,2)];
    