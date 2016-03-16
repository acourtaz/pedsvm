function poolCells

%Pools excel files from cells transfected with the same construct, both
%data files and rnd files
%Written 09/02 2009 by DP; updates...13/01/2016
%The files need to have the same number of randomized files (usually 200)
%IMPORTANT: for the function to work, put the Matlab directory in the
%correct directory, with the files needed, and only them
%Only works if histograms have been computed. Need to add an option???

list_files = dir;
Gre5 = []; Gre7 = []; Red = []; Histo = [];
pool5 = []; pool7 = []; poolR = []; poolH = [];
cellEvents = {'Total',0};%col1, cell #, col2 numEvents
for i = 1:size(list_files,1)
    %Pools the data files into 3 spreadsheets
    f = list_files(i).name;
    isdata = isempty(strfind(f,'rand'));
    isxls = ~isempty(strfind(f,'xls'));
    if isdata && isxls
        [~,sheets] = xlsfinfo(f);
        for j=1:size(sheets,2)
            isGre5 = [strfind(sheets{j},'TfR5'),strfind(sheets{j},'B2R5')];
            isGre7 = [strfind(sheets{j},'TfR7'),strfind(sheets{j},'B2R7')];
            isDeint = strfind(sheets{j},'deint');
            isHisto = strfind(sheets{j},'histo');
            if ~isempty(isGre5)
                Gre5 = j;
                if ~isempty(strfind(sheets{j},'TfR'))
                    rcp = 'TfR';
                elseif ~isempty(strfind(sheets{j},'B2R'))
                    rcp = 'B2R';
                end
            elseif ~isempty(isGre7)
                Gre7 = j;
            elseif ~isempty(isDeint)
                Red = j;
                prot = sheets{j}(isDeint-4:isDeint-2);
            elseif ~isempty(isHisto)
                Histo = j;
            end
        end
        if ~(Gre5 && Gre7 && Red && Histo)
            error('One fluo measure sheet is missing')
        end
        [dataRed,~] = xlsread(f,sheets{Red});
        [dataGre5,~] = xlsread(f,sheets{Gre5});
        [dataGre7,~] = xlsread(f,sheets{Gre7});
        [dataHisto,~] = xlsread(f,sheets{Histo});
        pHFirst = dataRed(1,8); %first pH, should be 7, if 5 see below
        evNum = dataRed(8:end,1);
        ratio7 = dataGre7(8:end,2);
        peaks = dataHisto(4:end,5);
        numEvents = size(dataRed,1)-7;
        c = strfind(f,'_')-1;  % modif Mo (+ see line 260)
        if isempty(c)
            c=5;
        end
        cellEvents = [cellEvents;{f(1:c(1)),numEvents}];
        cellEvents{1,2} = cellEvents{1,2} + numEvents;
%useful to find the number of events per cell for pooling randomized data
        evPool = size(pool5,1) + (1:numEvents)';
        sortingEv = [evPool,evNum,ratio7,peaks];
        dataGre5 = dataGre5(8:end,4:end);
        dataGre7 = dataGre7(8:end,4:end);
        dataRed = dataRed(8:end,4:end);
%if it is 5, then the first frames of dataRed and dataTfR7 are duplicated,
%and the last ones deleted. Kind of rough, but useful
        if pHFirst == 5
            dataGre7 = dataGre7(:,1:end-1);
            dataGre7 = [dataGre7(:,1),dataGre7];
            dataRed = dataRed(:,1:end-1);
            dataRed = [dataRed(:,1),dataRed];
        end
        pipou = isempty(pool5);
        if pipou %For first file
            pool5 = [pool5;sortingEv,dataGre5];
            pool7 = [pool7;sortingEv,dataGre7];
            poolR = [poolR;sortingEv,dataRed];
        else
            w5 = min(size(dataGre5,2),size(pool5,2)-4);
            w7 = min(size(dataGre7,2),size(pool7,2)-4);
            wR = min(size(dataRed,2),size(poolR,2)-4);
            pool5 = [pool5(:,1:w5+4);sortingEv,dataGre5(:,1:w5)];
            pool7 = [pool7(:,1:w7+4);sortingEv,dataGre7(:,1:w7)];
            poolR = [poolR(:,1:wR+4);sortingEv,dataRed(:,1:wR)];

        end
    end
