function playBW(action)

if nargin == 0
   [stk,stkd] = uigetfile('*.stk','Choose a Stack');
   if ~stk,return,end
   frame = 1;
   M = stkread(stk,stkd);
   figure
   map = gray(256);
   uicontrol('string','Stop','callback','playBW goto','position',[40,30,45,15])
   uicontrol('callback','playBW fullforward','string',...
      'Play -->','position',[130,30,45,15])
   uicontrol('callback','playBW fullbackward','string',...
      '<-- Play','position',[85,30,45,15])
   high = double(max(max(max(M(:,:,1:end)))));
   low = double(min(min(min(M(:,:,1:end)))));
   
   uicontrol('callback','playBW goto','string','frame#','style','slider',...
      'position',[275,0,280,15],...
      'max',size(M,3),...
      'min',1,...
      'value',1,...
      'sliderstep',[1/(size(M,3)-1),25/(size(M,3)-1)],'tag','frame#');
   uicontrol('style','text','position',[240,0,35,15],'string','Frame')
   set(gcf,'UserData',M,'keypressfcn','playBW key','doublebuffer','on'...
      ,'colormap',map)
   u = image(M(:,:,frame),'cdatamapping','scaled','tag','movi');
   set(gca,'clim',[low,high],'tag','moviaxis')
   h = title([stk,' Frame # = ',num2str(frame)],...
      'interpreter','none');
   set(h,'userdata',stk)
   mzoom on
   axis image
   goto
else
   eval(action)
end


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
