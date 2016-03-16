
[f,p] = uigetfile('*.stk','Green movie');
[g,q] = uigetfile('*.stk','Red movie');

maskcell=dlmread(uigetfile('*.txt','Select mask'));

data = stkread(f,p);
dataR = stkread(g,q);

avdata=zeros(512);
correl=[];
infoplot=[];
for i=1:30
    avdata= avdata + double(data(:,:,i));
end

avdataR=zeros(512);
for i=1:30
    avdataR= avdataR + double(dataR(:,:,i));
end

avdata=avdata/30;
avdataR=avdataR/30;

for i=1:512
    for j=1:512
        if maskcell(i,j)~=0
            infoplot=[j,i,avdata(i,j),avdataR(i,j)];
            correl=[correl;infoplot];
        end
    end
end

legend=['x','y','Green Value','Red Value','coeff'];


regression=polyfit(correl(:,4),correl(:,3),1);
reglin=(regression(2)+correl(:,4)*regression(1));

figure
plot(correl(:,4),correl(:,3),'xk',correl(:,4),reglin,'-r');


xlswrite('regression.xls', legend, 'correlation', 'A1')
xlswrite('regression.xls', correl, 'correlation', 'A2')
xlswrite('regression.xls', regression(1), 'correlation', 'E2')