end

totEv = cellEvents{1,2};
av5 = mean(pool5(:,5:end),1);
sem5 =std(pool5(:,5:end),0,1)./sqrt(totEv);
av7 = mean(pool7(:,5:end),1);
sem7 =std(pool7(:,5:end),0,1)./sqrt(totEv);
avRed = mean(poolR(:,5:end),1);
semRed =std(poolR(:,5:end),0,1)./sqrt(totEv);

%sorts the events in terminal and non-terminal, averages them
upBound = 8;
lowBound = -10;
ratioTerm = 0.4;
ratioNTerm = 0.6;
ratio7p = pool5(:,3);

isOutLow = ratio7p < lowBound;
numOutLow = sum(isOutLow); %number of events out of bounds (low)
isTerm = (ratio7p <= ratioTerm) & (ratio7p >= lowBound);
numTerm = sum(isTerm); %number of terminal events

isOutUp = ratio7p > upBound;
numOutUp = sum(isOutUp); %number of events out of bounds (up)
isNTerm = (ratio7p >= ratioNTerm) & (ratio7p <= upBound);
numNTerm = sum(isNTerm); %number of non terminal events

sortData5 = sortrows(pool5,3);
sortData7 = sortrows(pool7,3);
sortDataR = sortrows(poolR,3);

if numTerm == 0
    avTerm7 = zeros(1,size(sortData7,2)-1);
    semTerm7 = zeros(1,size(sortData7,2)-1);
    avTerm5 = zeros(1,size(sortData5,2)-1);
    semTerm5 = zeros(1,size(sortData5,2)-1);
    avTermR = zeros(1,size(sortDataR,2)-1);
    semTermR = zeros(1,size(sortDataR,2)-1);
else
    avTerm7 = mean(sortData7(1+numOutLow:numOutLow+numTerm,5:end),1);
    semTerm7 = std(sortData7(1+numOutLow:numOutLow+numTerm,5:end),0,1)./sqrt(numTerm);
    avTerm5 = mean(sortData5(1+numOutLow:numOutLow+numTerm,5:end),1);
    semTerm5 = std(sortData5(1+numOutLow:numOutLow+numTerm,5:end),0,1)./sqrt(numTerm);
    avTermR = mean(sortDataR(1+numOutLow:numOutLow+numTerm,5:end),1);
    semTermR = std(sortDataR(1+numOutLow:numOutLow+numTerm,5:end),0,1)./sqrt(numTerm);
end

if numNTerm == 0
    avNTerm7 = zeros(1,size(sortData7,2)-1);
    semNTerm7 = zeros(1,size(sortData7,2)-1);
    avNTerm5 = zeros(1,size(sortData5,2)-1);
    semNTerm5 = zeros(1,size(sortData5,2)-1);
    avNTermR = zeros(1,size(sortDataR,2)-1);
    semNTermR = zeros(1,size(sortDataR,2)-1);
else
    avNTerm7 = mean(sortData7(end-numOutUp-numNTerm+1:end-numOutUp,5:end),1);
    semNTerm7 = std(sortData7(end-numOutUp-numNTerm+1:end-numOutUp,5:end),0,1)./sqrt(numNTerm);
    avNTerm5 = mean(sortData5(end-numOutUp-numNTerm+1:end-numOutUp,5:end),1);
    semNTerm5 = std(sortData5(end-numOutUp-numNTerm+1:end-numOutUp,5:end),0,1)./sqrt(numNTerm);
    avNTermR = mean(sortDataR(end-numOutUp-numNTerm+1:end-numOutUp,5:end),1);
    semNTermR = std(sortDataR(end-numOutUp-numNTerm+1:end-numOutUp,5:end),0,1)./sqrt(numNTerm);
end




