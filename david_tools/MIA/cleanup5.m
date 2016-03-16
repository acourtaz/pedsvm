function cleanup5

%written by DP - last update 12/11/2013
%screens events generated by MIA according to various criteria (see code)
%and generates a .trc file with the events passing the screen
%generates also a summary excel file where all the parameters and results
%are written

%Added to cleanup5: looks for potential events corresponding to a fold
%increase of integrated intensity larger than fMIA (default 3)
%It can account for the incomplete quenching of TfR-pHuji 
%or TfR-SEP by trypan purple

%This function works with the two types of trc files: with or without 
%the '0' lines. It will write the '0' lines if they were present.

[f,p] = uigetfile('*.txt;*.trc','File with matrix of events (e.g. MIA.trc file');
if ~f,return,end
events = dlmread([p,f],'\t');
fk = strfind(f,'_');
cellNum = f(1:fk(1)-1); %the number of the cell analysed
[stk,stkd] = uigetfile('*.stk','Stack of events (TfR5)');
if ~stk,return,end
[stkMIA,stkdMIA] = ...
    uigetfile('*.stk','Stack of clusters (TfR7, MIA objects)');
if ~stkMIA
    warndlg('no screen for pre-existing cluster will be performed')
    clusters = [];
else
    clusters = stkread(stkMIA,stkdMIA);
end
movi = stkread(stk,stkd);
moviLength = size(movi,3);
output = zeros(size(events));

rCircle = 2; %Radius of the circle for fluorescence quantification, in pixels
rAnn = 5; %radius of the Annulus
Edge = 7; %Minimal distance from the edge of the image
sigNoise = 5; %Signal/Noise ratio estimated on TfR5 movie
slopeMax = 1; %Maximum slope for fluorescence increase
thClst = 0.2; %Threshold for pre-existing cluster (0<T<=1) taken on TfR7 MIA movie
minFrame = 5; % Minimal number of frames before the event
%It has to be bigger than 5 
%(the number of frames used to estimate local background)
maxFrame = 5; %Minimal number of frames after start of event
fMIA = 3; %Fold increase in the 'integrated intensity' (column 6 in the .trc file)
%Can detect potential events if quenching is not absolute (TfR-pHuji)
defaults = [rCircle,rAnn,Edge,sigNoise,slopeMax,thClst,minFrame,maxFrame,fMIA];
prompt = {'Circle radius','Annulus outer radius',...
    'Minimal distance from the edge of the image',...
    'Signal/Noise ratio',...
    'Maximum slope for fluorescence increase',...
    'Threshold for pre-existing cluster (0<T<=1)',...
    'Minimal number of frames before event (>5)',...
    'Minimal number of frames after start of event',...
    'Fold increase in intensity of MIA object'};
[rCircle,rAnn,Edge,sigNoise,slopeMax,thClst,minFrame,maxFrame,fMIA] = ...
numinputdlg(prompt,'Parameters for removing non qualified events',1,defaults);
pause(1)
params = [rCircle,rAnn,Edge,sigNoise,slopeMax,thClst,minFrame,maxFrame,fMIA];
[x,y] = meshgrid(1:2*rAnn+1);

if events(1,1) == 0 %obsolete, when trc files had 0 lines
    firstEvent = round(events(2,1));
else
    firstEvent = round(events(1,1));
end
lastEvent = round(events(end,1));

%Added to cleanup5: looks for potential events corresponding to a fold
%increase of integrated intensity larger than fMIA (default 3)
%It can account for the incomplete quenching of TfR-pHuji 
%or TfR-SEP by trypan purple

events(:,5) = events(:,1); %Keeps the original event numbers from MIA 
%in column 5 (areas, unused) before renaming the events with the added ones
ev1 = events(1:end-1,[1 6]);
ev2 = events(2:end,[1 6]);
ratio = (ev1(:,1)-ev2(:,1)+1).*(ev2(:,2)./ev1(:,2));

