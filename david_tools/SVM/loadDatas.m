function [labels, datas] = loadDatas()

    [datas, eventsID] = loadEvents();
    
    [b, bp] = uigetfile('*.trc','Load browsed events matrix');
    if ~b,return,end
    bEvents = dlmread([bp,b],'\t');
 
    browsedID = unique(bEvents(:,1));
    labels = ismember(eventsID, browsedID);
    
    if ~datas,return,end
    button = questdlg('Do you want to load one more experiment ?');
    more = strcmp(button,'Yes');
    
    while more
    [datas2, eventsID] = loadEvents();
    
    [b, bp] = uigetfile('*.trc','Load browsed events matrix');
    if ~b,return,end
    bEvents = dlmread([bp,b],'\t');
    
    browsedID = unique(bEvents(:,1));
    labels2 = ismember(eventsID, browsedID);
 
    labels = cat(1, labels, labels2);
    datas = cat(1, datas, datas2);
    
    button = questdlg('Do you want to load one more experiment ?');
    more = strcmp(button,'Yes');
    end
    
end




