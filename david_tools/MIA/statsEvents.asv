function statsEvents

%computes the statistics of candidate events and surface for each cell
list_files = dir;
stats = [];
headers = ...
    {'cellNum','objects','before','after','edges','slope','S/N','cluster','merge','candidates','#frames','surface'};
for i = 3:size(list_files,1)
    nf = list_files(i).name;
    isxls = ~isempty(strfind(nf,'.xls'));
    istxt = ~isempty(strfind(nf,'.txt'));
    if istxt %should be a mask file
        mask = dlmread(nf);
        s_mask = sum(sum(mask));
        nCell = nf(1:4);
        nCell = str2num(nCell);
        if ~isempty(stats)
            iCell = find(stats(:,1)==nCell);
            if ~isempty(iCell)
                stats(iCell,11) = s_mask;
            else
                stats = [stats;zeros(1,12)];
                stats(end,1) = nCell;
                stats(end,end) = s_mask;
            end 
        else
            stats = zeros(1,12);
            stats(1,1) = nCell;
            stats(1,end) = s_mask;
        end 
    elseif isxls %should be a data file with a summary spreadsheet
        [type,sheets] = xlsfinfo(nf);
        ssheet = [];
        for j = 1:size(sheets,2)
            isSum = strfind(sheets{j},'summary');
            isBrowse = strfind(sheets{j},'browse');
            if ~isempty(isSum)&&isempty(isBrowse)
                ssheet = j;
            end
        end
        if ~isempty(ssheet)
            [dataSum,textSum] = xlsread(nf,sheets{ssheet});
            events = dataSum(1:9,6)';
            frames = dataSum(end,10);
            events = [events,frames];
            nCell = nf(1:4);
            nCell = str2num(nCell);
            if ~isempty(stats)
                iCell = find(stats(:,1)==nCell);
                if ~isempty(iCell)
                    stats(iCell,2:11) = events;
                else
                    stats = [stats;zeros(1,12)];
                    stats(end,1) = nCell;
                    stats(end,2:11) = events;
                end 
            else
                stats = zeros(1,12);
                stats(1,1) = nCell;
                stats(1,2:11) = events;
            end
        end
    end
end
stats = num2cell(stats);
stats = [headers;stats];
warning off MATLAB:xlswrite:AddSheet
xlswrite('stats_Events.xls',stats);
                