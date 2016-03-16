function normFreqMo

% From a Freq.xls file, returns a spreadsheet with the cumulated frequency
% normalised to the event at frame 70 of cell attachd mode (100% of events)


[f1,p1] = uigetfile('*.xlsx','Data file with freq data');
if ~f1,return,end

c = strfind(f1,'_');
if isempty(c)
    c = 5;
else c = c(1)-1;
end
cellNum = num2str(f1(1:c));

%[type, sheets] = xlsfinfo(f1);

[data,file] = xlsread([p1,f1],'Freq');
file1 = file{2,1};
nbFr1 = data(2,1)-data(2,3)-data(2,4);

file2 = {};
if size(file,2) > 6
    file2 = file{2,8};
    nbFr2 = data(2,8)-data(2,10)-data(2,11);
end

isntEv = isnan(data(6:end,2));
[mEv,iEv] = max(isntEv);
if mEv > 0
    nbEv1 = iEv-1; 
else
    nbEv1 = size(data,1)-5;
end

ev1 = [data(6:nbEv1+5,2),data(6:nbEv1+5,4)];

binEv1 = 6:nbFr1+5;
binEv1 = [binEv1;(binEv1-data(2,3)).*(data(2,2)/60);zeros(1,nbFr1)]';
for j=1:nbFr1
    isframe = ev1(:,1)==binEv1(j);   
    if max(isframe)                  
        isLast = isframe.*ev1(:,2);
        [m,i] = max(isLast);
        binEv1(j,3) = ev1(i,2);
    else
        if j > 1
            binEv1(j,3) = binEv1(j-1,3);
        end
    end
end


if nbFr1 > 65
     normFr = 70;            % frame at which normalisation is done
else normFr = nbFr1+data(2,4);
end
normFrDef = num2str(normFr);

dlg_title = 'Normalisation frame';
prompt = {'frame'};
default = {normFrDef};
lines = 1;
normPpt = inputdlg(prompt,dlg_title,lines,default);
normFr = str2num(normPpt{1});

disp(['100% of events at frame ', num2str(normFr)])
coeff = binEv1((normFr-data(2,4)),3);


% if nbFr1 > 65
%       coeff = binEv1(65,3);   % freq value at frame normFr
% else  normFr = nbFr1+data(2,4);
%       coeff = binEv1(nbFr1,3);
% end

binEv1(:,3) = (100/coeff).*binEv1(:,3);

%Normalisation of second recording

binEv2 = [];
if ~isempty(file2)
    isntEv = isnan(data(6:end,9));
    [mEv,iEv] = max(isntEv);
    if mEv > 0
        nbEv2 = iEv-1;
    else
        nbEv2 = size(data,1)-5;
    end

    ev2 = [data(6:nbEv2+5,9),data(6:nbEv2+5,11)];

    binEv2 = 6:nbFr2+5;
    binEv2 = [binEv2;(binEv2-data(2,10)).*(data(2,9)/60);zeros(1,nbFr2)]';
    for j=1:nbFr2
        isframe = ev2(:,1)==binEv2(j);
        if max(isframe)
            isLast = isframe.*ev2(:,2);
            [m,i] = max(isLast);
            binEv2(j,3) = ev2(i,2);
        else
            if j > 1
                binEv2(j,3) = binEv2(j-1,3);
            end
        end
    end

    binEv2(:,3) = (100/coeff).*binEv2(:,3);
end

% Plot data

if ~isempty(file2)
    figure,plot(binEv1(:,2),binEv1(:,3),binEv2(:,2),binEv2(:,3))
else
    figure,plot(binEv1(:,2),binEv1(:,3))
end



[ffreq,pfreq] = uiputfile([cellNum,' normFreq',num2str(normFr),'.fig'],'save figure');
if ischar(ffreq)&& ischar(pfreq)
    saveas(gcf,[pfreq,ffreq])
end

Header1 = cell(6,3);
Header1{1,1} = 'Normalised Freq data';
Header1{1,3} = date;
Header1(6,:) = {'frame','Rel time','cumulFreq'};
Header1{2,1} = file1;
Header1{4,1} = coeff;
Header1{4,2} = 'ev. at frame';
Header1{4,3} = normFr;

binEv1 = num2cell(binEv1);

if ~isempty(file2)
    Header2 = Header1;
    Header2{2,1} = file2;
    binEv2 = num2cell(binEv2);
end

if size(binEv1,1) < size(binEv2,1)
    binEv1 = cat(1,binEv1,cell(size(binEv2,1)-size(binEv1,1),3));
else
    binEv2 = cat(1,binEv2,cell(size(binEv1,1)-size(binEv2,1),3));
end

binEv1 = cat(1,Header1,binEv1);

if ~isempty(file2)
    binEv2 = cat(1,Header2,binEv2);
end

if ~isempty(file2)
    toWrite = cat(2,binEv1,cell(size(binEv1,1),1),binEv2);
else
    toWrite = cat(2,binEv1,cell(size(binEv1,1),1));
end
    
warning off MATLAB:xlswrite:AddSheet
xlswrite([p1,f1],toWrite,['Norm Freq ',num2str(normFr)]);











