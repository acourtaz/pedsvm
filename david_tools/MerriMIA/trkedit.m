function varargout = trkedit(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trkedit_OpeningFcn, ...
                   'gui_OutputFcn',  @trkedit_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

% End initialization code - DO NOT EDIT

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Jobs to do:
% 2) 'recenter' button to snap cursor back to center if tracking
% needs redoing, also snap back to frame prior to scission event
% 3) indicator to tell when the computer can 'see' the spot
% 4) rolling output for dwell time (time that Tfnr spot is tracked), output
% for dwell time of mcherry labeled protein
% 6) 'dump data' button to invoke excel and write data to excel workbook
% 8) graphic output for msd displacement relative to scission
% 9) tweak scaling for the LUTs to eliminate excessive saturation
% 12) event name on current traces (red and green)
% 13) possible user text input to annotate particular events
% 14) rolling boxcar average for background, also use lower 25 percentile
% for background estimate to eliminate bias from bright objects
% 17) save graphics button to create new figure with the average plots
% (red, green and overlaid)
% 19) buttons to call up independent figures for red trace, green trace,
% average trace (in case you want to print them out or save them) could
% also have button to call up msd plot, map plot etc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes just before trkedit is made visible.
function trkedit_OpeningFcn(hObject, eventdata, handles, varargin)
% set renderer to zbuffer (fastest renderer for this purpose)
set(gcf,'renderer','zbuffer');
set(0,'DefaultFigureColor','w',...
      'DefaultAxesColor','w',...
      'DefaultAxesXColor','k',...
      'DefaultAxesYColor','k',...
      'DefaultAxesZColor','k',...
      'DefaultTextColor','k',...
      'DefaultLineColor','k')

% set values of counters etc
set(findobj('Tag','text12'),'String','1');
set(findobj('Tag','radiobutton1'),'Value',1);
set(findobj('Tag','radiobutton2'),'Value',0);
set(findobj('Tag','radiobutton3'),'Value',0);

% setup roi (by default the first dimension of the movie is used)
dim = 25; handles.dim = dim;           % default dimensions of ministack (vertical)
[circ,ann,circpix,annpix] = roi(dim);  % setup circle and annulus
handles.circ = circ;                   % update handles with variables returned from 'roi'
handles.ann = ann;
handles.circpix = circpix; guidata(hObject,handles);
handles.annpix = annpix; guidata(hObject,handles);
frame = 1; handles.frame = frame; guidata(hObject,handles);
noevents = 1; handles.noevents = noevents; guidata(hObject,handles);

% load stack
[name,stkd] = uigetfile('*.stk','Choose a Stack');
stk = char(name)
handles.stk = stk;
filen = 1; handles.filen = filen;guidata(hObject,handles);                            
handles.stkd = stkd; guidata(hObject,handles);
dat = stkread(stk,stkd); dat = double(dat); handles.stack = dat; guidata(hObject,handles);
name = 2; handles.name = name; guidata(hObject,handles);
frame = 20; handles.frame = frame; guidata(hObject,handles); % default first frame is just before scission
relframe = frame - 21;
set(findobj('Tag','text7'),'String',num2str(relframe),'ForegroundColor','w','BackgroundColor','k');
nframes = size(dat,3); handles.nframes = nframes; guidata(hObject,handles);
newframe = dat(:,:,frame);
grnim = newframe(1:25,1:25);
redim = newframe(1:25,26:50);
mingrnpix = min(min(grnim)); handles.mingrnpix = mingrnpix;
maxgrnpix = max(max(grnim)); handles.maxgrnpix = maxgrnpix;
minredpix = min(min(redim)); handles.minredpix = minredpix;
maxredpix = max(max(redim)); handles.maxredpix = maxredpix; 
guidata(hObject,handles);

% extract fluorescence data and plot
for fr = 1 : nframes;
    newframe = dat(:,:,fr);
    grnim = newframe(1:25,1:25);
    redim = newframe(1:25,26:50);
    grnroi = sum(sum(circ.*grnim))/circpix;
    grnann = sum(sum(ann.*grnim))/annpix;
    fl(1,fr) = grnroi - grnann;  
    grnsd = reshape((circ.*grnim),(dim*dim),1);
    grnsd = sort(grnsd,1,'descend');
    grnsd = grnsd(1:circpix,1);
    fl(3,fr) = std(grnsd);  
    redroi = sum(sum(circ.*redim))/circpix;
    redann = sum(sum(ann.*redim))/annpix;
    fl(2,fr) = redroi - redann;
    redsd = reshape((circ.*redim),(dim*dim),1);
    redsd = sort(redsd,1,'descend');
    redsd = redsd(1:circpix,1);
    fl(4,fr) = std(redsd);    