added = [];
nfLE = size(num2str(lastEvent),2); % number of figures of last event
%e.g. if lastEvent = 2543, it has 4 figures (254, 3 figures)
% a figure = un chiffre
nad = []; % numbers of added events
newStart = find(ratio > fMIA)';
for i = newStart %If newStart is empty, no error
    evNum = events(i+1,1);
    isEv = (events(:,1) == evNum);
    evLength = sum(isEv(i+1:end));
    if evLength >= 3
        new = events(i+1:i+evLength,:);
        new(:,5) = new(:,1); %Keeps the original event number from MIA
        oEv = num2str(evNum);
        aEv = 10^(1+nfLE-size(oEv,2));
        addEv = [num2str(aEv),oEv];
        oEv = addEv(3:end); %eg 0012 if evNum = 12 & lastEvent has 4 figures
        new(:,1) = str2double(addEv);
        if ~isempty(added)
            while max(added(:,1)==new(1,1))
                aEv = str2double(addEv(1:end-nfLE));
                aEv = aEv+10;
                addEv = [num2str(aEv),oEv];
                new(:,1) = str2double(addEv);
            end
        end
        nad = [nad,new(1,1)];
        added = [added;new];
    end
end
count2 = zeros(9,1); % To count the number of events added, then rejected with the screen
if ~isempty(newStart)
    events = cat(1,events,added);
    count2(1) = size(nad,2); % number of added events
end
%All  the events will go through the screen

k = 1; %token for the output matrix
r = 1; %token for the reject matrix
a = 1; %token for the accept matrix 

reject = zeros(lastEvent+size(nad,2),15);
accept = zeros(lastEvent+size(nad,2),9);
for i=[firstEvent:lastEvent nad]
    eventTrack = (events(:,1)==i);
    [u,start] = max(eventTrack);
    if u
        isAdd = (i > lastEvent); %0 if original event, 1 if added event
    if (events(start,2) > minFrame)
    if (events(start,2) < moviLength-maxFrame)
%Conditions: The object appears after minFrame frames
%and before moviLength - maxFrame
        indexEvent = find(eventTrack)';
        edge_xs = events(indexEvent,3) < Edge;
        edge_xl = events(indexEvent,3) > (size(movi,2)-Edge);
        edge_ys = events(indexEvent,4) < Edge;
        edge_yl = events(indexEvent,4) > (size(movi,1)-Edge);
        edge_xy = [edge_xs,edge_xl,edge_ys,edge_yl];
        if sum(sum(edge_xy))==0
%Condition: Trajectory of event is more than Edge pixels from the edge of the image
        if ~(events(1,1)==0)||((events(1,1)==0) && (events(start-1,3) == 0))
%Condition: if it is coded (0 lines), the object is not merge/split from
%parent objects
        frame = round(events(start,2));
        length = sum(eventTrack); %number of frames event is tracked (lifetime)
        if length >= 3
%A condition that is normally always fullfilled
%since MIA uses a minimum of 3 frames to define an event
%but in fact there can be events with less than 3 if they lead to or come from
%a merge/split
%Warning: these events will disappear from the excel summary file
%Calculates the slope

            xy1 = floor(events(start,3:4))+1;
            dxy1 = events(start,3:4)-xy1+1;
            xy3 = floor(events(start+2,3:4))+1;
            dxy3 = events(start+2,3:4)-xy3+1;
            distance1 = sqrt((x-rAnn-dxy1(1)-1).^2 +...
                (y-rAnn-dxy1(2)-1).^2);
            distance3 = sqrt((x-rAnn-dxy3(1)-1).^2 +...
                (y-rAnn-dxy3(2)-1).^2);
            circle1 = distance1<rCircle;
            annulus1 = (distance1>=rCircle)&(distance1<rAnn);
            circle3 = distance3<rCircle;
            annulus3 = (distance3>=rCircle)&(distance3<rAnn);
