function playBatch2(action)

% written by DP
% last updated 01/09/06

if nargin == 0
   [stk,stkd] = uigetfile('*.stk','Choose a (mini)Stack');
   if ~stk,return,end
   frame = 1;
   M = stkread(stk,stkd);
   [f,p] = uigetfile('*.txt;*.trc','File with matrix of events');
   if ~f,return,end
   events = dlmread([p,f],'\t');
   figure('name','Browse events')
   map = gray(256);
   removed = [];
   
   %controls for playing the movie
   uicontrol('string','Stop','callback','playBatch2 goto',...
       'position',[20,30,45,15])
   uicontrol('callback','playBatch2 fullforward','string',...
      'Play -->','position',[110,30,45,15])
   uicontrol('callback','playBatch2 fullbackward','string',...
      '<-- Play','position',[65,30,45,15])
  
  %controls for the scale
   high = double(max(max(max(M(:,:,1:end)))));
   low = double(min(min(min(M(:,:,1:end)))));
   uicontrol('style','slider',...
      'callback','playBatch2 scale',...
      'min',low,'max',high-3,...
      'value',low,...
      'position',[240,15,180,15],'tag','scalelow')
   uicontrol('style','text','position',[210,15,30,15],'tag','low_text')
   uicontrol('style','text','position',[175,15,35,15],'string','Low')
   uicontrol('style','slider',...
      'callback','playBatch2 scale',...
      'min',low+3,'max',high,...
      'value',high,...
      'position',[240,30,180,15],'tag','scalehigh')
   uicontrol('style','text','position',[210,30,30,15],'tag','high_text')
   uicontrol('style','text','position',[175,30,35,15],'string','High')
   
   %controls for frame selection
   uicontrol('callback','playBatch2 goto',...
      'style','slider',...
      'position',[55,15,100,15],...
      'max',size(M,3),...
      'min',1,...
      'value',1,...
      'sliderstep',[1/(size(M,3)-1),10/(size(M,3)-1)],'tag','frame#');
   uicontrol('style','text','position',[20,15,35,15],'string','Frame')
   
   % controls specific for playBatch.m : browse ministacks
   uicontrol('style','text','position',[20,200,70,15],'string','EVENTS')
   uicontrol('callback','playBatch2 previousEvent','string','PREVIOUS',...
       'position',[20,180,70,15])
   uicontrol('callback','playBatch2 nextEvent','string','NEXT',...
       'position',[20,165,70,15])
   uicontrol('style','text','string','#','position',[20,150,10,15])
   a = strfind(stk,'_');
   a = a(size(a,2))+1;
   b = strfind(stk,'.');
   b = b(size(b,2))-1;
   uicontrol('style','edit','tag','EvNumber','string',stk(a:b),...
       'position',[30,150,40,15])
   uicontrol('string','Go','callback','playBatch2 gotoEvent',...
       'position',[70,150,20,15])
   
   % controls for showing the tracked object coordinates
   uicontrol('style','checkbox','string','Track','value',0,...
       'position',[20,130,70,15],'userdata',events,'tag','trackEvents',...
       'callback','playBatch2 track')
   
   % controls specific for playBatch2.m : tag ministacks for removal   
   uicontrol('style','checkbox','callback','playBatch2 removeEvent',...
       'string','Remove','value',0,...
       'position',[20,90,70,15],'userdata',removed,'tag','removedEvent')
   uicontrol('callback','playBatch2 loadRemoved','string','Load',...
       'position',[20,75,70,15],...
       'TooltipString',' Loads a removed event file ')
   uicontrol('callback','playBatch2 saveRemoved','string','Save',...
       'position',[20,60,70,15],...
       'TooltipString',' Saves the removed event file ')
   %%%
   
   set(gcf,'UserData',M,'keypressfcn','playBatch2 key',...
      'doublebuffer','on',...
      'colormap',map,'tag',[stkd,stk],...
      'closerequestfcn','playBatch2 saveRemovedandClose')
   image(M(:,:,frame),'cdatamapping','scaled','tag','movi')
   set(gca,'clim',[low,high],'tag','moviaxis')
   h = title([stk,' Frame # = ',num2str(frame)],'interpreter','none');
   set(h,'userdata',stk)
   mzoom on
   axis image
   pixvalm
   scale
   goto
else
   eval(action)
end

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
M = get(gcf,'userdata');
children = get(gcf,'children');
frame = round(get(findobj(children,'tag','frame#'),'value'));
global stop
stop = 1;
delete(findobj(get(gca,'children'),'type','line'))
trackBox = findobj(children,'tag','trackEvents');
trackStatus = get(trackBox,'value');
if trackStatus
    drawtrack
