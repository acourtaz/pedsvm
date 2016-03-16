function histm = histoMax(varargin)

%Makes a histogram of maximums in a series of recruitments profiles
%To use with an excel file containing the fluorescence measures

if nargin == 0
    [f,p] = uigetfile('*.xls','File with fluo measures');
    if ~f,return,end
    fluo = xlsread([p,f],-1);
elseif nargin == 1
    fluo = xlsread(varargin{1},-1);
end
thresh = 5;
[maxval,maxrow] = max(fluo,[],2);
stdFluo = std(fluo(:,end-4:end),0,2);
avFluo = mean(fluo(:,end-4:end),2);
ratioMax = maxval./(thresh*stdFluo + avFluo);
isMax = ratioMax > 1;
trueMaxRow = isMax.*maxrow-floor(size(fluo,2)./2)-1;
x = -20:19;
histm = histc(trueMaxRow,x);
figure
bar(x,histm)
histm = {histm,trueMaxRow,ratioMax}