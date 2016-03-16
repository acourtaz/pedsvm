function cutmovie(varargin)

%Cuts Dual-View, alternating pH movies into 4 movies

if nargin == 0
    [f,p] = uigetfile('*.stk','Two color movie with alternated pH');
    if ~f,return,end
elseif nargin == 1
    f = varargin{1};
    p = cd;
end

f = f(1:end-4);
data = stkread(f,p);

%%%
button = questdlg('Is TfR on the left side of the image?');
isLeft = strcmp(button,'Yes');
width = size(data,2);
offset = floor(width/2);
green = data(:,1+offset*(~isLeft):offset*(1+~isLeft),:);
red = data(:,1+offset*(isLeft):offset*(1+isLeft),:);  
%%%   
      
%width = size(data,2);
%left = data(:,1:floor(width/2),:);
%right = data(:,floor(width/2)+1:width,:);
sum2 = sum(sum(green(:,:,2)));
sum3 = sum(sum(green(:,:,3)));

if sum2 > sum3
    name2 = [f,'_TfR7'];
    name3 = [f,'_TfR5'];
else
    name2 = [f,'_TfR5'];
    name3 = [f,'_TfR7'];
end

prot = inputdlg({'Name of the associated protein'});
prot = prot{1};

stkwrite(green(:,:,1:2:end),name3,p);
stkwrite(green(:,:,2:2:end),name2,p);
stkwrite(red(:,:,1:2:end),[f,'_',prot,name3(end)],p);
stkwrite(red(:,:,2:2:end),[f,'_',prot,name2(end)],p);