im1 = ...
  double(movi(xy1(2)-rAnn:xy1(2)+rAnn,xy1(1)-rAnn:xy1(1)+rAnn,frame));
im3 = ...
  double(movi(xy3(2)-rAnn:xy3(2)+rAnn,xy3(1)-rAnn:xy3(1)+rAnn,frame+2));
            av1 = sum(sum(im1.*circle1))/sum(sum(circle1)) -...
                sum(sum(im1.*annulus1))/sum(sum(annulus1));
            av3 = sum(sum(im3.*circle3))/sum(sum(circle3)) -...
                sum(sum(im3.*annulus3))/sum(sum(annulus3));
            slope = 0.5*(av3/av1-1);
%Calculates the background over 5 frames preceding the event
imbefore = ...
double(movi(xy1(2)-rAnn:xy1(2)+rAnn,xy1(1)-rAnn:xy1(1)+rAnn,frame-5:frame-1));
            circle0 = circle1(:,:,ones(1,5));
            annulus0 = annulus1(:,:,ones(1,5));
            avbefore = sum(sum(imbefore.*circle0))/sum(sum(circle1))-...
              sum(sum(imbefore.*annulus0))/sum(sum(annulus1));
            average = sum(avbefore)./5;
            stdev = sqrt(sum((average-avbefore).^2))./2;
            if stdev ~= 0
                SN = (av1-average)/stdev;
            else
                SN = 1000; %should be infinity
            end
%Calculates the fraction of pixels occupied by a pre-existing cluster in
%the circle for the 5 frames before
            if ~isempty(clusters)
                clstBefore = ...
clusters(xy1(2)-rAnn:xy1(2)+rAnn,xy1(1)-rAnn:xy1(1)+rAnn,frame-5:frame-1)>0;
                coClst = sum(circle0(:)&clstBefore(:))/sum(circle0(:));
            else
                coClst = 1;
            end
%Condition: the spot does not get brighter after appearance
%(as an approaching object would do)
            if slope < slopeMax
 %Condition: fluo of object above background
                if SN > sigNoise
                    if coClst > thClst
                        if events(1,1) == 0
                            start = start-1;
                            length = length+1;
                        end
                    output(k:k+length-1,:) = events(start:start+length-1,:);
                        k = k+length;
                        accept(a,1) = i;
                        accept(a,2:4) = events(start,2:4);
                        accept(a,5) = length;% +1 at line 145
                        accept(a,6) = slope;
                        accept(a,7) = SN;
                        accept(a,8) = coClst;
                        accept(a,9) = i; % adds the MIA trk number in col 9
                        a = a+1;
                        if isAdd
                            count2(9) = count2(9)+1;
                        end
                    else
   %rejection: pre existing cluster too small
                        reject(r,1:4) = events(start,1:4);
                        reject(r,5) = length;% +1 at line 145
                        reject(r,6) = slope;
                        reject(r,7) = SN;
                        reject(r,8) = coClst;
                        reject(r,14) = 1;
                        r = r+1;
                        if isAdd
                            count2(7) = count2(7)+1;
                        end
                    end
                else reject(r,1:4) = events(start,1:4); %rejection: S/N is too low
                    reject(r,5) = length;% +1 at line 145
                    reject(r,6) = slope;
                    reject(r,7) = SN;
                    reject(r,8) = coClst;
                    reject(r,13) = 1;
                    reject(r,14) = (coClst <= thClst);
                    r = r+1;
                    if isAdd
                        count2(6) = count2(6)+1;
                    end
                end
            else reject(r,1:4) = events(start,1:4); %rejection: slope is too high
                reject(r,5) = length;% +1 at line 145
                reject(r,6) = slope;
                reject(r,7) = SN;
                reject(r,8) = coClst;
                reject(r,12) = 1;
                reject(r,13) = (SN <= sigNoise);
                reject(r,14) = (coClst <= thClst);
                r = r+1;
                if isAdd
                    count2(5) = count2(5)+1;
                end
            end
            %some 'events' are rejected at this stage because they are too
            %short; doesn't count as a true rejection
        end
        else reject(r,1:4) = events(start,1:4); %rejection: event is a merge/split
            %reject(r,5) = length-1;% +1 at line 145
            reject(r,15) = 1;
            r = r+1;
            if isAdd
                count2(8) = count2(8)+1;
            end
        end
        else reject(r,1:4) = events(start,1:4); %rejection: event is close to an edge
            reject(r,11) = 1;
            r = r+1;
            if isAdd
                count2(4) = count2(4)+1;
            end
        end
    else reject(r,1:4) = events(start,1:4); %rejection: event is too late
        reject(r,10) = 1;
        r = r+1;
        if isAdd
            count2(3) = count2(3)+1;
        end
    end
    else reject(r,1:4) = events(start,1:4);
        reject(r,9) = 1; %rejection: event is too early
        r = r+1;
        if isAdd
            count2(2) = count2(2)+1;
        end
    end
    end
