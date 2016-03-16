function damfluoTubules

%Written by DP 16/06/10, updated by DJ 01/04/11

[f,p] = uigetfile('*.txt;*.trc','File with matrix of events (annotate)');
if ~f,return,end
sTRC = ~isempty(strfind(f,'.trc'));
events = dlmread([p,f],'\t');
pause (0.5);
[stkG,stkdG] = uigetfile('*.stk','Choose a Stack for exo events (green)');
if ~stkG,return,end
mG = stkread(stkG,stkdG);

pause (0.5);
maskcell=dlmread(uigetfile('*.txt','Select mask'));
airepix=sum((sum(maskcell)));
pixSize = 0.064516; %Size pixel spinning +63x, in �m�
aire=pixSize*airepix; 
pause (0.5);
[stkR,stkdR] = uigetfile('*.stk','Second color (red) to quantify (optional)');
%is_R = ~isempty(stkR);
if stkR
    mR = stkread(stkR,stkdR);
%Estimate of red fluorescence level for normalization
    pause (0.5);
    regionback=dlmread(uigetfile('*.txt', 'Select background region'));
    fluobackR=sum(sum(double(mR(regionback(1,2):(regionback(1,2)+regionback(1,4)), regionback(1,1):(regionback(1,1)+regionback(1,3))))))/(regionback(1,3)*regionback(1,4));
    fluobackG=sum(sum(double(mG(regionback(1,2):(regionback(1,2)+regionback(1,4)), regionback(1,1):(regionback(1,1)+regionback(1,3))))))/(regionback(1,3)*regionback(1,4));
    Redmoy = maskcell.*double(mR(:,:,1));
    Redmoy = ((sum(sum(Redmoy)))/airepix)-fluobackR;
    Greenmoy = maskcell.*double(mG(:,:,1));
    Greenmoy = ((sum(sum(Greenmoy)))/airepix)-fluobackG;
    [coFile,coDir] = uigetfile('*.txt',...
    'File with alignment coefficients (Press Cancel if green channel)');
    if ~coFile
    %warndlg('No alignment correction will be performed','Warning')
        coeff = [0 1 0 0 0 0 0 0 0 0 0 1 0 0]';
    else coeff = dlmread([coDir,coFile],'\t');
    end
end




output = [];
outputR = [];


%%% Parameters not visible from prompt
Offset = 10000; %offset for non-zero pixel values

%%% Parameters which can be changed through prompt
before = 10; %Number of frames measured before vesicle appearance
after = 30; %Number of frames measured after vesicle appearance
miniSize = 25; %Size of miniStack used for event measures (odd number)
Nfr = 5; %Number of frames to evaluate background fluorescence
thresh = 5; %Threshold (multiples of background SD) to segment image
pixThresh = 4; %Minimal number of pixels for detectable object
rCircle = 2.2; %radius (in pixels) of circle used to quantify fluo as minimum
defaults = [before,after,miniSize,Nfr,thresh,pixThresh,rCircle];
prompt = {'Number of frames before start of event',...
    'Number of frames after start of event',...
    'Size of ministack to find object'...
    'Number of frames to evaluate background fluorescence',...
    'Threshold for image segmentation (multiple of background SD)',... 
    'Minimal number of pixels for an object',...
    'Circle radius for quantification',};
[before,after,miniSize,Nfr,thresh,pixThresh,rCircle] = ...
numinputdlg(prompt,'Parameters for fluorescence measurements',1,defaults);  
pause(1)

ma = floor(miniSize/2); %12 if minisize = 25

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
        val = zeros(1,before+after+9);
        val(1) = events(start,1); %event number
        if stkR
            valR = zeros(1,before+after+4);
            valR(1) = val(1);
        end
        x0 = events(start,3) + sTRC;
        ix0 = floor(x0);
        rx0 = round(x0);
        dx0 = x0-ix0;
        y0 = events(start,4) + sTRC;
        iy0 = floor(y0);
        ry0 = round(y0);
        dy0 = y0-iy0;
        x_minG = max(1,rx0-ma);
        y_minG = max(1,ry0-ma);
        x_maxG = min(size(mG,2),rx0+ma);
        y_maxG = min(size(mG,1),ry0+ma);
%%%For red channel %%%At this stage no xy shift corrections
        if stkR
            x0R = interPolx(x0,y0,coeff);
            y0R = interPoly(x0,y0,coeff);
        end
        
        t_minG = max(frame-before,1);
        t_maxG = min(frame+after,size(mG,3));

%%%Warning, x coordinate is second dimension!!!
        miniG = double(mG(y_minG:y_maxG,x_minG:x_maxG,t_minG:t_maxG));
        miniAv = double(mG(y_minG:y_maxG,x_minG:x_maxG,frame-Nfr:frame-1));
        miniAv = sum(miniAv,3)./Nfr;
        miniAv = miniAv(:,:,ones(1,size(miniG,3)));
        miniGb = miniG - miniAv;
