function remove0lines

[f,p] = uigetfile('*.txt;*.trc','File with matrix of events');
if ~f,return,end
events = dlmread([p,f],'\t');

val = [];
for i=1:size(events,1)
    if events(i,1) > 0
        val = cat(1,val,events(i,:));
    end
end

[fle,p] = uiputfile([f(1:end-4),'_zer.trc']...
      ,'Where to put the zeroless event file');
  
if ischar(fle)&ischar(p)
   dlmwrite([p,fle],val,'\t')
end