end

output = output(1:k-1,:); %to create the new trc file
reject = reject(1:r-1,:);
sumReject = sum(reject);
counts = [(r+a-2);sumReject(9:15)';(a-1)]-count2;
%Takes away the counts from the added events
rejectRank = 100.*reject(:,12)+10.*reject(:,13)+reject(:,14);
%rejectRank for statistics about cause of rejection (see Taylor 2011)
reject = [reject,rejectRank];
accept = accept(1:a-1,:);

%Takes away lines from old events belonging to added events, then sorts the
%renamed events
if ~isempty(newStart)
    for i = nad
        eventTrack = (output(:,1)==i);
        [u,sta] = max(eventTrack);
        if u
            la = sum(eventTrack); %length of added event
 %finds if there are events in upper part of the trc file which are still on
%the same parent event evNum. There should be only one in the upper part.
            evNum = round(i-10^(nfLE+1));
            v = 0;
            while evNum > 0 && ~v
                evTr = (output(1:sta-1,1)==evNum); 
                [v,stp] = max(evTr);
                evNum = round(evNum-10^(nfLE+1));
            end
            if v
                lp = sum(evTr); %length of 'parent' event to crop
                if lp > la + 2
                    output = output([1:stp+lp-la-1 stp+lp:end],:);
                else %if added event is less than 2 frames after parent, removed 
                    if sta+la < size(output,1)
                        output = output([1:sta-1 sta+la:end],:);
                    else
                        output = output(1:sta-1,:);
                    end
                    aTrack = (accept(:,1)==i);
                    [w,s] = max(aTrack);
                    newReject = [accept(s,:) zeros(1,7)];
                    reject = cat(1,reject,newReject);
                    if s < size(accept,1)
                        accept = accept([1:s-1 s+1:end],:);
                    else
                        accept = accept(1:s-1,:);
                    end
                    count2(9) = count2(9)-1; %removes one pass from the final count
                end
            end
        end
    end
    reject = sortrows(reject,[2 1]);
    accept = sortrows(accept,[2 1]);
    accept(:,1) = (1:size(accept,1))';
    %assigns the new event numbers and sorts the output matrix (trc file)
    for j = 1:size(accept,1)
        ev = accept(j,9);
        evT = (output(:,1)==ev);
        lEv = sum(evT);
        [u,st] = max(evT);
        if u
            output(st:st+lEv-1,1) = j;
        end
    end
    output = sortrows(output,[1 2]);
end




cellHigh = max(size(accept,1),size(reject,1))+15;
tableSum = cell(cellHigh,25); %the cell array that will contain the xls sheet
tableSum(1:3,1) = {'exp type:';'analysis:';'date:'};
tableSum(1:2,2) = {'ppH';'cleanup5'};
tableSum{3,2} = date;
tableSum(5:9,1) = {'rCircle';'rAnnulus';'Edge';'S/N';'(+)slope'};
tableSum(10:13,1) = {'cluster';'fr_bef';'fr_aft';'Fold MIA'};
tableSum(5:13,2) = num2cell(params');
tableSum(4,6:7) = {'start MIA','Added'};
tableSum(5:8,4) = {'total events:';'failed frbef:';'failed fraft:';'failed edges:'};
tableSum(9:12,4) = {'failed slope:';'failed S/N:';'failed cluster:';'failed merge:'};
tableSum{13,4} = 'passed:';
tableSum(5:13,6) = num2cell(counts);
tableSum(5:13,7) = num2cell(count2);
tableSum{13,8} = counts(9)+count2(9);
tableSum{14,1} = 'passed events';
tableSum{14,10} = 'failed events';
tableSum(15,1:9) = {'new id','fr','x','y','lifetime','slope','S/N','cluster','old id'};
%new id is new assigned event number, old id is the one given by MIA
tableSum(15,10:17) = {'trk id','fr','x','y','lifetime','slope','S/N','cluster'};
tableSum(15,18:25) = {'frbef','fraft','edges','(+)slope','S/N','cluster','merge','rRank'};
if ~isempty(accept)
    tableSum(16:15+size(accept,1),1:9) = num2cell(accept);
end
if ~isempty(reject)
    tableSum(16:15+size(reject,1),10:25) = num2cell(reject);
end

[fle,p] = uiputfile([cellNum,'_cln',num2str(minFrame),'.trc']...
      ,'Where to put the cleaned up event file');
  
if ischar(fle) && ischar(p)
   dlmwrite([p,fle],output,'\t')
end

pause(0.1)
[fexcel,p] = uiputfile([cellNum,' candidates(',num2str(minFrame),').xlsx'],...
    'Where to put the excel data file');

if ischar(fexcel)&&ischar(p)
    warning off MATLAB:xlswrite:AddSheet
    sheet = [cellNum,' summary'];
    xlswrite([p,fexcel],tableSum,sheet)
end

%making graphs of parameters with thresholds
iSN = find(reject(:,6));
if ~isempty(iSN) && ~isempty(accept)
    naccept = size(accept,1);
    slopeAccept = sort(accept(:,6));
    slopeGraph = sort(reject(iSN,6));
    SNAccept = sort(accept(:,7));
    SNGraph = sort(reject(iSN,7));
    clusterAccept = sort(accept(:,8));
    clusterGraph = sort(reject(iSN,8));
    totR = size(iSN,1);
    fractionR = 1/totR:1/totR:1;
    fractionA = 1/naccept:1/naccept:1;
    scr = get(0,'ScreenSize');
    hf = figure('name',[cellNum,'Thresholds cleanup'],...
        'position',[scr(3)/4 scr(4)/2 scr(3)/2 scr(4)/4]);
    
    subplot(1,3,1)
    plot(slopeGraph,fractionR,slopeAccept,fractionA,'r')
    line([slopeMax slopeMax],[0 1],'color','k')
    axis square
    axis([-1 1 0 1])
    title('slope')
    text(-2,1.1,[num2str(size(accept,1)),' candidates'])
    
    subplot(1,3,2)
    plot(SNGraph,fractionR,SNAccept,fractionA,'r')
    line([sigNoise sigNoise],[0 1],'color','k')
    axis square
    axis([0 20 0 1])
    title('S/N')
    
    subplot(1,3,3)
    plot(clusterGraph,fractionR,clusterAccept,fractionA,'r')
    line([thClst thClst],[0 1],'color','k')
    axis square
    axis([0 1 0 1])
    title('cluster fraction')
    
    %c = strfind(f,'_');
    %if isempty(c)
    %    c = 5;
    %else c = c(1)-1;
    
    [fth, pth] = uiputfile([cellNum,'_thresholds',num2str(minFrame),'.fig'],'save figure');
    if ischar(fth) && ischar(pth)
        saveas(hf,[pth,fth]);
    end 
end