function paxiClath2(varargin)

%Written by DP 28/08/15
%This program computes various ways to visualize and quantify distance
%between adhesion sites (labelled with paxillin-GFP) and CCPs
%Uses three images: paxilin, clathrin and a mask
%Computes the number of adhesion sites, of CCPs within the mask
%Their average size, the fraction of mask taken by both
%The fraction of paxilin colocalized with clathrin
%The fraction of clathrin colocalized with paxilin
%The average distance of the nearest CCP to the center of paxilin sites

if isempty(varargin)
    [fileG,pthG] = uigetfile('*.tif','Choose the paxilin (green) image');
    if ~fileG,return,end
    [fileR,pthR] = uigetfile('*.tif','Choose the clathrin (red) image');
    if ~fileR,return,end
    
    [fileB,pthB] = uigetfile('*.tif','Choose the mask image');
    if ~fileB,return,end

else
    pth = varargin{1};
    pthG = pth; pthR = pth; pthB = pth;
    fileG = varargin{2};
    fileR = varargin{3};
    fileB = varargin{4};
end
fk = strfind(fileG,'_');
cellName = fileG(1:fk(1)-1); %the number of the cell analysed
imG = imread([pthG,fileG]);
imR = imread([pthR,fileR]);
imB = imread([pthB,fileB]);
%crops the images if they are of different size (it shouldn't happen, but
%it would prevent the procedure from making an error.
sizeIm = min([size(imG);size(imR);size(imB)]);
imG = imG(1:sizeIm(1),1:sizeIm(2));
imR = double(imR(1:sizeIm(1),1:sizeIm(2)));
imG = double(imG(1:sizeIm(1),1:sizeIm(2)));

if max(max(imB)) > 10000
    mask = double(imB > 64000);
else
    mask = double(imB > 0);
end
Pax = imG.*mask;
CCP = imR.*mask;
isPax = Pax > 0;
isCCP = CCP > 0;
CCP_Pax = isPax.*isCCP;
ccpDist = bwdist(imR);
ccpDist = ccpDist.*mask;
propPax = regionprops(Pax,'area','centroid');
%in propPax there will be zero area regions and NaN centroid coordinates
%if some regions are outside the mask
nPax = 0;
sPax = 0;
for i = 1:size(propPax,1)
    if propPax(i).Area > 0
        sPax = sPax+propPax(i).Area;
        nPax = nPax + 1;
    end
end
sPax = sPax/nPax;
propCCP = regionprops(CCP,'area');
nCCP = 0;
sCCP = 0;
for i = 1:size(propCCP,1)
    if propCCP(i).Area > 0
        sCCP = sCCP+propCCP(i).Area;
        nCCP = nCCP + 1;
    end
end
sCCP = sCCP/nCCP;
distPax = [];
for i = 1:size(propPax,1)
    if propPax(i).Area > 0
    distPax = cat(1,distPax,ccpDist(round(propPax(i).Centroid(1)),round(propPax(i).Centroid(2))));
    end
end
Titles = {'Number adhesion sites';'Average adhesion size';...
    'Number CCPs';'Average CCP size';...
    'Size mask';'% adhesion sites in mask';'% CCPs in mask';...
    '% paxilin coloc CCP';'% CCP coloc paxilin';...
    'Average distance nearest CCP center paxilin'};
%Calculates the distribution of distances in cell mask
pixMask = sum(sum(mask));
sDistPax = sort(ccpDist(:),'descend');
sDistPax = sDistPax(1:pixMask);
sDistPax = sort(sDistPax);

data = zeros(10,1);
data(1) = nPax;
data(2) = sPax;
data(3) = nCCP;
data(4) = sCCP;
data(5) = pixMask;
data(6) = 100*sum(sum(isPax))/data(5);
data(7) = 100*sum(sum(isCCP))/data(5);
data(8) = 100*sum(sum(CCP_Pax))/sum(sum(isPax));
data(9) = 100*sum(sum(CCP_Pax))/sum(sum(isCCP));
data(10) = mean(distPax);

distPax = sort(distPax);
hp = figure('name',cellName);
plot(distPax,1/nPax:1/nPax:1,sDistPax,1/pixMask:1/pixMask:1)
xlabel('distance from CCP')
ylabel('fraction of adhesion sites')
saveas(hp,[pthG,cellName,'_dist.fig'])

disp(['Pax image ',fileG])
disp(['CCP image ',fileR])
disp(['mask imge ',fileB])
disp(' ')
for i = 1:10
    disp([num2str(data(i)),' ',Titles{i}])
end

dlmwrite([pthG,cellName,'_quant.txt'],data','\t')

hf = figure('name',cellName);
image(isCCP+3*isPax+4*bwperim(mask),'cdatamapping','scaled')
axis image
colormap rainbow
pixvalm
saveas(hf,[pthG,cellName,'_coloc.fig'])


