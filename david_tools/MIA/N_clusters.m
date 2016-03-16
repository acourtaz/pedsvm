function N_clusters(varargin)

%Written by DP 05/01/2016
%Counts the number of clusters (MIA objects) 
%in a cell (defined by a Metamorph region)
%Uses the same code as rgn2mask

if nargin == 0
    [fc,pc] = uigetfile('*.tif','MIA image of clusters (objects)');    
    if ~fc,return,end
    [f,p] = uigetfile('*.rgn','Polygonal region file');
    if ~f,return,end
elseif nargin == 2
    p = [cd,'\'];
    pc = p;
    fc = varargin{1};
    f = varargin{2};
else
    error('mask2rgn needs 3 arguments (cluster objects filename,region filename) or none')
end

clust = imread([pc,fc]);
clust = double(clust);

rgn = dlmread([p,f]);
poly = rgn(1,17:end-2);
poly2 = zeros(size(poly,2)/2,2);
poly2(:,1) = poly(1:2:end)';
poly2(:,2) = poly(2:2:end)';
mask = poly2mask(poly2(:,1),poly2(:,2),size(clust,1),size(clust,2));

clust0 = (clust.*mask) > 0;
clustN = bwlabel(clust0,4);
prop = regionprops(clustN,'area');
disp(size(prop,1))
disp('clusters')

%mimage(clust-10*mask+1)

