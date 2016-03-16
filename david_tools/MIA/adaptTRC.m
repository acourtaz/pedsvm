function adaptTRC

%Written by DP 7/9/05%

[f,p] = uigetfile('*.trc','File with matrix of events');
if ~f,return,end
events = dlmread([p,f],'\t');
n = size(events,2);

output = zeros(1,n);
output(1,2)=events(1,1);
index = 1;

for i=1:size(events,1)
    if events(i,1)-index==0
        output = cat(1,output,events(i,:));
    else
        output = cat(1,output,zeros(1,n));
        index = events(i,1);
        output(size(output,1),2)=index;
        output = cat(1,output,events(i,:));
    end
end

[fle,p] = uiputfile([f(1:end-4),'_ad.trc']...
      ,'Where to put the average fluorescence file');
  
if ischar(fle)&ischar(p)
   dlmwrite([p,fle],output,'\t')
end