%%%For red channel %%%No xy shift corrections
        if stkR
        miniR = double(mR(y_minG:y_maxG,x_minG:x_maxG,t_minG:t_maxG));
        miniAvR = double(mR(y_minG:y_maxG,x_minG:x_maxG,frame-Nfr:frame-1));
        miniAvR = sum(miniAvR,3)./Nfr;
        miniAvR = miniAvR(:,:,ones(1,size(miniR,3)));
        miniRb = miniR - miniAvR;
        end
        [x,y] = meshgrid(1:size(miniGb,2),1:size(miniGb,1));
        l_t0 = min(frame,before+1); %local frame start
        l_x0 = min(x0,ma+1)+dx0;
        l_y0 = min(y0,ma+1)+dy0;
%%%Fluo calculations before the event
        distance = sqrt((x-l_x0).^2 + (y-l_y0).^2);
        mask = distance<rCircle;
        mask = mask(:,:,ones(1,size(miniGb,3))); 
 
        bck = miniGb(:,:,l_t0-Nfr:l_t0-1);
        abck = std(bck(:));
        evThr = abck*thresh;
%%%Filtering of movie, gaussian filter (default params)
        hgauss = fspecial('gaussian');
        miniGf = miniGb;
        for k=1:size(miniGf,3)
            miniGf(:,:,k) = imfilter(miniGb(:,:,k),hgauss);
        end
        segMiniG = miniGf>evThr; %segmented movie of tubule

        si = l_t0; %token for frames in segmented tubules
        %tub = 1; 1 if there is a tubule, 0 if a point like structure
%%%%Calculations for start frame 
        labMin = bwlabel(segMiniG(:,:,si),4); %4-connected objects
        prop = regionprops(labMin,'Area');
        if ~isempty(prop) %To clean up the segmented area
            for j = 1:size(prop,1)
                if prop(j).Area < pixThresh %default: 5
                    labMin(find(labMin==j))=0;
                end
            end
        end
        prop = regionprops(labMin,'all');
        if isempty(prop)
            tub = 0;
            val(3) = l_x0;
            val(4) = l_y0;
        else
            tub = 1;
            Ntub = size(prop,1);
            distub = zeros(1,Ntub);
            for j = 1:Ntub
                XY = prop(j).Centroid;
                distub(j) = sqrt((XY(1)-l_x0)^2+(XY(2)-l_y0)^2);
            end
            [dtub,itub] = min(distub);
            if dtub < 5 %tubule does not move more than 5 pixels
                mask(:,:,l_t0) = labMin==itub|mask(:,:,l_t0);
                %val(2) tubule persistence, in frames
                
                l_x0 = prop(itub).Centroid(1); %Need to put back right coordinates!!!
                val(3) = l_x0;
                l_y0 = prop(itub).Centroid(2);
                val(4) = l_y0;
                val(3) = prop(itub).Area;
                val(4) = prop(itub).Eccentricity;
                val(5) = prop(itub).MajorAxisLength;
                val(6) = prop(itub).Orientation;
            end
        end
        trXY = [l_x0 l_y0]; % tracking local coordinates
%%%Calculations for tracked frames
        si = si+1;        
        while tub && (si < size(miniG,3))
        labMin = bwlabel(segMiniG(:,:,si),4); %4-connected objects
        prop = regionprops(labMin,'Area');
        if ~isempty(prop) %To clean up the segmented area
            for j = 1:size(prop,1)
                if prop(j).Area < pixThresh %default: 5
                    labMin(find(labMin==j))=0;
                end
            end
        end
        prop = regionprops(labMin,'all');
        if isempty(prop)
            tub = 0;
        else
            tub = 1;
            Ntub = size(prop,1);
            distub = zeros(1,Ntub);
            for j = 1:Ntub
                XY = prop(j).Centroid;
                distub(j) = sqrt((XY(1)-trXY(end,1))^2+(XY(2)-trXY(end,2))^2);
            end
            [dtub,itub] = min(distub);
            if dtub < 5 %tubule does not move more than 5 pixels
                trXY = [trXY;prop(itub).Centroid(1) prop(itub).Centroid(2)];
                distance = sqrt((x-trXY(end,1)).^2 + (y-trXY(end,2)).^2);
                mask(:,:,si) = distance<rCircle;
                mask(:,:,si) = labMin==itub|mask(:,:,si);

                %Need to put back right (not local) coordinates!!!
                si=si+1;
            else
                tub = 0;
            end
        end
        end
        for k = si:size(miniGb,3)
            mask(:,:,k) = mask(:,:,si-1);
        end
        val(2) = si-l_t0; %tubule persistence, in frames
        values = sum(sum(miniGb.*mask)); %Total fluorescence; make average?
        val(before-l_t0+10:before-l_t0+9+size(mask,3)) = squeeze(values)';
        if stkR
            valR(2) = val(2);
            valuesR = sum(sum(miniRb.*mask));
            valR(before-l_t0+5:before-l_t0+4+size(mask,3)) = squeeze(valuesR)';
        end
    output = cat(1,output,val);
    if stkR
        outputR = cat(1,outputR,valR);
    end
    end