end

% initialize matrix to accept average values;
summdat(1:6,2:42,filen) = 0;
summdat(1,1,filen) = filen;
summdat(2,1,filen) = 1;
summdat(1,2:42,filen) = 13;
summdat(2,2:42,filen) = 13;
summdat(3:6,2:42,filen) = fl;
handles.summdat = summdat;

% plot data
axes(handles.axes2);
axis([0 (nframes) mingrnpix maxgrnpix]);
guidata(hObject, handles);
Xs = 1:nframes;
Ys = fl(1,:);
plot(Xs,Ys,'-g',Xs,Ys,'o','MarkerSize',7,'MarkerEdgeColor','g','MarkerFaceColor','g');
set(gca,'Xlim',[0 (nframes+1)],'YLim',[(min(Ys) - (0.1*max(Ys))) (max(Ys) + (0.1*max(Ys)))]);
grid on;

axes(handles.axes3);
axis([0 (nframes) mingrnpix maxgrnpix]);
guidata(hObject, handles);
Xs = 1:nframes;
Ys = fl(2,:);
plot(Xs,Ys,'-r',Xs,Ys,'o','MarkerSize',7,'MarkerEdgeColor','r','MarkerFaceColor','r');
set(gca,'Xlim',[0 (nframes+1)],'YLim',[(min(Ys) - (0.1*max(Ys))) (max(Ys) + (0.1*max(Ys)))]);
grid on;

axes(handles.axes5);
axis([0 (nframes) mingrnpix maxgrnpix]);
guidata(hObject, handles);
Xs = 1:nframes;
Ys = fl(1,:);
Ys = (Ys - min(Ys)) / (max(Ys) - min(Ys))*100;
plot(Xs,Ys,'-g',Xs,Ys,'o','MarkerSize',7,'MarkerEdgeColor','g','MarkerFaceColor','g');
hold on;
Ys = fl(2,:);
Ys = (Ys - min(Ys)) / (max(Ys) - min(Ys))*100;
plot(Xs,Ys,'-r',Xs,Ys,'o','MarkerSize',7,'MarkerEdgeColor','r','MarkerFaceColor','r');
set(gca,'Xlim',[0 (nframes+1)],'YLim',[(min(Ys) - (0.1*max(Ys))) (max(Ys) + (0.1*max(Ys)))]);
grid on;
hold off;

axes(handles.axes6);
axis([0 (nframes) mingrnpix maxgrnpix]);
guidata(hObject, handles);
Xs = 1:nframes;
Ys = fl(3,:);
Ys = (Ys - min(Ys)) / (max(Ys) - min(Ys))*100;
plot(Xs,Ys,'-g',Xs,Ys,'o','MarkerSize',7,'MarkerEdgeColor','g','MarkerFaceColor','g');
hold on;
Ys = fl(4,:);
Ys = (Ys - min(Ys)) / (max(Ys) - min(Ys))*100;
plot(Xs,Ys,'-r',Xs,Ys,'o','MarkerSize',7,'MarkerEdgeColor','r','MarkerFaceColor','r');
set(gca,'Xlim',[0 (nframes+1)],'YLim',[(min(Ys) - (0.1*max(Ys))) (max(Ys) + (0.1*max(Ys)))]);
grid on;
hold off;

% setup colormaps
redmap = hot;
grnmap(1:64,2) = redmap(1:64,1);
grnmap(1:64,1) = redmap(1:64,2);
grnmap(1:64,3) = redmap(1:64,3);
handles.redmap = redmap;
handles.grnmap = grnmap;

% load red image
axes(handles.axes4);
redim = round(((redim - (1.1*minredpix))/((maxredpix*1.1) - minredpix))*64);
redim = ind2rgb(redim,redmap);
image(redim);
set(gca,'NextPlot','replacechildren');guidata(hObject,handles);
guidata(hObject,handles);

