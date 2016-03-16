function avFluo4random

%Written by DP 6/9/05 updated feb 2006, sep 2006, april 2007%

[f,p] = uigetfile('*.txt;*.trc','File with matrix of events');
if ~f,return,end
events = dlmread([p,f],'\t');
[stk,stkd] = uigetfile('*.stk','Choose a Stack');
if ~stk,return,end
movi = stkread(stk,stkd);
[coFile,coDir] = uigetfile('*.txt',...
    'File with alignment coefficients (Press Cancel if green channel)');
if ~coFile
    %warndlg('No alignment correction will be performed','Warning')
    coeff = [0 1 0 0 0 0 0 0 0 0 0 1 0 0]';
else coeff = dlmread([coDir,coFile],'\t');
end
[fshift,pshift] = uigetfile('*.txt','File of random shifts');
if ~fshift,return,end
XYs = dlmread([pshift,fshift],'\t');

output = [];

rCircle = 3;
rAnn = 6;
lowpercent = 0.2; %lower percentile of the pixel values used for background
highpercent = 0.8;
before = 20; %number of frames measured before vesicle appearance%
length = 20; %maximum length of tracked vesicle%
defaults = [rCircle,rAnn,lowpercent,highpercent,before,length];
prompt = {'Circle radius','Annulus outer radius',...
    'Lower limit L of the pixel values used for background  (0<= L < H <=1)',...
    'Higher limit H of the pixel values used for background (0<= L < H <=1)',...
    'Number of frames before start of event',...
    'Number of frames after start of event'};
[rCircle,rAnn,lowpercent,highpercent,before,length] = ...
numinputdlg(prompt,'Parameters for fluorescence measurements',1,defaults);  
pause(1)
%height = size(movi,1);
%width = size(movi,2);
miniSize = 2*rAnn+1;
miniPix = miniSize^2;
[x,y] = meshgrid(1:miniSize);
%parameters: events, XYs, before, length, coeff, movi
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
        k = find(XYs(:,1)==i); %specific for avFluo4random
        k = k(1);
        %%%
        frame = round(events(start,2));
        val = zeros(1,length+before+3);
        val(1) = events(start,1);
%calculates avFluo before the event ; centered on first frame of event%
        minu = min([frame-1,before]);
        x0 = interPolx(events(start,3)+XYs(k,2),events(start,4)+XYs(k,3),coeff);
        ix0 = floor(x0)+1;
        dx0 = x0-ix0+1;
        y0 = interPoly(events(start,3)+XYs(k,2),events(start,4)+XYs(k,3),coeff);
        iy0 = floor(y0)+1;
        dy0 = y0-iy0+1;
        distance = sqrt((x-rAnn-dx0-1).^2 + (y-rAnn-dy0-1).^2);
        circle = distance<rCircle;
        circle = circle(:,:,ones(1,minu+1));
        annulus = (distance>=rCircle)&(distance<rAnn);
        annulus = annulus(:,:,ones(1,minu+1));
        im = ...
double(movi(iy0-rAnn:iy0+rAnn,ix0-rAnn:ix0+rAnn,frame-minu:frame));
        nPix = squeeze(round(sum(sum(annulus,1))))';
    %number of pixels in the lower percentile
        nLoPix = round(nPix*lowpercent);
        nHiPix = round(nPix*highpercent);
        back = im.*annulus;
        sortback = sort(reshape(back,miniPix,minu+1));
        background = ...
sum(sortback(miniPix-nPix+nLoPix+1:miniPix-nPix+nHiPix,:))./(nHiPix-nLoPix);
        values = sum(sum(im.*circle))/sum(sum(circle(:,:,1)));
        val([before+4-minu:before+4]) = squeeze(values)' - background;
        j=1; 
%calculates avFluo for the event after the first frame - tracked %
        trackLength = sum(eventTrack);
        while (start+j-1 < size(events,1)) & (j<trackLength) & (j < length)
            x0 = interPolx(events(start+j,3)+XYs(k,2),events(start+j,4)+XYs(k,3),coeff);
            ix0 = floor(x0)+1;
            dx0 = x0-ix0+1;
            y0 = interPoly(events(start+j,3)+XYs(k,2),events(start+j,4)+XYs(k,3),coeff);
            iy0 = floor(y0)+1;
            dy0 = y0-iy0+1;
            distance = sqrt((x-rAnn-dx0-1).^2 + (y-rAnn-dy0-1).^2);
            circle = distance<rCircle;
            annulus = (distance>=rCircle)&(distance<rAnn);
            im = double(movi(iy0-rAnn:iy0+rAnn,ix0-rAnn:ix0+rAnn,frame+j));
            nPix = round(sum(sum(annulus)));
            nLoPix = round(nPix*lowpercent);
            nHiPix = round(nPix*highpercent);
            back = im.*annulus;
            sortback = sort(back(:));
            background = ...
