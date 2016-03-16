%To compile results and display frequencies for
%conditions before and after application (of isoproterenol, NMDA etc...)

list_files = dir;
%select files to analyse
for i = 1:size(list_files,1)
    f = list_files(i).name;
    isAnno = ~isempty(strfind(f,'start'));
    if isAnno
        
        events = dlmread(f,'\t');
        disp(f)
            tm1 = (events(:,2) > 0)&(events(:,2) <= 50);
            Ntm1 = sum(tm1);
            int1 = (50-0-5)*4/60; %5fr removed at the beginning for clnup
            disp(num2str(Ntm1))
            disp(num2str(Ntm1/int1))
            
            tm2 = (events(:,2) > 65)&(events(:,2) <= 200);
            Ntm2 = sum(tm2);
            int2 = (200-65)*4/60;
            disp(num2str(Ntm2))
            disp(num2str(Ntm2/int2))
            
            tm3 = (events(:,2) > 215)&(events(:,2) <= 275);
            Ntm3 = sum(tm3);      
            int3 = (275-215-5)*4/60; %5fr removed at the end for clnup
            disp(num2str(Ntm3))
            disp(num2str(Ntm3/int3))
        disp(' ')
    end
end