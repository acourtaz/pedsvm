function avFluo4all

%Written by DP 6/9/05 updated feb 2006, sep 2006, april 2007%

[f,p] = uigetfile('*.txt;*.trc','File with matrix of events');
if ~f,return,end
events = dlmread([p,f],'\t');

[stk5g,stkd] = uigetfile('*.stk','Green channel movie (pH 5)');
if ~stk5g,return,end
M5g = stkread(stk5g,stkd);

[stk7g,stkd] = uigetfile('*.stk','Green channel movie (pH 7)');
if ~stk7g,return,end
M7g = stkread(stk7g,stkd);

[stk5r,stkd] = uigetfile('*.stk','Red channel movie (pH 5)');
if ~stk5r,return,end
M5r = stkread(stk5r,stkd);

[stk7r,stkd] = uigetfile('*.stk','Red channel movie (pH 7)');
if ~stk7r,return,end
M7r = stkread(stk7r,stkd);

movieLength = min([size(M5g,3),size(M7g,3),size(M5r,3),size(M7r,3)]);
M5g = M5g(:,:,1:movieLength);
M7g = M7g(:,:,1:movieLength);
M5r = M5r(:,:,1:movieLength);
M7r = M7r(:,:,1:movieLength);
%M = cat(4,M5g,M5r,M7g,M7r);

[coFile,coDir] = uigetfile('*.txt','File with alignment coefficients');
if ~coFile
    %warndlg('No alignment correction will be performed','Warning')
    coeff = [0 1 0 0 0 0 0 0 0 0 0 1 0 0]';
else coeff = dlmread([coDir,coFile],'\t');
end
%nCo = [0 1 0 0 0 0 0 0 0 0 0 1 0 0]';
output = [];

rCircle = 3;
rAnn = 6;
lowpercent = 0.3; %lower percentile of the pixel values used for background
before = 20; %number of frames measured before vesicle appearance%
length = 20; %maximum length of tracked vesicle%
defaults = [rCircle,rAnn,lowpercent,before,length];
prompt = {'Circle radius','Annulus outer radius',...
    'Lower percentile of the pixel values used for background (0<p<=1)',...
    'Number of frames before start of event',...
    'Number of frames after start of event'};
[rCircle,rAnn,lowpercent,before,length] = ...
numinputdlg(prompt,'Parameters for fluorescence measurements',1,defaults);  
pause(1)
param = [rCircle,rAnn,lowpercent,before,length];
miniSize = 2*rAnn+1;
miniPix = miniSize^2;
%[x,y] = meshgrid(1:miniSize);

if events(1,1) == 0
    firstEvent = round(events(2,1));
else
    firstEvent = round(events(1,1));
end
lastEvent = round(events(end,1));
for i=firstEvent:lastEvent
    eventTrack = (events(:,1)==i);
    [u,start] = max(eventTrack);
    if u
        frame = round(events(start,2));
        val = zeros(1,length+before+4);
        val(1) = events(start,1);
%calculates avFluo before the event ; centered on first frame of event%
        minu = min([frame-1,before]);
        xG = events(start,3);  
        yG = events(start,4);  
        ixG = floor(xG)+1;
        iyG = floor(yG)+1;
        xR = interPolx(events(start,3),events(start,4),coeff);
        yR = interPoly(events(start,3),events(start,4),coeff);
        ixR = floor(xR)+1;
        iyR = floor(yR)+1;
        
        [circleG,annG] = donut(xG,yG,rCircle,rAnn);
        circleG = circleG(:,:,ones(1,minu+1));
        annG = annG(:,:,ones(1,minu+1));
        [circleR,annR] = donut(xR,yR,rCircle,rAnn);
        circleR = circleR(:,:,ones(1,minu+1));
        annR = annR(:,:,ones(1,minu+1));
        
        im = ...
double(M5g(iy0-rAnn:iy0+rAnn,ix0-rAnn:ix0+rAnn,frame-minu:frame));
        npixG = squeeze(round(sum(sum(annG,1))))';
    %number of pixels in the lower percentile
        nlowpixG = round(npixG*lowpercent);
        back = im.*annulus;
        sortback = sort(reshape(back,miniPix,minu+1));
background = sum(sortback(miniPix-npix+1:miniPix-npix+nlowpix,:))./nlowpix;
        values = sum(sum(im.*circle))/sum(sum(circle(:,:,1)));
        val([before+5-minu:before+5]) = squeeze(values)' - background;
        j=1; 
