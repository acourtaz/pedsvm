cellNum = '1453-1-1co';
cln = '_clnR20';
cl = '_clnR5';
trc = '.trc';
dete = '_TfR';
prot = '_Clc';
coeffs = 'coeffs141202(gL).txt';
b = '_Base';
s = '_Stim';
w = '_Wash';
xls = '.xlsx';

selectEvents([cellNum,cl,trc],[cellNum,cl,'start',b,trc],[cellNum,cln,b,trc])
selectEvents([cellNum,cl,trc],[cellNum,cl,'start',b,trc],[cellNum,cl,b,trc])
avFluo5([cellNum,cln,b,trc],[cellNum,dete,'5.stk'],[],[cellNum,b,xls],[cellNum,dete,'5',b,'.fig'])
avFluo5([cellNum,cln,b,trc],[cellNum,dete,'7.stk'],[],[cellNum,b,xls],[cellNum,dete,'7',b,'.fig'])

selectEvents([cellNum,cl,trc],[cellNum,cl,'start',s,trc],[cellNum,cln,s,trc])
selectEvents([cellNum,cl,trc],[cellNum,cl,'start',s,trc],[cellNum,cl,s,trc])
avFluo5([cellNum,cln,s,trc],[cellNum,dete,'5.stk'],[],[cellNum,s,xls],[cellNum,dete,'5',s,'.fig'])
avFluo5([cellNum,cln,s,trc],[cellNum,dete,'7.stk'],[],[cellNum,s,xls],[cellNum,dete,'7',s,'.fig'])
%avFluo5([cellNum,cln,b,trc],[cellNum,prot,'5.stk'],coeffs,[cellNum,b,xls],[cellNum,prot,'5',b,'.fig'])
%avFluo5([cellNum,cln,b,trc],[cellNum,prot,'7.stk'],coeffs,[cellNum,b,xls],[cellNum,prot,'7',b,'.fig'])

pause(0.75)



clear