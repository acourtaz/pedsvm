%written by Damien Jullié
%last modification xlsx on 19/09/2011

list_files = dir;
MatGreen = [];
MatRed = [];
TotEv = [];
%select files to pool
for i = 1:size(list_files,1)
    f = list_files(i).name;
    isxls = ~isempty(strfind(f,'T_rand('));
    if isxls
        [type,sheets] = xlsfinfo(f);
     %sort sheets
        for j=1:size(sheets,2)
            isGreen = strfind(sheets{j},'TfR');
            isRed = strfind(sheets{j},'Red');
            isEnv = strfind(sheets{j},'env');
            if ~isempty(isGreen)
                green = j;
                [dataGreen,textGreen] = xlsread(f,sheets{green});
                
            elseif ~isempty(isRed)
                red = j;
                [dataRed,textRed] = xlsread(f,sheets{red});
                
            elseif ~isempty(isEnv)
                Env = j;
                [dataEnv,textEnv] = xlsread(f,sheets{Env});
                
            end
        end

        Title=f(7:end);
        Redmoy = dataEnv(1,12);
        NumberEv = dataEnv (1,10);

        %ValGreen = dataGreen (:,2:end);
        %AvGreen = sum(ValGreen(1:10,:))/10;
        %AvGreen=ones(size(ValGreen,1),1)*AvGreen;
        %MaxGreen = (ValGreen(:,11)*(ones(1,size(ValGreen,2))))-AvGreen;
        %NormGreen = (ValGreen-AvGreen)./MaxGreen;

        NormRed = dataRed(:,2:end)/Redmoy;

        %PondGreen = NumberEv*NormGreen;
        PondRed = NumberEv*NormRed;

        %if isequal(MatGreen,[]);
            %MatGreen = PondGreen;
        %else
            %MatGreen = MatGreen+PondGreen;
        %end
        
        if isequal(MatRed,[]);
            MatRed = PondRed;
        else
            MatRed = MatRed+PondRed; 
        end
        
        if isequal(TotEv,[]);
            TotEv = NumberEv;
        else
        TotEv = TotEv + NumberEv;
        end
        
    end
end

PoolRed = MatRed./TotEv;
PoolRed = sort(PoolRed,1);
med = round(size(PoolRed,1)/2);
hi95 = round(size(PoolRed,1)/20)+1;
lo95 = size(PoolRed,1) - hi95 + 1;

med = PoolRed(med,:);
hi95 = PoolRed(hi95,:);
lo95 = PoolRed(lo95,:);

esp = cell(1,size(PoolRed,2)+1);

med = cat(2,'median',num2cell(med));
hi95 = cat(2,'95%',num2cell(hi95));
lo95 = cat(2,'5%',num2cell(lo95));

PoolRed = cat(2, cell(size(PoolRed,1),1),num2cell(PoolRed));
PoolRed(1,1) = {'Trials'};

Redfinal=cat(1,med,esp,hi95,esp,lo95,esp,esp,PoolRed);

xlswrite('compilation.xlsx', Redfinal,Title, 'A1')