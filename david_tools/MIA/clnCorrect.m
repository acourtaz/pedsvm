function clnCorrect

% "Written" by Mo 21/06/13 
% Generates a clean file with corrected x and y coordinates according to
% coeffs

[f,p] = uigetfile('*.txt;*.trc','File with matrix of events');
if ~f,return,end
events = dlmread([p,f],'\t');

[coFile,coDir] = uigetfile('*.txt','File with alignment coefficients');
coeff = dlmread([coDir,coFile],'\t');

evCorr = events;
evCorr(:,3) = interPolx(events(:,3),events(:,4),coeff);
evCorr(:,4) = interPoly(events(:,3),events(:,4),coeff);

[fle,p] = uiputfile([f(1:end-4),'_',coFile(end-7:end-4),'.trc'], ...
    'Where to put the corrected cln file?');
dlmwrite([p,fle],evCorr, '\t')

function u = interPolx(x,y,c)
u = c(1) + c(2).*x + c(3).*x.^2 + c(4).*x.^3 +...
   c(5).*y + c(6).*y.^2 + c(7).*y.^3;

function v = interPoly(x,y,c)
v = c(8) + c(9).*x + c(10).*x.^2 + c(11).*x.^3 +...
   c(12).*y + c(13).*y.^2 + c(14).*y.^3;
