function sortEvents(varargin)

%Sorts the event coordinates into two regions

if nargin == 0
    [f,p,fi] = uigetfile('*.txt;*.trc','File with matrix of events');
    if ~f,return,end
    events = dlmread([p,f],'\t');
    [fm,pm,fim] = uigetfile('*mask.txt','Mask file');
    if ~fm,return,end
    mask = dlmread([pm,fm],'\t');
elseif nargin == 2
    events = dlmread(varargin{1},'\t');
    fm = varagin{2};
    mask = dlmread(varargin{2},'\t');
end

h = figure('name',fm);
set(h,'colormap',gray(4))
image(mask,'cdatamapping','scaled')
axis image

line(events(:,3),events(:,4),'lineStyle','none','marker','*',...
      'markerEdgeColor','r')

[ROI,x,y] = roipoly;
line('Xdata',x,'Ydata',y,'color','g')

ev1 = []; %events inside ROI
ev2 = []; %events outside ROI
ev3 = []; %events outside mask

for i = 1:size(events,1)
    xi = round(events(i,3));
    yi = round(events(i,4));
    if ROI(yi,xi) == 1 && mask(yi,xi) == 1
        ev1 = cat(1,ev1,events(i,:));
    elseif ROI(yi,xi) == 0 && mask(yi,xi) == 1
        ev2 = cat(1,ev2,events(i,:));
    else
        ev3 = cat(1,ev3,events(i,:));
    end
end

[f1,p1] = uiputfile([f(1:end-4),'_ROI',f(end-3:end)],'Event file within ROI');
if ischar(f1)&&ischar(p1)
   dlmwrite([p1,f1],ev1,'\t')
end

[f2,p2] = uiputfile([f(1:end-4),'_nROI',f(end-3:end)],'Event file outside ROI');
if ischar(f2)&&ischar(p2)
   dlmwrite([p2,f2],ev2,'\t')
end

ROImask = ROI.*mask;
[fr,pr] = uiputfile([fm(1:end-4),'_ROI',fm(end-3:end)],'ROI within mask');
if ischar(fr)&&ischar(pr)
   dlmwrite([pr,fr],ROImask,'\t')
end

nROImask = mask-ROImask;
[fnr,pnr] = uiputfile([fm(1:end-4),'_nROI',fm(end-3:end)],'ROI within mask');
if ischar(fnr)&&ischar(pnr)
   dlmwrite([pnr,fnr],nROImask,'\t')
end

disp(['Events outside mask: ',num2str(size(ev3,1))])
