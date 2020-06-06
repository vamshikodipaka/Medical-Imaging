   function [output] = smooth_convexhull(img)   
   
   % we convert nonzero element to logical 1 (true) 
   % and zeros to logical 0 (false) 
   % Convert into array of logical values
   m = logical(img);
   
   % 'Area' is actual number of pixels in the region
   sc  = regionprops(m, 'Area');
   
   % Add structure array which have Area into a single matrix
   areas = cat(1, sc.Area);
   open = max(areas)-10;
   
   % remove all object which has fewer than open pixels
   remove_object = bwareaopen(m,open);  

   % convert matrix to a grayscale image
   grayscale_img = mat2gray(remove_object);
   BW1(:,:)= grayscale_img(:,:,1);  
   
   % Generate convex hull image from binary image
   BW3 = bwconvhull(BW1,'objects',8); % connectivity 8

   BW3 = uint8(BW3);
   BW3 = zhenzhou_shape_filtering(BW3,10,4); % connectivity 4

   struct_element = strel('disk',2); % 2 is a redius
  
   % Dilates the image I
   output=imdilate(BW3,struct_element);   