%Pools the randomized data
Gre5 = []; Gre7 = []; Red = [];
rnd5 = []; rnd7 = []; rndR = [];
for i = 1:size(list_files,1)
    f = list_files(i).name;
    c = strfind(f,'_')-1;
    if isempty(c)
        c=5;
    end
    isrnd = ~isempty(strfind(f,'rand'));
    isxls = ~isempty(strfind(f,'xls'));
    if isrnd && isxls
        [~,sheets] = xlsfinfo(f);
        for j=1:size(sheets,2)
            isGre5 = [strfind(sheets{j},'TfR5'),strfind(sheets{j},'B2R5')];
            isGre7 = [strfind(sheets{j},'TfR7'),strfind(sheets{j},'B2R7')];
            isRed = strfind(sheets{j},prot);
            if ~isempty(isGre5)
                Gre5 = j;
            elseif ~isempty(isGre7)
                Gre7 = j;
            elseif ~isempty(isRed)
                Red = j;
            end
        end
        numEvents = 0;
        for k = 1:size(cellEvents,1)
            if strcmp(f(1:c(1)),cellEvents{k,1})
                numEvents = cellEvents{k,2};
            end
        end
        if numEvents == 0
            error('Data file corresponding to rand file is missing')
        end
        dataRnd5 = xlsread(f,sheets{Gre5});
        dataRnd7 = xlsread(f,sheets{Gre7});
        dataRndR = xlsread(f,sheets{Red});
        totEv = cellEvents{1,2};
        rnd5 = cat(3,rnd5,(numEvents/totEv).*dataRnd5);
        rnd7 = cat(3,rnd7,(numEvents/totEv).*dataRnd7);
        rndR = cat(3,rndR,(numEvents/totEv).*dataRndR);
    end
end
rnd5 = sum(rnd5,3);%makes average rnd trials accross cells
rnd7 = sum(rnd7,3);
rndR = sum(rndR,3);

rnd5 = sort(rnd5);%sorts all time points to determine 95% conf
rnd7 = sort(rnd7);
rndR = sort(rndR);

nTrials = size(rnd5,1);
med = round(nTrials/2);
lo95 = round(nTrials/20)+1;
hi95 = nTrials - lo95 + 1;

rnd5lo95 = rnd5(lo95,:);
rnd5med = rnd5(med,:);
rnd5hi95 = rnd5(hi95,:);

rnd7lo95 = rnd7(lo95,:);
rnd7med = rnd7(med,:);
rnd7hi95 = rnd7(hi95,:);

if ~isempty(rndR)
    rndRlo95 = rndR(lo95,:);
    rndRmed = rndR(med,:);
    rndRhi95 = rndR(hi95,:);
end

timeRed = -82:2:80; %Lazy version of picking up the time from xls file...
time5 = -80:4:80;
time7 = -82:4:78;

%Draws figures as usual
%TfR5
figure('name',[prot,' pooled'])
subplot(2,2,3)
errorbar(time5,avNTerm5,semNTerm5,'-oc','markerfacecolor','c')
hold on
errorbar(time5,avTerm5,semTerm5,'-og','markerfacecolor','g')
plot(time5,rnd5lo95,'k','linewidth',2)
plot(time5,rnd5med,'k')
plot(time5,rnd5hi95,'k','linewidth',2)
line([0 0],ylim)
xlabel('time (s)')
ylabel('average fluo')
hold off

%TfR7
subplot(2,2,1)
errorbar(time7,avNTerm7,semNTerm7,'-oc','markerfacecolor','c')
hold on
errorbar(time7,avTerm7,semTerm7,'-og','markerfacecolor','g')
plot(time7,rnd7lo95,'k','linewidth',2)
plot(time7,rnd7med,'k')
plot(time7,rnd7hi95,'k','linewidth',2)
line([0 0],ylim)
xlabel('time (s)')
ylabel('average fluo')
hold off

%Red protein
if ~isempty(rndR)
    subplot(2,2,2)
    errorbar(timeRed,avNTermR,semNTermR,'-om','markerfacecolor','m')
    hold on
    errorbar(timeRed,avTermR,semTermR,'-or','markerfacecolor','r')
    plot(timeRed,rndRlo95,'k','linewidth',2)
    plot(timeRed,rndRmed,'k')
    plot(timeRed,rndRhi95,'k','linewidth',2)
    line([0 0],ylim)
    xlabel('time (s)')
    ylabel('corrected fluo')
    hold off
end

%Histogram of peak recruitment
[hist_max,u] = histc(pool5(:,4),timeRed);
subplot(2,2,4)
bar(timeRed,hist_max,'k')
line([0 0],ylim,'color','r')
xlabel('time of peak (s)')
ylabel('number of events')

