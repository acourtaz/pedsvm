function y=loadMIATrc(fname)

y=[];

fid=fopen(fname,'r');

fmt='%f%f%f%f%f%f';

while 1
    tline=fgetl(fid);
    if(~ischar(tline))
        break;
    end;
    
    trcline=sscanf(tline,fmt,6);
    y=[y;trcline'];
    
end;
if(isempty(y))
  return
end;
y=y(find(y(:,1)~=0),:);

fclose(fid);



