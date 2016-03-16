function interleave_Correct

%written by DP. updates 27/09/2008; 12/01/2016 from
%Interleave the pH5 and pH7 frames and 
%correct the red channel for bleed-through

[f,p] = uigetfile('*.xlsx','Data file with fluo measures');
if ~f,return,end
c = strfind(f,'-');
if isempty(c)
    c = 5;
else c = c(end)+1;
end
cellNum = num2str(f(1:c));

first_pH = 7;
bleed = 'auto'; % normally around 0.032
time_int = 4;

defaults = {first_pH,bleed,time_int};
prompt = {'pH of the first frame (7 or 5)','bleed-through coefficient',...
    'time interval between pH5 frames (s)'};
    %'Name of protein (e.g. dyn)'};
[first_pH,bleed,time_int] = numinputdlg(prompt,'',1,defaults);

%checks if pH value is correct
if ~(first_pH==5 || first_pH==7)
    error('Enter a value of 5 or 7 for pH of first frame')
end

[type,sheets] = xlsfinfo([p,f]);
red5 = 0; red7 = 0; 
gre5 = 0; gre7 = 0;
%finds the last spreadsheets marked TfR5, TfR7, dyn5, dyn7
%if you keep the candidates spreadsheets, put them first in the 
%excel file
for i=1:size(sheets,2)
    isdata5 = strfind(sheets{i}(6:end),'5');
    isdata7 = strfind(sheets{i}(6:end),'7');
    if ~isempty(isdata5)
        TfR = strfind(sheets{i}(5:5+isdata5),'TfR');
        B2R = strfind(sheets{i}(5:5+isdata5),'B2R');
        if isempty(TfR)&&isempty(B2R)
            red5 = i;
            prot = sheets{i}(c+2:c+4);
        else
            gre5 = i;
        end
    elseif ~isempty(isdata7)
        TfR = strfind(sheets{i}(5:5+isdata7),'TfR');
        B2R = strfind(sheets{i}(5:5+isdata7),'B2R');
        if isempty(TfR)&&isempty(B2R)
            red7 = i;
        else
            gre7 = i;
        end
    end
end
if ~(red5 && red7 && gre5 && gre7)
    error('One fluo measure sheet is missing')
end

[dataRed5,textRed5] = xlsread(f,sheets{red5});
[dataGre5,textGre5] = xlsread(f,sheets{gre5});
[dataRed7,textRed7] = xlsread(f,sheets{red7});
[dataGre7,textGre7] = xlsread(f,sheets{gre7});

%compares the event file names of the 4 fluo files
sameEvents1 = strcmp(textRed5{1,5},textGre5{1,5});
sameEvents2 = strcmp(textRed5{1,5},textRed7{1,5});
sameEvents3 = strcmp(textRed7{1,5},textGre7{1,5});
if ~(sameEvents1 && sameEvents2 && sameEvents3)
    error('Not all fluo files have the same events')
end

%compares the parameters used to generate the fluo files
if ~(isequal(dataRed5(1,1:6),dataGre5(1,1:6))...
        && isequal(dataRed5(1,1:6),dataRed7(1,1:6))...
        && isequal(dataRed7(1,1:6),dataGre7(1,1:6)))
    error('Different parameters were used to calculate fluo in files')
end

cellName = sheets{red5}(1:end-6);

%determines the best bleed-through coefficient, that minimizes the sum of
%squares for a range of coefficients BTcoeff = 0:0.001:0.05
if isempty(bleed)
    bleedFig = 1;
    avRed7 = dataRed7(4,4:end);
    avRed5 = dataRed5(4,4:end);
    avGre7 = dataGre7(4,4:end);
    avGre5 = dataGre5(4,4:end);
    BT = -0.05:0.001:0.05;
    SSquares = zeros(size(BT));
    for i = -50:50 %1:51
        BTi = i*0.001; %(i-1)*0.001;
        sqDiff = ((avRed5-BTi.*avGre5)-(avRed7-BTi.*avGre7)).^2;
        SSquares(i+51) = sum(sqDiff);
    end
    [u,miniBT_X]= min(SSquares);
    bleed = BT(miniBT_X);
    hbleed = figure('name',[cellName,' bleedthrough']);
    plot(BT,SSquares,'o')
    line([bleed bleed],ylim,'color','r')
    xlabel('bleed-through coeff')
    ylabel('sum of squares')
