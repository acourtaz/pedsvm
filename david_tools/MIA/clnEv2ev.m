function clnEv2ev

% written by Mo 07/01/2013
% removes unmatched events after running ev2ev
% input = cln_compare.trc
% output = newcln


[fev,pev] = uigetfile('*.txt;*.trc','File with matrix of events');
if ~fev,return,end
ev = dlmread([pev,fev],'\t');
fEv = fev(1:size(fev,2)-12);


matched = [];
unmatched = [];

for i = 1:size(ev,1)
    if ev(i,5) ~= 0
        matched=cat(1,matched,ev(i,:));
    else
        unmatched=cat(1,unmatched,ev(i,:));
    end
end

[fevM,pevM] = uiputfile([fEv,'_mached.trc'],'Save file');
if ischar(fevM) && ischar(pevM)
   dlmwrite([pevM,fevM],matched,'\t')
end

[fevU,pevU] = uiputfile([fEv,'_unmached.trc'],'Save file');
if ischar(fevU) && ischar(pevU)
   dlmwrite([pevU,fevU],unmatched,'\t')
end

