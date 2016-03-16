function clnOffset(varargin)

% returns a cln file with corrected x/y coordinates according to an input
% "OffsetMovie" transformation file

if nargin == 0
    [f,p] = uigetfile('*.txt;*.trc','File with matrix of events');
    [f1,p1] = uigetfile('*.txt','Offset data File');
    if ~f,return,end
    if ~f1,return,end
    ev = dlmread([p,f],'\t');
    coeffs = dlmread([p1,f1],'\t');
elseif nargin ==1
    ev = dlmread(varargin{1},'\t');
    coeffs = dlmread(varargin{2},'\t');
end

ev2 = ev;
for i = 1:size(coeffs,1)
    ind = find((ev(:,2)==i)); 
    ev2(ind,3)=ev(ind,3)+coeffs(i,1);
    ev2(ind,4)=ev(ind,4)+coeffs(i,2);
end

[f2,p2] = uiputfile([f(1:end-4),'o',f(end-3:end)],'Cln file corrected for offset');
if ischar(f2)&&ischar(p2)
   dlmwrite([p2,f2],ev2,'\t')
end