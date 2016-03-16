function avFluo_averages

rCircle = 2;
rAnn = 5; % changed from 3 6 to 2 5 by Mo on 23/07/2014
lowpercent = 0.2; %lower percentile of the pixel values used for background
highpercent = 0.8;
Edge = rAnn+1;

[f1,p1] = uigetfile('*.txt;*.trc','File with green objects');
if ~f1,return,end
sTRC = ~isempty(strfind(f1,'.trc')); %shift of 1 pixel between
%trc coordinates and Matlab matrix coordinates
events1 = dlmread([p1,f1],'\t');
pause(0.1)

[f2,p2] = uigetfile('*.txt;*.trc','File with red objects');
if ~f2,return,end
sTRC = ~isempty(strfind(f2,'.trc')); %shift of 1 pixel between
%trc coordinates and Matlab matrix coordinates
events2 = dlmread([p2,f2],'\t');
pause(0.1)

[stk,stkd] = uigetfile('*.stk','Green images');
if ~stk,return,end
movi = stkread(stk,stkd);
pause(0.1)

[stkR,stkdR] = uigetfile('*.stk','Red images');
if ~stkR,return,end
moviR = stkread(stkR,stkdR);
pause(0.1)

output1 = fluoCorrAv(events1,movi,moviR,sTRC);
output2 = fluoCorrAv(events2,moviR,movi,sTRC);

[fle,p] = uiputfile([f1,'.xlsx'], ...
    'Where to put the average fluorescence file');
if ischar(fle) && ischar(p)
    warning off MATLAB:xlswrite:AddSheet
    xlswrite([p,fle],output1,f1)
    xlswrite([p,fle],output2,f2)
end

function output = fluoCorrAv(events,movi,moviR,sTRC)

rCircle = 2;
rAnn = 5; % changed from 3 6 to 2 5 by Mo on 23/07/2014
lowpercent = 0.2; %lower percentile of the pixel values used for background
highpercent = 0.8;
Edge = rAnn+1;

miniSize = 2*rAnn+1;
miniPix = miniSize^2;
[x,y] = meshgrid(1:miniSize);
output = [];

events = sortrows(events,2);
output = zeros(size(events,1),7);
output(:,1) = 1:size(output,1);
output(:,2:4) = events(:,2:4);

edge_xs = events(:,3) < Edge;
edge_xl = events(:,3) > (size(movi,2)-Edge);
edge_ys = events(:,4) < Edge;
edge_yl = events(:,4) > (size(movi,1)-Edge);
edge_xy = edge_xs|edge_xl|edge_ys|edge_yl; %1 if too close to an edge
output(:,7) = edge_xy;
    
for i=1:size(events,1)
    if output(i,7) == 0
        x0 = events(i,3);
        ix0 = floor(x0)+sTRC;
        dx0 = x0-ix0+sTRC;
        y0 = events(i,4);
        iy0 = floor(y0)+sTRC;
        dy0 = y0-iy0+sTRC;
        distance = sqrt((x-rAnn-dx0-1).^2 + (y-rAnn-dy0-1).^2);
        circle = distance<rCircle;
        annulus = (distance>=rCircle)&(distance<rAnn);
        im = double(movi(iy0-rAnn:iy0+rAnn,ix0-rAnn:ix0+rAnn,events(i,2)));
        imR = double(moviR(iy0-rAnn:iy0+rAnn,ix0-rAnn:ix0+rAnn,events(i,2)));
        nPix = round(sum(sum(annulus)));
        nLoPix = round(nPix*lowpercent);
        nHiPix = round(nPix*highpercent);
        back = im.*annulus;
        sortback = sort(back(:));
        background = ...
sum(sortback(miniPix-nPix+nLoPix+1:miniPix-nPix+nHiPix))/(nHiPix-nLoPix);
        backR = imR.*annulus;
        sortbackR = sort(backR(:));
        backgroundR = ...
sum(sortbackR(miniPix-nPix+nLoPix+1:miniPix-nPix+nHiPix))/(nHiPix-nLoPix);
        output(i,5) = sum(sum(im.*circle))/sum(sum(circle)) - background;
        output(i,6) = sum(sum(imR.*circle))/sum(sum(circle)) - backgroundR;
    else
disp(['event ',num2str(i),' frame ',num2str(output(i,2)),' too close to edge'])
    end
end

