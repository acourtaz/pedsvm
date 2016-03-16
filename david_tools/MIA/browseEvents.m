function browseEvents(action)

%Written by DP 05/09/06
%This function shows 'ministacks' around events that can be selected
%or rejected

if nargin == 0
   [stk,stkd] = uigetfile('*.stk','Choose a Stack (events)');
   if ~stk,return,end
   M = stkread(stk,stkd);
   [f,p] = uigetfile('*.txt;*.trc','File with matrix of events');
   if ~f,return,end
   events = dlmread([p,f],'\t');
   [coFile,coDir] = uigetfile('*.txt','File with alignment coefficients');
   if ~coFile
       %w = warndlg('No alignment correction will be performed','Warning');
       %uiwait(w,10)
       coeff = [0 1 0 0 0 0 0 0 0 0 0 1 0 0]';
   else coeff = dlmread([coDir,coFile],'\t');
   end
   if ~(size(coeff)==[14 1]),return,end
   
%%% DEFAULT PARAMETERS FOR THE MINISTACKS %%%
   prompt = {'Size Ministack','Frames before event','Frames after start'};
   [sizeMini before after] = ...
	   numinputdlg(prompt,'Parameters for the ministacks',1,[25 20 20]);
   param = [sizeMini before after];
   
   map = gray(256);
   removed = [];
   figure('name','Browse events')
       
%controls for playing the movie
   uicontrol('string','Stop','callback','browseEvents goto',...
       'position',[20,30,45,15])
   uicontrol('callback','browseEvents fullforward','string',...
      'Play -->','position',[110,30,45,15])
   uicontrol('callback','browseEvents fullbackward','string',...
      '<-- Play','position',[65,30,45,15])
   uicontrol('style','text','position',[20,15,35,15],'string','Frame')
  
%controls for the scale that do not change with each ministack
   uicontrol('style','text','position',[210,15,30,15],'tag','low_text')
   uicontrol('style','text','position',[175,15,35,15],'string','Low')
   uicontrol('style','text','position',[210,30,30,15],'tag','high_text')
   uicontrol('style','text','position',[175,30,35,15],'string','High')
   
% controls to browse ministacks
   uicontrol('style','text','position',[20,230,70,15],'string','EVENTS',...
       'tag','param','userdata',param)
   uicontrol('callback','browseEvents previousEvent','string','PREVIOUS',...
       'position',[20,210,70,15])
   uicontrol('callback','browseEvents nextEvent','string','NEXT',...
       'position',[20,195,70,15])
   uicontrol('style','text','string','#','position',[20,180,10,15],...
       'tag','coeff','userdata',coeff)
   uicontrol('string','Go','callback','browseEvents gotoEvent',...
       'position',[70,180,20,15])
   
% controls for showing the tracked object coordinates
   uicontrol('style','checkbox','string','Track','value',0,...
       'position',[20,160,70,15],'userdata',events,'tag','trackEvents',...
       'callback','browseEvents track')
   
% controls to tag and remove ministacks
   uicontrol('callback','browseEvents loadRemoved','string','Load',...
       'position',[20,105,70,15],...
       'TooltipString',' Loads a removed event file ')
   uicontrol('callback','browseEvents saveRemoved','string','Save',...
       'position',[20,90,70,15],...
       'TooltipString',' Saves the removed event file ')   
   uicontrol('style','checkbox','callback','browseEvents removeEvent',...
       'string','Remove','value',0,...
       'position',[20,75,70,15],'userdata',removed,'tag','removedEvent')
   uicontrol('callback','browseEvents removeTRC','string','RemoveTRC',...
       'position',[20,60,70,15],...
       'tooltipstring',' Removes tagged events from trc file permanently')
%%%
   
   set(gcf,'UserData',M,'keypressfcn','browseEvents key',...
      'doublebuffer','on',...
      'colormap',map,'tag',[stkd,stk])
      %'closerequestfcn','browseEvents saveRemovedandClose')
   firstEvent = events(2,1);
   ministack(firstEvent)
   mzoom on
   pixvalm
   scale
   goto
else
    eval(action)
end

function ministack(numEv)
children = get(gcf,'children');
M = get(gcf,'userdata');
events = get(findobj(children,'tag','trackEvents'),'userdata');
param = get(findobj(children,'tag','param'),'userdata');
coeff = get(findobj(children,'tag','coeff'),'userdata');
firstEvent = events(2,1);
lastEvent = events(end,1);
eventTrack = events(:,1)==numEv;
[isAnEvent,start] = max(eventTrack);

