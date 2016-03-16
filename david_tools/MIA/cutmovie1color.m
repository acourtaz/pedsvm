function cutmovie1color(varargin)

%Cuts alternating pH movies into 2 movies

if nargin == 0
    [f,p] = uigetfile('*.stk','Single color movie with alternated pH');
    if ~f,return,end
elseif nargin == 1
    f = varargin{1};
    p = cd;
end

f = f(1:end-4);
data = stkread(f,p);

sum2 = sum(sum(data(:,:,2)));
sum3 = sum(sum(data(:,:,3)));

if sum2 > sum3
    name2 = [f,'_TfR7'];
    name3 = [f,'_TfR5'];
else
    name2 = [f,'_TfR5'];
    name3 = [f,'_TfR7'];
end

stkwrite(data(:,:,1:2:end),name3,p);
stkwrite(data(:,:,2:2:end),name2,p);