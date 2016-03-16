function varargout = ev2evExt(varargin)

% ev2ev written by Mo 11/07/2013
% Determines the distance between events of two trc files
% ev2evExt = extention added by Mo on 03/03/2014: 
% Considers codetection of the same event in both trc files at different
% times (+/- 5 frames)

if nargin == 0
    [fev1,pev1] = uigetfile('*.txt;*.trc','File with 1st matrix of events');
    if ~fev1,return,end
    ev1 = dlmread([pev1,fev1],'\t');
    fEv1 = fev1(1:size(fev1,2)-4);
    c=strfind(fEv1,'_');
    cellNum = fEv1(1:c);
    fEv1 = fEv1(c+1:size(fev1,2)-4);
    [fEv2,pev2] = uigetfile('*.txt;*.trc','File with 2nd matrix of events');
    if ~fEv2,return,end
    ev2 = dlmread([pev2,fEv2],'\t');
    fEv2 = fEv2(c+1:size(fEv2,2)-4);
    
elseif nargin == 2
    ev1 = varargin{1};
    ev2 = varargin{2};
    
else return
    
end

MD = 5; % Max distance between events from both files

%  from startEvents.m

startEvents1 = [];
if ev1(1,1)==0
    firstEv1 = round(ev1(2,1));
else 
    firstEv1 = round(ev1(1,1));
end
lastEv1 = round(ev1(end,1));
for i=firstEv1:lastEv1
    eventTrack = (ev1(:,1)==i);
    [u,start] = max(eventTrack);
    if u
        if ev1(1,1)==0
            startEvents1 = cat(1,startEvents1,ev1(start+1,:));
        else
            startEvents1 = cat(1,startEvents1,ev1(start,:));
        end
    end
end
ev1 = startEvents1;

startEvents2 = [];
if ev2(1,1)==0
    firstEv2 = round(ev2(2,1));
else 
    firstEv2 = round(ev2(1,1));
end
lastEv2 = round(ev2(end,1));
for i=firstEv2:lastEv2
    eventTrack = (ev2(:,1)==i);
    [u,start] = max(eventTrack);
    if u
        if ev2(1,1)==0
            startEvents2 = cat(1,startEvents2,ev2(start+1,:));
        else
            startEvents2 = cat(1,startEvents2,ev2(start,:));
        end
    end
end
ev2 = startEvents2;

%

for i = 1:size(ev1,1)
    startFr = ev1(i,2);    
        j = find(ev2(:,2)>= startFr-5 & ev2(:,2)<= startFr+5); % indices for which
                                                                % an event appering in
                                                                % ev1 appears at the same +/- 5 frame in ev2
    if ~isempty(j)        
        dist = sqrt((ev2(j,3)-ev1(i,3)).^2+ (ev2(j,4)-ev1(i,4)).^2);
        [min_dist,min_ind] = min(dist);
        if min_dist < MD
            ev1(i,5) = (ev2((min_ind+j(1)-1),1))'; % nearest ev2 event nb
                                                   % to the ev1 event i
        else 
            ev1(i,5) = 0; % no event close enough to ev1 event i in ev2
        end
        ev1(i,6) = min_dist;
    else 
        ev1(i,5) = 0;
        ev1(i,6) = 500;
    end
end

noCorr = sum(~ev1(:,5));

% added 19/07/2013 ... to be tested on a cell with events with no parent
% CCS


if noCorr == 0
    disp('all events from 1st file have a corresponding event in second file (100% match)')
else if noCorr == 1
        disp(['There is ',num2str(noCorr),' event from 1st file with no corresponding event in 2nd file (',num2str((1-noCorr/size(ev1,1))*100) ,'% matched)'])
        
    else
        disp(['There are ',num2str(noCorr),' events from 1st file with no corresponding events in 2nd file (',num2str((1-noCorr/size(ev1,1))*100) ,'% matched)'])
    end
end


if nargin == 0
    
[fevSt,pevSt] = uiputfile([cellNum,'[',fEv1,']_[',fEv2,']_ExtCompare.trc'],'Save file');
if ischar(fevSt) && ischar(pevSt)
   dlmwrite([pevSt,fevSt],ev1,'\t')
end

elseif nargin == 2
    varargout{1} = ev1;
end

toPlot = sortrows(ev1,6);
toPlot = toPlot(:,6);
MD_ind = find(toPlot > MD,1,'first'); % index of first event above MD threshold
X_bMD = [1:MD_ind-1]'; % x vector below MD threshold
Y_bMD = toPlot(1:MD_ind-1,1); % y vector below MD threshold
X_aMD = [MD_ind:size(toPlot,1)]'; % x vector above MD threshold
Y_aMD = toPlot(MD_ind:size(toPlot,1),1); % y vector above MD threshold
figure 
plot(X_bMD,Y_bMD,'b')
hold on 
plot(X_aMD,Y_aMD,'r')
text(40,450,['Min distance Threshold: ',num2str(MD), ' pix'])

[fplot, pplot] = uiputfile([fevSt(1:end-4),'.fig'],'save figure');
    if ischar(fplot) && ischar(pplot)
        saveas(gcf,[pplot,fplot]);
    end 
end