end

%%%Average+sem for green channel
averageEv = mean(output);
stdEv = std(output);
datathere = output~=0;
datathere = datathere(:,9:end);
stdPlot = stdEv(9:size(stdEv,2));
averagePlot = averageEv(9:size(averageEv,2));
semPlot = stdPlot./sqrt(sum(datathere,1));
frameNumb = -before:after;

grandAverage = zeros(5,size(output,2));
grandAverage(1,9:end) = frameNumb;
grandAverage(2,9:end) = averagePlot;
grandAverage(3,9:end) = semPlot;
grandAverage(4,9:end) = sum(datathere,1);

output = cat(1,grandAverage,output);

%%%Average+sem for red channel
if stkR
    averageR = mean(outputR);
    stdR = std(outputR);
    dataRthere = outputR~=0;
    dataRthere = dataRthere(:,4:end);
    stdPlotR = stdR(4:size(stdR,2));
    averagePlotR = averageR(4:size(averageR,2));
    semPlotR = stdPlotR./sqrt(sum(dataRthere,1));
    frameNumbR = -before:after;

    grandAverageR = zeros(5,size(outputR,2));
    grandAverageR(1,4:end) = frameNumbR;
    grandAverageR(2,4:end) = averagePlotR;
    grandAverageR(3,4:end) = semPlotR;
    grandAverageR(4,4:end) = sum(dataRthere,1);

    outputR = cat(1,grandAverageR,outputR);
end


%%%Figure for green channel
figure('name',stkG(1:end-4)) %%%changed?
errorbar(frameNumb,averagePlot,semPlot,'-og','markerfacecolor','g')
line([0 0],ylim)
xlabel('Frame #')
ylabel('average fluo')
title(['cell #  ',stkG(1:5),' ',stkG(7:9)])
pause(0.05)

%%%Figure for red channel 
if stkR
    figure('name',stkR(1:end-4)) %%%changed?
    errorbar(frameNumbR,averagePlotR,semPlotR,'-or','markerfacecolor','r')
    line([0 0],ylim)
    xlabel('Frame #')
    ylabel('average fluo')
    title(['cell #  ',stkR(1:5),' ',stkR(7:9)])
    pause(0.05)
end





%instructions to remove 0s and putting names in the excel file

output = num2cell(output);
hightCell = size(output,1);
widthCell = size(output,2);
output(5,:) = {''};
output(:,7:8) = {''};
output(1:4,1:7) = {''};
output(1:4,8) = {'frame';'average';'sem';'N'};
output(5,1:6) = {'event#','track','area','eccent','length','orient'};

parcell = cell(4,widthCell);
parcell{1,1} = ['Fluorescence quantification: total fluo with mask for ',stkG(1:end-4)];
parcell(1,4:12) = {'event file:',f,'',date,'','','','Cell','area �m�'};
parcell(1,13)=num2cell(aire);
parcell(2,13)=num2cell(Greenmoy);
parcell(2,1:12) = {'miniSize','fr_bef','fr_aft','fr_av','threshold','nPixels','rCircle','','','','','FluoAv'};
params = num2cell([miniSize,before,after,Nfr,thresh,pixThresh,rCircle]);
parcell(3,1:7) = params;
output = cat(1,parcell,output);

if stkR
    outputR = num2cell(outputR);
    hightCellR = size(outputR,1);
    widthCellR = size(outputR,2);
    outputR(5,:) = {''};
    outputR(:,3) = {''};
    outputR(1:4,1:2) = {''};
    outputR(1:4,3) = {'frame';'average';'sem';'N'};
    outputR(5,1:2) = {'event#','track'};

    parcellR = parcell(:,1:widthCellR);
    parcellR(1,13)=num2cell(aire);
    parcellR(2,13)=num2cell(Redmoy);
    outputR = cat(1,parcellR,outputR);
end

[fle,p] = uiputfile([f(1:5),'.xlsx'],...
      'Where to put the average fluorescence file');

if ischar(fle) && ischar(p)
   warning off MATLAB:xlswrite:AddSheet
   sheetG = [stkG(1:end-4),' Green'];
   xlswrite([p,fle],output,sheetG)
   if stkR
       sheetR = [stkR(1:end-4),' red'];
       xlswrite([p,fle],outputR,sheetR)
   end
end


%Third order polynomials for interpolation

function u = interPolx(x,y,c)
u = c(1) + c(2).*x + c(3).*x.^2 + c(4).*x.^3 +...
   c(5).*y + c(6).*y.^2 + c(7).*y.^3;

function v = interPoly(x,y,c)
v = c(8) + c(9).*x + c(10).*x.^2 + c(11).*x.^3 +...
   c(12).*y + c(13).*y.^2 + c(14).*y.^3;