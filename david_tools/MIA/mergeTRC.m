function mergeTRC(varargin)

%Written by DP 110405
%Merges two .trc files, removing duplicates and sorting events

if nargin == 0
    [f1,p1] = uigetfile('*.txt;*.trc','File #1 with matrix of events');
    if ~f1,return,end
    ev1 = dlmread([p1,f1],'\t');
    [f2,p2] = uigetfile('*.txt;*.trc','File #2 with matrix of events');
    if ~f2,return,end
    ev2 = dlmread([p2,f2],'\t');
elseif nargin == 2
    ev1 = dlmread(varargin{1},'\t');
    ev2 = dlmread(varargin{2},'\t');
end

first1 = round(ev1(2,1));
last1 = round(ev1(end,1));
for i = first1:last1
    track1 = (ev1(:,1)==i);
    [u1,s1] = max(track1);
    if u1
        atrack2 = (ev2(:,1)~=i);
        ev2(:,1) = ev2(:,1).*atrack2;
    end
end

ev2 = sortrows(ev2,1);
dupli2 = ev2(:,1)==0;
ndupli = round(sum(dupli2));
if ndupli < size(ev2,1)
    ev2 = ev2(ndupli+1:end,:);
else
    ev2 = [];
end

events = cat(1,ev1,ev2);
events = sortrows(events,1);

[f,p] = uiputfile([f1(1:end-4),'mrg.trc'],'Where to put the merged file');

if ischar(f) && ischar(p)
    dlmwrite([p,f],events,'\t')
end