else
    bleedFig = 0;
end
        
numEv = size(dataRed5,1)-7;
newdata = zeros(size(dataRed5,1),size(dataRed5,2)*2-3);
newdata(:,1:3) = dataRed5(:,1:3);
if first_pH == 5
    newdata(8:end,4:2:end) = ...
        dataRed5(8:end,4:end)-bleed.*dataGre5(8:end,4:end);
    newdata(8:end,5:2:end) = ...
        dataRed7(8:end,4:end)-bleed.*dataGre7(8:end,4:end);
    newdata(3,4:2:end) = dataRed5(3,4:end).*time_int;
    newdata(3,5:2:end) = (dataRed7(3,4:end) + 0.5).*time_int;
elseif first_pH == 7
    newdata(8:end,4:2:end) = ...
        dataRed7(8:end,4:end)-bleed.*dataGre7(8:end,4:end);
    newdata(8:end,5:2:end) = ...
        dataRed5(8:end,4:end)-bleed.*dataGre5(8:end,4:end);
    newdata(3,5:2:end) = dataRed5(3,4:end).*time_int;
    newdata(3,4:2:end) = (dataRed7(3,4:end) - 0.5).*time_int;
end

%%% Modifs Mo

c = findstr(f,'-');
if isempty(c)
    c = 4;
else c = c(end)+1;
end

if bleedFig
    [fbleed,pbleed] = uiputfile([f(1:c),'_bleedthrough',num2str(bleed*1000),'.fig'],...
    'Save Bleedthrough coefficient');
    if ischar(fbleed) && ischar(pbleed)
        saveas(hbleed,[pbleed,fbleed]);
    end
end


disp(['bleedthrough = ',num2str(bleed)]);

%calculates average and sem of corrected fluo 
averagePlot = mean(newdata(8:end,4:end));
newdata(4,4:end) = averagePlot;
% Modifs Mo in case there is only one event
if size(newdata(8:end,4:end),1) == 1
    semPlot = zeros(size(newdata(8:end,4:end)));
else
semPlot = std(newdata(8:end,4:end))./sqrt(numEv);
end
newdata(5,4:end) = semPlot;
timePlot = newdata(3,4:end);
newdata(6,4:end) = numEv;


hCurve = figure('name',cellName);
errorbar(timePlot,averagePlot,semPlot,'-or','markerfacecolor','r')
line([0 0],ylim)
xlabel('time (s)')
ylabel('average fluo corrected')
title(['cell #  ',cellNum,' ',prot])

zerdata = cell(2,size(newdata,2));
celldata = num2cell(newdata);
celldata = [zerdata;celldata];
celldata(3:4,4:end) = {''};
celldata(9,4:end) = {''};
celldata{1,1} = 'Red fluo data, deinterlaced and bleed-through corrected';
celldata(1,4:5) = textRed5(1,4:5);
celldata(2,1:6) = textRed5(2,1:6);
celldata(2,8:10) = {'pH first frame','bleedthrough','time interval'};
celldata(3,4:6) = num2cell(dataRed5(1,4:6));
celldata(3,8:10) = num2cell([first_pH,bleed,time_int]);
celldata{1,7} = date;
celldata(9,1:2) = {'event#','track'};
celldata{5,3} = 'time (s)';
celldata(6:8,3) = textRed5(6:8,3);

%%% Modifs Mo

[fdeInt,pdeInt] = uiputfile([cellNum,'_',prot,'.fig'], 'Save Corrected Red quantification');
saveas(hCurve,[pdeInt,fdeInt]);

[fle,p] = uiputfile([cellNum,'.xlsx']...
      ,'Where to put the average fluorescence file');
if ischar(fle)&&ischar(p)
   warning off MATLAB:xlswrite:AddSheet
   newsheet = [sheets{red5}(1:c),'_',prot,' deint'];
   xlswrite([p,fle],celldata,newsheet)
