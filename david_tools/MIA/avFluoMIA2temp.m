function avFluoMIA2temp

%Written by DP 6/9/05 updated feb 2006, sep 2006%
%needs to be modified from line 74 onwards

[f,p] = uigetfile('*.txt;*.trc','File with matrix of events');
if ~f,return,end
events = dlmread([p,f],'\t');
[stk,stkd] = uigetfile('*.stk','Choose a Stack');
if ~stk,return,end
movi = stkread(stk,stkd);
[coFile,coDir] = uigetfile('*.txt','File with alignment coefficients');
if ~coFile
    %warndlg('No alignment correction will be performed','Warning')
    coeff = [0 1 0 0 0 0 0 0 0 0 0 1 0 0]';
else coeff = dlmread([coDir,coFile],'\t');
end
output = [];

rCircle = 3;
rAnnulus = 6;
length = 20; %maximum length of tracked vesicle%
before = 20; %number of frames measured before vesicle appearance%
lowpercent = 0.3; %lower percentile of the pixel values used for background

height = size(movi,1);
width = size(movi,2);
[x,y] = meshgrid(1:size(movi,2),1:size(movi,1));
lastEvent = round(events(end,1);
for i=1:lastEvent
    eventTrack = (events(:,1)==i);
    [w,start] = max(eventTrack);
    if w
        frame = round(events(start,2));
        val = zeros(1,length+before+4);
        val(1) = events(start,1);
%calculates avFluo before the event ; centered on first frame of event%
        u = min([frame-1,before]);
        x0 = interPolx(events(start,3),events(start,4),coeff);
        y0 = interPoly(events(start,3),events(start,4),coeff);
        distance = sqrt((x-x0).^2 + (y-y0).^2);
        circle = distance<rCircle;
        circle = circle(:,:,ones(1,u+1));
        annulus = (distance>=rCircle)&(distance<rAnnulus);
        annulus = annulus(:,:,ones(1,u+1));
        im = double(movi(:,:,frame-u:frame));
        npix = squeeze(round(sum(sum(annulus,1))))';
    %number of pixels in the lower percentile
        nlowpix = round(npix*lowpercent);
        back = im.*annulus;
        sortback = sort(reshape(back,height*width,u+1));
        background = sum(sortback(1:height*width-npix+nlowpix,:))./nlowpix;
        values = sum(sum(im.*circle))/sum(sum(circle(:,:,1)));
        val([before+5-u:before+5]) = squeeze(values)' - background;
        trackLength = sum(EventTrack);
        trackLength = min(length,trackLength);
%calculates avFluo for the event after the first frame - tracked %
        for j=1:trackLength-1
            x0 = interPolx(events(start+j,3),events(start+j,4),coeff);
            y0 = interPoly(events(start+j,3),events(start+j,4),coeff);
            distance = sqrt((x-x0).^2 + (y-y0).^2);
            circle = distance<rCircle;
            annulus = (distance>=rCircle)&(distance<rAnnulus);
            im = double(movi(:,:,frame+j));
            npix = round(sum(sum(annulus)));
            nlowpix = round(npix*lowpercent);
            back = im.*annulus;
            sortback = sort(back(:));
            background = sum(sortback(1:height*width-npix+nlowpix))/nlowpix;
            val(before+5+j) = sum(sum(im.*circle))/sum(sum(circle)) - background;
        end
%calculates avFluo after the object has stopped being tracked -
%the center stays where the object was in the last frame
        if (length-trackLength > 0) & (frame+length < size(movi,3))
            v = min([frame+length,size(movi,3)]);
            v = v - frame; %The maximal length of measures
            x0 = interPolx(events(i+j,3),events(i+j,4),coeff);
            y0 = interPoly(events(i+j,3),events(i+j,4),coeff);
            distance = sqrt((x-x0).^2 + (y-y0).^2);
            circle = distance<rCircle;
            circle = circle(:,:,ones(1,v-j));
            annulus = (distance>=rCircle)&(distance<rAnnulus);
            annulus = annulus(:,:,ones(1,v-j));
            im = double(movi(:,:,frame+j:frame+v-1));
            npix = squeeze(round(sum(sum(annulus,1))))';
            nlowpix = round(npix*lowpercent);
            back = im.*annulus;
            sortback = sort(reshape(back,height*width,v-j));
            background = sum(sortback(1:height*width-npix+nlowpix,:))./nlowpix;
            values = sum(sum(im.*circle))/sum(sum(circle(:,:,1)));
            val([before+j+5:before+v+4]) = squeeze(values)' - background;
        end  
        val(3)=j;
        output = cat(1,output,val);
        a = [events(i+1,1) j];
        a %just to have a marker while the program is running
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

grandAverage = zeros(4,size(output,2));
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

[fle,p] = uiputfile([f(1:end-4),'_av.txt']...
      ,'Where to put the average fluorescence file');
  
if ischar(fle)&ischar(p)
   dlmwrite([p,fle],output,'\t')
end


%Third order polynomials for interpolation

function u = interPolx(x,y,c)
u = c(1) + c(2).*x + c(3).*x.^2 + c(4).*x.^3 +...
   c(5).*y + c(6).*y.^2 + c(7).*y.^3;

function v = interPoly(x,y,c)
v = c(8) + c(9).*x + c(10).*x.^2 + c(11).*x.^3 +...
   c(12).*y + c(13).*y.^2 + c(14).*y.^3;
