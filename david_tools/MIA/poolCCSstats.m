function poolCCSstats

% written by Mo 02/09/2013
% Pools data from CCSstats
% Average * CCS lifetime in frames
%         * nb of events per CCS
%         * nb of frames between initiation of CCS & 1st event
%         * nb of frames between last event and disappearence of CCS
%         * nb of frames bewtween events of a given CCS

list_files = dir;
nbFiles = size(list_files,1);
avStats = []; avI = [];

for i = 1:nbFiles
    f = list_files(i).name;
    if ~isempty(strfind(f,'xls'));
        [type,sheets] = xlsfinfo(f);
        for j=1:size(sheets,2)
            if ~isempty(strfind(sheets{j},'stats'))
                nStats = j;
            end
        end
        if ~(nStats)
            error(['missing sheet in file: ',f])
        end
        
        [dataStats,textStats] = xlsread(f,sheets{nStats},'A5:C9');
        
        avStats = cat(2,avStats,dataStats(1:4));
        if size(dataStats,1) > 4 % if there are CCSs with more than 1 ev
            avI = cat(2,avI,dataStats(5));
        end
    end   
end
       
avStats = cat(1,mean(avStats,2),mean(avI,2));
toWrite = cat(2,cell(textStats),num2cell(avStats));
h = cell(2,2);
h{1,1} = ['Mean values (n=',num2str(nbFiles),')'];
toWrite = cat(1,h,toWrite);
[f1,p1] = uiputfile('pooledCCSstats.xlsx',...
      'Where to put the CCS stats file?');
if ischar(f1) && ischar(p1)
   warning off MATLAB:xlswrite:AddSheet
   xlswrite([p1,f1],toWrite,'pooledCCSstats')
end

end











% [fev,pev] = uigetfile('*.txt;*.trc','File with matrix of events');
%     if ~fev,return,end
%     events = dlmread([pev,fev],'\t');
%     [fCCS,pCCS] = uigetfile('*.txt;*.trc','File with tracked CCS (MIA)');
%     if ~fCCS,return,end
%     CCS = dlmread([pCCS,fCCS],'\t');
%     
% c = strfind(fev,'_');
% if isempty(c)
%     c = 5;
% else c = c(1)-1;
% end
% cellNum = num2str(fev(1:c));
% 
%     
% events = ev2CCS(events,CCS);
% 
% %  from startEvents.m
% 
% CCSstart = [];
% 
% firstEvent = round(CCS(2,1));
% lastEvent = round(CCS(end,1));
% for i=firstEvent:lastEvent
%     eventTrack = (CCS(:,1)==i);
%     [u,start] = max(eventTrack);
%     if u
%         if CCS(1,1)==0
%             CCSstart = cat(1,CCSstart,CCS(start+1,:));
%         else
%             CCSstart = cat(1,CCSstart,CCS(start,:));
%         end
%     end
% end
% 
% % CCSo = CCS statistics output matrix to build
% 
% CCSo = CCSstart(:,1:2); 
% nbCCS = size(CCSo,1);
% I_start = zeros(nbCCS,1);
% I_end = zeros(nbCCS,1);
% I=[];
% 
% for i=1:nbCCS
%     LT(i,1) = sum(CCS(:,1) == CCSo(i,1)); % LifeTime 
%     isEv = events(:,5) == CCSo(i,1);
%     evPerCCS(i,1) = sum(isEv);
%     if sum(isEv)
%         isEv_ind = find(isEv); % indexes of events appearing at CCS i
%         I_start(i,1) = events(isEv_ind(1),2) - CCSstart(i,2);
%         I_end(i,1) = (CCSstart(i,2)+LT(i,1)-1) - events(isEv_ind(end),2);
%         if sum(isEv) > 1
%             j=2;
%             while j <= sum(isEv)
%                 I(i,j-1) = events(isEv_ind(j),2) - events(isEv_ind(j-1),2);
%                 j=j+1;
%             end
%         end
%     end
% end
%           
% CCSo = cat(2,CCSo,LT,evPerCCS,I_start,I_end);
% if ~isempty(I)
%     I = cat(1,I,zeros((size(CCSo,1)-size(I,1)),size(I,2)));
%     CCSo = cat(2,CCSo,I);
% end
% 
% % Writes the results in Excel
% 
% Header = cell(11,size(CCSo,2));
% Header{1,1} = 'CCS stats';
% Header{2,1} = fev;
% Header{1,3} = date;
% Header{2,3} = fCCS;
% Header{4,1} = 'mean values :';
% Header{5,1} = 'Lifetime :';
% Header{5,3} = mean(LT(~~LT)); % mean of only non 0 values
% Header{5,4} = 'fr';
% Header{6,1} = 'nb of events / CCS :';
% Header{6,3} = mean(evPerCCS(~~evPerCCS));
% Header{6,4} = 'ev/CCS';
% Header{7,1} = 'start to 1st event :';
% Header{7,3} = mean(I_start(~~I_start));
% Header{7,4} = Header{5,4};
% Header{8,1} = 'last event to end :';
% Header{8,3} = mean(I_end(~~I_end));
% Header{8,4} = Header{5,4};
% 
% if ~isempty(I)
%     Header{9,1} = 'between 2 events :';
%     Header{9,3} = mean(mean(I(~~I)));
%     Header{9,4} = Header{5,4};
% end
% Header(11,1:6) = {'# CCS','frame','Lifetime','ev/CCS','I_start','I_end'};
% if ~isempty(I)
%     for i = 1:size(I,2)
%         Header{11,6+i} = ['I',num2str(i)];
%     end
% end
% 
% % Removes the zeros from CCSo
% 
% CCSo2 = cell(size(CCSo,1),size(CCSo,2));
% for i = 1:size(CCSo,1)*size(CCSo,2)
%     if CCSo(i) 
%         CCSo2{i} = CCSo(i);
%     else CCSo2{i} = ' ';
%     end
% end    
%     
% toWrite = cat(1,Header,CCSo2);
% [f1,p1] = uiputfile([cellNum,'_CCSstats.xlsx'],...
%       'Where to put the CCS stats file?');
% 
% if ischar(f1) && ischar(p1)
%    warning off MATLAB:xlswrite:AddSheet
%    xlswrite([p1,f1],toWrite,'CCSstats')
% end



