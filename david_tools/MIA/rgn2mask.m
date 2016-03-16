function rgn2mask(varargin)

%Written by DP 05/01/2016
%Converts a Metamorph polygonal region into a Matlab mask
%from a HxW (height x width) size image (eg 512x256 pixels)
%The rgn file has n lines corresponding to n ROIs. Only the first will be
%used by this function. The first 16 numbers in each line are use to
%characterize the ROI, and will not be used, as well as the last two
%numbers.
if nargin == 0
    [f,p] = uigetfile('*.rgn','Polygonal region file');
    if ~f,return,end
    prompt = {'Image height','Image width'};
    [H,W] = numinputdlg(prompt,'Image size',1,[512 256]);
elseif nargin == 3
    p = [cd,'\'];
    f = varargin{1};
    H = varargin{2};
    W = varargin{3};
else
    error('rgn2mask needs 3 arguments (filename,Height,Width) or none')
end

rgn = dlmread([p,f]);
poly = rgn(1,17:end-2);
poly2 = zeros(size(poly,2)/2,2);
poly2(:,1) = poly(1:2:end)';
poly2(:,2) = poly(2:2:end)';
mask = poly2mask(poly2(:,1),poly2(:,2),H,W);
mimage(mask)

if nargin == 0
    [fle,p] = uiputfile([f(1:end-4),'_mask.txt'],...
        'Where to put the mask file');
    if ischar(fle) && ischar(p)
       dlmwrite([p,fle],mask,'\t')
    end
elseif nargin == 3
    dlmwrite([f(1:end-4),'_mask.txt'],mask,'\t')
end
    