%load green image
axes(handles.axes1);
grnim = round(((grnim - (1.1*mingrnpix))/((maxgrnpix*1.1) - mingrnpix))*64);
grnim = ind2rgb(grnim,grnmap);
image(grnim);
currim = findobj('Type','Image');
set(currim,'ButtonDownFcn',{@cursor,handles});
hold(handles.axes1,'on');
frame = handles.frame;
x = summdat(1,frame + 1,filen);
y = summdat(2,frame + 1,filen);
xspoke1 = [0.5 x-2.5]; yspoke1 = [y y]; plot(xspoke1,yspoke1,'color','y','linewidth',1.5); hold all;
xspoke2 = [x x]; yspoke2 = [25.5 y+2.5]; plot(xspoke2,yspoke2,'color','y','linewidth',1.5);
xspoke3 = [x+3.0 25.5]; yspoke3 = [y y]; plot(xspoke3,yspoke3,'color','y','linewidth',1.5);
xspoke4 = [x x]; yspoke4 = [y-2.5 0.5]; plot(xspoke4,yspoke4,'color','y','linewidth',1.5);
set(gca,'NextPlot','replacechildren');guidata(hObject,handles);
guidata(hObject,handles);

% map the refresh function
handles.refresh = {@refresh,handles};

% set values for slider
set(handles.slider1,'Min',1,'Max',nframes,'Value',20,'SliderStep',[(1/(nframes-1)), 0.1]); % slider set to frame just before scission
set(handles.slider9,'Min',mingrnpix,'Max',maxgrnpix,'Value',mingrnpix,'SliderStep',[(1/maxgrnpix), 0.1]);
set(handles.slider10,'Min',mingrnpix,'Max',maxgrnpix,'Value',maxgrnpix,'SliderStep',[(1/maxgrnpix), 0.1]);
set(handles.slider11,'Min',minredpix,'Max',maxredpix,'Value',minredpix,'SliderStep',[(1/maxredpix), 0.1]);
set(handles.slider12,'Min',minredpix,'Max',maxredpix,'Value',maxredpix,'SliderStep',[(1/maxredpix), 0.1]);

% Choose default command line output for trkedit
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = trkedit_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% --- Frame slider.
function slider1_Callback(hObject,eventdata,handles)
frame = round(get(hObject,'Value'));
handles.frame = frame; guidata(hObject,handles);
handles = refresh(hObject,eventdata,handles);
handles.output = hObject;
guidata(hObject,handles);

% --- Grab cursor on windows button down over axes1.
function cursor(hObject, eventdata, handles)
set(gcf,'WindowButtonMotionFcn',{@draw,handles});
handles.output = hObject;
guidata(hObject, handles);

% --- Draw marker
function draw(hObject, eventdata, handles)
set(gcf,'WindowButtonUpFcn',{@blank})
frame = handles.frame;
coords = get(gca,'CurrentPoint');
filen = handles.filen;
summdat = handles.summdat;
summdat(1,frame + 1,filen) = coords(1,1);
summdat(2,frame + 1,filen) = coords(1,2);
handles.summdat = summdat;
guidata(hObject,handles);
handles = refresh(hObject,eventdata,handles);
handles.output = hObject;
guidata(hObject, handles);

% --- Blank (use as hold for axes WindowsButtonMotionFcn and WindowsButtonUpFcn).
function blank(hObject, eventdata, handles)
set(gcf,'WindowButtonMotionFcn',{@blank});

% --- Green channel lower pixel limit.
function slider9_Callback(hObject,eventdata,handles)
axes(handles.axes1);
temp = round(get(hObject,'Value'));
maxgrnpix = handles.maxgrnpix;
if temp == maxgrnpix | temp > maxgrnpix;
    handles.mingrnpix = maxgrnpix - 1; guidata(hObject,handles);
else
handles.mingrnpix = temp; guidata(hObject,handles);
end
mingrnpix = handles.mingrnpix;
maxgrnpix = handles.maxgrnpix;
handles = refresh(hObject,eventdata,handles);
handles.output = hObject;
guidata(hObject,handles);

% --- Green channel upper pixel limit.
function slider10_Callback(hObject,eventdata,handles)
axes(handles.axes1);
temp = round(get(hObject,'Value'));
mingrnpix = handles.mingrnpix;
if temp == mingrnpix | temp < mingrnpix;
    handles.maxgrnpix = mingrnpix+1; guidata(hObject,handles);
else
handles.maxgrnpix = temp; guidata(hObject,handles);
end
maxgrnpix = handles.maxgrnpix;
mingrnpix = handles.mingrnpix;
handles = refresh(hObject,eventdata,handles);
handles.output = hObject;
guidata(hObject,handles);

% --- Red channel lower pixel limit.
function slider11_Callback(hObject, eventdata, handles)
axes(handles.axes4);
temp = round(get(hObject,'Value'));
maxredpix = handles.maxredpix;
if temp == maxredpix | temp > maxredpix;
    handles.minredpix = maxredpix - 1; guidata(hObject,handles);
