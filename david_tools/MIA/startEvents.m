function startEvents(varargin)

%counts the number of events in a .trc file

if nargin == 0
    [f,p] = uigetfile('*.txt;*.trc','File with matrix of events');
    if ~f,return,end
    events = dlmread([p,f],'\t');
elseif nargin ==1
    events = dlmread(varargin{1},'\t');
end

startEvents = [];
%merge = 0;
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
        if events(1,1)==0
            startEvents = cat(1,startEvents,events(start+1,:));
        else
            startEvents = cat(1,startEvents,events(start,:));
        end
    end
end
[f1,p1] = uiputfile([f(1:end-4),'start',f(end-3:end)],'file with first frame of events');
if ischar(f1)&&ischar(p1)
   dlmwrite([p1,f1],startEvents,'\t')
end