end
img = M(:,:,frame);
set(findobj(children,'tag','movi'),'cdata',img)
tit = get(gca,'title');
stk = get(tit,'userdata');
title([stk,' Frame # = ',num2str(frame)]);


function fullbackward
M = get(gcf,'userdata');
children = get(gcf,'children');
current_frame = round(get(findobj(children,'tag','frame#'),'value'));
global stop
stop = 0;
nframes = size(M,3);
for frame = current_frame:-1:1
   if stop
      break
   end
   set(findobj(children,'type','image'),'cdata',M(:,:,frame))
   set(findobj(children,'tag','frame#'),'value',frame)
   drawnow
end
goto

function fullforward
M = get(gcf,'userdata');
children = get(gcf,'children');
current_frame = round(get(findobj(children,'tag','frame#'),'value'));
global stop
stop = 0;
nframes = size(M,3);
for frame = current_frame:nframes
   if stop
      break
   end
   set(findobj(children,'type','image'),'cdata',M(:,:,frame))
   set(findobj(children,'tag','frame#'),'value',frame)
   drawnow
end
goto

function key
M = get(gcf,'userdata');
children = get(gcf,'children');
frame = round(get(findobj(children,'tag','frame#'),'value'));
global stop
stop = 1;
if get(gcf,'currentcharacter') == '.'
   if frame < size(M,3)
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
%finds the name of the previous event file
event = get(gcf,'tag');
a = strfind(event,'_');
a = a(size(a,2))+1;
b = strfind(event,'.');
b = b(size(b,2))-1;
numEv = str2num(event(a:b));
numEv = numEv-1;
while (numEv > 0) ...
    & (exist([event(1:a-1),num2str(numEv),event(b+1:size(event,2))]) == 0)
    numEv = numEv-1;