end

%%%

%%%%%
%%%%% Second part : Peaks analysis %%%%%
%%%%%

button = questdlg('Do you want to detect peaks in individual traces?',...
    'Peaks analysis','No');
if strcmp(button,'Yes')
    thresh = 1;
    fNoise = 6;
    minPeaks = 6;
    cNoise = 2;
%The threshold for comparing the two noise estimates
    defaults = [thresh,fNoise,minPeaks];
    prompt = {'threshold for defining a maximum (multiples of std)',...
        'number of frames for estimating noise',...
        'minimum number of frames between peaks'};
    [thresh,fNoise,minPeaks] = numinputdlg(prompt,'',1,defaults);
%makes 2 estimates of noise. Normally the estimate will be noise1.
%If noise1 > cNoise*noise2 (e.g. there is recruitment during the period 
%of noise estimation), then the estimate is noise2
    fluo = newdata(8:end,4:end);
    noise1 = std(fluo(:,end-fNoise+1:end),0,2);
    noise2 = std(fluo(:,end-2*fNoise+1:end-fNoise),0,2);
    noisy = max([noise1,cNoise.*noise2],[],2);
    w_noise = noise1==noisy;
    noise = noise1.*(~w_noise) + noise2.*w_noise;
%calculates average fluorescence during noise estimate
    avFluo1 = mean(fluo(:,end-fNoise+1:end),2);
    avFluo2 = mean(fluo(:,end-2*fNoise+1:end-fNoise),2);
    avFluo = avFluo1.*(~w_noise) + avFluo2.*w_noise;
%calculates the signal/noise. If it is bigger than thresh, then a maximum
%is defined.
    [maxval1,maxrow1] = max(fluo,[],2);
    sigNoise1 = (maxval1-avFluo)./noise;
    isMax1 = sigNoise1>thresh;
    max1 = maxval1.*isMax1;
    time1 = timePlot(1)+(time_int/2).*(isMax1.*maxrow1-1);
    for i=1:size(isMax1,1)
        if ~isMax1(i)
            time1(i) = NaN;
        end
    end
%calculates signal/noise to look for a second peak    
    for i=1:size(isMax1,1)
        a = max(maxrow1(i)-minPeaks,1);
        b = min(maxrow1(i)+minPeaks,size(fluo,2));
        fluo(i,a:b) = NaN;
    end
    [maxval2,maxrow2] = max(fluo,[],2);
    sigNoise2 = (maxval2-avFluo)./noise;
    isMax2 = sigNoise2>thresh;
    max2 = maxval2.*isMax2;
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
        fluo(i,a:b) = NaN;
    end
    [maxval3,maxrow3] = max(fluo,[],2);
    sigNoise3 = (maxval3-avFluo)./noise;
    isMax3 = sigNoise3>thresh;
    max3 = maxval3.*isMax3;
    time3 = timePlot(1)+(time_int/2).*(isMax3.*maxrow3-1);
    for i=1:size(isMax3,1)
        if ~isMax3(i)
            time3(i) = NaN;
        end
    end
    
    newfluo = num2cell([newdata(8:end,1),fluo]);
%%%%% Figure of peak recruitment time histogram    
    [hist_max1,u] = histc(time1,timePlot);
    [hist_max2,v] = histc(time2,timePlot);
    [hist_max3,w] = histc(time3,timePlot);
    % Modifs Mo in case there is only one event
    if size(time1,1) == 1
        hist_max1 = hist_max1';
        hist_max2 = hist_max2';
        hist_max3 = hist_max3';
    end
    hpeaks = figure('name',[cellNum,' peaks']);
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
    
    [fpeak,ppeak] = uiputfile([f(1:c),'_peaks.fig'],'Save interval histogramm');
    saveas(hpeaks,[ppeak,fpeak]);
    
%%%%% Construction of the xls spreadsheet
results = [newdata(8:end,1),noise1,noise2,noise,time1,max1,time2,max2,inter12,time3,max3];
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
        newfluosheet = [cellNum,' newfluo'];
        xlswrite([p,fle],newfluo,newfluosheet)
    end
    
end