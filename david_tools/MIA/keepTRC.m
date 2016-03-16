function keepTRC

%keeps events in eventlist from the TRC file

[fk,pk] = uigetfile('*.txt','File with event numbers to keep');
if~fk,return,end
evKeep = dlmread([pk,fk],'\t');

[f,p] = uigetfile('*.txt;*.trc','File with matrix of events');
if ~f,return,end
events = dlmread([p,f],'\t');

toKeep = ismember(events(:,1),evKeep);

if events(1,1) == 0
    t2 = toKeep(2:end);
    t2 = cat(1,t2,0);
    toKeep = toKeep + t2 > 0;
end
i = find(toKeep);
newEvents = events(i,:);

if ~isempty(newEvents)
    [fle,p] = uiputfile([f(1:end-4),'_keep.trc'],...
        'Where to put the kept events file?');
    if ischar(fle)&&ischar(p)
        dlmwrite([p,fle],newEvents,'\t')
    else
        return
    end
else
    return
end