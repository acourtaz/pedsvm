function sortEventsMo(action)

%Sorts the event coordinates into two regions

%%% Modifs Mo

if nargin == 0
    [f,p,fi] = uigetfile('*.txt;*.trc','File with matrix of events');
    if ~f
        return
    else
        events = dlmread([p,f],'\t');
    end
    [fm,pm,fim] = uigetfile('*.txt;*.tif','Mask file');
    if ~fm,return,end
    isTxt = strfind(fm(end-4:end), 'txt');
    isTif = strfind(fm(end-4:end), 'tif');
    if isTxt
        mask = dlmread([pm,fm],'\t');
    elseif isTif
        mask = imread([pm,fm]);
    end
%elseif nargin == 2
%    events = dlmread(varargin{1},'\t');
%    fm = varagin{2};
%    mask = dlmread(varargin{2},'\t');
h = figure('name',fm);
set(h,'colormap',gray(4))
image(mask,'cdatamapping','scaled')
axis image

line(events(:,3),events(:,4),'lineStyle','none','marker','o',...
    'markerEdgeColor','r', 'markerFaceColor','r')
uicontrol('string','Create ROI','position',[15,300,70,15],...
    'callback','sortEventsMo createROI','userdata',[],'tag','createROI')
uicontrol('string','Load ROI','position',[15,280,70,15],...
    'callback','sortEventsMo loadROI','tag','events','userdata',events)
uicontrol('string','Save ROI','position',[15,260,70,15],...
    'callback','sortEventsMo saveROI','tag','mask','userdata',mask)
uicontrol('string','Sort Events','position',[15,220,70,15],...
    'callback','sortEventsMo sortNOW','tag','sortNOW','userdata',{f,fm})
%to try (13/12/13) Mo
% uicontrol('string','Add Events','position',[15,180,70,15],...
%     'callback','sortEventsMo adEvs','tag','adEvs')

else
    eval(action)
end


%[ROI,x,y] = roipoly;
%line('Xdata',x,'Ydata',y,'color','g')



% for i = 1:size(events,1)
%     xi = round(events(i,3));
%     yi = round(events(i,4));
%     if ROI(yi,xi) == 1 && mask(yi,xi) == 1
%         ev1 = cat(1,ev1,events(i,:));
%     elseif ROI(yi,xi) == 0 && mask(yi,xi) == 1
%         ev2 = cat(1,ev2,events(i,:));
%     else
%         ev3 = cat(1,ev3,events(i,:));
%     end
% end

function createROI
children = get(gcf,'children');
%delete(findobj(children,'type','line','color','g'))

[ROI,x,y] = roipoly;
line('Xdata',x,'Ydata',y,'color','g')
ROIxy = {ROI,x,y};
set(findobj(children,'tag','createROI'),'userdata',ROIxy)

function loadROI
children = get(gcf,'children');
mask = get(findobj(children,'tag','mask'),'userdata');
[fxy,pxy] = uigetfile('*.txt','ROI polygon file');
polyXY = dlmread([pxy,fxy],'\t');
x = polyXY(:,1);
y = polyXY(:,2);
ROI = poly2mask(x,y,size(mask,1),size(mask,2));
delete(findobj(children,'type','line','color','g'))
line('Xdata',x,'Ydata',y,'color','g')
ROIxy = {ROI,x,y};
set(findobj(children,'tag','createROI'),'userdata',ROIxy)

function saveROI
children = get(gcf,'children');
ROIxy = get(findobj(children,'tag','createROI'),'userdata');
fnames = get(findobj(children,'tag','sortNOW'),'userdata');
f = fnames{1};
c = strfind(f,'_'); 
if ~isempty(c)
    c = c(1)-1;
else
    c = size(f,2)-4;
end
x = ROIxy{2};
y = ROIxy{3};
polyXY = cat(2,x,y);
[fs,ps] = uiputfile('*.txt','ROI polygon',[f(1:c),'_poly.txt']);
if ischar(fs)&&ischar(ps)
   dlmwrite([ps,fs],polyXY,'\t')
end

%
% function adEvs
% [f,p,fi] = uigetfile('*.txt;*.trc','File with matrix of events');
%     if ~f
%         return
%     else


