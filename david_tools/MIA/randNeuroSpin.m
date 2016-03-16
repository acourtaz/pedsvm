function randNeuroSpin(nTrials)

%written by David Perrais, 31/03/10
%adapted from randomization.m for 2color movies of neurons (spinning)
%creates a number of randomized traces for determining the significance
%of a recruitment profile
%inputs: TfR.stk, Red.stk, events, coeff, mask
%No bleed-through correction
%last parameter is nTrials, the number of trials for randomization
%output is an excel file of the nTrials randomized traces

[f,p] = uigetfile('*.txt;*.trc','File with matrix of events');
if ~f,return,end
events = dlmread([p,f],'\t');

[fmask,pmask] = uigetfile('*.txt','Mask of the cell surface');
if ~fmask
    warndlg('No mask has been selected for this randomized trial')
end
mask = dlmread([pmask,fmask]);

[stkGre5,stkdGre5] = uigetfile('*.stk','Stack of TfR at pH 5');
if ~stkGre5,return,end
mGre5 = stkread(stkGre5,stkdGre5);
movieSize = size(mGre5);
if isempty(mask)
    mask = ones(movieSize(1),movieSize(2));
end

[stkGre7,stkdGre7] = uigetfile('*.stk','Stack of TfR at pH 7');
if ~stkGre7,return,end
mGre7 = stkread(stkGre7,stkdGre7);

[stkRed5,stkdRed5] = uigetfile('*.stk','Stack of red protein at pH 5');
if ~stkRed5,return,end
mRed5 = stkread(stkRed5,stkdRed5);
cellName = stkRed5(1:end-4);
cellN = stkRed5(1:4);

[stkRed7,stkdRed7] = uigetfile('*.stk','Stack of red protein at pH 7');
if ~stkRed7,return,end
mRed7 = stkread(stkRed7,stkdRed7);

[coFile,coDir] = uigetfile('*.txt',...
    'File with alignment coefficients for red channel');
if ~coFile,return,end
coeff = dlmread([coDir,coFile],'\t');

rCircle = 3;
rAnn = 6;
lowpercent = 0.2; %lower percentile of the pixel values used for background
highpercent = 0.8;
before = 10; %number of frames measured before vesicle appearance%
length = 10; %maximum length of tracked vesicle%
defaults = [rCircle,rAnn,lowpercent,highpercent,before,length];
prompt = {'Circle radius','Annulus outer radius',...
    'Lower limit L of the pixel values used for background  (0<= L < H <=1)',...
    'Higher limit H of the pixel values used for background (0<= L < H <=1)',...
    'Number of frames before start of event',...
    'Number of frames after start of event'};
[rCircle,rAnn,lowpercent,highpercent,before,length] = ...
numinputdlg(prompt,'Parameters for the fluorescence measurements',1,defaults);  
pause(1)

miniSize = 2*rAnn+1;
miniPix = miniSize^2;
[x,y] = meshgrid(1:miniSize);

first_pH = 7;
bleed = 0.032; % normally around 0.032
time_int = 4;

defaults = {first_pH,bleed,time_int};
prompt = {'pH of the first frame (7 or 5)',...
    'bleed-through coefficient (should be the one used for actual data)',...
    'time interval between pH5 frames (s)'};
    %'Name of protein (e.g. dyn)'};
[first_pH,bleed,time_int] = ...
    numinputdlg(prompt,'Parameters for deinterlacing the traces',1,defaults);

%checks if pH value is correct
if ~(first_pH==5 || first_pH==7)
    error('Enter a value of 5 or 7 for pH of first frame')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%First part: generating shifted event coordinates (from generateRandXYfluo)
%adapted from generateRandXYfluo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
edge = rAnn+5; %minimum distance from edge
distMin = 10; %minimal distance from actual measurement point
distMax = 40; %maximal distance from actual measurement point

%generates the event number column of the output
evNum = [];
firstEvent = round(events(2,1));
lastEvent = round(events(end,1));
for i=firstEvent:lastEvent
    eventTrack = (events(:,1)==i);
    [u,start] = max(eventTrack);
    if u
        evNum = [evNum;i];
    end
end

numberEvents = size(evNum,1);
XYshift = zeros(numberEvents,2,nTrials);
Xmax = ceil(max(events(:,3)));
Ymax = ceil(max(events(:,4)));
se = strel('disk',edge); 
erMask = imerode(mask,se); %the shifted events will not be too close to edge
%erMask = mask; %No erosion for neurons
a = 'mask done'
%generate the matrix of event shifts
for j = 1:nTrials
for i = 1:numberEvents
    eventTrack = (events(:,1)==evNum(i));
    [u,st] = max(eventTrack);
    if u
        lenEv = sum(eventTrack)-1;
        bibi = 1; %condition to stay in the while loop
        nTimesLoop = 0; %to count the number of choices for a shift >1 if
        %rejection due to outside of bonds
        while bibi
            theta = 2*pi*rand;
            r = distMin + distMax*rand;
            Xs = r*cos(theta);
            Ys = r*sin(theta);
        
            maxShiftX = max(events(st:st+lenEv,3));
            maxShiftY = max(events(st:st+lenEv,4));
            minShiftX = min(events(st:st+lenEv,3));
            minShiftY = min(events(st:st+lenEv,4));
            nTimesLoop = nTimesLoop +1;
