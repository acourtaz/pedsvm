function generateRandXYfluo

%generates a range of XY coordinates shifts for randomized data sets
%that does not make the coordinates fall outside of the image and cell mask

[f,p] = uigetfile('*.txt;*.trc','File with matrix of events');
if ~f,return,end
events = dlmread([p,f],'\t');
[fmask,pmask] = uigetfile('*.txt','Mask of the cell surface');
if ~fmask
    warndlg('No mask has been selected for this randomized trial')
end
mask = dlmread([pmask,fmask]);

edge = 7; %minimum distance from edge (to have a 6 pixel annulus)
distMin = 10; %minimal distance from actual measurement point
distMax = 40; %maximal distance from actual measurement point
sizeMovie = [300,256];

%generates the event number column of the output
evNum = [];
firstEvent = round(events(2,1));
numberEvents = round(events(end,1));
for i=firstEvent:numberEvents
    eventTrack = (events(:,1)==i);
    [u,start] = max(eventTrack);
    if u
        evNum = [evNum;i];
    end
end

numberEvents = size(evNum,1);
XYshift = zeros(numberEvents,5); %columns 1,2 Xs and Ys, column 3 number of
%repetitions for the choice of Xs and Ys
%columns 4,5 shifted coordinates (start of event)
Xmax = ceil(max(events(:,3)));
Ymax = ceil(max(events(:,4)));
if isempty(mask)   %%%actually this shouldn't work!!!!! (but never used)
    mask = ones(Xmax,Ymax);
end
se = strel('disk',edge); 
erMask = imerode(mask,se);
%output = evNum;

for i = 1:numberEvents
    eventTrack = (events(:,1)==evNum(i));
    [u,st] = max(eventTrack);
    if u
        lenEv = sum(eventTrack)-1;
        bibi = 1; %condition to stay in the while loop
        trialXY = 0;
        while bibi
            theta = 2*pi*rand;
            r = distMin + distMax*rand;
            Xs = r*cos(theta);
            Ys = r*sin(theta);
        
            maxShiftX = max(events(st:st+lenEv,3));
            maxShiftY = max(events(st:st+lenEv,4));
            minShiftX = min(events(st:st+lenEv,3));
            minShiftY = min(events(st:st+lenEv,4));
if (maxShiftX+Xs<Xmax)&&(maxShiftY+Ys<Ymax)&&(minShiftX+Xs>edge)&&(minShiftY+Ys>edge)
    shiftX = round(events(st:st+lenEv,3)+Xs);
    shiftY = round(events(st:st+lenEv,4)+Ys);
    shiftraj = sparse(shiftY,shiftX,ones(lenEv+1,1),size(mask,1),size(mask,2));
    trajInMask = full(sum(sum(shiftraj.*erMask)));
    if trajInMask >= lenEv+1
        bibi = 0;
    end
end
trialXY = trialXY + 1;
        end
    end
        XYshift(i,1) = Xs;
        XYshift(i,2) = Ys;
        XYshift(i,3) = trialXY;
        XYshift(i,4) = events(st,3) + Xs;
        XYshift(i,5) = events(st,4) + Ys;
end

output = cat(2,evNum,XYshift);
figure
image(2*erMask-mask,'cdatamapping','scaled')
axis image
colormap gray(4)
for i = 1:numberEvents
line(XYshift(i,4)-XYshift(i,1),XYshift(i,5)-XYshift(i,2),'linestyle','none','marker','.')
line([XYshift(i,4),XYshift(i,4)-XYshift(i,1)],[XYshift(i,5),XYshift(i,5)-XYshift(i,2)],'color','r')
end
[fout,pout] = uiputfile([f(1:4),'_shift.txt'],'file of random shifts');
if fout
    dlmwrite([pout,fout],output,'\t')
end
%axis ij
%axis image