function sortNOW
children = get(gcf,'children');
ROIxy = get(findobj(children,'tag','createROI'),'userdata');
mask = get(findobj(children,'tag','mask'),'userdata');
isCheck = 0; 
if isempty(ROIxy)
    m = size(mask);
    [ROI,x,y] = roipoly(ones(m),[1,1,m(2),m(2)],[1, m(1), m(1),1]); 
    ROIxy = {ROI,x,y};
    line('Xdata',x,'Ydata',y,'color','g')
    isCheck = 1; 
end
fnames = get(findobj(children,'tag','sortNOW'),'userdata');
events = get(findobj(children,'tag','events'),'userdata');
mask = get(findobj(children,'tag','mask'),'userdata');
f = fnames{1};
fm = fnames{2};
ROI = ROIxy{1};

ev1 = []; %events with whole track inside ROI and mask (cell of interest)
ev2 = []; %events with part of track outside ROI but in mask (2nd cell)
ev3 = []; %events outside mask
n1 = 0;
n2 = 0;
n3 = 0;

firstEvent = round(events(1,1));
lastEvent = round(events(end,1));

for i = firstEvent:lastEvent
    
    eventTrack = (events(:,1) == i);
    [u, start] = max(eventTrack);
    eventLength = sum(eventTrack);
    %sumEvent = 0;
    
    if u
        
        trXY = round(events(start:start+eventLength-1,3:4));
        evInMask = 1;
        evInROIandMask = 1;
        for j = 1:eventLength
            evInMask = evInMask & mask(trXY(j,2),trXY(j,1));
            evInROIandMask = evInROIandMask & ROI(trXY(j,2),trXY(j,1)) & mask(trXY(j,2),trXY(j,1));
        end
        %evInROIandMask = ROI(trXY(:,2),trXY(:,1)) & mask(trXY(:,2),trXY(:,1));
        %evInMask = mask(trXY(:,2),trXY(:,1));
        if evInROIandMask
            ev1 = cat(1,ev1,events(start:start+eventLength-1,:));  
            n1 = n1+1;
        elseif evInMask
            ev2 = cat(1,ev2,events(start:start+eventLength-1,:));
            n2 = n2+1;
        else
            ev3 = cat(1,ev3,events(start:start+eventLength-1,:));
            n3 = n3+1;
        end
    end
end

line(ev1(:,3),ev1(:,4),'lineStyle','none','marker','*',...
      'markerEdgeColor','c')
if ~isempty(ev2)
    line(ev2(:,3),ev2(:,4),'lineStyle','none','marker','*',...
        'markerEdgeColor','b')
end

if ~isCheck
    disp('Quantification was done on ROI')
    [f1,p1] = uiputfile([f(1:end-4),'_ROI',f(end-3:end)],'Event file within ROI');
    if ischar(f1)&&ischar(p1)
      dlmwrite([p1,f1],ev1,'\t')
    end

    [f2,p2] = uiputfile([f(1:end-4),'_nROI',f(end-3:end)],'Event file outside ROI');
    if ischar(f2)&&ischar(p2)
       dlmwrite([p2,f2],ev2,'\t')
    end

    ROImask = ROI.*mask;
    ROImask = (ROImask == 1);
    [fr,pr] = uiputfile([fm(1:end-4),'_ROI',fm(end-3:end)],'mask within ROI');
    if ischar(fr)&&ischar(pr)
        if strfind(fm(end-4:end), 'txt')
            dlmwrite([pr,fr],ROImask,'\t')
        elseif strfind(fm(end-4:end), 'tif')
            imwrite(ROImask,[pr,fr])
        end
    end

    nROImask = mask-ROImask;
    nROImask = (nROImask == 1);
    [fnr,pnr] = uiputfile([fm(1:end-4),'_nROI',fm(end-3:end)],'mask outside of ROI');
    if ischar(fnr)&&ischar(pnr)
        if strfind(fm(end-4:end), 'txt')
            dlmwrite([pnr,fnr],nROImask,'\t')
        elseif strfind(fm(end-4:end), 'tif')
            imwrite(nROImask,[pnr,fnr])
        end
    end
else disp('Quantification was done on whole image')
end

  
disp(['Events in ROI:       ',num2str(n1)])
disp(['Events outside ROI:  ',num2str(n2)])
disp(['Events outside mask: ',num2str(n3)])



