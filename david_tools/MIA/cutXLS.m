function cutXLS
%this function takes an XLS file and cuts it into three news XLS files
%according to the base, stim and wash conditions

%% TO UNCOMMENT IF USED ONCE
% %ask the user for the input XLS filename
% [f1,p1] = uigetfile('*.xlsx','XLS data file to cut');
% if ~f1,return,end
% 
% %ask the user about the frame at which the cut should be done
% prompt = {'Nb Frames Base','Nb Frames Stim','Nb Frames Wash'};
% [B S W] = numinputdlg(prompt,'Parameters',1,[100 300 150]);
% B = B/2;
% S = B+S/2;
% W = S+W/2;
% 
% inputFilename = [p1,f1];


%% TO UNCOMMENT IF USED IN BATCH MODE
B=100;S=300;W=150;
B = B/2;
S = B+S/2;
W = S+W/2;

files = dir;
for i=3:length(files)
    inputFilename = files(i).name;

    cut(inputFilename, [inputFilename(1:end-5) '_Base.xlsx'],1,B);
    cut(inputFilename, [inputFilename(1:end-5) '_Stim.xlsx'],B+1,S);
    cut(inputFilename, [inputFilename(1:end-5) '_Wash.xlsx'],S+1,W);
end

%% 






function cut(inputFilename, outputFilename, firstFrame, lastFrame)

[typ, sheets] = xlsfinfo(inputFilename);

if ~strcmp(typ,'Microsoft Excel Spreadsheet')
    disp('Error, the input file is not an XLS file')
    return
end

%finding the relevant sheets
for i=1:length(sheets)
    if ~isempty(strfind(sheets{i},'browse'))
        browseInd=i;
    end
    if ~isempty(strfind(sheets{i},'Master'))
        masterInd=i;
    end
    if ~isempty(strfind(sheets{i},'Slave'))
        slaveInd=i;
    end
end

%cutting the browse summary sheet
[numBrowse,txtBrowse,rawBrowse] = xlsread(inputFilename,browseInd); %reading the sheet content
keptLines = find(numBrowse(:,2)>=firstFrame & numBrowse(:,2)<=lastFrame); %identifying the lines within the frame range
eventsToKeep = numBrowse(keptLines,1); %the list of events to keep in the other sheets
rawBrowse = rawBrowse([1;2;keptLines+2],1:8); %keeping only these lines

warning off MATLAB:xlswrite:AddSheet
xlswrite(outputFilename, rawBrowse, [sheets{browseInd} ' ' outputFilename(end-9:end-5)]); %saving them to the new XLS file

%cutting the fluo data sheets
for i=[masterInd masterInd+1 slaveInd slaveInd+1]
    %identifying the lines to keep
    [numFluo,txtFluo,rawFluo] = xlsread(inputFilename,i); %reading the sheet content
    keptLines = ismember(numFluo(8:end,1),eventsToKeep);
    numFluo = numFluo([logical(ones(7,1));keptLines],:);
    keptLines = [logical(ones(9,1));keptLines];
    rawFluo = rawFluo(keptLines,:);
    
    %re-computing the means and sem
    numFluo = numFluo(8:end,4:end);
    means = mean(numFluo);
    nb = size(numFluo,1);
    sem = std(numFluo)./sqrt(nb);
    rawFluo(6,4:end) = num2cell(means);
    rawFluo(7,4:end) = num2cell(sem);
    rawFluo(8,4:end) = num2cell(nb);    
    
    %writing the final xls file    
    warning off MATLAB:xlswrite:AddSheet
    xlswrite(outputFilename, rawFluo, [sheets{i} ' ' outputFilename(end-9:end-5)]); %saving them to the new XLS file
end
    








