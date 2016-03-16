cellNum = '1099-1';
cln = '_clnR20';
trc = '.trc';
detection = 'B2R';
prot = 'Clc';
coeffs = 'coeffs141202(gL).txt';
xn = [cellNum,'_browsed.xlsx'];
b = '_Base';
s = '_Stim';
w = '_Wash';

avFluo4([cellNum,cln,b,trc],[cellNum,'_',detection,'5.stk'],[],xn)
avFluo4([cellNum,cln],[cellNum,'_',detection,'7.stk'],[],xn)
avFluo4([cellNum,cln],[cellNum,'_',prot,'7.stk'],coeffs,xn)
avFluo4([cellNum,cln],[cellNum,'_',prot,'5.stk'],coeffs,xn)

pause(0.75)
close
close
close
close
clear