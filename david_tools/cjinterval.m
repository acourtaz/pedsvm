function cjinterval

[f,p] = uigetfile('*.txt','File with matrix of event times');
M = dlmread([p,f],'\t');
u=1;N=[];
for j=1:size(M,2)
   tim = 0;
   for i=size(M,1):-1:1
      if M(i,j) > 0
         if tim > 0 int = tim - M(i,j);N(u,:) = int;u=u+1;
         end
         tim = M(i,j);
      end
   end
end
[file,p] = uiputfile('*.txt','Where to put the list of intervals');
dlmwrite([p,file],N,'\t')
