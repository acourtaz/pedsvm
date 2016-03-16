function benFifouDiff(C,R)

%Takes a stk file and makes the following transformation: 
%frame(N) - frame(N-1) + C, where C is a constant

[f,p] = uigetfile('*.stk','Movie to perform difference image');
if ~f,return,end

f = f(1:end-4); %we trash the '.stk' suffix
data = stkread(f,p);

data = bsxfun(@minus,data,uint16(R*mean(data,3)));
data(data<0)=0;

didata1 = data(:,:,3:end); %all frames but the two first
didata2 = data(:,:,2:end-1); %all frames but both first and last
didata3 = data(:,:,1:end-2); %all frames but the two last
didata = C*(abs(didata1 - didata2) + abs(didata2 - didata3)) ;
didata = uint16(didata);
avdid = uint16(mean(didata,3));
mimage(avdid)
clear didata1
clear didata2
didata = cat(3,avdid,didata);

stkwrite(didata,[f,'_dif'],p);
end