else
handles.minredpix = temp; guidata(hObject,handles);
end
minredpix = handles.minredpix;
maxredpix = handles.maxredpix;
handles = refresh(hObject,eventdata,handles);
handles.output = hObject;
guidata(hObject,handles);

% --- Red channel upper pixel limit.
function slider12_Callback(hObject, eventdata, handles)
axes(handles.axes1);
temp = round(get(hObject,'Value'));
minredpix = handles.minredpix;
if temp == minredpix | temp < minredpix;
    handles.maxredpix = minredpix+1; guidata(hObject,handles);
else
handles.maxredpix = temp; guidata(hObject,handles);
end
maxredpix = handles.maxredpix;
minredpix = handles.minredpix;
handles = refresh(hObject,eventdata,handles);
handles.output = hObject;
guidata(hObject,handles);

% --- Load next.
function pushbutton1_Callback(hObject, eventdata, handles)
axes(handles.axes1);
nframes = handles.nframes; circ = handles.circ; circpix = handles.circpix; ann = handles.ann; annpix = handles.annpix; dim = handles.dim;
filen = handles.filen; filen = filen + 1; handles.filen = filen; guidata(hObject,handles);
summdat = handles.summdat;
summdat(1,1,filen) = filen;
summdat(2,1,filen) = 1;
summdat(1,2:42,filen) = 13;
summdat(2,2:42,filen) = 13;
handles.summdat = summdat;
stk = handles.stk;
stk = [stk(1:5),(int2str(filen)),'.stk']; handles.stk = stk;
stkd = handles.stkd; dat = stkread(stk,stkd); dat = double(dat); handles.stack = dat;
frame = handles.frame; frame = 20; handles.frame = frame; guidata(hObject,handles);
newframe = dat(:,:,frame);
grnim = newframe(1:25,1:25);
redim = newframe(1:25,26:50);
mingrnpix = min(min(grnim)); handles.mingrnpix = mingrnpix;
maxgrnpix = max(max(grnim)); handles.maxgrnpix = maxgrnpix;
minredpix = min(min(redim)); handles.minredpix = minredpix;
maxredpix = max(max(redim)); handles.maxredpix = maxredpix;
guidata(hObject,handles);
handles.output = hObject;
handles = refresh(hObject,eventdata,handles);
relframe = frame - 21;
set(findobj('Tag','text7'),'String',num2str(relframe));
status = summdat(2,1,filen);
set(findobj('Tag','text10'),'String',num2str(status));

for fr = 1 : nframes;
    newframe = dat(:,:,fr);
    grnim = newframe(1:25,1:25);
    redim = newframe(1:25,26:50);
    grnroi = sum(sum(circ.*grnim))/circpix;
    grnann = sum(sum(ann.*grnim))/annpix;
    fl(1,fr) = grnroi - grnann;                         % av fl of pixels in roi
    grnsd = reshape((circ.*grnim),(dim*dim),1);
    grnsd = sort(grnsd,1,'descend');
    grnsd = grnsd(1:circpix,1);
    fl(3,fr) = std(grnsd);                              % std deviation of pixels in roi
    redroi = sum(sum(circ.*redim))/circpix;
    redann = sum(sum(ann.*redim))/annpix;
    fl(2,fr) = redroi - redann - 0.1* fl(1,fr);         % compensate for bleed through (10%)
    redsd = reshape((circ.*redim),(dim*dim),1);
    redsd = sort(redsd,1,'descend');
    redsd = redsd(1:circpix,1);
    fl(4,fr) = std(redsd);                              % av fl of pixels in roi
end

summdat(3:6,2:42,filen) = fl; handles.summdat = summdat; guidata(hObject,handles);
b = 1;
for a = 1:size(summdat,3);
   if summdat(2,1,a) == 1;
       tmpav(1:6,1:42,b) = summdat(:,:,a);
       b = b + 1;
   else
   end
end
av = sum(tmpav,3) / b;
av = av(3:6,2:42);
sem = (std(summdat,1,3))/(b ^ 0.5);
sem = sem(3:6,2:42);
set(findobj('Tag','text12'),'String',num2str(b - 1));
set(findobj('Tag','text16'),'String',num2str(filen - b + 1));

