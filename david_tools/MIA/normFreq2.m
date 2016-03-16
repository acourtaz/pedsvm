function poolFreq

[f1,p1] = uigetfile('*.xlsx','Data file with freq data');
if ~f1,return,end

[f2,p2] = uigetfile('*.xlsx','Second data file with freq data');
if ~f2,return,end

%cellNum = f(1:(strfind(f,'_')-1));
%if isempty(cellNum)
%    cellNum = f(1:4);
%end

% creates a matrix with the cumulated freqency in the first row
% (1,2,3,4,...) and the associated event number in the second

data1 = xlsread(f1,'Freq');
data2 = xlsread(f2,'Freq');

i=6;
nbEv1 = 0;
while ~isnan(data1(i,1))
    nbEv1 = nbEv1+1;
    events1 = cat(2,data1((6:i),2),data1((6:i),4));
    i = i+1;
end

i=6;
nbEv2 = 0;
while ~isnan(data2(i,1))
    nbEv2 = nbEv2+1;
    events2 = cat(2,data2((6:i),2),data2((6:i),4));
    i = i+1;
end

start1 = events1(1,2);
i=2;
while events1(i,1) == events1(i-1,1)
    start1 = events1(i,2);
    i = i+1;
end

ev1a = events1(start1,:);

for i = start1+2:nbEv1-1       
    %if i == nbEv1
     %   ev1a = cat(1,ev1a,events1(i,:));
    if events1(i,1) ~= events1(i-1,1)
        ev1a = cat(1,ev1a, events1(i-1,:));
    end
end

ev1a = cat(1,ev1a,events1(nbEv1,:));

start2 = events2(1,2);
i=2;
while events2(i,1) == events2(i-1,1)
    start2 = events2(i,2);
    i = i+1;
end

ev1b = events2(start2,:);

for i = start2+2:nbEv2-1       
    %if i == nbEv1
     %   ev1a = cat(1,ev1a,events1(i,:));
    if events2(i,1) ~= events2(i-1,1)
        ev1b = cat(1,ev1b, events2(i-1,:));
    end
end

ev1b = cat(1,ev1b,events2(nbEv2,:));

nbFr = 65;
if data1(4,1) < nbFr-data1(2,3)-data1(2,4)
    nbFr = data1(2,1)-data1(2,3)-data1(2,4);
end
if data2(4,1) < nbFr-data2(2,3)-data2(2,4)
    nbFr = data2(2,1)-data2(2,3)-data2(2,4);
end

j=1;
for i = events1(1,1):nbFr+data1(2,4)
    ev2a(j,1) = i;
    j=j+1;
end

j=1;
while j < size(ev1a)
for i = 1:nbFr-1    % can't get the last event right
    if ev2a(i,1) == ev1a(j,1)
        ev2a(i,2) = ev1a(j,2);
        j=j+1;
    else ev2a(i,2) = ev2a(i-1,2);         
    end
end
end

j=1;
for i = events2(1,1):nbFr+data2(2,4)
    ev2b(j,1) = i;
    j=j+1;
end

j=1;
while j < size(ev1b)
for i = 1:nbFr-1    % can't get the last event right
    if ev2b(i,1) == ev1b(j,1)
        ev2b(i,2) = ev1b(j,2);
        j=j+1;
    else ev2b(i,2) = ev2b(i-1,2);         
    end
end
end

for i = 1:nbFr
    totEv(i,1) = i;
    totEv(i,2) = (ev2a(i,2)+ev2b(i,2))/2;
end

disp(totEv);








    