sum(sortback(miniPix-nPix+nLoPix+1:miniPix-nPix+nHiPix))/(nHiPix-nLoPix);
            val(before+4+j) = ...
                sum(sum(im.*circle))/sum(sum(circle)) - background;
            j=j+1;
        end
%calculates avFluo after the object has stopped being tracked -
%the center stays where the object was in the last frame
        if (j<length) & (frame+j < size(movi,3))
            v = min([frame+length,size(movi,3)]);
            v = v - frame; %The maximal length of measures
            x0 = interPolx(events(start+j-1,3)+XYs(k,2),events(start+j-1,4)+XYs(k,3),coeff);
            ix0 = floor(x0)+1;
            dx0 = x0-ix0+1;
            y0 = interPoly(events(start+j-1,3)+XYs(k,2),events(start+j-1,4)+XYs(k,3),coeff);
            iy0 = floor(y0)+1;
            dy0 = y0-iy0+1;
            distance = sqrt((x-rAnn-dx0-1).^2 + (y-rAnn-dy0-1).^2);
            circle = distance<rCircle;
            circle = circle(:,:,ones(1,v-j));
            annulus = (distance>=rCircle)&(distance<rAnn);
            annulus = annulus(:,:,ones(1,v-j));
            im = ...
       double(movi(iy0-rAnn:iy0+rAnn,ix0-rAnn:ix0+rAnn,frame+j:frame+v-1)); 
            nPix = squeeze(round(sum(sum(annulus,1))))';
            nLoPix = round(nPix*lowpercent);
            nHiPix = round(nPix*highpercent);
            back = im.*annulus;
            sortback = sort(reshape(back,miniPix,v-j));
            background = ...
sum(sortback(miniPix-nPix+nLoPix+1:miniPix-nPix+nHiPix,:))./(nHiPix-nLoPix);
            values = sum(sum(im.*circle))/sum(sum(circle(:,:,1)));
            val([before+j+4:before+v+3]) = squeeze(values)' - background;
        end  
        val(2)=j;
        output = cat(1,output,val);
        %a = [events(start,1) j];
        %a %just to have a marker while the program is running
    end
end

averageEv = mean(output);
stdEv = std(output);
datathere = output~=0;
datathere = datathere(:,4:end);
stdPlot = stdEv(4:size(stdEv,2));
averagePlot = averageEv(4:size(averageEv,2));
semPlot = stdPlot./sqrt(sum(datathere,1));
frameNumb = -before:length-1;

grandAverage = zeros(5,size(output,2));
grandAverage(1,4:end) = frameNumb;
grandAverage(2,4:end) = averagePlot;
grandAverage(3,4:end) = semPlot;
grandAverage(4,4:end) = sum(datathere,1);

output = cat(1,grandAverage,output);

figure('name',stk(1:end-4))
if ~coFile
    errorbar(frameNumb,averagePlot,semPlot,'-og','markerfacecolor','g')
else
    errorbar(frameNumb,averagePlot,semPlot,'-or','markerfacecolor','r')
end
line([0 0],ylim)
xlabel('Frame #')
ylabel('average fluo')
title(['cell #  ',stk(1:4),' ',stk(6:9)])

[fle,p] = uiputfile([f(1:4),'_data.xls']...
      ,'Where to put the average fluorescence file');

%instructions to remove 0s and putting names in the excel file


output = num2cell(output);
hightCell = size(output,1);
widthCell = size(output,2);
output(5,:) = {''};
output(:,3) = {''};
output(1:4,1:2) = {''};
output(1:4,3) = {'frame';'average';'sem';'N'};
output(5,1:2) = {'event#','track'};

parcell = cell(4,widthCell);
parcell{1,1} = ['Fluorescence quantification: circle-annulus for ',stk(1:end-4)];
parcell(1,4:7) = {'event file:',f,'',date};
parcell(2,1:6) = {'rCircle','rAnnulus','low_perc','high_perc','fr_bef','fr_aft'};
params = num2cell([rCircle,rAnn,lowpercent,highpercent,before,length]);
parcell(3,1:6) = params;
output = cat(1,parcell,output);

if ischar(fle)&ischar(p)
   warning off MATLAB:xlswrite:AddSheet
   sheet = [stk(1:end-4),' fluo'];
   xlswrite([p,fle],output,sheet)
end


%Third order polynomials for interpolation

function u = interPolx(x,y,c)
u = c(1) + c(2).*x + c(3).*x.^2 + c(4).*x.^3 +...
   c(5).*y + c(6).*y.^2 + c(7).*y.^3;

function v = interPoly(x,y,c)
v = c(8) + c(9).*x + c(10).*x.^2 + c(11).*x.^3 +...
   c(12).*y + c(13).*y.^2 + c(14).*y.^3;
