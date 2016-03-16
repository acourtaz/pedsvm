function ConcatStk

%Written by DP 05/11/2012
%Concatenates stk files. Can insert an image of zeros between stacks
%Initally made to analyse data on aGFP with stimulation of b2AR

[stk1,stkd1] = uigetfile('*.stk','First stk file');
if ~stk1,return,end
M1 = stkread(stk1,stkd1);

pause(0.5)
[stk2,stkd2] = uigetfile('*.stk','First stk file');
if ~stk2,return,end
M2 = stkread(stk2,stkd2);

is0Image = questdlg('Insert a black image?');

if strcmp(is0Image,'Yes')
    im0 = zeros(size(M1,1),size(M1,2));
else
    im0 = [];
end

M = cat(3,M1,im0,M2);

[stk,stkd] = uiputfile([stk1(1:end-4),'-cat.stk'],'Name of the concatenated stack');

if stk
    stkwrite(M,stk,stkd)
end