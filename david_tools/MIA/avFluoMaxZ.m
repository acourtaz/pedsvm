function avFluoMaxZ(varargin)

%Adapted from avFluo4. Makes fluo measures aligned to the maximum
%avFluoMaxZ: no quantification on images with no tracked object
%avFluoMax: quantification at same location after tracking has stopped
%With varargin, avFluo4(events,stack,xls_fname,evMax_fname,coeff), batch mode
%In batch mode, automatically saves data with default parameters 
%(see line 41)

if isempty(varargin)
    [f,p] = uigetfile('*.txt;*.trc','File with matrix of events');
    if ~f,return,end
    sTRC = ~isempty(strfind(f,'.trc')); %shift of 1 pixel between
    %trc coordinates and Matlab matrix coordinates
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
else
    stkd = [cd,'\'];
    coDir = stkd;
    f = varargin{1};
    stk = varargin{2};
    sTRC = ~isempty(strfind(f,'.trc'));
    events = dlmread(f,'\t');
    movi = stkread(stk,stkd);
    xls_fname = varargin{3};
    evMax_fname = varargin{4};
    if isempty(varargin{5})
        coFile = 0;
        coeff = [0 1 0 0 0 0 0 0 0 0 0 1 0 0]';
    else
        coFile = varargin{5};
        coeff = dlmread([coDir,coFile],'\t');
    end
end
c = strfind(f,'_');
if isempty(c)
    c = 6;
else c = c(1)-1;
end

%Default parameters (to change here if in batch mode)
%xls_fname = [f(1:c),'.xlsx']; %The xls file name to save the data in batch mode

rCircle = 2;
rAnn = 5;
lowpercent = 0.2; %lower percentile of the pixel values used for background
highpercent = 0.8;
before = 20; %number of frames measured before maximum%
after = 20; %number of frames measured after maximum%
length = before + after + 1;
%End of default parameters

if isempty(varargin)
    defaults = [rCircle,rAnn,lowpercent,highpercent,before,after];
    prompt = {'Circle radius','Annulus outer radius',...
    'Lower limit L of the pixel values used for background  (0<= L < H <=1)',...
    'Higher limit H of the pixel values used for background (0<= L < H <=1)',...
    'Number of frames before start of event',...
    'Number of frames after start of event'};
    [rCircle,rAnn,lowpercent,highpercent,before,after] = ...
    numinputdlg(prompt,'Parameters for fluorescence measurements',1,defaults);  
    pause(1)
end


miniSize = 2*rAnn+1;
miniPix = miniSize^2;
[x,y] = meshgrid(1:miniSize);
output = [];
evMax = [];


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
%Verifies that the object trajectory is in the image for red quantification        
        Edge = rAnn+1;
        indexEvent = find(eventTrack)';
        edge_xs = interPolx(events(indexEvent,3),events(indexEvent,4),coeff) < Edge;
        edge_xl = interPolx(events(indexEvent,3),events(indexEvent,4),coeff) > (size(movi,2)-Edge);
        edge_ys = interPoly(events(indexEvent,3),events(indexEvent,4),coeff) < Edge;
        edge_yl = interPoly(events(indexEvent,3),events(indexEvent,4),coeff) > (size(movi,1)-Edge);
        edge_xy = [edge_xs,edge_xl,edge_ys,edge_yl];
    if sum(sum(edge_xy))==0
        frame = round(events(start,2));
        val = zeros(1,length+3);
        val(1) = events(start,1);

        j=0; 
%calculates avFluo for the event after the first frame - tracked %
        trackLength = sum(eventTrack);
        valTr = zeros(1,trackLength);
        while (start+j-1 < size(events,1)) && (j<trackLength) && (j < length)
            x0 = interPolx(events(start+j,3),events(start+j,4),coeff);
            ix0 = floor(x0)+sTRC;
            dx0 = x0-ix0+sTRC;
            y0 = interPoly(events(start+j,3),events(start+j,4),coeff);
            iy0 = floor(y0)+sTRC;
            dy0 = y0-iy0+sTRC;
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
            j=j+1;
            valTr(j) = ...
                sum(sum(im.*circle))/sum(sum(circle)) - background;

        end
%finds the maximum fluorescence in the tracked frames
        valTr = valTr(1:j);
        val(2) = j;
        [valMax,frMax] = max(valTr);
        evMax = cat(1,evMax,events(start+frMax-1,:));
        if frMax+after <= j
            val(before+5:length+3) = valTr(frMax+1:frMax+after);
        else
            val(before+5:j-frMax+before+4) = valTr(frMax+1:j);
        end
        
        if frMax > before
            val(4:before+4) = valTr(frMax-before:frMax);
        else
            val(before-frMax+5:before+4) = valTr(1:frMax);
        end
        
        output = cat(1,output,val);
        %a = [events(start,1) j];
        %a %just to have a marker while the program is running
    end
    end
end

averageEv = mean(output);
stdEv = std(output);
datathere = output~=0;
datathere = datathere(:,4:end);
stdPlot = stdEv(4:size(stdEv,2));
averagePlot = averageEv(4:size(averageEv,2));
semPlot = stdPlot./sqrt(sum(datathere,1));
frameNumb = -before:after;

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
title(['cell #  ',stk(1:c),' ',stk(end-7:end-4)])
pause(0.05)

%%% Mo's modif

pname = findstr(stk,'.');
if isempty(pname)
    pname = ' ';
else pname = stk(pname(end)-4:pname(end)-1);
end

if isempty(varargin)
[fquant,pquant] = uiputfile([f(1:c),'_',pname],'Save quantification');
saveas(gcf,[pquant,fquant])
else
    hgsave(gcf,[stkd,f(1:c),'_',pname])
end


%%%

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
params = num2cell([rCircle,rAnn,lowpercent,highpercent,before,after]);
parcell(3,1:6) = params;
output = cat(1,parcell,output);

if isempty(varargin)
    [fle,p] = uiputfile([f(1:c),'_max.xlsx'], ...
    'Where to put the average fluorescence file');
    if ischar(fle) && ischar(p)
        warning off MATLAB:xlswrite:AddSheet
        sheet = [stk(1:end-4),' fluo'];
        xlswrite([p,fle],output,sheet)
    end
    pause(0.1)
    [fev,p] = uiputfile([f(1:c),'_max.trc'], ...
    'Where to put the events max file');
    if ischar(fev) && ischar(p)
        dlmwrite([p,fev],evMax,'\t')
    end
else
    warning off MATLAB:xlswrite:AddSheet
    sheet = [stk(1:end-4),' fluo'];
    xlswrite([stkd,xls_fname],output,sheet)
    dlmwrite([stkd,evMax_fname],evMax,'\t')
end

%Third order polynomials for interpolation

function u = interPolx(x,y,c)
u = c(1) + c(2).*x + c(3).*x.^2 + c(4).*x.^3 +...
   c(5).*y + c(6).*y.^2 + c(7).*y.^3;

function v = interPoly(x,y,c)
v = c(8) + c(9).*x + c(10).*x.^2 + c(11).*x.^3 +...
   c(12).*y + c(13).*y.^2 + c(14).*y.^3;