end
%if this is the first event of the directory, nothing happens
if numEv <= 0,return,end
%redraws in the same window the new event, starting at frame 1
event = [event(1:a-1),num2str(numEv),event(b+1:size(event,2))];
c = strfind(event,'\');
c = c(size(c,2));
stkd = event(1:c); stk = event(c+1:size(event,2));
frame = 1;
M = stkread(stk,stkd);
map = gray(256);
high = double(max(max(max(M(:,:,1:end-1)))));
low = double(min(min(min(M(:,:,1:end-1)))));
%checks wether or not this event has been tagged for removal
removedBox = findobj(gcf,'tag','removedEvent');
removedStatus = get(removedBox,'value');
removed = get(removedBox,'userdata');
tag = max(removed==numEv);
if tag>0
    set(removedBox,'value',1)
else
    set(removedBox,'value',0)
end
%sets new controls for frame # and grey scale
delete(findobj(gcf,'tag','scalelow'))
delete(findobj(gcf,'tag','scalehigh'))
delete(findobj(gcf,'tag','frame#'))
delete(findobj(gcf,'tag','EvNumber'))
uicontrol('style','slider',...
      'callback','playBatch2 scale',...
      'min',low,'max',high-3,...
      'value',low,...
      'position',[240,15,180,15],'tag','scalelow')
uicontrol('style','slider',...
      'callback','playBatch2 scale',...
      'min',low+3,'max',high,...
      'value',high,...
      'position',[240,30,180,15],'tag','scalehigh')
uicontrol('callback','playBatch2 goto','style','slider',...
      'position',[55,15,100,15],...
      'max',size(M,3),...
      'min',1,...
      'value',1,...
      'sliderstep',[1/(size(M,3)-1),10/(size(M,3)-1)],'tag','frame#')
uicontrol('style','edit','tag','EvNumber','string',num2str(numEv),...
      'position',[30,150,40,15])
set(gcf,'UserData',M,'keypressfcn','playBatch2 key','doublebuffer','on'...
      ,'colormap',map,'tag',[stkd,stk])
u = image(M(:,:,frame),'cdatamapping','scaled','tag','movi');
set(gca,'clim',[low,high],'tag','moviaxis')
h = title([stk,' Frame # = ',num2str(frame)],...
     'interpreter','none');
set(h,'userdata',stk)
mzoom on
axis image
pixvalm
scale
goto

function nextEvent
%finds the name of the next event file
children = get(gcf,'children');
tracks = get(findobj(children,'tag','trackEvents'),'userdata');
lastEvent = tracks(end,1);
event = get(gcf,'tag');
a = strfind(event,'_');
a = a(size(a,2))+1;
b = strfind(event,'.');
b = b(size(b,2))-1;
numEv = str2num(event(a:b));
numEv = numEv+1;
while (numEv < lastEvent) ...
    & (exist([event(1:a-1),num2str(numEv),event(b+1:end)]) == 0)
    numEv = numEv+1;
end
%if this is the last event of the directory, nothing happens
if numEv >= lastEvent,return,end
%redraws in the same window the new event, starting at frame 1
event = [event(1:a-1),num2str(numEv),event(b+1:end)];
c = strfind(event,'\');
c = c(size(c,2));
stkd = event(1:c); stk = event(c+1:size(event,2));
frame = 1;
M = stkread(stk,stkd);
map = gray(256);
high = double(max(max(max(M(:,:,1:end-1)))));
low = double(min(min(min(M(:,:,1:end-1)))));
%checks wether or not this event has been tagged for removal
removedBox = findobj(gcf,'tag','removedEvent');
removedStatus = get(removedBox,'value');
removed = get(removedBox,'userdata');
tag = max(removed==numEv);
if tag>0
    set(removedBox,'value',1)
else
    set(removedBox,'value',0)
end
%sets new controls for frame # and grey scale
delete(findobj(gcf,'tag','scalelow'))
delete(findobj(gcf,'tag','scalehigh'))
delete(findobj(gcf,'tag','frame#')) 
delete(findobj(gcf,'tag','EvNumber'))
uicontrol('style','slider',...
      'callback','playBatch2 scale',...
      'min',low,'max',high-3,...
      'value',low,...
      'position',[240,15,180,15],'tag','scalelow')
uicontrol('style','slider',...
      'callback','playBatch2 scale',...
      'min',low+3,'max',high,...
      'value',high,...
      'position',[240,30,180,15],'tag','scalehigh')
uicontrol('callback','playBatch2 goto','style','slider',...
      'position',[55,15,100,15],...
      'max',size(M,3),...
      'min',1,...
      'value',1,...
      'sliderstep',[1/(size(M,3)-1),10/(size(M,3)-1)],'tag','frame#')
uicontrol('style','edit','tag','EvNumber','string',num2str(numEv),...
       'position',[30,150,40,15])
set(gcf,'UserData',M,'keypressfcn','playBatch2 key','doublebuffer','on'...
      ,'colormap',map,'tag',[stkd,stk])
u = image(M(:,:,frame),'cdatamapping','scaled','tag','movi');
set(gca,'clim',[low,high],'tag','moviaxis')
h = title([stk,' Frame # = ',num2str(frame)],...
     'interpreter','none');
set(h,'userdata',stk)
mzoom on
axis image
pixvalm
scale
goto

function gotoEvent
%Shows the event listed in the edit window (tagged EvNumber)
%If the ministack does not exist, it will take the next event after the 
%selected event number. If it is after the last event, it will go to this
%last event.

children = get(gcf,'children');
tracks = get(findobj(children,'tag','trackEvents'),'userdata');
lastEvent = tracks(end,1);
event = get(gcf,'tag');
numEvInit = str2num(get(findobj(children,'tag','EvNumber'),'string'));
a = strfind(event,'_');
a = a(size(a,2));
b = strfind(event,'.');
b = b(size(b,2));
numEv = numEvInit;
while (numEv < lastEvent) ...
        & (exist([event(1:a),num2str(numEv),event(b:end)]) == 0)
    numEv = numEv+1;
end
if numEv >= lastEvent
    numEv = lastEvent;
    while (numEv > 0) ...
        & (exist([event(1:a),num2str(numEv),event(b:end)]) == 0)
        numEv = numEv-1;
    end
end
if numEv <= 0,return,end
%redraws in the same window the new event, starting at frame 1
event = [event(1:a),num2str(numEv),event(b:end)];
c = strfind(event,'\');
c = c(size(c,2));
stkd = event(1:c); stk = event(c+1:size(event,2));
frame = 1;
M = stkread(stk,stkd);
map = gray(256);
high = double(max(max(max(M(:,:,1:end-1)))));
low = double(min(min(min(M(:,:,1:end-1)))));
%checks wether or not this event has been tagged for removal
removedBox = findobj(gcf,'tag','removedEvent');
removedStatus = get(removedBox,'value');
removed = get(removedBox,'userdata');
tag = max(removed==numEv);
if tag>0
    set(removedBox,'value',1)
else
    set(removedBox,'value',0)
end
%sets new controls for frame # and grey scale
delete(findobj(gcf,'tag','scalelow'))
delete(findobj(gcf,'tag','scalehigh'))
delete(findobj(gcf,'tag','frame#')) 
delete(findobj(gcf,'tag','EvNumber'))
uicontrol('style','slider',...
      'callback','playBatch2 scale',...
      'min',low,'max',high-3,...
      'value',low,...
      'position',[240,15,180,15],'tag','scalelow')
uicontrol('style','slider',...
      'callback','playBatch2 scale',...
      'min',low+3,'max',high,...
      'value',high,...
      'position',[240,30,180,15],'tag','scalehigh')
uicontrol('callback','playBatch2 goto','style','slider',...
      'position',[55,15,100,15],...
      'max',size(M,3),...
      'min',1,...
      'value',1,...
      'sliderstep',[1/(size(M,3)-1),10/(size(M,3)-1)],'tag','frame#')
uicontrol('style','edit','tag','EvNumber','string',num2str(numEv),...
       'position',[30,150,40,15])
set(gcf,'UserData',M,'keypressfcn','playBatch2 key','doublebuffer','on'...
      ,'colormap',map,'tag',[stkd,stk])
u = image(M(:,:,frame),'cdatamapping','scaled','tag','movi');
set(gca,'clim',[low,high],'tag','moviaxis')
h = title([stk,' Frame # = ',num2str(frame)],...
     'interpreter','none');
set(h,'userdata',stk)
mzoom on
axis image
pixvalm
scale
goto

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
frame = round(get(findobj(children,'tag','frame#'),'value'));
frame = frame - 10;
% 10 represents the number of frames before the event 
% used to construct the ministacks. If this number changes, one should 
% change the number in the line above accordingly
if frame > 0
    events = get(findobj(children,'tag','trackEvents'),'userdata');
    numEv = str2num(get(findobj(children,'tag','EvNumber'),'string'));
    eventTrack = events(:,1)==numEv;
    [isEvent,startEvent] = max(eventTrack);
    absFrame = round(startEvent+frame-1);
    if absFrame <= size(eventTrack,1)
    if isEvent & eventTrack(absFrame)
        M = get(gcf,'userdata');
        centerX = round((size(M,1)+1)/2); %normally 13 for a 25x25 ministack
        centerY = round((size(M,2)+1)/2);
        % local coordinates of the tracked object center
        objectX = events(absFrame,3)-round(events(startEvent,3)) + centerX;
        objectY = events(absFrame,4)-round(events(startEvent,4)) + centerY;
        line('xdata',objectX,'ydata',objectY,'linestyle','none',...
            'marker','+','markerEdgeColor','red')
    end
    end
end
        
    

function removeEvent
children = get(gcf,'children');
removedBox = findobj(children,'tag','removedEvent');
removedStatus = get(removedBox,'value');
removed = get(removedBox,'userdata');
event = get(gcf,'tag');
    a = strfind(event,'_');
    a = a(size(a,2))+1;
    b = strfind(event,'.');
    b = b(size(b,2))-1;
    numEv = str2num(event(a:b));

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
    removedBox = findobj(gcf,'tag','removedEvent');
    set(removedBox,'userdata',removed)
%checks wether the current event is tagged for removal or not
    event = get(gcf,'tag');
    a = strfind(event,'_');
    a = a(size(a,2))+1;
    b = strfind(event,'.');
    b = b(size(b,2))-1;
    numEv = str2num(event(a:b));
    tag = max(removed==numEv);
    if tag>0
        set(removedBox,'value',1)
    else
        set(removedBox,'value',0)
    end
end

function saveRemoved
event = get(gcf,'tag');
c = strfind(event,'\');
c = c(size(c,2));
a = strfind(event,'_');
a = a(size(a,2));
children = get(gcf,'children');
removed = get(findobj(children,'tag','removedEvent'),'userdata');
[fle,pth] = uiputfile([event(c+1:a),'removed.txt'],...
'Where to put the file showing removed events');
if ischar(fle)&ischar(pth)
   dlmwrite([pth,fle],removed,'\t')
end
goto

function saveRemovedandClose
event = get(gcf,'tag');
c = strfind(event,'\');
c = c(size(c,2));
a = strfind(event,'_');
a = a(size(a,2));
children = get(gcf,'children');
removed = get(findobj(children,'tag','removedEvent'),'userdata');
[fle,pth] = uiputfile([event(c+1:a),'removed.txt'],...
'Where to put the file showing removed events');
if ischar(fle)&ischar(pth)
   dlmwrite([pth,fle],removed,'\t')
end
delete(gcf)