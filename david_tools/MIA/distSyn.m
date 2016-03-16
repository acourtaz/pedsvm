function distSyn(action)

%Written by DP. Last update 7/04/2015 
%Calculates the distance between a event (clnR5) and the nearest synapse
% (Hom.MIA)

%if nargin == 0
[f,p,fi] = uigetfile('*.txt;*.trc','File with matrix of events');
if ~f,return,end
events = dlmread([p,f],'\t');
[fm,pm,fim] = uigetfile('*.txt;*.tif','Mask file');
if ~fm,return,end
if strfind(fm(end-4:end), 'txt')
    mask = dlmread([pm,fm],'\t');
elseif strfind(fm(end-4:end), 'tif')
    mask = imread([pm,fm]);
end
[fsyn,psyn] = uigetfile('*.tif','Image of synapse (filtered with MIA)');
if ~fsyn,return,end
syn = imread([psyn,fsyn]);

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

%%% First figure: pseudocoloured distance map

% mimage(synDist)
% colormap rainbow
% line(startEvents(:,3),startEvents(:,4),'lineStyle','none','marker','+',...
%     'markerEdgeColor','r')
% 
% [fpseudo,ppseudo] = uiputfile([f(1:end-4),'_Pseudo.fig'],'save figure');
% if ischar(fpseudo)&& ischar(ppseudo)
%     saveas(gcf,[ppseudo,fpseudo])
% end

%%% Second figure: gray mask, white synapses, red events

mimage(mask+syn2)
line(startEvents(:,3),startEvents(:,4),'lineStyle','none','marker','+',...
    'markerEdgeColor','r')

[fmask,pmask] = uiputfile([fpseudo(1:end-11),'_distSyn.fig'],'save figure');
if ischar(fmask)&& ischar(pmask)
    saveas(gcf,[pmask,fmask])
end

%%% Third figure: distance distribution (mask against events)

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

evCell = startEvents(:,1);
evCell = cat(2,evCell,zeros(size(evCell)));
valDist = [];
for i=1:size(startEvents,1)
    xi = round(startEvents(i,4));
    yi = round(startEvents(i,3));
    if xi ~= 0 && yi ~= 0
    %evCell{i,2} = synDist(xi,yi);
    evCell(i,2) = synDist(xi,yi);
    valDist = [valDist;synDist(xi,yi)];
    end
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


if ~isempty(valDist)
    figure('name',[f(1:5),' synDist'])
    plot(valDist,1/Nval:1/Nval:1,sDistSyn,1/pixMask:1/pixMask:1)
    xlabel('distance from synapse')
    ylabel('fraction events')
    cumulEv = cat(2,valDist,(1/Nval:1/Nval:1)');
    cumulMask = cat(2,sDistSyn,(1/pixMask:1/pixMask:1)');
end

[fcumul,pcumul] = uiputfile([fpseudo(1:end-11),'_Cumul.fig'],'save figure');
if ischar(fcumul)&& ischar(pcumul)
    saveas(gcf,[pcumul,fcumul])
end

[fd,pd] = uiputfile([f(1:end-4),'_distData.trc'],'Where to put the distance .trc data');
if ischar(fd) && ischar(pd)
    dlmwrite([pd,fd],evCell,'\t')
end


% Xls file
evCell = num2cell(evCell);
titCell = cell(6,5);
titCell{1,1} = date;
titCell{3,1} = 'Distance to nearest synapse';
titCell(4,:) = {'events',f,'','mask',fm};
titCell(5,:) = {'average',num2str(evmDist),'','average',num2str(maskmDist)};
titCell(6,:) = {'event#','distance','','distance',''};
maskCell = num2cell(sDistSyn);
toAdd = cell(size(maskCell,1)-size(evCell,1),2);
evCell = cat(1,evCell,toAdd);
dataCell = cat(2,evCell,cell(size(maskCell,1),1),maskCell,cell(size(maskCell,1),1));
totCell = cat(1,titCell,dataCell);

Header = cell(1,4);
Header{1,1} = 'Cumul Ev';
Header{1,3} = 'Cumul Mask';
toAdd2 = cell(size(cumulMask,1)-size(cumulEv,1),2);
cumulEv = num2cell(cumulEv);
cumulEv = cat(1,cumulEv,toAdd2);
cumulMask = num2cell(cumulMask);
cumulData = cat(2,cumulEv,cumulMask);
cumulTot = cat(1,Header,cumulData);


[fx,px] = uiputfile([fpseudo(1:end-11),'_distSyn.xlsx'],'where to write distance data');
if ischar(fx) && ischar(px)
    warning off MATLAB:xlswrite:AddSheet
    xlswrite([px,fx],totCell,'synDistance')
    xlswrite([px,fx],cumulTot,'cumulData')
end


disp(['mean dist Mask: ',num2str(maskmDist)])
disp(['mean dist Ev: ',num2str(evmDist)])
disp(['nb ev: ',num2str(size(evCell,1))])

%end