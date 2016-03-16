function varargout = ev2CCS(varargin)

% written by Mo 11/07/2013
% Determines the parent CCS of a given Vesicle
% writes the parent CCS in the 5th column of the .trc file
% writes the distance from the event to its parent CCS in the 6th

if nargin == 0
    
    [fev,pev] = uigetfile('*.txt;*.trc','File with matrix of events');
    if ~fev,return,end
    events = dlmread([pev,fev],'\t');
    fEv = fev(1:size(fev,2)-4);
    [fCCS,pCCS] = uigetfile('*.txt;*.trc','File with tracked CCS (MIA)');
    if ~fCCS,return,end
    CCS = dlmread([pCCS,fCCS],'\t');
    
elseif nargin == 2
    events = varargin{1};
    CCS = varargin{2};
    
else return
    
end

%MD = 5; % Max distance in pixels between an event and its parent CCS
MD = 1024; % test for clc-homer distance anna 09/05/2014
%  from startEvents.m

startEvents = [];

firstEvent = round(events(2,1));
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

events = startEvents;
CCS = sortrows(CCS,2);

for i = 1:size(events,1)
    startFr = events(i,2);    
    j = find(CCS(:,2)== startFr); % indices for which there is a CCS
                                  % at startFr
    dist = sqrt((CCS(j,3)-events(i,3)).^2+ (CCS(j,4)-events(i,4)).^2);
    [min_dist,min_ind] = min(dist);
    a = 0;
    while min_dist > MD && a < 4
        startFr = startFr-1;
        j = find(CCS(:,2)== startFr); % indices for which there is a CCS
                                      % at startFr
        dist = sqrt((CCS(j,3)-events(i,3)).^2+ (CCS(j,4)-events(i,4)).^2);
        [min_dist,min_ind] = min(dist);
        a = a+1;
    end
    if min_dist < MD
        events(i,5) = (CCS((min_ind+j(1)-1),1))'; % nearest CCP to the event i
    else 
        events(i,5) = 0;
    end
    events(i,6) = min_dist;
end

noParent = sum(~events(:,5));

% added 19/07/2013 ... to be tested on a cell with events with no parent
% CCS


if noParent == 0
    disp('all events have a parent CCS (100% classified)')
else if noParent == 1
        disp(['There is ',num2str(noParent),' event with no detectable parent CCS (',num2str((1-noParent/size(events,1))*100) ,'% classified)'])
        
    else
        disp(['There are ',num2str(noParent),' events with no detectable parent CCS (',num2str((1-noParent/size(events,1))*100) ,'% classified)'])
    end
end


if nargin == 0
    
[fevSt,pevSt] = uiputfile([fEv,'_CCP.trc'],'Save file');
if ischar(fevSt) && ischar(pevSt)
   dlmwrite([pevSt,fevSt],events,'\t')
end

elseif nargin == 2
    varargout{1} = events;
end







