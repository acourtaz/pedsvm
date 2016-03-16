function gapClosing(varargin)

%Written by DP March 30th 2015
%Connects tracked objects if frames are skipped
%Makes extra lines with interpolated coordinates between missing lines

if nargin == 0
    [f,p] = uigetfile('*.txt;*.trc','File with matrix of events');
    if ~f,return,end
    events = dlmread([p,f],'\t');
    prompt = {'Maximum number of frames to skip','Maximum distance between objects'};
    [fMx,dMx] = ...
        numinputdlg(prompt,'Parameters for Gap closing',1,[2,5]);
    pause(0.1)
elseif nargin == 3
    f = varargin{1};
    events = dlmread(f,'\t');
    fMx = varargin{2}; 
    dMx = varargin{3};
end

fk = strfind(f,'_');
cellNum = f(1:fk(1)-1); %the number of the cell analysed

startEv = [];
stopEv = [];

if events(1,1) == 0
    firstEvent = round(events(2,1));
else
    firstEvent = round(events(1,1));
end
lastEvent = round(events(end,1));
%% Calculates times of start and stop events
for i=firstEvent:lastEvent
    eventTrack = (events(:,1)==i);
    [u,start] = max(eventTrack);
    lenEv = sum(eventTrack);
    if u
        if events(1,1)==0
            startEv = cat(1,startEv,events(start+1,:));
        else
            startEv = cat(1,startEv,events(start,:));
        end
        stopEv = cat(1,stopEv,events(start+lenEv-1,:));
    end
end
%stopEv = sortrows(stopEv,2);
%% 
for i = 1:size(stopEv,1)
    stEv = stopEv(i,2);
    isNewSt = (startEv(:,2) > stEv) & (startEv(:,2) <= stEv+fMx+1);
    [u,newSt] = max(isNewSt);
    nbNewSt = sum(isNewSt);
    if u
        distNst = zeros(nbNewSt,1);
        for k = 1:nbNewSt
            distNst(k) = sqrt((stopEv(i,3)-startEv(newSt+k-1,3)).^2+(stopEv(i,4)-startEv(newSt+k-1,4)).^2);
        end
        nEv = cat(2,startEv(newSt:newSt+nbNewSt-1,1:2),distNst); % A Nx3 matrix
        nEv = sortrows(nEv,[3,1,2]);
        %the first line is the start of the new event to connect 
        if nEv(1,3) < dMx
            evTrack = (events(:,1) == nEv(1,1));
            [v,start] = max(evTrack);
            lEv = sum(evTrack);
            if v
                events(start:start+lEv-1,1) = stopEv(i,1);
            end
            if nEv(1,2) > stEv+1
                ns = nEv(1,2)-stEv-1; % gap duration in frames
                addEv = zeros(ns,size(events,2));
                for j = 1:ns
                    addEv(j,1) = stopEv(i,1);
                    addEv(j,2) = stEv+j;
                    addEv(j,3) = ((ns-j+1)*stopEv(i,3)+j*events(start,3))/(ns+1);
                    addEv(j,4) = ((ns-j+1)*stopEv(i,4)+j*events(start,4))/(ns+1);
                    if size(events,2) > 4
                        addEv(j,5:end) = stopEv(i,5:end);
                    end
                end
                events = cat(1,events,addEv);
            end
                    
                    
        end
    end
end
pause(1)
events = sortrows(events,[1,2]);
%%
[fle,p] = uiputfile([cellNum,'_gc.trc']...
      ,'Where to put the event file with gap closing');
  
if ischar(fle) && ischar(p)
   dlmwrite([p,fle],events,'\t')
end