axes(handles.axes2);
mingrnpix = handles.mingrnpix;
maxgrnpix = handles.maxgrnpix;
axis([0 (nframes) mingrnpix maxgrnpix]);
guidata(hObject, handles);
Xs = 1:nframes;
Ys = fl(1,:);
plot(Xs,Ys,'-g',Xs,Ys,'o','MarkerSize',7,'MarkerEdgeColor','g','MarkerFaceColor','g');
set(gca,'Xlim',[0 (nframes+1)],'YLim',[(min(Ys) - (0.1*max(Ys))) (max(Ys) + (0.1*max(Ys)))]);
grid on;

axes(handles.axes3);
mingrnpix = handles.mingrnpix;
maxgrnpix = handles.maxgrnpix;
axis([0 (nframes) mingrnpix maxgrnpix]);
guidata(hObject, handles);
Xs = 1:nframes;
Ys = fl(2,:);
plot(Xs,Ys,'-r',Xs,Ys,'o','MarkerSize',7,'MarkerEdgeColor','r','MarkerFaceColor','r');
set(gca,'Xlim',[0 (nframes+1)],'YLim',[(min(Ys) - (0.1*max(Ys))) (max(Ys) + (0.1*max(Ys)))]);
grid on;

axes(handles.axes5);
mingrnpix = handles.mingrnpix;
maxgrnpix = handles.maxgrnpix;
axis([0 (nframes) mingrnpix maxgrnpix]);
guidata(hObject, handles);
Xs = 1:nframes;
Ys = av(1,:);
Ys = (Ys - min(Ys)) / (max(Ys) - min(Ys))*100;
Ysem = sem(1,:)*(100/((max(Ys) - min(Ys))));
errorbar(Xs,Ys,Ysem,'Color','g','LineStyle','-','Marker','o','MarkerSize',5,'MarkerEdgeColor','g','MarkerFaceColor','g');
hold on;
Ys = av(2,:);
Ysem = sem(2,:)*(100/((max(Ys) - min(Ys))));
Ys = (Ys - min(Ys)) / (max(Ys) - min(Ys))*100;
errorbar(Xs,Ys,Ysem,'Color','r','Linestyle','-','Marker','o','MarkerSize',5,'MarkerEdgeColor','r','MarkerFaceColor','r');
set(gca,'Xlim',[0 (nframes+1)],'YLim',[(min(Ys) - (0.1*max(Ys))) (max(Ys) + (0.1*max(Ys)))]);
grid on;
hold off;

axes(handles.axes6);
mingrnpix = handles.mingrnpix;
maxgrnpix = handles.maxgrnpix;
axis([0 (nframes) mingrnpix maxgrnpix]);
guidata(hObject, handles);
Xs = 1:nframes;
Ys = av(3,:);
Ys = (Ys - min(Ys)) / (max(Ys) - min(Ys))*100;
Ysem = sem(3,:)*(100/((max(Ys) - min(Ys))));
errorbar(Xs,Ys,Ysem,'Color','g','LineStyle','-','Marker','o','MarkerSize',5,'MarkerEdgeColor','g','MarkerFaceColor','g');
hold on;
Ys = av(4,:);
Ysem = sem(4,:)*(100/((max(Ys) - min(Ys))));
Ys = (Ys - min(Ys)) / (max(Ys) - min(Ys))*100;
errorbar(Xs,Ys,Ysem,'Color','r','Linestyle','-','Marker','o','MarkerSize',5,'MarkerEdgeColor','r','MarkerFaceColor','r');
set(gca,'Xlim',[0 (nframes+1)],'YLim',[(min(Ys) - (0.1*max(Ys))) (max(Ys) + (0.1*max(Ys)))]);
grid on;
hold off;

set(handles.slider1,'Min',1,'Max',nframes,'Value',20,'SliderStep',[(1/(nframes-1)), 0.1]); % slider set to frame just before scission
set(handles.slider9,'Min',mingrnpix,'Max',maxgrnpix,'Value',mingrnpix,'SliderStep',[(1/maxgrnpix), 0.1]);
set(handles.slider10,'Min',mingrnpix,'Max',maxgrnpix,'Value',maxgrnpix,'SliderStep',[(1/maxgrnpix), 0.1]);
set(handles.slider11,'Min',minredpix,'Max',maxredpix,'Value',minredpix,'SliderStep',[(1/maxredpix), 0.1]);
set(handles.slider12,'Min',minredpix,'Max',maxredpix,'Value',maxredpix,'SliderStep',[(1/maxredpix), 0.1]);
handles.output = hObject;
guidata(hObject,handles);

