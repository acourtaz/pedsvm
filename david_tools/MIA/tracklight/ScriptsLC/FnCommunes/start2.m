function opt = start2 

global MASCHINE; MASCHINE='PCXX';

global KINETICSBORDERS; KINETICSBORDERS=[0 2];
global opt;
opt=fitopt([]);
opt(7)=1.7;
opt(9)=1.5;