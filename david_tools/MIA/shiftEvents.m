function output = shiftEvents(input)

%shifts the coordinates of events in the events file
%input is a n by 3 matrix of 

[f,p] = uigetfile('*.txt;*.trc','File with matrix of events');
if ~f,return,end
events = dlmread([p,f],'\t');

evNum = input(:,1);
Xs = input(:,2);
Ys = input(:,3);

for i = 1:size(events,1)
    if ~(events(i,1) == 0)
        numEv = events(i,1);
        j = find(evNum == numEv);
        events(i,3) = events(i,3) + Xs(j);
        events(i,4) = events(i,4) + Ys(j);
    end
end

output = events;