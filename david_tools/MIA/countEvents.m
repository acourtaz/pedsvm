function countEvents(varargin)

%counts the number of events in a .trc file

if nargin == 0
    [f,p] = uigetfile('*.txt;*.trc','File with matrix of events');
    if ~f,return,end
    events = dlmread([p,f],'\t');
elseif nargin ==1
    events = dlmread(varargin{1},'\t');
end

count = 0;
merge = 0;
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
        count = count+1;
        if events(1,1)==0
            if events(start-1,3) ~= 0
              merge = merge+1;
            end
        end
    end
end
%count = [count,merge];
disp(['In ',f])
disp([num2str(count),' events, ',num2str(merge),' merges/splits'])