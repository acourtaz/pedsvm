function distSyn2

%Written by DP. Last update 8/04/2015 
%Calculates the distance between a event (clnR5) and the nearest synapse
% (Hom.MIA)
%Compares it to: 1. distribution of all pixels in the mask (as in distSyn)
%2. The median/average of ...

%if nargin == 0
[f,p,~] = uigetfile('*.txt;*.trc','File with matrix of events');
if ~f,return,end
events = dlmread([p,f],'\t');
[fm,pm,~] = uigetfile('*.txt;*.tif','Mask file');
if ~fm,return,end
if strfind(fm(end-4:end), 'txt')
    mask = dlmread([pm,fm],'\t');
elseif strfind(fm(end-4:end), 'tif')
    mask = imread([pm,fm]);
end
[fsyn,psyn] = uigetfile('*.tif','Image of synapse (filtered with MIA)');
if ~fsyn,return,end
syn = imread([psyn,fsyn]);

cSyn = 2; %Maximum distance for event "close" to a synapse, in pixels
nRnd = 1000; %Number of random trials to estimate enrichment
prompt = {'Distance for an event close to a synapse','Number of random trials'};
[cSyn,nRnd] = ...
    numinputdlg(prompt,'Parameters for event mapping',1,[cSyn,nRnd]);
pause(0.1)

syn2 = syn > 0;
synDist = bwdist(syn2); % distance map to synapses
synDist = synDist.*mask;

startEvents = [];

firstEvent = round(events(1,1));
lastEvent = round(events(end,1));
for i=firstEvent:lastEvent
    eventTrack = (events(:,1)==i);
    [u,start] = max(eventTrack);
    if u
        if events(1,1)==0
            startEvents = cat(1,startEvents,events(start+1,:));
        else
            startEvents = cat(1,startEvents,events(start,:));
        end
    end
end
nEv = size(startEvents,1); % Number of events
se = size(startEvents,2);

%%% Obsolete: pseudocoloured distance map

% mimage(synDist)
% colormap rainbow
% line(startEvents(:,3),startEvents(:,4),'lineStyle','none','marker','+',...
%     'markerEdgeColor','r')
% 
% [fpseudo,ppseudo] = uiputfile([f(1:end-4),'_Pseudo.fig'],'save figure');
% if ischar(fpseudo)&& ischar(ppseudo)
%     saveas(gcf,[ppseudo,fpseudo])
% end

%%% Second figure: distance distribution (mask against events)

% evCell = num2cell(startEvents(:,1));
% evCell = cat(2,evCell,cell(size(evCell)));
% valDist = [];
% for i=1:size(startEvents,1)
%     xi = round(startEvents(i,4));
%     yi = round(startEvents(i,3));
%     evInMask = mask(xi,yi);
%     if evInMask
%         evCell{i,2} = synDist(xi,yi);
%         valDist = [valDist;synDist(xi,yi)];
%     end
% end

evAll = cat(2,startEvents,zeros(nEv,1));
valDist = [];
for i=1:size(startEvents,1)
    xi = round(startEvents(i,4));
    yi = round(startEvents(i,3));
    if xi ~= 0 && yi ~= 0
    evAll(i,se+1) = synDist(xi,yi);
    valDist = [valDist;synDist(xi,yi)];
    end
end

evSort = sortrows(evAll,se+1);
isClose = evSort(:,se+1)<cSyn;
Nclose = sum(isClose);
if Nclose > 0 %Number of 'close' (less than cSyn pixels) events
    evClose = evSort(1:Nclose,:);
    evClose = sortrows(evClose,1);
else
    Nclose = [];
end

if Nclose < nEv
    evFar = evSort(Nclose+1:end,:);
    evFar = sortrows(evFar,1);
else
    evFar = [];
end

%%% First figure: gray mask, white synapses, red close events, green far
%%% events

h1 = mimage(mask+syn2);
set(gcf,'name',[f(1:5),' mapEvents'])
line(startEvents(:,3),startEvents(:,4),'lineStyle','none','marker','+',...
    'markerEdgeColor','r')
if ~isempty(evFar)
    line(evFar(:,3),evFar(:,4),'lineStyle','none','marker','+',...
        'markerEdgeColor','g')
end
[fmask,pmask] = uiputfile([f(1:end-4),'_distSyn.fig'],'save figure');
if ischar(fmask)&& ischar(pmask)
    saveas(h1,[pmask,fmask])
end

evmDist = mean(valDist);
valDist = sort(valDist);
Nval = size(valDist,1);
%Calculates the distribution of distances in cell mask
pixMask = sum(sum(mask));
sDistSyn = sort(synDist(:),'descend');
sDistSyn = sDistSyn(1:pixMask);
sDistSyn = sort(sDistSyn);
maskmDist = mean(sDistSyn);
%Calculates the distribution of distance in nRnd random trials

