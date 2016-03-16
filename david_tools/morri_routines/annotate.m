function annotate(action)
if nargin == 0
   [stk,stkd] = uigetfile('*.stk','Choose a Stack');
   if ~stk,return,end
   frame = 1;
   M = stkread(stk,stkd);
   figure
   map = gray(256);
   %controls specific to annotate
   cd(stkd)
   data = cell(1,size(M,3)); %structure of selected events: 
                  %array of pairs of coordinates grouped by frame
   uicontrol('style','toggle','string','Pick ?','position',[88,0,40,15]...
      ,'tag','pick','callback','annotate pick','value',0)
   uicontrol('callback','annotate ld','string','Load','position'...
      ,[107,15,68,15])
   uicontrol('callback','annotate sv','string','Save','position'...
      ,[40,15,67,15],'tag','sv','userdata',data)
   %controls inherited from play
   uicontrol('string','Stop','callback','annotate goto','position',[40,30,45,15])
   uicontrol('callback','annotate fullforward','string',...
      'Play -->','position',[130,30,45,15])
   uicontrol('callback','annotate fullbackward','string',...
      '<-- Play','position',[85,30,45,15])
   high = double(max(max(max(M(:,:,1:end-1)))));
   low = double(min(min(min(M(:,:,1:end-1)))));
   uicontrol('style','slider',...
      'callback','annotate scale',...
      'min',low,'max',high-3,...
      'value',low,...
      'position',[240,15,315,15],'tag','scalelow')
   uicontrol('style','text','position',[210,15,30,15],'tag','low_text','fontsize',...
      5)
   uicontrol('style','text','position',[175,15,35,15],'string','Low')
   uicontrol('style','slider',...
      'callback','annotate scale',...
      'min',low+3,'max',high,...
      'value',high,...
      'position',[240,30,315,15],'tag','scalehigh')
   uicontrol('style','text','position',[210,30,30,15],'tag','high_text','fontsize',...
      5)
   uicontrol('style','text','position',[175,30,35,15],'string','High')
   uicontrol('callback','annotate goto','string','frame#','style','slider',...
      'position',[275,0,280,15],...
      'max',size(M,3),...
      'min',1,...
      'value',1,...
      'sliderstep',[1/(size(M,3)-1),25/(size(M,3)-1)],'tag','frame#');
   uicontrol('style','text','position',[240,0,35,15],'string','Frame')
   set(gcf,'UserData',M,'keypressfcn','annotate key','doublebuffer','on'...
      ,'colormap',map)
   u = image(M(:,:,frame),'cdatamapping','scaled','tag','movi');
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

%functions all from play
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

function fullbackward
M = get(gcf,'userdata');
children = get(gcf,'children');
current_frame = round(get(findobj(children,'tag','frame#'),'value'));
global stop
stop = 0;
nframes = size(M,3);
%line is specific to annotate
delete(findobj(get(gca,'children'),'type','line'))
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
%line is specific to annotate
delete(findobj(get(gca,'children'),'type','line'))
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

%functions specific to annotate
%new version of goto specific to annotate
function goto
M = get(gcf,'userdata');
children = get(gcf,'children');
frame = round(get(findobj(children,'tag','frame#'),'value'));
global stop
stop = 1;
data = get(findobj(children,'tag','sv'),'userdata');
frameevents = data{frame};
delete(findobj(get(gca,'children'),'type','line'))
if ~isempty(frameevents)
   for j = 1:size(frameevents,1)
      xy = frameevents(j,:);
      line([xy(1)-3,xy(1)-3,xy(1)+3,xy(1)+3,xy(1)-3],...
         [xy(2)-3,xy(2)+3,xy(2)+3,xy(2)-3,xy(2)-3],'color','r',...
         'buttondownfcn','annotate pos','userdata',j,...
         'linestyle',':');
   end
end
img = M(:,:,frame);
set(findobj(children,'tag','movi'),'cdata',img)
tit = get(gca,'title');
stk = get(tit,'userdata');
title([stk,' Frame # = ',num2str(frame)]);

function pick
if get(findobj(get(gcf,'children'),'tag','pick'),'value') == 1
   mzoom off
   set(findobj(get(gcf,'children'),'type','image'),'buttondownfcn',...
      'annotate pos');
else mzoom on
   pixvalm
end

function pos
M = get(gcf,'userdata');
xy = round(get(gca,'currentpoint'));
xy = xy';
xy = xy(1:2);
children = get(gcf,'children');
frame = round(get(findobj(children,'tag','frame#'),'value'));
data = get(findobj(children,'tag','sv'),'userdata');

if strcmp(get(gcf,'selectiontype'),'normal')
   if ~isempty(data{frame}) %to find whether the selected pixel is already in data
      A = data{frame} == xy(ones(size(data{frame},1),1),:);
      a1 = A(:,1);
      a2 = A(:,2);
      row = find(a1&a2);
      if isempty(row)
         row = 0;
      end
   end
   if isempty(data{frame})
      row = 0;
   end
   if row == 0
      data{frame}(end+1,:) = xy;
   end
end

if strcmp(get(gcf,'selectiontype'),'alt')
   if ~isempty(data{frame})
      A = (data{frame} == xy(ones(size(data{frame},1),1),:));      
      a1 = A(:,1);
      a2 = A(:,2);
      row = find(a1&a2);
      if strcmp(get(gcbo,'type'),'line')
         row = get(gcbo,'userdata');
      end
            
      if ~isempty(row)
         for j = 1:length(row)
            rowi = row(j);
            data{frame}(row:end-1,:) = data{frame}(row+1:end,:);
            data{frame} = data{frame}(1:end-1,:);
         end
      end
   end
end
set(findobj(children,'tag','sv'),'userdata',data)
goto

function sv
children = get(gcf,'children');
data = get(findobj(children,'tag','sv'),'userdata');
stk = get(get(gca,'title'),'userdata');
[f,p] = uiputfile([stk(1:end-4),'_annotate.txt']...
      ,'Where to put the textfile with vesicle info');
output = [];
k = 0;
for frame = 1:length(data);
   if ~isempty(data{frame})
        numEv = size(data{frame},1);
        output(end+1:end+numEv,:) = ...
[(k+1:k+numEv)',frame(ones(numEv,1)),data{frame}(:,1),data{frame}(:,2)];
        k = k + numEv;
   end
end
if ischar(f)&ischar(p)
   dlmwrite([p,f],output,'\t')
end

function ld 
children = get(gcf,'children');
stk = get(get(gca,'title'),'userdata');
[f,p] = uigetfile([stk(1:end-4),'_annotate.txt'],'Choose the textfile with the Information to Load');
if ischar(f)&ischar(p)
   M = get(gcf,'userdata'); % the data file, or movie
   dims = size(M);
   data = cell(1,dims(3));
   ves = dlmread([p,f],'\t');
   for r = 1:size(ves,1)
      frame = ves(r,2);
      xy = ves(r,3:4);
      if [xy(2),xy(1),frame]<=dims 
         data{frame}(end+1,1:2) = xy;
      end
   end
   set(findobj(children,'tag','sv'),'userdata',data)
end
goto