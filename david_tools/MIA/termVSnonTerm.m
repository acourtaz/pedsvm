function termVSnonTerm

%written by DP. Updates 13/01/2016;10/06/2008
%Separates terminal vs non terminal events

[f,p] = uigetfile('*.xlsx','Data file with fluo measures');
if ~f,return,end
cellNum = f(1:(strfind(f,'_')-1));
if isempty(cellNum)
    cellNum = f(1:4);
end

%Parameters for definition of terminal and non terminal events

nFr = 4;
firstStart = -3;
firstEnd = 9;
ratioNTerm = 0.6;
ratioTerm = 0.4;


defaults = [nFr,firstStart,firstEnd,ratioNTerm,ratioTerm];
prompt = {'number of frames for averages to calculate TfR7 ratio',...
    'first frame for average start','first frame for average end',...
    'minimum ratio for non terminal event','maximum ratio for terminal event'};
    
[nFr,firstStart,firstEnd,ratioNTerm,ratioTerm] = ...
    numinputdlg(prompt,'',1,defaults);


[~,sheets] = xlsfinfo([p,f]);
gre5 = 0; gre7 = 0;
deint = 0;
%finds the last spreadsheets marked TfR5 and TfR7, and deint
%if you keep earlier versions (like the candidate events), put them
%first in the excel file
for i=1:size(sheets,2)
    isGre5 = [strfind(sheets{i},'TfR5'),strfind(sheets{i},'B2R5')];
    isGre7 = [strfind(sheets{i},'TfR7'),strfind(sheets{i},'B2R7')];
    isDeint = strfind(sheets{i},'deint');
    if ~isempty(isGre5)
        gre5 = i;
        if ~isempty(strfind(sheets{i},'TfR'))
                    rcp = 'TfR';
                elseif ~isempty(strfind(sheets{i},'B2R'))
                    rcp = 'B2R';
                end
    elseif ~isempty(isGre7)
        gre7 = i;
    elseif ~isempty(isDeint)
        deint = i;
    end
end
if ~(gre5 && gre7 && deint)
    error('One fluo measure sheet is missing')
end

[data5,~] = xlsread(f,sheets{gre5});
[data7,~] = xlsread(f,sheets{gre7});
[dataRed,~] = xlsread(f,sheets{deint});

%Need to add tests for comparing the files


%output of the function:
%a line in TfR7 sheet with the ratios end/start
%a new spreadsheet with averages, all events, terminal, non terminal
%graphs with TfR5, TfR7 and red with term vs non term

numEv = size(data5,1) - 7;

first_pH = dataRed(1,8);
time_int = dataRed(1,10);

isStart = data7(3,4:end) == firstStart;
startindex = find(isStart)+3;
isEnd = data7(3,4:end) == firstEnd;
endindex = find(isEnd)+3;

avStart = mean(data7(8:end,startindex:startindex+nFr-1),2);
avEnd = mean(data7(8:end,endindex:endindex+nFr-1),2);
ratio7 = avEnd./avStart;

%defines upper and lower bounds for outlier events

upBound = 8;
lowBound = -10;


isOutLow = ratio7 < lowBound;
numOutLow = sum(isOutLow); %number of events out of bounds (low)
isTerm = (ratio7 <= ratioTerm) & (ratio7 >= lowBound);
numTerm = sum(isTerm); %number of terminal events

isOutUp = ratio7 > upBound;
numOutUp = sum(isOutUp); %number of events out of bounds (up)
isNTerm = (ratio7 >= ratioNTerm) & (ratio7 <= upBound);
numNTerm = sum(isNTerm); %number of non terminal events

sortData7 = sortrows(cat(2,ratio7,data7(8:end,4:end)),1);
sortData5 = sortrows(cat(2,ratio7,data5(8:end,4:end)),1);
sortDataRed = sortrows(cat(2,ratio7,dataRed(8:end,4:end)),1);

if numTerm == 0
    avTerm7 = zeros(1,size(sortData7,2)-1);
    semTerm7 = zeros(1,size(sortData7,2)-1);
    avTerm5 = zeros(1,size(sortData5,2)-1);
    semTerm5 = zeros(1,size(sortData5,2)-1);
    avTermRed = zeros(1,size(sortDataRed,2)-1);
    semTermRed = zeros(1,size(sortDataRed,2)-1);
else
    avTerm7 = mean(sortData7(1+numOutLow:numOutLow+numTerm,2:end),1); %Why 2:end? Check asap
    semTerm7 = std(sortData7(1+numOutLow:numOutLow+numTerm,2:end),0,1)./sqrt(numTerm);
    avTerm5 = mean(sortData5(1+numOutLow:numOutLow+numTerm,2:end),1);
    semTerm5 = std(sortData5(1+numOutLow:numOutLow+numTerm,2:end),0,1)./sqrt(numTerm);
    avTermRed = mean(sortDataRed(1+numOutLow:numOutLow+numTerm,2:end),1);
    semTermRed = std(sortDataRed(1+numOutLow:numOutLow+numTerm,2:end),0,1)./sqrt(numTerm);
end

if numNTerm == 0
    avNTerm7 = zeros(1,size(sortData7,2)-1);
    semNTerm7 = zeros(1,size(sortData7,2)-1);
    avNTerm5 = zeros(1,size(sortData5,2)-1);
    semNTerm5 = zeros(1,size(sortData5,2)-1);
    avNTermRed = zeros(1,size(sortDataRed,2)-1);
    semNTermRed = zeros(1,size(sortDataRed,2)-1);
