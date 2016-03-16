function normFreq

[f1,p1] = uigetfile('*.xlsx','Data file with freq data');
if ~f1,return,end

%cellNum = f(1:(strfind(f,'_')-1));
%if isempty(cellNum)
%    cellNum = f(1:4);
%end

% creates a matrix with the cumulated freqency in the first row
% (1,2,3,4,...) and the associated event number in the second

data = xlsread([p1,f1],'Freq');
[num,txt,raw] = xlsread([p1,f1],'Freq');
file = raw(2,1);

disp(file);

isntEv = isnan(data(6:end,2));
[mEv,iEv] = max(isntEv);
nbEv1 = iEv-1; 
ev1 = [data(6:nbEv1+5,2),data(6:nbEv1+5,4)];

binEv1 = [6:70;zeros(1,65)]';
for j=1:65
    isframe = ev1(:,1)==binEv1(j);
    if max(isframe)
        isLast = isframe.*ev1(:,2);
        [m,i] = max(isLast);
        binEv1(j,2) = ev1(i,2);
    else
        if j > 1
            binEv1(j,2) = binEv1(j-1,2);
        end
    end
end

binEv1(:,2) = (100/nbEv1).*binEv1(:,2);

%Normalisation of second recording

isntEv = isnan(data(6:end,9));
[mEv,iEv] = max(isntEv);
if mEv > 0
    nbEv2 = iEv-1; 
else
    nbEv2 = size(data,1)-5;
end

ev2 = [data(6:nbEv2+5,9),data(6:nbEv2+5,11)];

binEv2 = [6:145;zeros(1,140)]';
for j=1:140
    isframe = ev2(:,1)==binEv2(j);
    if max(isframe)
        isLast = isframe.*ev2(:,2);
        [m,i] = max(isLast);
        binEv2(j,2) = ev2(i,2);
    else
        if j > 1
            binEv2(j,2) = binEv2(j-1,2);
        end
    end
end

binEv2(:,2) = (100/nbEv1).*binEv2(:,2);

figure,plot(binEv1(:,1),binEv1(:,2),binEv2(:,1),binEv2(:,2))

Header1 = cell(4,3);
Header1{1,1} = 'Normalised Freq data';
%Header2 = Header1;
Header1{1,3} = date;
Header1{2,1} = 'First file';
Header1(4,:) = {'frame','cumulFreq',''};









    






