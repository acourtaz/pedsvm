function selectEvents(varargin)

%selects a list of events (eg start of a subset of events) 
%from a trc file
%Either user selection or selectEvents(events,list,filename), where events is
%the file of events (trc or text) and list is the file of subset
%New event file stored in filename


if nargin == 0
    [f,p] = uigetfile('*.txt;*.trc','File with matrix of events');
    if ~f,return,end
    events = dlmread([p,f],'\t');
    [fl,pl] = uigetfile('*.txt;*.trc','File with list of selected events');
    if ~f,return,end
    list = dlmread([pl,fl],'\t');
else
    f = varargin{1};
    events = dlmread(f,'\t');
    list = dlmread(varargin{2},'\t');
    filename = varargin{3};
end

trackList = ismember(events(:,1),list(:,1));
i = find(trackList);
selectEvents = events(i,:);

if nargin == 0
    [fle,p] = uiputfile([fl(1:end-9),fl(end-3:end)]...
        ,'Where to put the selected events file');
    if ischar(fle)&&ischar(p)
        dlmwrite([p,fle],selectEvents,'\t')
    else
        return
    end
else
    dlmwrite(filename,selectEvents,'\t')
end
