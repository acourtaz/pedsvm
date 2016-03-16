function blankmovie(C,D)

%Takes a stk file and makes the following transformation:
%From frame C, C+xD = empty matrix

[f,p] = uigetfile('*.stk','Movie to perform difference image');
if ~f,return,end

f = f(1:end-4); %????
data = stkread(f,p);


blankframe = round((size(data,3)-C)/D);

for i=1:blankframe

data(:,:, C+i*D)= zeros(512);

end


stkwrite(data,[f,'_blank'],p);