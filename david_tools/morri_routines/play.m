function play(action)

if nargin == 0
   [stk,stkd] = uigetfile('*.stk','Choose a Stack');
   if ~stk,return,end
   frame = 1;
   M = stkread(stk,stkd);
   figure
   map = gray(256);
   %%%controls for playing the movie
   uicontrol('string','Stop','callback','play goto','position',[10,30,45,15])
   uicontrol('callback','play fullforward','string',...
      'Play -->','position',[100,30,45,15])
   uicontrol('callback','play fullbackward','string',...
      '<-- Play','position',[55,30,45,15])
   uicontrol('callback','play goto','string','frame#','style','slider',...
      'position',[50,15,90,15],'max',size(M,3),'min',1,'value',1,...
      'sliderstep',[1/(size(M,3)-1),10/(size(M,3)-1)],'tag','frame#');
   uicontrol('style','text','position',[10,15,35,15],'string','Frame')
   %%%controls for the scale
   high = double(max(max(max(M(:,:,1:end-1)))));
   low = double(min(min(min(M(:,:,1:end-1)))));
   uicontrol('style','slider','callback','play scale',...
      'min',low,'max',high-3,'value',low,...
      'position',[240,15,120,15],'tag','scalelow')
   uicontrol('style','text','position',[210,15,30,15],'tag','low_text')
   uicontrol('style','text','position',[175,15,35,15],'string','Low')
   uicontrol('style','slider','callback','play scale',...
      'min',low+3,'max',high,'value',high,...
      'position',[240,30,120,15],'tag','scalehigh')
   uicontrol('style','text','position',[210,30,30,15],'tag','high_text')
   uicontrol('style','text','position',[175,30,35,15],'string','High')
   %%%controls for removing planes
   uicontrol('string','Remove plane','position',[30,90,80,15],...
       'callback','play removePlane')
   uicontrol('string','Save Movie','position',[30,75,80,15],...
       'callback','play saveMovi')

   set(gcf,'UserData',M,'keypressfcn','play key','doublebuffer','on',...
      'colormap',map)
   u = image(M(:,:,frame),'cdatamapping','scaled','tag','movi');
   set(gca,'clim',[low,high],'tag','moviaxis','units','pixels')
   aspRatio = size(M,1)/size(M,2);
   set(gca,'position',[140,70,260,260*aspRatio])
   h = title([stk,' Frame # = ',num2str(frame)],...
      'interpreter','none');
   set(h,'userdata',stk)
   mzoom on
   %axis image
   pixvalm
   scale
   %zoom on
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
img = M(:,:,frame);
set(findobj(children,'tag','movi'),'cdata',img)
tit = get(gca,'title');
stk = get(tit,'userdata');
title([stk,' Frame # = ',num2str(frame)]);
%zoom on


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
