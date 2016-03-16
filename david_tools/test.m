function movi = test;

[stk,stkd] = uigetfile('*.stk','Choose a Stack');
if ~stk,return,end

movi = stkread(stk,stkd);


stkwrite(movi);