function randomFT(nTrials)

%adapted from randomization by David Perrais, 13/05/2011
%creates a number of randomized traces for determining the significance
%of a recruitment profile
%inputs: TfR5.stk, TfR7.stk, pro5.stk, pro7.stk, events, coeff, mask
%parameters: bleed(through), pH first frame, time interval (same as
%deIntCorrect
%last parameter is nTrials, the number of trials for randomization
%output is an excel file of the nTrials randomized traces

[f,p] = uigetfile('*.txt;*.trc','File with matrix of events');
if ~f,return,end
events = dlmread([p,f],'\t');

pause(0.1)
[fmask,pmask] = uigetfile('*.txt','Mask of the cell surface');
if ~fmask
    warndlg('No mask has been selected for this randomized trial')
end
cellMask = dlmread([pmask,fmask]); %not to be confounded with event mask

pause(0.1)
[stkGre,stkdGre] = uigetfile('*.stk','TfR movie');
if ~stkGre,return,end
mGre = stkread(stkGre,stkdGre);
movieSize = size(mGre);
if isempty(mask)
    mask = ones(movieSize(1),movieSize(2));
end

pause(0.1)
[stkRed,stkdRed] = uigetfile('*.stk','Movie of red protein');
if ~stkRed,return,end
mRed5 = stkread(stkRed,stkdRed);
cellName = stkRed(1:end-4);
c = strfind(stkRed,'_');
if ~isempty(c)
    c = c(end)-1;
else
    c = 4;
end
cellN = stkRed(1:c);

pause(0.1)
[coFile,coDir] = uigetfile('*.txt',...
    'File with alignment coefficients for red channel');
if ~coFile
    coeff = [0 1 0 0 0 0 0 0 0 0 0 1 0 0]';
else
    coeff = dlmread([coDir,coFile],'\t');
end

%%% Parameters which can be changed through prompt
before = 10; %Number of frames measured before vesicle appearance
after = 30; %Number of frames measured after vesicle appearance
miniSize = 25; %Size of miniStack used for event measures (odd number)
Nfr = 5; %Number of frames to evaluate background fluorescence
thresh = 5; %Threshold (multiples of background SD) to segment image
pixThresh = 4; %Minimal number of pixels for detectable object
rCircle = 2.2; %radius (in pixels) of circle used to quantify fluo as minimum
lper = 0.2;
hper = 0.8;
rAn = 3; %Value for region dilatation; must be an integer
defaults = [before,after,miniSize,Nfr,thresh,pixThresh,rCircle,rAn,lper,hper];
prompt = {'Number of frames before start of event',...
    'Number of frames after start of event',...
    'Size of ministack to find object'...
    'Number of frames to evaluate background fluorescence',...
    'Threshold for image segmentation (multiple of background SD)',... 
    'Minimal number of pixels for an object',...
    'Circle radius for quantification',...
    'Mask expansion (in pixels) for background (must be an integer)',...
    'Lower limit L of the pixel values used for background  (0<= L < H <=1)',...
    'Higher limit H of the pixel values used for background (0<= L < H <=1)'};
[before,after,miniSize,Nfr,thresh,pixThresh,rCircle,rAn,lper,hper] = ...
numinputdlg(prompt,'Parameters for fluorescence measurements',1,defaults);  
pause(0.1)

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
%Makes the evMask (event mask, not to be confounded with cell mask like in
%fluoTubules2 
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
        
        t_minG = max(frame-before,1);
        t_maxG = min(frame+after,size(mG,3));

%%%Warning, x coordinate is second dimension!!!
        miniG = double(mG(y_minG:y_maxG,x_minG:x_maxG,t_minG:t_maxG));
        miniAv = double(mG(y_minG:y_maxG,x_minG:x_maxG,frame-Nfr:frame-1));
        miniAv = sum(miniAv,3)./Nfr;
        miniAv = miniAv(:,:,ones(1,size(miniG,3)));
        miniGb = miniG - miniAv;
        
        [x,y] = meshgrid(1:size(miniGb,2),1:size(miniGb,1));
        l_t0 = min(frame,before+1); %local frame start
        l_x0 = min(x0,ma+1)+dx0;
        l_y0 = min(y0,ma+1)+dy0;
%%%Fluo calculations before the event
        distance = sqrt((x-l_x0).^2 + (y-l_y0).^2);
        evMask = distance<rCircle;
        evMask = evMask(:,:,ones(1,size(miniGb,3))); 
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
                l_tub = labMin==itub;
                l_tub = l_tub(:,:,ones(1,l_t0));
                mask(:,:,1:l_t0) = l_tub|mask(:,:,1:l_t0);
%Mask is the same for all frames before event
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
        SE = strel('disk',rAn); %rAn must be an integer 
        amask = imdilate(mask,SE);
        amask = amask-mask;
        valmask = sum(sum(miniG.*mask))./sum(sum(mask));
        aminiG = miniG.*amask;
%Takes 20-80% middle pixels in 'annulus' region
        valamask = sum(sum(aminiG))./sum(sum(amask));
        back = zeros(size(valamask));
        Pix = size(miniG,1)*size(miniG,2);
        nPix = zeros(1,size(miniG,3));
        nLoPix = nPix; nHiPix = nPix;
        for np = 1:size(miniG,3)
            nPix(np) = round(sum(sum(amask(:,:,np))));
            nLoPix(np) = round(nPix(np)*lper);
            nHiPix(np) = round(nPix(np)*hper);
        end
        s_vam = sort(reshape(aminiG,Pix,size(miniG,3)));
        for q = 1:size(miniG,3)
back(q) = sum(s_vam(Pix-nPix(q)+nLoPix(q)+1:Pix-nPix(q)+nHiPix(q),q))/(nHiPix(q)-nLoPix(q));
        end
        values = valmask - back;
        val(2) = si-l_t0; %tubule persistence, in frames
        %values = sum(sum(miniGb.*mask)); %Old way (in fluoTubules) Total fluorescence; make average?
        val(before-l_t0+10:before-l_t0+9+size(mask,3)) = squeeze(values)';
        if stkR
            valR(2) = val(2);
            valmaskR = sum(sum(miniR.*mask))./sum(sum(mask));
            aminiR = miniR.*amask;
            valamaskR = sum(sum(miniR.*amask))./sum(sum(amask));
            backR = zeros(size(valamaskR));
            back = zeros(size(valamask));
            %Pix = size(miniG,1)*size(miniG,2);
            nPir = zeros(1,size(miniR,3));
            nLoPir = nPir; nHiPir = nPir;
            for np = 1:size(miniR,3)
                nPir(np) = round(sum(sum(amask(:,:,np))));
                nLoPir(np) = round(nPir(np)*lper);
                nHiPir(np) = round(nPir(np)*hper);
            end
            s_vamR = sort(reshape(aminiR,Pix,size(miniR,3)));
        for q = 1:size(miniR,3)
backR(q) = sum(s_vamR(Pix-nPir(q)+nLoPir(q)+1:Pix-nPir(q)+nHiPir(q),q))/(nHiPir(q)-nLoPir(q));
        end
        valuesR = valmaskR - backR;
            %valuesR = sum(sum(miniRb.*mask)); Old way (in fluoTubules)
            valR(before-l_t0+5:before-l_t0+4+size(mask,3)) = squeeze(valuesR)';
        end
    output = cat(1,output,val);
    if stkR
        outputR = cat(1,outputR,valR);
    end
    end  
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
disp('mask done')
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
disp(j)
end
disp('shifts done')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Second part: generates the randomized traces of Gre5, Gre7, and deint Red
%adapted from avFluo4random
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trialsGre5 = [];
trialsGre7 = [];
trialsRed = [];
%trialsRed7 = [];
param = [numberEvents,before,after,rCircle,rAnn,lowpercent,highpercent];
ncoeff = [0 1 0 0 0 0 0 0 0 0 0 1 0 0]';
pts = 2*(before+after);
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
    disp(j)
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
timeGre5 = -before*time_int:time_int:(after-1)*time_int;
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
params = num2cell([rCircle,rAnn,lowpercent,highpercent,before,after]);
headerEnv(3,1:6) = params;
headerEnv(4,1:3) = {'pH first frame','bleedthrough','time interval'};
headerEnv(5,1:3) = num2cell([first_pH,bleed,time_int]);
headerEnv{6,1} = 'Red channel';
headerEnv{6,6} = 'TfR_7';
headerEnv{6,11} = 'TfR_5';
cellEnv = [headerEnv;cellEnv];
sheets = {[cellN,' env'],[cellName,'_rnd'],[cellN,'_TfR7 rnd'],...
    [cellN,'_TfR5 rnd']};
[frnd,prnd] = uiputfile([f(1:4),'_rand(',num2str(nTrials),').xlsx']...
      ,'Where to put the randomized trials file');
if ischar(frnd)&&ischar(prnd)
    warning off MATLAB:xlswrite:AddSheet
    xlswrite([prnd,frnd],cellEnv,sheets{1})
    xlswrite([prnd,frnd],trialsRed,sheets{2})
    xlswrite([prnd,frnd],trialsGre7,sheets{3})
    xlswrite([prnd,frnd],trialsGre5,sheets{4})
end
    


%parameters: events, XYs, before, after, coeff, movi
%param = [numberEvents,before,after,rCircle,rAnn,lowpercent,highpercent]
function avFluoR = calcFluoR(movi,events,evNum,XYs,param,coeff,x,y)
numberEvents = param(1);
before = param(2);
after = param(3);
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
        val = zeros(1,after+before); %there was a +3 in avFluo
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
        while (start+j-1 < size(events,1)) && (j<trackLength) && (j < after)
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
        if (j<after) && (frame+j < size(movi,3))
            v = min([frame+after,size(movi,3)]);
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
            val(before+j+1:before+v) = squeeze(values)' - background;
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