if (maxShiftX+Xs<Xmax)&&(maxShiftY+Ys<Ymax)&&(minShiftX+Xs>edge)&&(minShiftY+Ys>edge)
    shiftX = round(events(st:st+lenEv,3)+Xs);
    shiftY = round(events(st:st+lenEv,4)+Ys);
    shiftraj = sparse(shiftY,shiftX,ones(lenEv+1,1),size(mask,1),size(mask,2));
    trajInMask = full(sum(sum(shiftraj.*erMask)));
    if (trajInMask >= lenEv+1)
        bibi = 0;
    end
end
if nTimesLoop > 10
    bibi = 0;
    Xs = 0;
    Ys = 0;
end
        end
    end
        XYshift(i,1,j) = Xs;
        XYshift(i,2,j) = Ys;
        %XYshift(i,3) = trialXY;
        %XYshift(i,4) = events(st,3) + Xs; %from generateRandXYfluo
        %XYshift(i,5) = events(st,4) + Ys;
end
j
end
a = 'shifts done'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Second part: generates the randomized traces of Gre5, Gre7, and deint Red
%adapted from avFluo4random
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trialsGre5 = [];
trialsGre7 = [];
trialsRed = [];
%trialsRed7 = [];
param = [numberEvents,before,length,rCircle,rAnn,lowpercent,highpercent];
ncoeff = [0 1 0 0 0 0 0 0 0 0 0 1 0 0]';
pts = 2*(before+length);
for j = 1:nTrials
    randGre5 = calcFluoR(mGre5,events,evNum,XYshift(:,:,j),param,ncoeff,x,y);
    trialsGre5 = cat(1,trialsGre5,randGre5);
    randGre7 = calcFluoR(mGre7,events,evNum,XYshift(:,:,j),param,ncoeff,x,y);
    trialsGre7 = cat(1,trialsGre7,randGre7);
    randRed5 = calcFluoR(mRed5,events,evNum,XYshift(:,:,j),param,coeff,x,y);
    randRed7 = calcFluoR(mRed7,events,evNum,XYshift(:,:,j),param,coeff,x,y);
    %pts = 2*size(randGre5,2);
    if first_pH == 5
        randRed(1:2:pts) = randRed5 - bleed.*randGre5;
        randRed(2:2:pts) = randRed7 - bleed.*randGre7;
    elseif first_pH == 7
        randRed(1:2:pts) = randRed7 - bleed.*randGre7;
        randRed(2:2:pts) = randRed5 - bleed.*randGre5;
    end
    trialsRed = cat(1,trialsRed,randRed); 
    j
end
%determines the median, high95% and low95% for the randomized trials
med = round(nTrials/2);
hi95 = round(nTrials/20)+1;
lo95 = nTrials - hi95 + 1;
sortRed = sort(trialsRed)';
envRed = cat(2,sortRed(:,hi95),sortRed(:,med),sortRed(:,lo95));
sortGre5 = sort(trialsGre5)';
envGre5 = cat(2,sortGre5(:,hi95),sortGre5(:,med),sortGre5(:,lo95));
sortGre7 = sort(trialsGre7)';
envGre7 = cat(2,sortGre7(:,hi95),sortGre7(:,med),sortGre7(:,lo95));
timeGre5 = -before*time_int:time_int:(length-1)*time_int;
if first_pH == 5
    timeGre7 = timeGre5+time_int/2;
    timeRed(1:2:pts) = timeGre5;
    timeRed(2:2:pts) = timeGre7;
elseif first_pH == 7
    timeGre7 = timeGre5-time_int/2;
    timeRed(1:2:pts) = timeGre7;
    timeRed(2:2:pts) = timeGre5;