%calculates avFluo for the event after the first frame - tracked %
        trackLength = sum(eventTrack);
        while (start+j-1 < size(events,1)) & (j<trackLength) & (j < length)
            x0 = interPolx(events(start+j,3),events(start+j,4),coeff);
            ix0 = floor(x0)+1;
            dx0 = x0-ix0+1;
            y0 = interPoly(events(start+j,3),events(start+j,4),coeff);
            iy0 = floor(y0)+1;
            dy0 = y0-iy0+1;
            distance = sqrt((x-rAnn-dx0-1).^2 + (y-rAnn-dy0-1).^2);
            circle = distance<rCircle;
            annulus = (distance>=rCircle)&(distance<rAnn);
            im = double(M5g(iy0-rAnn:iy0+rAnn,ix0-rAnn:ix0+rAnn,frame+j));
            npix = round(sum(sum(annulus)));
            nlowpix = round(npix*lowpercent);
            back = im.*annulus;
            sortback = sort(back(:));
            background = ...
                sum(sortback(miniPix-npix+1:miniPix-npix+nlowpix))/nlowpix;
            val(before+5+j) = ...
                sum(sum(im.*circle))/sum(sum(circle)) - background;
            j=j+1;
        end
%calculates avFluo after the object has stopped being tracked -
%the center stays where the object was in the last frame
        if (j<length) & (frame+j < size(M5g,3))
            v = min([frame+length,size(M5g,3)]);
            v = v - frame; %The maximal length of measures
            x0 = interPolx(events(start+j-1,3),events(start+j-1,4),coeff);
            ix0 = floor(x0)+1;
            dx0 = x0-ix0+1;
            y0 = interPoly(events(start+j-1,3),events(start+j-1,4),coeff);
            iy0 = floor(y0)+1;
            dy0 = y0-iy0+1;
            distance = sqrt((x-rAnn-dx0-1).^2 + (y-rAnn-dy0-1).^2);
            circle = distance<rCircle;
            circle = circle(:,:,ones(1,v-j));
            annulus = (distance>=rCircle)&(distance<rAnn);
            annulus = annulus(:,:,ones(1,v-j));
            im = ...
       double(M5g(iy0-rAnn:iy0+rAnn,ix0-rAnn:ix0+rAnn,frame+j:frame+v-1)); 
            npix = squeeze(round(sum(sum(annulus,1))))';
            nlowpix = round(npix*lowpercent);
            back = im.*annulus;
            sortback = sort(reshape(back,miniPix,v-j));
            background = ...
             sum(sortback(miniPix-npix+1:miniPix-npix+nlowpix,:))./nlowpix;
            values = sum(sum(im.*circle))/sum(sum(circle(:,:,1)));
            val([before+j+5:before+v+4]) = squeeze(values)' - background;
        end  
        val(3)=j;
        output = cat(1,output,val);
        %a = [events(start,1) j];
        %a %just to have a marker while the program is running
    end
end

averageEv = mean(output);
stdEv = std(output);
datathere = output~=0;
datathere = datathere(:,5:end);
stdPlot = stdEv(5:size(stdEv,2));
averagePlot = averageEv(5:size(averageEv,2));
semPlot = stdPlot./sqrt(sum(datathere,1));
frameNumb = -before:length-1;

grandAverage = zeros(5,size(output,2));
grandAverage(1,5:end) = frameNumb;
grandAverage(2,5:end) = averagePlot;
grandAverage(3,5:end) = semPlot;
grandAverage(4,5:end) = sum(datathere,1);

output = cat(1,grandAverage,output);

figure
if ~coFile
    errorbar(frameNumb,averagePlot,semPlot,'-og','markerfacecolor','g')
else
    errorbar(frameNumb,averagePlot,semPlot,'-or','markerfacecolor','r')
end
line([0 0],ylim)
xlabel('Frame #')
ylabel('average fluo')
title(['cell # ',f(1:4)])

[fle,p] = uiputfile([f(1:end-4),'_av.xls']...
      ,'Where to put the average fluorescence file');

%instructions to remove 0s and putting names in the excel file
output = num2cell(output);
output{1,1} = 'frame';
output{2,1} = 'average';
output{3,1} = 'sem';
output{4,1} = 'N';
hightCell = size(output,1);
widthCell = size(output,2);
for i=2:widthCell
    output{5,i}='';
end
output{5,1} = 'event#';
output{5,3} = 'track';
for i=1:hightCell
    output{i,2} = '';
    output{i,4} = '';
end
for i=1:4
    output{i,3} = '';
end
    
if ischar(fle)&ischar(p)
   xlswrite([p,fle],output)
end


%Third order polynomials for interpolation

function [cir,ann] = donut(x0,y0,rc,ra)
[x,y] = meshgrid(1:2*ra+1);
dx0 = x0-floor(x0);
dy0 = y0-floor(y0);
distance = sqrt((x-ra-dx0-1).^2 + (y-ra-dy0-1).^2);
cir = distance<rc;
ann = (distance>=rc)&(distance<ra);

function u = interPolx(x,y,c)
u = c(1) + c(2).*x + c(3).*x.^2 + c(4).*x.^3 +...
   c(5).*y + c(6).*y.^2 + c(7).*y.^3;

function v = interPoly(x,y,c)
v = c(8) + c(9).*x + c(10).*x.^2 + c(11).*x.^3 +...
   c(12).*y + c(13).*y.^2 + c(14).*y.^3;