%Header for xls spreadsheets
numCells = size(cellEvents,1)-1;
if numCells < 11
Header = cell(16,4);
else
    Header = cell(numCells + 5,4);
end
S = size(Header,1);  % modif Mo 
Header{1,1} = ['Pooled ',prot,' data'];
Header{2,1} = date;
Header(4,1:2) = {'Cells','# events'};
% numCells = size(cellEvents,1)-1;        % modifs Mo (+ see line 50)
% if numCells < 11
    Header(5:4+numCells,1:2) = cellEvents(2:end,:);
% else
    % Header(5:15,1:2) = cellEvents(2:12,:);
% end
Header{3,3} = 'Total';
Header{4,3} = cellEvents{1,2};
Header{6,3} = 'Terminal';
Header{7,3} = numTerm;
Header{9,3} = 'Non term';
Header{10,3} = numNTerm;
Header{1,4} = 'time(s)';
Header(3:4,4) = {'average';'sem'};
Header(6:7,4) = {'average';'sem'};
Header(9:10,4) = {'average';'sem'};
Header{12,3} = 'Randomized';
Header(12:14,4) = {'high95';'median';'low95'};
Header(end,1:4) = {'Pooled ev#','Event #','ratio7','time peak'};

% sh_av5 = cell(16,size(time5,2));
sh_av5 = cell(S,size(time5,2));
sh_av5(1,:) = num2cell(time5);
sh_av5(3,:) = num2cell(av5);
sh_av5(4,:) = num2cell(sem5);
sh_av5(6,:) = num2cell(avTerm5);
sh_av5(7,:) = num2cell(semTerm5);
sh_av5(9,:) = num2cell(avNTerm5);
sh_av5(10,:)= num2cell(semNTerm5);
sh_av5(12,:)= num2cell(rnd5hi95);
sh_av5(13,:)= num2cell(rnd5med);
sh_av5(14,:)= num2cell(rnd5lo95);
pool5 = num2cell(pool5);
pool5 = [Header,sh_av5;pool5];

sh_av7 = cell(S,size(time7,2));
sh_av7(1,:) = num2cell(time7);
sh_av7(3,:) = num2cell(av7);
sh_av7(4,:) = num2cell(sem7);
sh_av7(6,:) = num2cell(avTerm7);
sh_av7(7,:) = num2cell(semTerm7);
sh_av7(9,:) = num2cell(avNTerm7);
sh_av7(10,:)= num2cell(semNTerm7);
sh_av7(12,:)= num2cell(rnd7hi95);
sh_av7(13,:)= num2cell(rnd7med);
sh_av7(14,:)= num2cell(rnd7lo95);
pool7 = num2cell(pool7);
pool7 = [Header,sh_av7;pool7];

if ~isempty(rndR)
    sh_avRed = cell(S,size(timeRed,2));
    sh_avRed(1,:) = num2cell(timeRed);
    sh_avRed(3,:) = num2cell(avRed);
    sh_avRed(4,:) = num2cell(semRed);
    sh_avRed(6,:) = num2cell(avTermR);
    sh_avRed(7,:) = num2cell(semTermR);
    sh_avRed(9,:) = num2cell(avNTermR);
    sh_avRed(10,:)= num2cell(semNTermR);
    sh_avRed(12,:)= num2cell(rndRhi95);
    sh_avRed(13,:)= num2cell(rndRmed);
    sh_avRed(14,:)= num2cell(rndRlo95);
    poolR = num2cell(poolR);
    poolR = [Header,sh_avRed;poolR]; %%%or shaved???
end


warning off MATLAB:xlswrite:AddSheet
xlswrite(['pooled_',prot,'.xlsx'],pool5,[rcp,'5 data']);
xlswrite(['pooled_',prot,'.xlsx'],pool7,[rcp,'7 data']);
if ~isempty(rndR)
    xlswrite(['Pooled_',prot,'.xlsx'],poolR,[prot,' data']);
end

[fpool,ppool] = uiputfile(['Pooled_',prot,'.fig'],'save figure');
if ischar(fpool)&& ischar(ppool)
    saveas(gcf,[ppool,fpool])
end