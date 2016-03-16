function RemoveStacksMIA

%written by DP 12/02/06
%
%Uses the tag file "filename_removed.txt" to put the ministacks in a
%"Removed" daughter directory. 

[f,p] = uigetfile('*.txt','File with removed (tagged) events');
if ~f,return,end
remEvents = dlmread([p,f],'\t');
[stk,stkd] = uigetfile('*.stk','Choose a (mini)Stack');
if ~stk,return,end
[f2,p2] = uigetfile('*.txt;*.trc','File with matrix of events');
if ~f2,return,end

%Puts removed ministacks in the 'removed' folder
current = cd;
a = strfind(stk,'_');
a = a(size(a,2));
rootFile = stk(1:a);
cd(stkd)
if (exist('removed','dir')==0)
    mkdir('removed')
end
for i=1:size(remEvents,1)
    evNum = remEvents(i);
    evName = [rootFile,num2str(evNum),'.stk'];
    if (exist(evName)>0)
        movefile(evName,[stkd,'\removed'])
    end
end
cd(current)

%Removes events from the trc file
events = dlmread([p2,f2],'\t');
removed = ismember(events(:,1),remEvents);
removed2 = removed(2:size(removed,1));
removed2 = cat(1,removed2,0);
removed = removed+removed2>0;
output = zeros(size(events));
k=1;
for i=1:size(events,1)
    if removed(i) == 0
        output(k,:) = events(i,:);
        k=k+1;
    end
end
output = output(1:k-1,:);
[fle,p] = uiputfile([f2(1:end-4),'_rem.trc']...
      ,'Where to put the cleaned up event file');
if ischar(fle)&ischar(p)
   dlmwrite([p,fle],output,'\t')
end