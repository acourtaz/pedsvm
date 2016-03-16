% Calculates correlation coefficients between SEP and pHuji (or pHoran4) intensities
% at the time of detection


[f,p] = uigetfile('*.xlsx','File with intensity data');
if ~f,return,end

SEP5 = 0;
pHu5 = 0;

[type,sheets] = xlsfinfo(f);
for j=1:size(sheets,2)
    isSEP5 = strfind(sheets{j},'TfR5');
    if isempty(isSEP5)
        isSEP5 = strfind(sheets{j},'B2R5');
    end
    ispHu5 = strfind(sheets{j},'OpH5');
    if isempty(ispHu5)
        ispHu5 = strfind(sheets{j},'SEP5');
    end
    if ~isempty(isSEP5)
        SEP5 = j;
    elseif ~isempty(ispHu5)
        pHu5 = j;
    end
end
if ~(SEP5 && pHu5)
        disp('One fluo measure sheet is missing')
end

p = strfind(sheets{pHu5},'5');
p = p(end);
enrich = sheets{pHu5}(p-3:p-1);
if isequal(enrich,'OpH') 
    detect = 'SEP'; 
else detect = 'OpH'; 
end

[dataSEP,textSEP] = xlsread(f,sheets{SEP5});
[datapHu,textpHu] = xlsread(f,sheets{pHu5});

ev = dataSEP(8:size(dataSEP,1),1);

scission = find(dataSEP(3,:)==0);
if datapHu(3,scission)~= 0
    disp('xls file has probably been modified')
    return
end

AmpSEP = dataSEP(8:size(dataSEP,1),scission);
BckgrndSEP = mean(dataSEP(8:size(dataSEP,1),scission-5:scission-1),2);
SEP = AmpSEP-BckgrndSEP;

AmppHu = datapHu(8:size(datapHu,1),scission);
BckgrndpHu = mean(datapHu(8:size(datapHu,1),scission-5:scission-1),2);
pHu = AmppHu-BckgrndpHu;

%[poly,stats] = polyfit(SEP,pHu,1);
[R,slope,offset] = regression(SEP',pHu');

disp('The regression coefficient for this dataset is: ')
disp(num2str(R*R))

Header = {' ' 'detection' 'enrichment' 'R²';'ev' detect enrich num2str(R*R)};
data = num2cell([ev SEP pHu]);
empty = cell(size(SEP,1), 1);
data = cat(2,data,empty);
toWrite = cat(1,Header,data);
c = strfind(f,'_');
c = c(1)-1;
[f2,p2] = uiputfile([f(1:c),'_AmpCorrel Raw.xlsx'],...
      'Where to put the test data file');

if ischar(f2) && ischar(p2)
   warning off MATLAB:xlswrite:AddSheet
   xlswrite([p2,f2],toWrite,'testAmpCorrel')
end

clear



        
        