function changeClnIDs1

% written by Mo 07/01/2013
% renames ev IDs of a trc file with those of a corresponding clnStart file 
% Case1 : new cln is larger than old cln (ex: Th3 done after Th5)

[fev1,pev1] = uigetfile('*.txt;*.trc','File with 1st matrix of startEvents');
if ~fev1,return,end
ev1 = dlmread([pev1,fev1],'\t'); % start file to expand with new IDs
c = strfind(fev1,'_');
cellNum = fev1(1:c);

[fev2,pev2] = uigetfile('*.txt;*.trc','File with 2nd start matrix of startEvents');
if ~fev2,return,end
ev2 = dlmread([pev2,fev2],'\t'); % start file to take IDs from


[fev3,pev3] = uigetfile('*.txt;*.trc','File with full matrix of events');
if ~fev3,return,end
ev3 = dlmread([pev3,fev3],'\t'); % expanded cln file with old IDs 
                                 % ev3 = expanded ev1

j=1;
newEv = ev3;

for i = ev1(1,1):ev1(end,1)
    if i == ev1(j,1)
        isEv = ev3(:,1) == i;
        first = find(isEv,1,'first');
        last = find(isEv,1,'last');
        newEv(first:last,1) = ev2(j,1);
        j=j+1;
    end
end

[fnew,pnew] = uiputfile([num2str(cellNum),'.trc'],'Save file');
if ischar(fnew) && ischar(pnew)
   dlmwrite([pnew,fnew],newEv,'\t')
end