valRnd = zeros(nEv,nRnd);
for j=1:nRnd
    for i=1:nEv
        evInMask = 0;
        while ~evInMask
            xr = ceil(rand*size(mask,1));
            yr = ceil(rand*size(mask,2));
            evInMask = mask(xr,yr);
        end
        valRnd(i,j) = synDist(xr,yr);
    end
end
   
valRnd = sort(valRnd,1);
mimage(valRnd)
pRnd = prctile(valRnd,[5,50,95],2);
meanRnd = mean(valRnd,2);
Xval = 1/Nval:1/Nval:1;

if ~isempty(valDist)
    h2 = figure('name',[f(1:5),' synDist']);
    hold on
    plot(pRnd(:,1),Xval,'k')
    hl50 = plot(pRnd(:,2),Xval,'k');
    plot(pRnd(:,3),Xval,'k')
    line([cSyn cSyn],ylim)    
    hlav = plot(meanRnd,Xval,'b');
    hlmsk = plot(sDistSyn,1/pixMask:1/pixMask:1,'c');
    hlev = plot(valDist,Xval,'r','linewidth',2);
    legend([hl50,hlav,hlmsk,hlev],'95confid','average','mask','events')
    xlabel('distance from synapse')
    ylabel('fraction events')
    hold off
    cumulEv = cat(2,Xval',valDist,meanRnd,pRnd);
    cumulMask = cat(2,(1/pixMask:1/pixMask:1)',sDistSyn);
end

[fcumul,pcumul] = uiputfile([f(1:end-4),'_Cumul.fig'],'save figure');
if ischar(fcumul)&& ischar(pcumul)
    saveas(h2,[pcumul,fcumul])
end

[fd,pd] = uiputfile([f(1:end-4),'_dist.trc'],'Where to put the distance .trc data');
if ischar(fd) && ischar(pd)
    dlmwrite([pd,fd],evAll,'\t')
end

[fc,pc] = uiputfile([f(1:end-4),'_Close.trc'],'Where to put CLOSE events .trc data');
if ischar(fc) && ischar(pc)
    dlmwrite([pc,fc],evClose,'\t')
end

[ff,pf] = uiputfile([f(1:end-4),'_Far.trc'],'Where to put FAR events .trc data');
if ischar(ff) && ischar(pf)
    dlmwrite([pf,ff],evFar,'\t')
end

[fr,pr] = uiputfile([f(1:end-4),'_rnd.txt'],'Randomizations file');
if ischar(fr) && ischar(pr)
    dlmwrite([pr,fr],valRnd,'\t')
end


% XLS file

titCell = cell(6,8);
titCell{1,1} = date;
titCell{2,1} = 'Distance to nearest synapse';
titCell(3,1:4) = {'Thresh closeness',num2str(cSyn),'#trials random',num2str(nRnd)};
titCell(4,1:5) = {'events',f,'','mask',fm};
titCell(5,1:5) = {'average',num2str(evmDist),'','average',num2str(maskmDist)};
titCell(6,1:2) = {'event#','distance'};
titCell(6,4:5) = {'CloseEv#','distance'};
titCell(6,7:8) = {'FarEv#','distance'};
evCell = cell(size(evAll,1),8);
evCell(:,1:2) = num2cell(evAll(:,[1,se+1]));
if Nclose > 0
    evCell(1:Nclose,4:5) = num2cell(evClose(:,[1,se+1]));
end
if Nclose < nEv
    evCell(1:nEv-Nclose,7:8) = num2cell(evFar(:,[1,se+1]));
end
totCell = cat(1,titCell,evCell);

% maskCell = num2cell(sDistSyn);
% toAdd = cell(size(maskCell,1)-size(evCell,1),2);
% evCell = cat(1,evCell,toAdd);
% dataCell = cat(2,evCell,cell(size(maskCell,1),1),maskCell,cell(size(maskCell,1),1));


Header = cell(1,8);
Header(1,1:6) = {'Normalized','Events','Rnd Av','Rnd 05','Rnd 50','Rnd 95'};
Header(1,7:8) = {'NormMask','Mask'};
cumulData = cell(size(cumulMask,1),8);
cumulData(1:nEv,1:6) = num2cell(cumulEv);
cumulData(:,7:8) = num2cell(cumulMask);
cumulTot = cat(1,Header,cumulData);


[fx,px] = uiputfile([f(1:end-4),'_distSyn.xlsx'],'where to write distance data');
if ischar(fx) && ischar(px)
    warning off MATLAB:xlswrite:AddSheet
    xlswrite([px,fx],totCell,'synDistance')
    xlswrite([px,fx],cumulTot,'cumulData')
end


disp(['mean dist Mask: ',num2str(maskmDist)])
disp(['mean dist Ev: ',num2str(evmDist)])
disp(['nb ev: ',num2str(nEv)])
disp(['nb close: ',num2str(Nclose)])

%end