%calculates the ministack for the event
frame = round(events(start,2));
a = floor(param(1)/2);  % 12 if sizeStack=param(1)=25 %
xa = round(interPoly(events(start,3),events(start,4),coeff))+1;
ya = round(interPolx(events(start,3),events(start,4),coeff))+1;
%xa = round(events(start,4)+1);
%ya = round(events(start,3)+1);
x_mini = max(1,xa-a);
y_mini = max(1,ya-a);
x_maxi = min(size(M,1),xa+a);
y_maxi = min(size(M,2),ya+a);
t_mini = max(frame-param(2),1); %event will start at frame 21 or less%
t_maxi = min(frame+param(3),size(M,3));
Mini = M(x_mini:x_maxi,y_mini:y_maxi,t_mini:t_maxi);
    %needs to add zeros%
if xa-a < 1
    comp = zeros(1-xa+a,size(Mini,2),size(Mini,3));
    Mini = cat(1,comp,Mini);
end
if xa+a > size(M,1)
    comp = zeros(xa+a-size(M,1),size(Mini,2),size(Mini,3));
    Mini = cat(1,Mini,comp);
end
if ya-a < 1
    comp = zeros(size(Mini,1),1-ya+a,size(Mini,3));
    Mini = cat(2,comp,Mini);
end
if ya+a > size(M,2)
    comp = zeros(size(Mini,1),ya+a-size(M,2),size(Mini,3));
    Mini = cat(2,Mini,comp);
end

%checks for removed status
removedBox = findobj(gcf,'tag','removedEvent');
removedStatus = get(removedBox,'value');
removed = get(removedBox,'userdata');
tag = max(removed==numEv);
if tag>0
    set(removedBox,'value',1)
else
    set(removedBox,'value',0)
end

% sets the controls for the ministack
delete(findobj(gcf,'tag','scalelow'))
delete(findobj(gcf,'tag','scalehigh'))
delete(findobj(gcf,'tag','frame#')) 
delete(findobj(gcf,'tag','EvNumber'))
low = double(min(min(min(Mini(:,:,1:end)))));
high = double(max(max(max(Mini(:,:,1:end)))));

uicontrol('style','slider',...
      'callback','browseEvents scale',...
      'min',low,'max',high-3,...
      'value',low,...
      'position',[240,15,180,15],'tag','scalelow')
uicontrol('style','slider',...
      'callback','browseEvents scale',...
      'min',low+3,'max',high,...
      'value',high,...
      'position',[240,30,180,15],'tag','scalehigh')
uicontrol('callback','browseEvents goto',...
      'style','slider',...
      'position',[55,15,100,15],...
      'max',size(Mini,3),...
      'min',1,...
      'value',1,...
      'sliderstep',[1/(size(Mini,3)-1),10/(size(Mini,3)-1)],'tag','frame#')
uicontrol('style','edit','tag','EvNumber','string',num2str(numEv),...
       'position',[30,180,40,15])