% --- Load Previous.
function pushbutton5_Callback(hObject, eventdata, handles)
axes(handles.axes1);
nframes = handles.nframes; circ = handles.circ; circpix = handles.circpix; ann = handles.ann; annpix = handles.annpix; dim = handles.dim;
filen = handles.filen; filen = filen - 1; handles.filen = filen; guidata(hObject,handles);
summdat = handles.summdat;
summdat(:,:,filen + 1) = [];
handles.summdat = summdat;
a = summdat(2,1,filen);
if a == 1;
    status = findobj('Tag','text10');
    set(status,'String','1');
else
    status = findobj('Tag','text10');
    set(status,'String','0');
end
stk = handles.stk;
stk = [stk(1:5),(int2str(filen)),'.stk']; handles.stk = stk;
stkd = handles.stkd; dat = stkread(stk,stkd); dat = double(dat); handles.stack = dat;
frame = handles.frame; frame = 20; handles.frame = frame; guidata(hObject,handles);
relframe = frame - 21;
frameind = findobj('Tag','text7');
set(frameind,'String',num2str(relframe));
newframe = dat(:,:,frame);
grnim = newframe(1:25,1:25);
redim = newframe(1:25,26:50);
mingrnpix = min(min(grnim)); handles.mingrnpix = mingrnpix;
maxgrnpix = max(max(grnim)); handles.maxgrnpix = maxgrnpix;
minredpix = min(min(redim)); handles.minredpix = minredpix;
maxredpix = max(max(redim)); handles.maxredpix = maxredpix;
guidata(hObject,handles);
handles = refresh(hObject,eventdata,handles);

for fr = 1 : nframes;
    newframe = dat(:,:,fr);
    grnim = newframe(1:25,1:25);
    redim = newframe(1:25,26:50);
    grnroi = sum(sum(circ.*grnim))/circpix;
    grnann = sum(sum(ann.*grnim))/annpix;
    fl(1,fr) = grnroi - grnann;  
    grnsd = reshape((circ.*grnim),(dim*dim),1);
    grnsd = sort(grnsd,1,'descend');
    grnsd = grnsd(1:circpix,1);
    fl(3,fr) = std(grnsd);  
    redroi = sum(sum(circ.*redim))/circpix;
    redann = sum(sum(ann.*redim))/annpix;
    fl(2,fr) = redroi - redann - 0.1* fl(1,fr);             % compensate for bleed through (10%)
    redsd = reshape((circ.*redim),(dim*dim),1);
    redsd = sort(redsd,1,'descend');
    redsd = redsd(1:circpix,1);
    fl(4,fr) = std(redsd);
end

b = 1;
for a = 1:size(summdat,3);
   if summdat(2,1,a) == 1;
       tmpav(1:6,1:42,b) = summdat(:,:,a);
       b = b + 1;
   else
   end
end
av = sum(tmpav,3) / b;
av = av(3:6,2:42);
sem = (std(summdat,1,3))/(b^0.5);
sem = sem(3:6,2:42);

set(findobj('Tag','text12'),'String',num2str(b - 1));
set(findobj('Tag','text16'),'String',num2str(filen - b + 1));

axes(handles.axes2);
mingrnpix = handles.mingrnpix;
maxgrnpix = handles.maxgrnpix;
axis([0 (nframes) mingrnpix maxgrnpix]);
guidata(hObject, handles);
Xs = 1:nframes;
Ys = fl(1,:);
plot(Xs,Ys,'-g',Xs,Ys,'o','MarkerSize',7,'MarkerEdgeColor','g','MarkerFaceColor','g');
set(gca,'Xlim',[0 (nframes+1)],'YLim',[(min(Ys) - (0.1*max(Ys))) (max(Ys) + (0.1*max(Ys)))]);
grid on;

axes(handles.axes3);
mingrnpix = handles.mingrnpix;
maxgrnpix = handles.maxgrnpix;
axis([0 (nframes) mingrnpix maxgrnpix]);
guidata(hObject, handles);
Xs = 1:nframes;
Ys = fl(2,:);
plot(Xs,Ys,'-r',Xs,Ys,'o','MarkerSize',7,'MarkerEdgeColor','r','MarkerFaceColor','r');
set(gca,'Xlim',[0 (nframes+1)],'YLim',[(min(Ys) - (0.1*max(Ys))) (max(Ys) + (0.1*max(Ys)))]);
grid on;

