%script to pool all the averages into a single excel file

list_files = dir;
pooled5 = []; pooled7 = []; pooledR = []; 
Npooled5 = []; Npooled7 = []; NpooledR = [];
Header = {};
cellEvents = {'Total',0};%col1, cell #, col2 numEvents
for i = 1:size(list_files,1)
    %Pools the data files into 3 spreadsheets
    f = list_files(i).name;
    isxls = ~isempty(strfind(f,'xls'));
    if isxls
        [data5,text5] = xlsread(f,4);
        [data7,text7] = xlsread(f,5);
        [dataR,textR] = xlsread(f,6);
        pooled5 = [pooled5,data5(3,5:end)'];
        pooled7 = [pooled7,data7(3,5:end)'];
        pooledR = [pooledR,dataR(3,5:end)'];
        median5 = mean(data5(13,5:end),2);
        median7 = mean(data7(13,5:end),2);
        medianR = mean(dataR(13,5:end),2);
        high5 = mean(data5(12,5:end),2);
        high7 = mean(data7(12,5:end),2);
        highR = mean(dataR(12,5:end),2);
        norm5 = (data5(3,5:end)' - median5)./(high5 - median5);
        norm5 = [median5;(high5 - median5);norm5];
        norm7 = (data7(3,5:end)' - median7)./(high7 - median7);
        norm7 = [median7;(high7 - median7);norm7];
        normR = (dataR(3,5:end)' - medianR)./(highR - medianR);
        normR = [medianR;(highR - medianR);normR];
        Npooled5 = [Npooled5,norm5];
        Npooled7 = [Npooled7,norm7];
        NpooledR = [NpooledR,normR];
        prot = f(8:10);
        Header  = cat(2,Header,{prot});
    end
end

cell5 = num2cell([pooled5;Npooled5]);
cell5 = [Header;cell5];
cell7 = num2cell([pooled7;Npooled7]);
cell7 = [Header;cell7];
cellR = num2cell([pooledR;NpooledR]);
cellR = [Header;cellR];

warning off MATLAB:xlswrite:AddSheet
xlswrite(['pooled_averages.xls'],cell5,'TfR5 data');
xlswrite(['pooled_averages.xls'],cell7,'TfR7 data');
xlswrite(['pooled_averages.xls'],cellR,'Red data');

        