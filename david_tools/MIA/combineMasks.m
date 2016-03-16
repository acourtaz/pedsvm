function combineMasks

% creates a new mask from either: 
%  - cell masks generated from 2 different colour labellings
%  - a cell mask + a thresholded image from a synaptic marker

[f1,p1] = uigetfile('*.txt;*.tif','First mask file');
if ~f1,return,end
isTxt = strfind(f1(end-4:end), 'txt');
isTif = strfind(f1(end-4:end), 'tif');
if isTxt
    mask1 = dlmread([p1,f1],'\t');
elseif isTif
    mask1 = imread([p1,f1]);
end

[f2,p2] = uigetfile('*.txt;*.tif','Mask file');
if ~f2,return,end
isTxt = strfind(f2(end-4:end), 'txt');
isTif = strfind(f2(end-4:end), 'tif');
if isTxt
    mask2 = dlmread([p2,f2],'\t');
elseif isTif
    mask2 = imread([p2,f2]);
end
mask2 = mask2 > 0; % creates a binary image if not the case
dlmwrite([f2(1:7),'_MIA_mask.txt'],mask2,'\t')

if size(mask1) == size(mask2)
    mask = mask1 | mask2;
    c = strfind(f1,'_');
    c = c(1)-1;
    dlmwrite([f1(1:c),'_Combined_mask.txt'],mask,'\t')
else disp('These 2 masks can not be combined')
end


