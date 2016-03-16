function normRedVariability

%written by DP. Last update 2/11/2009
%Normalizes the deinterlaced traces with a peak (two methods)
%Computes an average and a distribution graph (a series of histograms)

[f,p] = uigetfile('*.xls','Data file pooled cells');
if ~f,return,end
prot = f(end-6:end-4);

[type,sheets] = xlsfinfo([p,f]);
[dataRed,textRed] = xlsread([p,f],[prot,' data']);

fluoRed = dataRed(17:end,:);
timeR = dataRed(1,5:end);

button = questdlg('Do you want to use events with a defined peak?',...
    'Events with peaks?','Yes');
if strcmp(button,'Yes')%events with a peak, sorted by peak time
    sortRed = sortrows(fluoRed,4);
    nPeaks = find(isnan(sortRed(:,4)));
    nPeaks = nPeaks(1)-1;
    nPeaks
    spRed = sortRed(1:nPeaks,:); 
    titend = 'events with peak';
elseif strcmp(button,'No') %NO PEAK, all events are used
    nPeaks = size(fluoRed,1);
    spRed = fluoRed;
    titend = 'all events';
else
    return
end

%Simple normalization (between min and max) of each trace
minRed = min(spRed(:,5:end),[],2);
maxRed = max(spRed(:,5:end),[],2);
spnRed = zeros(size(spRed));
spnRed(:,1:4)= spRed(:,1:4);
for i = 1:nPeaks %this loop creates normalized fluo values, sorted by peak time
    spnRed(i,5:end) = (spRed(i,5:end)-minRed(i))./(maxRed(i)-minRed(i));
end

%makes an average plot of the normalized traces
avPlot = mean(spnRed(:,5:end));
semPlot = std(spnRed(:,5:end))./sqrt(nPeaks);

figure('name',[prot,'_avNorm'])
errorbar(timeR,avPlot,semPlot,'-or','markerfacecolor','r')
line([0 0],ylim)
xlabel('time (s)')
ylabel('average norm events')
title([prot,' ',titend,', normalized'])
    
%makes a distribution plot of the normalized events (histograms)
ynorm = 0:0.01:1;
DispEvents = zeros(size(ynorm,2),size(timeR,2));
for j = 5:size(spnRed,2)
    [n,yn] = hist(spnRed(:,j)',ynorm);
    DispEvents(:,j-4) = n';
end

mimage(DispEvents)
set(gca,'YDir','normal')
colormap rainbow
colorbar
line([41 41],ylim,'color','w')
title([prot,' dispersion, ',titend])

figure('name',[prot,' peaks ',titend])
bar(timeR,DispEvents(101,:))
colormap gray(4)
line([0 0],ylim,'color','r')
xlabel('time of peak (s)')
ylabel('number of events')
title([prot,' peaks ',titend])