%draws the ministack image
image(Mini(:,:,1),'cdatamapping','scaled','tag','movi')
set(gca,'clim',[low,high],'tag','moviaxis','userdata',Mini)
cellNum = get(gcf,'tag');
c = strfind(cellNum,'\');
c = c(end)+1;
h = title(['Cell ',cellNum(c:c+3),'  Event ',num2str(numEv),'  Frame # = 1'],...
    'interpreter','none');
set(h,'userdata',['Cell ',cellNum(c:c+3),'  Event ',num2str(numEv)])
axis image
pixvalm
scale

%Third order polynomials for interpolation

function u = interPolx(x,y,c)
u = c(1) + c(2).*x + c(3).*x.^2 + c(4).*x.^3 +...
   c(5).*y + c(6).*y.^2 + c(7).*y.^3;

function v = interPoly(x,y,c)
v = c(8) + c(9).*x + c(10).*x.^2 + c(11).*x.^3 +...
   c(12).*y + c(13).*y.^2 + c(14).*y.^3;

function scale
children = get(gcf,'children');
low = round(get(findobj(children,'tag','scalelow'),'value'));
high = round(get(findobj(children,'tag','scalehigh'),'value'));
minlow = get(findobj(children,'tag','scalelow'),'min');
maxhigh = get(findobj(children,'tag','scalehigh'),'max');
if high == minlow+1
   high = high +1;
end
if low == maxhigh-1
   low = low-1;
end

set(gca,'clim',[low,high])
set(findobj(children,'tag','scalelow'),'max',high-1,...
   'sliderstep',[1/(high-1-minlow),25/(high-1-minlow)],...
   'value',low)
set(findobj(children,'tag','low_text'),'string',num2str(low));
set(findobj(children,'tag','scalehigh'),'min',low+1,...
   'sliderstep',[1/(maxhigh-(low+1)),25/(maxhigh - (low+1))],...
   'value',high)
set(findobj(children,'tag','high_text'),'string',num2str(high));

function goto
children = get(gcf,'children');
Mini = get(gca,'userdata');
frame = round(get(findobj(children,'tag','frame#'),'value'));
global stop
stop = 1;
delete(findobj(get(gca,'children'),'type','line'))
trackBox = findobj(children,'tag','trackEvents');
trackStatus = get(trackBox,'value');
if trackStatus
    drawtrack
end
img = Mini(:,:,frame);
set(findobj(children,'tag','movi'),'cdata',img)
tit = get(gca,'title');
stk = get(tit,'userdata');
title([stk,' Frame # = ',num2str(frame)]);

function fullbackward
Mini = get(gca,'userdata');
children = get(gcf,'children');
current_frame = round(get(findobj(children,'tag','frame#'),'value'));
global stop
stop = 0;
nframes = size(Mini,3);
for frame = current_frame:-1:1
   if stop
      break
   end
   set(findobj(children,'type','image'),'cdata',Mini(:,:,frame))
   set(findobj(children,'tag','frame#'),'value',frame)
   drawnow
end
goto

function fullforward
Mini = get(gca,'userdata');
children = get(gcf,'children');
current_frame = round(get(findobj(children,'tag','frame#'),'value'));
global stop
stop = 0;
nframes = size(Mini,3);
for frame = current_frame:nframes
   if stop
      break
   end
   set(findobj(children,'type','image'),'cdata',Mini(:,:,frame))
   set(findobj(children,'tag','frame#'),'value',frame)
   drawnow
end
goto

function key
Mini = get(gca,'userdata');
children = get(gcf,'children');
frame = round(get(findobj(children,'tag','frame#'),'value'));
global stop
stop = 1;
if get(gcf,'currentcharacter') == '.'
   if frame < size(Mini,3)
      frame = frame+1;
   end
end
if get(gcf,'currentcharacter') == ','
   if frame>1
      frame = frame-1;
   end
end
set(findobj(children,'tag','frame#'),'value',frame)
goto

function previousEvent
children = get(gcf,'children');
M = get(gcf,'userdata');
events = get(findobj(children,'tag','trackEvents'),'userdata');
numEv = str2num(get(findobj(children,'tag','EvNumber'),'string'));
firstEvent = round(events(2,1));
isAnEvent = false;
if numEv < firstEvent
    numEv = firstEvent;
end
while ~isAnEvent & (numEv > firstEvent)
    numEv = numEv-1;
    eventTrack = events(:,1)==numEv;
    isAnEvent = max(eventTrack);
end
ministack(numEv)

function nextEvent
children = get(gcf,'children');
M = get(gcf,'userdata');
events = get(findobj(children,'tag','trackEvents'),'userdata');
numEv = str2num(get(findobj(children,'tag','EvNumber'),'string'));
lastEvent = round(events(end,1));
isAnEvent = false;
if numEv > lastEvent
    numEv = lastEvent;
end
while ~isAnEvent & (numEv < lastEvent)
    numEv = numEv+1;
    eventTrack = events(:,1)==numEv;
    isAnEvent = max(eventTrack);
end
ministack(numEv)

function gotoEvent
children = get(gcf,'children');
M = get(gcf,'userdata');
events = get(findobj(children,'tag','trackEvents'),'userdata');
numEv = str2num(get(findobj(children,'tag','EvNumber'),'string'));
firstEvent = round(events(2,1));
lastEvent = round(events(end,1));
if numEv < firstEvent
    numEv = firstEvent;
end
if numEv >= lastEvent
    numEv = lastEvent;
end
if firstEvent < numEv & numEv < lastEvent
    eventTrack = events(:,1)==numEv;
    isAnEvent = max(eventTrack);
    while ~isAnEvent & (numEv < lastEvent)
        numEv = numEv+1;
        eventTrack = events(:,1)==numEv;
        isAnEvent = max(eventTrack);
    end
end
ministack(numEv)

function track
children = get(gcf,'children');
trackBox = findobj(children,'tag','trackEvents');
trackStatus = get(trackBox,'value');
if trackStatus
    drawtrack
else
    delete(findobj(get(gca,'children'),'type','line'))
end

function drawtrack
children = get(gcf,'children');
param = get(findobj(children,'tag','param'),'userdata');
frame = round(get(findobj(children,'tag','frame#'),'value'));
events = get(findobj(children,'tag','trackEvents'),'userdata');
numEv = str2num(get(findobj(children,'tag','EvNumber'),'string'));
eventTrack = events(:,1)==numEv;
[isAnEvent,startEvent] = max(eventTrack);
if startEvent <= param(2)
    absFrame = round(frame);
else
    absFrame = round(startEvent+frame-param(2)-1);
end
if absFrame <= size(eventTrack,1)
if isAnEvent & eventTrack(absFrame)
    Mini = get(gca,'userdata');
    center = round((param(1)+1)/2); %normally 13 for a 25x25 ministack
    % local coordinates of the tracked object center
    objectX = events(absFrame,3)-round(events(startEvent,3)) + center;
    objectY = events(absFrame,4)-round(events(startEvent,4)) + center;
    line('xdata',objectX,'ydata',objectY,'linestyle','none',...
        'marker','+','markerEdgeColor','red')
end
end


function removeEvent
children = get(gcf,'children');
removedBox = findobj(children,'tag','removedEvent');
removedStatus = get(removedBox,'value');
removed = get(removedBox,'userdata');
numEv = str2num(get(findobj(children,'tag','EvNumber'),'string'));
if removedStatus
    removed = cat(1,removed,numEv);
    removed = sort(removed);
else
    tag = removed==numEv;
    [c,i] = max(tag);
    if c>0
        removed(i) = [];
    end
end  
set(removedBox,'userdata',removed)
goto

function loadRemoved
button = questdlg('Do you really want to load a removed event file?',...
    'Load removed event numbers','No');
if strcmp(button,'Yes')
    [fle,pth] = uigetfile('*.txt','File with events tagged for removal');
    if ~fle,return,end
    removed = load([pth,fle]);
    children = get(gcf,'children');
    removedBox = findobj(children,'tag','removedEvent');
    set(removedBox,'userdata',removed)
    numEv = str2num(get(findobj(children,'tag','EvNumber'),'string'));
    tag = max(removed==numEv);
    if tag>0
        set(removedBox,'value',1)
    else
        set(removedBox,'value',0)
    end
end

function saveRemoved
cellName = get(gcf,'tag');
c = strfind(cellName,'\');
c = c(end)+1;
d = strfind(cellName,'.');
d = d(end)-1;
children = get(gcf,'children');
removed = get(findobj(children,'tag','removedEvent'),'userdata');
[fle,pth] = uiputfile([cellName(c:d),'_removed.txt'],...
'Where to put the file showing removed events');
if ischar(fle)&ischar(pth)
   dlmwrite([pth,fle],removed,'\t')
end
goto

function removeTRC
button = ...
  questdlg('Do you really want to remove tagged events from the trc file?',...
  'Load removed event numbers','No');
children = get(gcf,'children');
remEvents = get(findobj(children,'tag','removedEvent'),'userdata');
events = get(findobj(children,'tag','trackEvents'),'userdata');
trackRemoved = ismember(events(:,1),remEvents);
numEv = str2num(get(findobj(children,'tag','EvNumber'),'string'));
if events(1,1) == 0
    t2 = trackRemoved(2:end);
    t2 = cat(1,t2,0);
    trackRemoved = trackRemoved + t2 > 0;
end
[i,j] = find(~trackRemoved);
newEvents = events(i,:);
cellName = get(gcf,'tag');
c = strfind(cellName,'\');
c = c(end)+1;
d = strfind(cellName,'.');
d = d(end)-1;
[fle,p] = uiputfile([cellName(c:d),'_cln_rem.trc']...
      ,'Where to put the cleaned up event file');
if ischar(fle)&ischar(p)
   dlmwrite([p,fle],newEvents,'\t')
end
events = newEvents;
removed = [];
eventTrack = events(:,1)==numEv;
isAnEvent = max(eventTrack);
if ~isAnEvent
   numEv = events(2,1);
end
set(findobj(children,'tag','trackEvents'),'userdata',events)
set(findobj(children,'tag','removedEvent'),'userdata',removed,'value',0)
ministack(numEv)

function saveRemovedandClose
cellName = get(gcf,'tag');
c = strfind(cellName,'\');
c = c(end)+1;
d = strfind(cellName,'.');
d = d(end)-1;
children = get(gcf,'children');
removed = get(findobj(children,'tag','removedEvent'),'userdata');
[fle,pth] = uiputfile([cellName(c+1:a),'_removed.txt'],...
'Where to put the file showing removed events');
if ischar(fle)&ischar(pth)
   dlmwrite([pth,fle],removed,'\t')
end
delete(gcf)