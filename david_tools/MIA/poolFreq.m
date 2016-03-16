function poolFreq

%Pools excel normalised frequency files from cells transfected with the
%same construct and normalised at the same time point
%Written 08/10 2012 by Mo
%IMPORTANT: for the function to work, put the Matlab directory in the
%correct directory, with the frequency files needed, and only them

list_files = dir;
nbFiles = size(list_files,1);
nFreq = []; poolCAR = []; poolWCR = [] ; header = cell(1,2) ; nTime = 1;

for i = 1:nbFiles
    %Pools the data files in a spreadsheet
    f = list_files(i).name;
    if ~isempty(strfind(f,'xls'));
        [type,sheets] = xlsfinfo(f);
        for j=1:size(sheets,2)
            if ~isempty(strfind(sheets{j},'Norm'))
                nFreq = j;
            end
        end
        if ~(nFreq)
            error(['The normalised frequency sheet is missing in: ',f])
        end
        cellNum = list_files(i).name(1:5);
        [dataFreq,textFreq] = xlsread(f,sheets{nFreq});
        nTime = cat(2,nTime,dataFreq(1,3)); % time of normalisation
        testNorm = nTime == nTime(1,1);
        goodNorm = sum(testNorm,2); % 1 if all files normalised
        % at the same timepoint
        if ~(goodNorm)
            error('All files have not been normalised at the same timepoint')
        end

        [m1,n1]=max(dataFreq(4:end,1));
        n1=n1+3;
        dataCAR = dataFreq(4:n1,1:3); %cell attached recording data
        if size(poolCAR,1)<size(dataCAR,1)
            header(1,1:2) = textFreq(6,1:2);
            poolCAR(size(poolCAR,1)+1:size(dataCAR,1),:) = NaN;
            poolCAR(:,1:2) = dataCAR(:,1:2);
        else
            dataCAR(size(dataCAR,1)+1:size(poolCAR,1),:) = NaN;
        end

        header{1,i} = cellNum;
        poolCAR(:,i) = dataCAR(:,3);
        
        if size(dataFreq,2)>3
            [m2,n2]=max(dataFreq(4:end,5));
            n2=n2+3;
            dataWCR = dataFreq(4:n2,5:7); %whole cell recording data
            if size(poolWCR,1)<size(dataWCR,1)
                poolWCR(size(poolWCR,1)+1:size(dataWCR,1),:) = NaN;
                poolWCR(:,1:2) = dataWCR(:,1:2);
            else
                dataWCR(size(dataWCR,1)+1:size(poolWCR,1),:) = NaN;
            end
            poolWCR(:,i) = dataWCR(:,3);
        end
    end
end

% calculates the mean frequency of the pooled files

avCAR=[]; semCAR=[];
for i=1:size(poolCAR,1)
    vect = poolCAR(i,3:end);
    vect = vect(~isnan(vect)); %removes NaN from vector vect
    avCAR = cat(1,avCAR,mean(vect));
    semCAR = cat(1,semCAR,std(vect)/sqrt(length(vect)));
end
poolCAR = cat(2,poolCAR,avCAR,semCAR);

if ~isempty(poolWCR)
 avWCR=[]; semWCR=[];
    for i=1:size(poolWCR,1)
        vect = poolWCR(i,3:end);
        vect = vect(~isnan(vect)); %removes NaN from vector vect
        avWCR = cat(1,avWCR,mean(vect));
        semWCR = cat(1,semWCR,std(vect)/sqrt(length(vect)));
    end
    poolWCR = cat(2,poolWCR,avWCR,semWCR);
end

% plots the averages

hFreq = figure('name','pooledFreq ');
plot(poolCAR(:,2),poolCAR(:,size(poolCAR,2)-1),'color','r','linewidth',2)
if~isempty(poolWCR)
    hold on
    plot(poolWCR(:,2),poolWCR(:,size(poolWCR,2)-1),'color','b','linewidth',2)
end
[fpool,ppool] = uiputfile('PooledFreq.fig','save figure');
if ischar(fpool)&& ischar(ppool)
    saveas(hFreq,[ppool,fpool])
end
  
% writes the xls file

header = cat(2,header,'mean','sem');
h1 = cell(2,size(header,2));
h1(1,1)={'CA'};
poolCAR = cat(1,h1,header,num2cell(poolCAR));

if~isempty(poolWCR)
    h2 = cell(3,size(header,2));
    h2(2,1)={'WCR'};
    poolWCR = cat(1,h2,header,num2cell(poolWCR));
    towrite = cat(1,poolCAR,poolWCR);
else towrite = poolCAR;
end

warning off MATLAB:xlswrite:AddSheet
xlswrite([fpool(1:end-4),'.xlsx'],towrite);

%%%%%%