axes(handles.axes5);
mingrnpix = handles.mingrnpix;
maxgrnpix = handles.maxgrnpix;
axis([0 (nframes) mingrnpix maxgrnpix]);
guidata(hObject, handles);
Xs = 1:nframes;
Ys = av(1,:);
Ys = (Ys - min(Ys)) / (max(Ys) - min(Ys))*100;
Ysem = sem(1,:)*(100/((max(Ys) - min(Ys))));
errorbar(Xs,Ys,Ysem,'Color','g','LineStyle','-','Marker','o','MarkerSize',5,'MarkerEdgeColor','g','MarkerFaceColor','g');
hold on;
Ys = av(2,:);
Ysem = sem(2,:)*(100/((max(Ys) - min(Ys))));
Ys = (Ys - min(Ys)) / (max(Ys) - min(Ys))*100;
errorbar(Xs,Ys,Ysem,'Color','r','Linestyle','-','Marker','o','MarkerSize',5,'MarkerEdgeColor','r','MarkerFaceColor','r');
set(gca,'Xlim',[0 (nframes+1)],'YLim',[(min(Ys) - (0.1*max(Ys))) (max(Ys) + (0.1*max(Ys)))]);
grid on;
hold off;

axes(handles.axes6);
mingrnpix = handles.mingrnpix;
maxgrnpix = handles.maxgrnpix;
axis([0 (nframes) mingrnpix maxgrnpix]);
guidata(hObject, handles);
Xs = 1:nframes;
Ys = av(3,:);
Ys = (Ys - min(Ys)) / (max(Ys) - min(Ys))*100;
Ysem = sem(3,:)*(100/((max(Ys) - min(Ys))));
errorbar(Xs,Ys,Ysem,'Color','g','LineStyle','-','Marker','o','MarkerSize',5,'MarkerEdgeColor','g','MarkerFaceColor','g');
hold on;
Ys = av(4,:);
Ysem = sem(4,:)*(100/((max(Ys) - min(Ys))));
Ys = (Ys - min(Ys)) / (max(Ys) - min(Ys))*100;
errorbar(Xs,Ys,Ysem,'Color','r','Linestyle','-','Marker','o','MarkerSize',5,'MarkerEdgeColor','r','MarkerFaceColor','r');
set(gca,'Xlim',[0 (nframes+1)],'YLim',[(min(Ys) - (0.1*max(Ys))) (max(Ys) + (0.1*max(Ys)))]);
grid on;
hold off;

set(handles.slider1,'Min',1,'Max',nframes,'Value',20,'SliderStep',[(1/(nframes-1)), 0.1]); % slider set to frame just before scission
set(handles.slider9,'Min',mingrnpix,'Max',maxgrnpix,'Value',mingrnpix,'SliderStep',[(1/maxgrnpix), 0.1]);
set(handles.slider10,'Min',mingrnpix,'Max',maxgrnpix,'Value',maxgrnpix,'SliderStep',[(1/maxgrnpix), 0.1]);
set(handles.slider11,'Min',minredpix,'Max',maxredpix,'Value',minredpix,'SliderStep',[(1/maxredpix), 0.1]);
set(handles.slider12,'Min',minredpix,'Max',maxredpix,'Value',maxredpix,'SliderStep',[(1/maxredpix), 0.1]);
handles.output = hObject;
guidata(hObject,handles);

% 'Refresh' updates the current frame in the image window
function [handles] = refresh(hObject,eventdata,handles)
frame = handles.frame;
relframe = frame - 21;
set(findobj('Tag','text7'),'String',num2str(relframe));
dat = handles.stack;
newframe = dat(:,:,frame);
grnim = newframe(1:25,1:25);
redim = newframe(1:25,26:50);
redmap = handles.redmap;
grnmap = handles.grnmap;
axes(handles.axes4);
minredpix = handles.minredpix;
maxredpix = handles.maxredpix;
redim = round(((redim - (1.1*minredpix))/((maxredpix*1.1) - minredpix))*64);
redim = ind2rgb(redim,redmap);
image(redim);
set(gca,'NextPlot','replacechildren');guidata(hObject,handles);
guidata(hObject,handles);
axes(handles.axes1);
mingrnpix = handles.mingrnpix;
maxgrnpix = handles.maxgrnpix;
grnim = round(((grnim - (1.1*mingrnpix))/((maxgrnpix*1.1) - mingrnpix))*64);
grnim = ind2rgb(grnim,grnmap);
image(grnim);
currim = findobj('Type','Image');
set(currim,'ButtonDownFcn',{@cursor,handles});
hold(handles.axes1,'on');
filen = handles.filen;
summdat = handles.summdat;
x = summdat(1,frame + 1,filen);
y = summdat(2,frame + 1,filen);
xspoke1 = [0.5 x-2.5]; yspoke1 = [y y]; plot(xspoke1,yspoke1,'color','y','linewidth',1.5); hold all;
xspoke2 = [x x]; yspoke2 = [25.5 y+2.5]; plot(xspoke2,yspoke2,'color','y','linewidth',1.5);
xspoke3 = [x+3.0 25.5]; yspoke3 = [y y]; plot(xspoke3,yspoke3,'color','y','linewidth',1.5);
xspoke4 = [x x]; yspoke4 = [y-2.5 0.5]; plot(xspoke4,yspoke4,'color','y','linewidth',1.5);
set(gca,'NextPlot','replacechildren');guidata(hObject,handles);
handles.output = hObject;
guidata(hObject,handles);

