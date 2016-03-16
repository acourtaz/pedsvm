function diffMovie(C)

%Takes a stk file and makes the following transformation: 
%frame(N) - frame(N-1) + C, where C is a constant

[f,p] = uigetfile('*.stk','Movie to perform difference image');
if ~f,return,end

f = f(1:end-4); %????
data = stkread(f,p);

didata1 = data(:,:,2:end);
didata2 = data(:,:,1:end-1);
didata = C + didata1 - didata2;
didata = uint16(didata);
avdid = uint16(max(didata,[],3));
mimage(avdid)
clear didata1
clear didata2
didata = cat(3,avdid,didata);

stkwrite(didata,[f,'_dif'],p);