else
    avNTerm7 = mean(sortData7(end-numOutUp-numNTerm+1:end-numOutUp,2:end),1);
    semNTerm7 = std(sortData7(end-numOutUp-numNTerm+1:end-numOutUp,2:end),0,1)./sqrt(numNTerm);
    avNTerm5 = mean(sortData5(end-numOutUp-numNTerm+1:end-numOutUp,2:end),1);
    semNTerm5 = std(sortData5(end-numOutUp-numNTerm+1:end-numOutUp,2:end),0,1)./sqrt(numNTerm);
    avNTermRed = mean(sortDataRed(end-numOutUp-numNTerm+1:end-numOutUp,2:end),1);
    semNTermRed = std(sortDataRed(end-numOutUp-numNTerm+1:end-numOutUp,2:end),0,1)./sqrt(numNTerm);
end
timeRed = dataRed(3,4:end);
time5 = data5(3,4:end).*time_int;
if ~(mod(dataRed(3,4),4)) %equivalent to 'if first frame is at pH 7'
    time7 = dataRed(3,4:2:end);
else
    time7 = dataRed(3,5:2:end);
end

cellName = sheets{deint}(1:end-6);
cellNum = sheets{deint}(1:4);
prot = sheets{deint}(6:8);

figure('name',cellName)
errorbar(timeRed,avTermRed,semTermRed,'-or','markerfacecolor','r')
hold on
errorbar(timeRed,avNTermRed,semNTermRed,'-om','markerfacecolor','m')
line([0 0],ylim)
xlabel('time (s)')
ylabel('average fluo')
title(['cell #  ',cellNum,' ',prot,' tnt'])
hold off

figure('name',[cellNum,' ',rcp,'7 tnt'])
errorbar(time7,avTerm7,semTerm7,'-og','markerfacecolor','g')
hold on
errorbar(time7,avNTerm7,semNTerm7,'-oc','markerfacecolor','c')
line([0 0],ylim)
xlabel('time (s)')
ylabel('average fluo')
title(['cell #  ',cellNum,' ',rcp,'7 tnt'])
hold off

figure('name',[cellNum,' ',rcp,'5 tnt'])
errorbar(time5,avTerm5,semTerm5,'-og','markerfacecolor','g')
hold on
errorbar(time5,avNTerm5,semNTerm5,'-oc','markerfacecolor','c')
line([0 0],ylim)
xlabel('time (s)')
ylabel('average fluo')
title(['cell #  ',cellNum,' ',rcp,'5 tnt'])
hold off

ratio7cell = num2cell(ratio7);
ratio7cell = cat(1,{['ratio ',rcp,'7']},ratio7cell);
xlswrite([p,f],ratio7cell,sheets{gre7},'B9')

cellAv = cell(size(timeRed,2)+6,30);

cellAv{1,1} = 'Average fluorescence data: total, terminal, non terminal';
cellAv{1,9} = date;
cellAv{2,1} = ['ratio ',rcp,'7'];
cellAv(2,3:7) = {'fr start','fr end','nFrame','ratio NTerm','ratio Term'};
cellAv(3,3:7) = num2cell([firstStart,firstEnd,nFr,ratioNTerm,ratioTerm]);
%red data
cellAv{5,2} = [prot,' total'];
cellAv{5,5} = [prot,' non terminal'];
cellAv{5,8} = [prot,' terminal'];
hd = {'average','sem','N'};
cellAv{6,1} = 'time';
cellAv(6,2:10) = [hd,hd,hd];

cellAv(7:end,1:3) = num2cell(dataRed(3:5,4:end)');
cellAv(7,4) = num2cell(numEv);
cellAv(7:end,5:6) = num2cell([avNTermRed;semNTermRed]');
cellAv(7,7) = num2cell(numNTerm);
cellAv(7:end,8:9) = num2cell([avTermRed;semTermRed]');
cellAv(7,10) = num2cell(numTerm);

%TfR7 data
cellAv{5,12} = [rcp,'7 total'];
cellAv{5,15} = [rcp,'7 non terminal'];
cellAv{5,18} = [rcp,'7 terminal'];
cellAv{6,11} = 'time';
cellAv(6,12:20) = [hd,hd,hd];

cellAv(7:6+size(time7,2),11:13) = num2cell([time7;data7(4:5,4:end)]');
cellAv(7,14) = num2cell(numEv);
cellAv(7:6+size(time7,2),15:16) = num2cell([avNTerm7;semNTerm7]');
cellAv(7,17) = num2cell(numNTerm);
cellAv(7:6+size(time7,2),18:19) = num2cell([avTerm7;semTerm7]');
cellAv(7,20) = num2cell(numTerm);

%TfR5 data
cellAv{5,22} = [rcp,'5 total'];
cellAv{5,25} = [rcp,'5 non terminal'];
cellAv{5,28} = [rcp,'5 terminal'];
cellAv{6,21} = 'time';
cellAv(6,22:30) = [hd,hd,hd];

cellAv(7:6+size(time5,2),21:23) = num2cell([time5;data5(4:5,4:end)]');
cellAv(7,24) = num2cell(numEv);
cellAv(7:6+size(time5,2),25:26) = num2cell([avNTerm5;semNTerm5]');
cellAv(7,27) = num2cell(numNTerm);
cellAv(7:6+size(time7,2),28:29) = num2cell([avTerm5;semTerm5]');
cellAv(7,30) = num2cell(numTerm);

warning off MATLAB:xlswrite:AddSheet
xlswrite([p,f],cellAv,[cellNum,'_averages'])