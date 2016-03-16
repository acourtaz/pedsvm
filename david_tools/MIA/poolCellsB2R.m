function poolCellsB2R

%Pools excel files from cells transfected with the same construct, both
%data files and rnd files
%Written 09/02 2009 by DP
%The files need to have the same number of randomized files (usually 200)
%IMPORTANT: for the function to work, put the Matlab directory in the
%correct directory, with the files needed, and only them
%Only works if histograms have been computed. Need to add an option???

list_files = dir;
TfR5 = []; TfR7 = []; Red = []; Histo = [];
pool5 = []; pool7 = []; poolR = []; poolH = [];
cellEvents = {'Total',0};%col1, cell #, col2 numEvents
for i = 1:size(list_files,1)
    %Pools the data files into 3 spreadsheets
    f = list_files(i).name;
    isdata = isempty(strfind(f,'rand'));
    isxls = ~isempty(strfind(f,'xls'));
    if isdata && isxls
        [type,sheets] = xlsfinfo(f);
        for j=1:size(sheets,2)
            isTfR5 = strfind(sheets{j},'B2R5');
            isTfR7 = strfind(sheets{j},'B2R7');
            isDeint = strfind(sheets{j},'deint');
            isHisto = strfind(sheets{j},'histo');
            if ~isempty(isTfR5)
                TfR5 = j;
            elseif ~isempty(isTfR7)
                TfR7 = j;
            elseif ~isempty(isDeint)
                Red = j;
                prot = sheets{j}(isDeint-4:isDeint-2);
            elseif ~isempty(isHisto)
                Histo = j;
            end
        end
        if ~(TfR5 && TfR7 && Red && Histo)
            error('One fluo measure sheet is missing')
        end
        [dataRed,textRed] = xlsread(f,sheets{Red});
        [dataTfR5,textTfR5] = xlsread(f,sheets{TfR5});
        [dataTfR7,textTfR7] = xlsread(f,sheets{TfR7});
        [dataHisto,textHisto] = xlsread(f,sheets{Histo});
        pHFirst = dataRed(1,8); %first pH, should be 7, if 5 see below
        evNum = dataRed(8:end,1);
        ratio7 = dataTfR7(8:end,2);
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
        dataTfR5 = dataTfR5(8:end,4:end);
        dataTfR7 = dataTfR7(8:end,4:end);
        dataRed = dataRed(8:end,4:end);
%if it is 5, then the first frames of dataRed and dataTfR7 are duplicated,
%and the last ones deleted. Kind of rough, but useful
        if pHFirst == 5
            dataTfR7 = dataTfR7(:,1:end-1);
            dataTfR7 = [dataTfR7(:,1),dataTfR7];
            dataRed = dataRed(:,1:end-1);
            dataRed = [dataRed(:,1),dataRed];
        end
        pipou = isempty(pool5);
        if pipou %For first file
            pool5 = [pool5;sortingEv,dataTfR5];
            pool7 = [pool7;sortingEv,dataTfR7];
            poolR = [poolR;sortingEv,dataRed];
        else
            w5 = min(size(dataTfR5,2),size(pool5,2)-4);
            w7 = min(size(dataTfR7,2),size(pool7,2)-4);
            wR = min(size(dataRed,2),size(poolR,2)-4);
            pool5 = [pool5(:,1:w5+4);sortingEv,dataTfR5(:,1:w5)];
            pool7 = [pool7(:,1:w7+4);sortingEv,dataTfR7(:,1:w7)];
            poolR = [poolR(:,1:wR+4);sortingEv,dataRed(:,1:wR)];

        end
    end
end

totEv = cellEvents{1,2};
av5 = mean(pool5(:,5:end));
sem5 =std(pool5(:,5:end))./sqrt(totEv);
av7 = mean(pool7(:,5:end));
sem7 =std(pool7(:,5:end))./sqrt(totEv);
avRed = mean(poolR(:,5:end));
semRed =std(poolR(:,5:end))./sqrt(totEv);

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
avTerm5 = mean(sortData5(1+numOutLow:1+numOutLow+numTerm,5:end));
semTerm5 = std(sortData5(1+numOutLow:1+numOutLow+numTerm,5:end))./sqrt(numTerm);
avNTerm5 = mean(sortData5(end-numOutUp-numNTerm:end-numOutUp,5:end));
semNTerm5 = std(sortData5(end-numOutUp-numNTerm:end-numOutUp,5:end))./sqrt(numNTerm);

sortData7 = sortrows(pool7,3);
avTerm7 = mean(sortData7(1+numOutLow:1+numOutLow+numTerm,5:end));
semTerm7 = std(sortData7(1+numOutLow:1+numOutLow+numTerm,5:end))./sqrt(numTerm);
avNTerm7 = mean(sortData7(end-numOutUp-numNTerm:end-numOutUp,5:end));
semNTerm7 = std(sortData7(end-numOutUp-numNTerm:end-numOutUp,5:end))./sqrt(numNTerm);
%red protein data
sortDataR = sortrows(poolR,3);
avTermR = mean(sortDataR(1+numOutLow:1+numOutLow+numTerm,5:end));
semTermR = std(sortDataR(1+numOutLow:1+numOutLow+numTerm,5:end))./sqrt(numTerm);
avNTermR = mean(sortDataR(end-numOutUp-numNTerm:end-numOutUp,5:end));
semNTermR = std(sortDataR(end-numOutUp-numNTerm:end-numOutUp,5:end))./sqrt(numNTerm);



%Pools the randomized data
TfR5 = []; TfR7 = []; Red = [];
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
        [type,sheets] = xlsfinfo(f);
        for j=1:size(sheets,2)
            isTfR5 = strfind(sheets{j},'B2R5');
            isTfR7 = strfind(sheets{j},'B2R7');
            isRed = strfind(sheets{j},prot);
            if ~isempty(isTfR5)
                TfR5 = j;
            elseif ~isempty(isTfR7)
                TfR7 = j;
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
        dataRnd5 = xlsread(f,sheets{TfR5});
        dataRnd7 = xlsread(f,sheets{TfR7});
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
%B2R5
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

%B2R7
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
xlswrite(['pooled_',prot,'.xlsx'],pool5,'B2R5 data');
xlswrite(['pooled_',prot,'.xlsx'],pool7,'B2R7 data');
if ~isempty(rndR)
    xlswrite(['Pooled_',prot,'.xlsx'],poolR,[prot,' data']);
end

[fpool,ppool] = uiputfile(['Pooled_',prot,'.fig'],'save figure');
if ischar(fpool)&& ischar(ppool)
    saveas(gcf,[ppool,fpool])
end