end
figure('name',[cellName,' rnd(',num2str(nTrials),')'])
plot(timeRed',envRed(:,1),timeRed',envRed(:,2),timeRed',envRed(:,3))
figure('name',[cellN,'_TfR5 rnd(',num2str(nTrials),')'])
plot(timeGre5',envGre5(:,1),timeGre5',envGre5(:,2),timeGre5',envGre5(:,3))
figure('name',[cellN,'_TfR7 rnd(',num2str(nTrials),')'])
plot(timeGre7',envGre7(:,1),timeGre7',envGre7(:,2),timeGre7',envGre7(:,3))

titCol = {'time(s)','low 95%','median','high 95%'};
titCol = cat(2,titCol,{''},titCol,{''},titCol);
cellEnv = cell(pts,14);
cellEnv(:,1) = num2cell(timeRed');
cellEnv(:,2:4) = num2cell(envRed);
cellEnv(1:pts/2,6) = num2cell(timeGre7');
cellEnv(1:pts/2,7:9) = num2cell(envGre7);
cellEnv(1:pts/2,11) = num2cell(timeGre5');
cellEnv(1:pts/2,12:14) = num2cell(envGre5);
cellEnv = [titCol;cellEnv];
headerEnv = cell(6,14);
headerEnv{1,1} = 'Randomized data';
headerEnv{1,3} = '# Trials:';
headerEnv{1,4} = nTrials;
headerEnv(1,5:8) = {'event file:',f,'',date};
headerEnv(2,1:6) = {'rCircle','rAnnulus','low_perc','high_perc','fr_bef','fr_aft'};
params = num2cell([rCircle,rAnn,lowpercent,highpercent,before,length]);
headerEnv(3,1:6) = params;
headerEnv(4,1:3) = {'pH first frame','bleedthrough','time interval'};
headerEnv(5,1:3) = num2cell([first_pH,bleed,time_int]);
headerEnv{6,1} = 'Red channel';
headerEnv{6,6} = 'TfR_7';
headerEnv{6,11} = 'TfR_5';
cellEnv = [headerEnv;cellEnv];
sheets = {[cellN,' env'],[cellName,'_rnd'],[cellN,'_TfR7 rnd'],...
    [cellN,'_TfR5 rnd']};
[frnd,prnd] = uiputfile([f(1:4),'_rand(',num2str(nTrials),').xls']...
      ,'Where to put the randomized trials file');
if ischar(frnd)&&ischar(prnd)
    warning off MATLAB:xlswrite:AddSheet
    xlswrite([prnd,frnd],cellEnv,sheets{1})
    xlswrite([prnd,frnd],trialsRed,sheets{2})
    xlswrite([prnd,frnd],trialsGre7,sheets{3})
    xlswrite([prnd,frnd],trialsGre5,sheets{4})
end
    


%parameters: events, XYs, before, length, coeff, movi
%param = [numberEvents,before,length,rCircle,rAnn,lowpercent,highpercent]
function avFluoR = calcFluoR(movi,events,evNum,XYs,param,coeff,x,y)
numberEvents = param(1);
before = param(2);
length = param(3);
rCircle = param(4);
rAnn = param(5);
lowpercent = param(6);
highpercent = param(7);
miniPix = size(x,1)^2;
output = [];
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
        k = find(evNum==i); %specific for avFluo4random
        k = k(1);
        if ~(XYs(k,1)==0 && XYs(k,2)==0) %Will ignore the events were no shift 
        %%% could be found, like in little cell corners
        %%%
        frame = round(events(start,2));
        val = zeros(1,length+before); %there was a +3 in avFluo
        %val(1) = events(start,1); from avFluo
%calculates avFluo before the event ; centered on first frame of event%
        minu = min([frame-1,before]);
        x0 = interPolx(events(start,3)+XYs(k,1),events(start,4)+XYs(k,2),coeff);
        ix0 = floor(x0)+1;
        dx0 = x0-ix0+1;
        y0 = interPoly(events(start,3)+XYs(k,1),events(start,4)+XYs(k,2),coeff);
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
        val([before+1-minu:before+1]) = squeeze(values)' - background;
        j=1; 
%calculates avFluo for the event after the first frame - tracked %
        trackLength = sum(eventTrack);
        while (start+j-1 < size(events,1)) && (j<trackLength) && (j < length)
            x0 = interPolx(events(start+j,3)+XYs(k,1),events(start+j,4)+XYs(k,2),coeff);
            ix0 = floor(x0)+1;
            dx0 = x0-ix0+1;
            y0 = interPoly(events(start+j,3)+XYs(k,1),events(start+j,4)+XYs(k,2),coeff);
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
            val(before+1+j) = ...
                sum(sum(im.*circle))/sum(sum(circle)) - background;
            j=j+1;
        end
%calculates avFluo after the object has stopped being tracked -
%the center stays where the object was in the last frame
        if (j<length) && (frame+j < size(movi,3))
            v = min([frame+length,size(movi,3)]);
            v = v - frame; %The maximal length of measures
            x0 = interPolx(events(start+j-1,3)+XYs(k,1),events(start+j-1,4)+XYs(k,2),coeff);
            ix0 = floor(x0)+1;
            dx0 = x0-ix0+1;
            y0 = interPoly(events(start+j-1,3)+XYs(k,1),events(start+j-1,4)+XYs(k,2),coeff);
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
            val([before+j+1:before+v]) = squeeze(values)' - background;
        end 
        else
            val = []; %event is ignored because no XY shift could be found
        end
        %val(2)=j; from avFluo
        output = cat(1,output,val);
        %a = [events(start,1) j];
        %a %just to have a marker while the program is running
    end
end

avFluoR = mean(output);
%%%End of calcFluoR

%Third order polynomials for interpolation

function u = interPolx(x,y,c)
u = c(1) + c(2).*x + c(3).*x.^2 + c(4).*x.^3 +...
   c(5).*y + c(6).*y.^2 + c(7).*y.^3;

function v = interPoly(x,y,c)
v = c(8) + c(9).*x + c(10).*x.^2 + c(11).*x.^3 +...
   c(12).*y + c(13).*y.^2 + c(14).*y.^3;

