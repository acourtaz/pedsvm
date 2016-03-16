function [] = classify()
%CLASSIFY Summary of this function goes here
%   Detailed explanation goes here
[datas, eventsID, events, stk] = loadEvents();
[f, p] = uigetfile('*.mat','Load the SVM model');
SVMModel = importdata(f,'SVMModel');
datas = single(datas);
labels = predict(SVMModel, datas);


i = find(labels);
newID = eventsID(i,:);
i = ismember(events(:,1), newID(:,1));
i = find(i);
newEvents = events(i,:);

d = strfind(stk,'_');
d = d(1)-1;
[f, p] = uiputfile([stk(1:d),'_clnSVM.trc']...
    ,'Where to put the classified file');
if ischar(f)&&ischar(p)
    dlmwrite([p,f],newEvents,'\t');
else 
    return
end

end
