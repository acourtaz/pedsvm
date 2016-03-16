function mixRedTraces(nTrials,sumType)

%mixes two sets of red traces (different proteins, or separate sets of
%proteins, like rejected vs candidate events) and determines the
%variability of sum of absolute differences (sumType=1), sum of squares 
%(sumType=2) or correlation coefficient (sumType=3) estimated on nTrials 
%trials where the two datasets are randomly mixed.

[f1,p1] = uigetfile('*.xls','Data file with fluo measures');
if ~f1,return,end

ev1 = xlsread([p1,f1],-1);
N1 = size(ev1,1);

[f2,p2] = uigetfile('*.xls','Data file with fluo measures');
if ~f2,return,end

ev2 = xlsread([p2,f2],-1);
N2 = size(ev2,1);

realsum = ssum(ev1,ev2,sumType)

events = [ev1;ev2];
randsums = zeros(1,nTrials);

for i=1:nTrials
    j = randperm(N1+N2);
    randEv = events(j,:);
    randsums(i) = ssum(randEv(1:N1,:),randEv(N1+1:end,:),sumType);
end

maxsum = max(randsums) 
minsum = min(randsums)
figure('name',f1)
hist(randsums,50)
line([realsum realsum],ylim,'color','r')
if sumType==1
    xlabel('sum of abs')
elseif sumType==2
    xlabel('sum of squares')
elseif sumType==3
    xlabel('correlation coeff')
end

function outsum = ssum(av1,av2,t)
dav = mean(av1)-mean(av2);
if t==1
    outsum = sum(abs(dav));
elseif t==2
    outsum = sum(dav.*dav);
elseif t==3
    ccf = corrcoef(mean(av1)',mean(av2)');
    outsum = ccf(1,2);
end