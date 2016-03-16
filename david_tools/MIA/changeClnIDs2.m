function changeClnIDs2


% written by Mo 07/01/2013
% renames ev IDs of a trc file with those of a corresponding clnStart file
% Case2 : new cln is smaller than old cln (ex: Th3 done after Th2)


%%%%%% NOTE: !!!!!!!!!!!! SOME EVENTS ARE NOT PROPERLY COPIED BECAUSE THE
%%%%%% TWO CLN FILES WERE NOT WRITTEN IN THE SAME ORDER (EX: 3 EVENTS
%%%%%% APPEARING AT THE SAME FRAME MAY BE WRITTEN IN VARIOUS ORDERS)
%%%%%% NOT YET CORRECTED FOR !!!!!!!!!!! TO DO !!!!!!!!!


[fev1,pev1] = uigetfile('*.txt;*.trc','File with 1st matrix of startEvents');
if ~fev1,return,end
ev1 = dlmread([pev1,fev1],'\t'); % start file to take IDs from
c = strfind(fev1,'_');
cellNum = fev1(1:c);

[fev2,pev2] = uigetfile('*.txt;*.trc','File with 2nd start matrix of startEvents');
if ~fev2,return,end
ev2 = dlmread([pev2,fev2],'\t'); % start file to expand with new IDs


[fev3,pev3] = uigetfile('*.txt;*.trc','File with full matrix of events');
if ~fev3,return,end
ev3 = dlmread([pev3,fev3],'\t'); % expanded cln file with old IDs
% ev3 = expanded ev1

j=1; % goes through ev1
k=1; % goes through ev2
newEv = ev3;
last = 2;

for i = ev2(1,1):ev2(end,1)
    if i == ev2(k,1) 
        j = find(ev1(:,1) == ev2(k,5));
        isEv = ev3(:,1) == ev1(j,1);
        first = find(isEv,1,'first');
        if first ~= last+1
            newEv(last+1:first-1,1) = 0; % fills excess ev by zeros
        end
        last = find(isEv,1,'last');
        newEv(first:last,1) = ev2(k,1);
        k = k+1;
    end
end


if ev2(end,5)<ev1(end,1)
    newEv(find(isEv,1,'last')+1:end,1) = 0;
end

j = 1;
newEv2 = [];
toCopy = find(newEv(:,1));
newEv=newEv(toCopy,:);
        
[fnew,pnew] = uiputfile([num2str(cellNum),'.trc'],'Save file');
if ischar(fnew) && ischar(pnew)
   dlmwrite([pnew,fnew],newEv,'\t')
end

%%%%%% NOTE: !!!!!!!!!!!! SOME EVENTS ARE NOT PROPERLY COPIED BECAUSE BOTH
%%%%%% CLN FILES DID NOT WRITE THEM IN THE SAME ORDER (EX: 3 EVENTS
%%%%%% APPEARING AT THE SAME FRAME MAY BE WRITTEN IN VARIOUS ORDERS)
%%%%%% NOT YET CORRECTED FOR !!!!!!!!!!! TO DO !!!!!!!!!


