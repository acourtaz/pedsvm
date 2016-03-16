function peaksDetection

[f,p] = uigetfile('*.xlsx','Data file with fluo measures');
if ~f,return,end
c = strfind(f,'_');
if isempty(c)
    c = 5;
else c = c(1)-1;
end
cellNum = num2str(f(1:c));

[type,sheets] = xlsfinfo([p,f]);
for i  = 1:size(sheets,2)
    isdeint = strfind(sheets{i},'deint');
    if isdeint
        [data,text] = xlsread(f,sheets{i});
        prot = sheets{i}(c+2:c+4);
    end
end

thresh = 1;
    fNoise = 6;
    lNoise = -1;
    minPeaks = 6;
    cNoise = 2;
%The threshold for comparing the two noise estimates
    defaults = [thresh,fNoise,lNoise,minPeaks];
    prompt = {'threshold for defining a maximum (multiples of std)',...
        'number of frames for estimating noise',...
        'last frame (relative to scission) for estimating noise',...
        'minimum number of frames between peaks'};
    [thresh,fNoise,lNoise,minPeaks] = numinputdlg(prompt,'',1,defaults);
%makes 2 estimates of noise. Normally the estimate will be noise1.
%If noise1 > cNoise*noise2 (e.g. there is recruitment during the period 
%of noise estimation), then the estimate is noise2
    fluo = data(8:end,4:end);
    timePlot = data(3,4:end);
    time_int = data(1,10);
    events = data(8:end,1);
    nEv = size(events,1);
    
    normF = zeros(size(fluo));
    length = size(fluo,2);
    lNs = round(length/2)+2+lNoise; %time 0 is at frame 42 in 80 frame measures
    lNs = min(lNs,size(fluo,2));  %To make sure the noise estimate is in the fluo data
    lNs = max(lNs,1+fNoise);
    noise1 = std(fluo(:,lNs-fNoise+1:lNs),0,2);
    noise2 = std(fluo(:,lNs-2*fNoise+1:lNs-fNoise),0,2);
    noisy = max([noise1,cNoise.*noise2],[],2);
    w_noise = noise1==noisy;
    noise = noise1.*(~w_noise) + noise2.*w_noise;
%calculates average fluorescence during noise estimate
    avFluo1 = mean(fluo(:,lNs-fNoise+1:lNs),2);
    avFluo2 = mean(fluo(:,lNs-2*fNoise+1:lNs-fNoise),2);
    avFluo = avFluo1.*(~w_noise) + avFluo2.*w_noise;
%calculates the signal/noise. If it is bigger than thresh, then a maximum
%is defined.
    [maxval1,maxrow1] = max(fluo,[],2);
    sigNoise1 = (maxval1-avFluo)./noise;
    isMax1 = sigNoise1>thresh;
    max1 = sigNoise1.*isMax1;
    time1 = timePlot(1)+(time_int/2).*(isMax1.*maxrow1-1);
    for i=1:size(isMax1,1)
        if isMax1(i)
            normF(i,:) = (fluo(i,:)-avFluo(i))./(maxval1(i)-avFluo(i));
        else
            time1(i) = NaN;
            normF(i,:) = NaN;
        end
    end
%calculates signal/noise to look for a second peak    
pfluo = fluo;    
for i=1:size(isMax1,1)
        a = max(maxrow1(i)-minPeaks,1);
        b = min(maxrow1(i)+minPeaks,size(fluo,2));
        pfluo(i,a:b) = NaN;
    end
    [maxval2,maxrow2] = max(pfluo,[],2);
    sigNoise2 = (maxval2-avFluo)./noise;
    isMax2 = sigNoise2>thresh;
    max2 = sigNoise2.*isMax2;
    time2 = timePlot(1)+(time_int/2).*(isMax2.*maxrow2-1);
    for i=1:size(isMax2,1)
        if ~isMax2(i)
            time2(i) = NaN;
        end
    end
    inter12 = abs(time1-time2);