% --- Save data saves the datamatrix and returns an annotated plot of the average.
function pushbutton6_Callback(hObject, eventdata, handles)
uisave;

% 'roi' makes the masks for quantifying the fluorescence data
function [circ,ann,circpix,annpix] = roi(dim);
circ = zeros(dim,dim);
midx = (0.5*(size(circ,1))) + 0.5;
midy = (0.5*(size(circ,2))) + 0.5;
x = 1;
y = 1;
for y = 1:25;
    for x = 1:25;
        dist = (((y - midy)^2 + (x - midx)^2) ^ 0.5);
        if dist <= 6.5;
            circ(y,x) = 1;
        end
    x = x + 1;
    end
    y = y + 1;
end
circpix = sum(sum(circ));
sizecircpix = size(circpix);

ann = zeros(dim,dim);
midx = (0.5*(size(ann,1))) + 0.5;
midy = (0.5*(size(ann,2))) + 0.5;
x = 1;
y = 1;
for y = 1:25;
    for x = 1:25;
        dist = (((y - midy)^2 + (x - midx)^2) ^ 0.5);
        if  6 <= dist & dist <= 12;
            ann(y,x) = 1;
        end
    x = x + 1;
    end
    y = y + 1;
end
annpix = sum(sum(ann));
sizeannpix = size(annpix);

% --- Discard.
function pushbutton4_Callback(hObject, eventdata, handles)
filen = handles.filen;
summdat = handles.summdat;
summdat(2,1,filen) = 0;
handles.summdat = summdat;
status = findobj('Tag','text10');
set(status,'String','0');
handles.output = hObject;
guidata(hObject,handles);

% --- Reinstate.
function pushbutton7_Callback(hObject, eventdata, handles)
filen = handles.filen;
summdat = handles.summdat;
summdat(2,1,filen) = 1;
handles.summdat = summdat;
status = findobj('Tag','text10');
set(status,'String','1');
handles.output = hObject;
guidata(hObject,handles);

% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
a = get(gco,'Value')
if a == 1;
    set(findobj('Tag','radiobutton2'),'Value',0);
    set(findobj('Tag','radiobutton3'),'Value',0);
else
    set(findobj('Tag','radiobutton1'),'Value',1);
    set(findobj('Tag','radiobutton2'),'Value',0);
    set(findobj('Tag','radiobutton3'),'Value',0);
end

% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
a = get(gco,'Value')
if a == 1;
    set(findobj('Tag','radiobutton1'),'Value',0);
    set(findobj('Tag','radiobutton3'),'Value',0);
else
    set(findobj('Tag','radiobutton1'),'Value',0);
    set(findobj('Tag','radiobutton2'),'Value',1);
    set(findobj('Tag','radiobutton3'),'Value',0);
end

% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
a = get(gco,'Value')
if a == 1;
    set(findobj('Tag','radiobutton1'),'Value',0);
    set(findobj('Tag','radiobutton2'),'Value',0);
else
    set(findobj('Tag','radiobutton1'),'Value',0);
    set(findobj('Tag','radiobutton2'),'Value',0);
    set(findobj('Tag','radiobutton3'),'Value',1);
end




% junk written by guide
% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject,eventdata,handles)
if isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject,eventdata,handles)
if isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject,eventdata,handles)
if isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
% --- Executes during object creation, after setting all properties.
function slider9_CreateFcn(hObject,eventdata,handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
% --- Executes during object creation, after setting all properties.
function slider10_CreateFcn(hObject,eventdata,handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
% --- Executes during object creation, after setting all properties.
function slider12_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
% --- Executes during object creation, after setting all properties.
function slider11_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end









