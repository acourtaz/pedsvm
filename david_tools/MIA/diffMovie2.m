function diffMovie2(varargin)

%diffMovie2(C,n,f) makes 
%Takes a stk file and makes the following transformation: 
%frame(N) - [Sum(1-n) (frame(N-i))/n] + C, where C is a constant and 
%n the number of frames to be averaged and subtracted
%

if size(varargin,2) < 3
    [f,p] = uigetfile('*.stk','Movie to perform difference image');
    if ~f,return,end
else
    p = [cd,'\'];
    f = varargin{3};
end

if size(varargin,2) < 2
    nf = 5;
else
    nf = varargin{2};
end

if size(varargin,2) < 1;
    C = 10000; %default value for added constant
else
    C = varargin{1};
end

%f = f(1:end-4); %????
data = stkread(f,p);

didata1 = data(:,:,nf+1:end);
%Calculates a sliding average
didata2 = zeros(size(didata1));
for i = 1:size(didata1,3)
    didata2(:,:,i) = sum(data(:,:,i:i+nf-1),3,'double')/nf;
end

didata2 = uint16(didata2);
didata = C + didata1 - didata2;
didata = uint16(didata);
avdid = uint16(max(didata,[],3));
%mimage(avdid)
avdid = avdid(:,:,ones(1,nf));
clear didata1
didata = cat(3,avdid,didata);

stkwrite(didata,[f(1:end-4),'_dif',num2str(nf)],p);
stkwrite(didata2,[f(1:end-4),'_sav',num2str(nf)],p);