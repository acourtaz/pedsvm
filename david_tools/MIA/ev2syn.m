function varargout = ev2syn(varargin)

% written by Mo 28/11/2013
% Determines if an event is close to a synapse (Homer staining)
% writes closest synapse ID in the 5th column of the .trc file
% writes the distance from the event to its closest synapse in the 6th

if nargin == 0
    
    [fev,pev] = uigetfile('*.txt;*.trc','File with matrix of events');
    if ~fev,return,end
    events = dlmread([pev,fev],'\t');
    fEv = fev(1:size(fev,2)-4);
    [fSyn,pSyn] = uigetfile('*.txt;*.trc','File with tracked CCS (MIA)');
    if ~fSyn,return,end
    Syn = dlmread([pSyn,fSyn],'\t');
    
elseif nargin == 2
    events = varargin{1};
    Syn = varargin{2};
    
else return
    
end

MD = 5; % Max distance in pixels between an event and its 
% closest synapse to consider there is overlap

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
Syn = sortrows(Syn,2);

for i = 1:size(events,1)  
    dist = sqrt((Syn(:,3)-events(i,3)).^2+ (Syn(:,4)-events(i,4)).^2);
    [min_dist,min_ind] = min(dist);
    if min_dist < MD
        events(i,5) = (Syn((min_ind),1))'; % nearest syn to the event i
    else 
        events(i,5) = 0;
    end
    events(i,6) = min_dist;
end

noSyn = sum(~events(:,5));

if noSyn == 0
    disp('all events are within 5 pixels of a synaptic staining (100% classified)')
else if noSyn == 1
        disp([num2str(noSyn),' event is further than 5 pixels away from a synaptic staining (',num2str((1-noSyn/size(events,1))*100) ,'% classified)'])
        
    else
        disp([num2str(noSyn),' events are further than 5 pixels away from a synaptic staining (',num2str((1-noSyn/size(events,1))*100) ,'% classified)'])
    end
end


if nargin == 0
    
[fevSt,pevSt] = uiputfile([fEv,'_ev2Homer.trc'],'Save file');
if ischar(fevSt) && ischar(pevSt)
   dlmwrite([pevSt,fevSt],events,'\t')
end

elseif nargin == 2
    varargout{1} = events;
end







