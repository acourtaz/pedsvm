function CCSstats

% written by Mo 12/07/2013
% Gives * CCS number
%       * CCS starting frame
%       * CCS lifetimes in frames
%       * nb of events per CCS
%       * nb of frames between initiation of CCS & 1st event
%       * nb of frames between last event and disappearence of CCS
%       * nb of frames bewtween events of a given CCS


[fev,pev] = uigetfile('*.txt;*.trc','File with matrix of events');
    if ~fev,return,end
    events = dlmread([pev,fev],'\t');
    [fCCS,pCCS] = uigetfile('*.txt;*.trc','File with tracked CCS (MIA)');
    if ~fCCS,return,end
    CCS = dlmread([pCCS,fCCS],'\t');
    
c = strfind(fev,'_');
if isempty(c)
    c = 5;
else c = c(1)-1;
end
cellNum = num2str(fev(1:c));
    
events = ev2CCS(events,CCS); % see function ev2CCS.m

%  adapted from startEvents.m

CCSstart = [];

firstEvent = round(CCS(1,1));
lastEvent = round(CCS(end,1));
for i=firstEvent:lastEvent
    eventTrack = (CCS(:,1)==i);
    [u,start] = max(eventTrack);
    if u
        CCSstart = cat(1,CCSstart,CCS(start,:));
    end
end

 
% CCSo = CCS statistics output matrix to build

CCSo = CCSstart(:,1:2); 
nbCCS = size(CCSo,1);
I_start = zeros(nbCCS,1);
I_end = zeros(nbCCS,1);
I=[];
LT_all = [];  % LifeTimes of all CCSs
LT_isEv = []; % Lifetimes of CCSs with one or more events
LT_noEv = []; % Lifetimes of CCSs without any events

for i=1:nbCCS
    LT_all(i,1) = sum(CCS(:,1) == CCSo(i,1)); % LifeTime of all CCSs
    isEv = events(:,5) == CCSo(i,1)  ;
    evPerCCS(i,1) = sum(isEv);
    if sum(isEv)
        isEv_ind = find(isEv); % indexes of events appearing at CCS i
        I_start(i,1) = events(isEv_ind(1),2) - CCSstart(i,2);
        I_end(i,1) = (CCSstart(i,2)+LT_all(i,1)-1) - events(isEv_ind(end),2);
        if I_start(i,1) == 0
            I_start(i,1) = -1000;
        end
        if I_end(i,1) == 0
            I_end(i,1) = -1000;
        end
        LT_isEv = cat(1,LT_isEv,LT_all(end,1));
        if sum(isEv) > 1
            j=2;
            while j <= sum(isEv)
                I(i,j-1) = events(isEv_ind(j),2) - events(isEv_ind(j-1),2);
                j=j+1;
            end
        end
    else LT_noEv = cat(1,LT_noEv,LT_all(end,1));
    end
end

isI = size(I,2);

CCSo = cat(2,CCSo,LT_all,evPerCCS,I_start,I_end);
if isI
    I = cat(1,I,zeros((size(CCSo,1)-size(I,1)),size(I,2)));
    CCSo = cat(2,CCSo,I);
end

% Removes the zeros from CCSo and replaces the -1000 values by zeros
for i = 1:size(CCSo,1)
    if ~CCSo(i,4:end)
        CCSo(i,4:end) = NaN;
    else
        CCSo(i,find(~CCSo(i,:)))=NaN;
        for j = 5:6
            CCSo(i,j) = max(0,CCSo(i,j));
        end
    end
end



% Writes the results in Excel

Header = cell(13,size(CCSo,2));
Header{1,1} = 'CCS stats';
Header{2,1} = fev;
Header{1,3} = date;
Header{2,3} = fCCS;
Header{4,1} = 'mean values :';
Header{5,1} = 'Lifetime :';
Header{5,3} = mean(LT_all(~~LT_all)); % mean of only non 0 values
Header{6,1} = 'Lifetime with Ev:';
Header{6,3} = mean(LT_isEv(~~LT_isEv));
Header{7,1} = 'Lifetime without Ev:';
Header{7,3} = mean(LT_noEv(~~LT_noEv));
Header{5,4} = 'fr';
Header{6,4} = Header{5,4};
Header{7,4} = Header{5,4};
Header{8,1} = 'nb of events / CCS :';
Header{8,3} = nanmean(CCSo(:,4));
Header{8,4} = 'ev/CCS';
Header{9,1} = 'start to 1st event :';
Header{9,3} = nanmean(CCSo(:,5));
Header{9,4} = Header{5,4};
Header{10,1} = 'last event to end :';
Header{10,3} = nanmean(CCSo(:,6));
Header{10,4} = Header{5,4};

if isI
    Header{11,1} = 'between 2 events :';
    Header{11,3} = nanmean(CCSo(:,7));
    Header{11,4} = Header{5,4};
end
Header(13,1:6) = {'# CCS','frame','Lifetime','ev/CCS','I_start','I_end'};
if isI
    for i = 1:size(I,2)
        Header{13,6+i} = ['I',num2str(i)];
    end
end



toWrite = cat(1,Header,num2cell(CCSo));
[f1,p1] = uiputfile([cellNum,'_CCSstats.xlsx'],...
      'Where to put the CCS stats file?');

if ischar(f1) && ischar(p1)
   warning off MATLAB:xlswrite:AddSheet
   xlswrite([p1,f1],toWrite,'CCSstats')
end



