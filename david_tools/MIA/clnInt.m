% Cuts cln_start.trc files into new (shorter) cln_start.trc files according to
% conditions before during and after application (of isoproterenol, NMDA etc...)


% [f,p] = uigetfile('*.txt;*.trc','File with start matrix of events');
% if ~f,return,end
% ev = dlmread([p,f],'\t');
% 
% 

%[ffull,pfull] = uigetfile('*.txt;*.trc','File with corresponding full matrix of events');
[ffull,pfull] = uigetfile('*.txt;*.trc','File with matrix of events');
if ~ffull,return,end
evfull = dlmread([pfull,ffull],'\t');
fEvfull = ffull(1:size(ffull,2)-4);

% taken from startEvents

if evfull(1,1) == 0
    firstEvent = round(evfull(2,1));
else
    firstEvent = round(evfull(1,1));
end
lastEvent = round(evfull(end,1));
ev=[];
for i=firstEvent:lastEvent
    eventTrack = (evfull(:,1)==i);
    [u,start] = max(eventTrack);
    if u
        if evfull(1,1)==0
            ev = cat(1,ev,evfull(start+1,:));
        else
            ev = cat(1,ev,evfull(start,:));
        end
    end
end

prompt = {'Nb Frames Base','Nb Frames Stim','Nb Frames Wash'};
    [B S W] = numinputdlg(prompt,'Parameters',1,[100 300 150]);

% isStart = ~isempty(strfind(f,'start'));
% if isStart
%     ev = dlmread([p,f],'\t');
%     i = find(ev(:,2) <= 50);
%     j = find(ev(:,2) >= 51 & ev(:,2)<= 200);
%     k = find(ev(:,2) >= 201 & ev(:,2)<= 275);
    i = find(ev(:,2) <= B/2);
    j = find(ev(:,2) >= (B/2+1) & ev(:,2)<= (S+B)/2);
    k = find(ev(:,2) >= ((S+B)/2+1) & ev(:,2)<= (S+B+W)/2);
    
    ev1 = ev(i,:);
    ev2 = ev(j,:);
    ev3 = ev(k,:);
    
% else disp('input must be a start.trc file')
%     return
% end


track1 = ismember(evfull(:,1),ev1(:,1));
i = find(track1);
ev1 = evfull(i,:);

track2 = ismember(evfull(:,1),ev2(:,1));
j = find(track2);
ev2 = evfull(j,:);

track3 = ismember(evfull(:,1),ev3(:,1));
k = find(track3);
ev3 = evfull(k,:);

[fev1,pev1] = uiputfile([fEvfull,'_Base.trc'],'Save file');
if ischar(fev1) && ischar(pev1)
    dlmwrite([pev1,fev1],ev1,'\t')
end

[fev2,pev2] = uiputfile([fEvfull,'_Stim.trc'],'Save file');
if ischar(fev2) && ischar(pev2)
    dlmwrite([pev2,fev2],ev2,'\t')
end

[fev3,pev3] = uiputfile([fEvfull,'_Wash.trc'],'Save file');
if ischar(fev3) && ischar(pev3)
    dlmwrite([pev3,fev3],ev3,'\t')
end

clear