%calculates and looks for a third peak
    for i=1:size(isMax1,1)
        a = max(maxrow2(i)-minPeaks,1);
        b = min(maxrow2(i)+minPeaks,size(fluo,2));
        pfluo(i,a:b) = NaN;
    end
    [maxval3,maxrow3] = max(fluo,[],2);
    sigNoise3 = (maxval3-avFluo)./noise;
    isMax3 = sigNoise3>thresh;
    max3 = sigNoise3.*isMax3;
    time3 = timePlot(1)+(time_int/2).*(isMax3.*maxrow3-1);
    for i=1:size(isMax3,1)
        if ~isMax3(i)
            time3(i) = NaN;
        end
    end
    
    NFmean = nanmean(normF);
    NFstd = nanstd(normF);
    NFsem = NFstd./sqrt(sum(isMax1));
    
    normFluo = num2cell([events,sigNoise1,time1,normF]);
    titNorm = cell(9,size(normFluo,2));
    titNorm(2,1:10) = text(2,1:10);
    titNorm(5:9,1:3) = text(5:9,1:3);
    titNorm{1,1} = 'Red fluo data, normalized to peak fluorescence';
    titNorm{1,7} = date;
    titNorm{9,2} = 'sig/noise';
    titNorm{9,3} = 'time peak1';
    titNorm(3,:) = num2cell(data(1,:));
    titNorm(5,4:end) = num2cell(data(3,4:end));
    titNorm(6,4:end) = num2cell(NFmean);
    titNorm(7,4:end) = num2cell(NFsem);
    titNorm(8,4:end) = num2cell(sum(isMax1));
    
    normFluo = cat(1,titNorm,normFluo);

figure('name',[cellNum,'Norm'])
errorbar(timePlot,NFmean,NFsem,'-or','markerfacecolor','r')
line([0 0],ylim)
xlabel('time (s)')
ylabel('average normalized fluo')
title(['cell #  ',cellNum,' ',prot])
    
%%%%% Figure of peak recruitment time histogram    
    [hist_max1,u] = histc(time1,timePlot);
    [hist_max2,v] = histc(time2,timePlot);
    [hist_max3,w] = histc(time3,timePlot);
    figure('name',[cellNum,' peaks'])
    bar(timePlot,[hist_max1,hist_max2,hist_max3],'stack')
    colormap gray(4)
    line([0 0],ylim,'color','r')
    xlabel('time of peak (s)')
    ylabel('number of events')
    title(['cell # ',cellNum,' ',prot,' peaks'])
%%%%% Figure of signal/noise histogram
    x_thresh = 0:40;
    hist_sigNoise1 = histc(sigNoise1,x_thresh);
    figure('name',[cellNum,' threshold'])
    bar(x_thresh,hist_sigNoise1)
    line([thresh thresh],ylim,'color','r')
    xlabel('signal/noise')
    ylabel('number of events')
    title(['cell # ',cellNum,' ',prot,' threshold'])
%%%%% Figure of interval histogram
    figure('name',[cellNum,' intervals'])
    hist_int = histc(inter12,0:2:timePlot(end)-timePlot(1));
    bar(0:2:timePlot(end)-timePlot(1),hist_int)
    title(['cell#',cellNum,' interval peak1-peak2'])
    xlabel('interval (s)')
    ylabel('number of events')
    
    %%% Modifs Mo
    
    [fpeak,ppeak] = uiputfile([f(1:c),'_peaks'],'Save interval histogramm');
    saveas(gcf,[ppeak,fpeak]);
    
%%%%% Construction of the xls spreadsheet
results = [data(8:end,1),noise1,noise2,noise,time1,max1,time2,max2,inter12,time3,max3];
titColumns = {'event #','noise1','noise2','noise','time 1st','1st max val','time 2nd','2nd max val','interval between peaks','time 3rd','3rd max val'};
    results = num2cell(results);
    results = [titColumns;results];
    header_peaks = cell(4,size(results,2));
    header_peaks{1,1} = 'Peaks analysis';
    header_peaks{1,4} = date;
    header_peaks(2,1:3) = {'Threshold','noise#frames','#frames between peaks'};
    header_peaks(3,1:3) = num2cell([thresh,fNoise,minPeaks]);
    results = [header_peaks;results];
    [fle,p] = uiputfile([f(1:c),'.xlsx']...
      ,'Where to put the maximums analysis file');
    if ischar(fle)&&ischar(p)
        warning off MATLAB:xlswrite:AddSheet
        histsheet = [cellNum,' histo'];
        xlswrite([p,fle],results,histsheet)
        normFluosheet = [cellNum,' normFluo'];
        xlswrite([p,fle],normFluo,normFluosheet)
    end