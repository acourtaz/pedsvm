[file,path] = uigetfile('*.txt','File with matrix of events');
if ~file,return,end
events = dlmread([path,file],'\t');

data = zeros(299,256);
output = [];
for i=1:size(events,1)
    a = round(events(i,2));
    b = round(events(i,1));
    data(a,b) = data(a,b)+1;
end
mimage(data)