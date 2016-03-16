function output = Ripley;

% Script for generating a simulation of random dots
% Calculates the Ripley K function
% Written by DP 14/9/05

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
%mimage(data)

[u,v,f]=find(data);
[x,y] = meshgrid(1:256,1:299);
for i=1:size(u,1)
    line = zeros(1,50);
    for j=1:f(i)
          distance = sqrt((x-v(i)).^2 + (y-u(i)).^2);
          for k=1:50
              circle = distance <= k;
              line(k) = sum(sum(data.*circle))-1;
          end
          output = cat(1,output,line);
      end
  end
 
[fle,p] = uiputfile([file(1:end-4),'_Ripley.txt']...
      ,'Where to put the output file');
  
if ischar(fle)&ischar(p)
   dlmwrite([p,fle],output,'\t')
end