function play7(action)

%Upgrade from play6: possibility to quantify in the mask or an ROI average
%fluo- average in background

if nargin == 0
   [stk,stkd] = uigetfile('*.stk','Choose a Stack');
   if ~stk,return,end
   frame = 1;
   M = stkread(stk,stkd);
   h_play = figure('name',['Play ',stk]);
   map = gray(256);
   %%%controls for playing the movie
   uicontrol('string','Stop','callback','play7 goto','position',[10,30,45,15])
   uicontrol('callback','play7 fullforward','string',...
      'Play -->','position',[100,30,45,15])
   uicontrol('callback','play7 fullbackward','string',...
      '<-- Play','position',[55,30,45,15])
   uicontrol('callback','play7 goto','string','frame#','style','slider',...
      'position',[50,15,90,15],'max',size(M,3),'min',1,'value',1,...
      'sliderstep',[1/(size(M,3)-1),10/(size(M,3)-1)],'tag','frame#');
   uicontrol('style','text','position',[10,15,35,15],'string','Frame')
   %%%controls for the scale
   high = double(max(max(max(M))));
   low = double(min(min(min(M))));
   uMax = find(M>high-100);
   uMin = find(M<low+100);
   MhPix = M;
   MhPix(uMax) = low;
   McPix = M;
   McPix(uMin) = high;
   hPix = double(max(max(max(MhPix)))); %the second highest pixel value in Movie
   cPix = double(min(min(min(McPix)))); %the second lowest pixel value in Movie
   uicontrol('style','slider','callback','play7 scale',...
      'min',low,'max',high-3,'value',low,...
      'position',[240,15,120,15],'tag','scalelow')
   uicontrol('style','text','position',[210,15,30,15],'tag','low_text')
   uicontrol('style','text','position',[175,15,35,15],'string','Low')
   uicontrol('style','slider','callback','play7 scale',...
      'min',low+3,'max',high,'value',high,...
      'position',[240,30,120,15],'tag','scalehigh')
   uicontrol('style','text','position',[210,30,30,15],'tag','high_text')
   uicontrol('style','text','position',[175,30,35,15],'string','High')
   uicontrol('style','checkbox','position',[370,15,60,15],...
       'string','HotPix','value',0,'tag','hotpix',...
       'callback','play7 scale','userdata',[high,hPix])
   uicontrol('style','checkbox','position',[370,30,60,15],...
       'string','ColdPix','value',0,'tag','coldpix',...
       'callback','play7 scale','userdata',[low,cPix])
   %%%controls for removing planes
   uicontrol('string','Keep planes','position',[30,150,80,15],...
       'callback','play7 keepPlane')
   uicontrol('string','Remove plane','position',[30,135,80,15],...
       'callback','play7 removePlane')
   uicontrol('string','Save Movie','position',[30,110,80,15],...
       'callback','play7 saveMovi')
   uicontrol('string','Save 1 image','position',[30,95,80,15],...
       'callback','play7 saveImage')
   uicontrol('style','checkbox','position',[40,80,70,15],...
       'string','8bit copy','value',0,'tag','c8bit')
   uicontrol('string','Make Stripe','position',[30,65,80,15],...
       'callback','play7 makeStripe')
   %%%controls for threshold annotation (automatic annotation)
   uicontrol('style','text','position',[30,360,30,15],'string','Thresh')
   uicontrol('style','edit','position',[60,360,40,15],'string','8400',...
       'tag','Thresh')
   uicontrol('string','Ann > Thresh','position',[30,345,70,15],...
       'TooltipString','Detects objects above threshold',...
       'tag','AnnTh','callback','play7 annoThr')
   %%%controls for annotating movie
   data = cell(1,size(M,3));
   uicontrol('style','text','position',[30,215,80,15],'string','ANNOTATE')
   uicontrol('style','toggle','position',[30,200,30,15],'string','Pick',...
       'tag','pick','callback','play7 pick','value',0)
   uicontrol('string','Show All','position',[60,200,50,15],...
       'callback','play7 showAll')
%    uicontrol('string','R_fr','position',[30,185,40,15],...
%        'TooltipString','Removes all events in frame',...
%        'callback','play7 rFrame')
   uicontrol('string','R_rgn','position',[70,185,40,15],...
       'TooltipString','Removes all events in region',...
       'callback','play7 rRegion')
   uicontrol('string','Load','position',[30,170,40,15],'tag','ld',...
       'callback','play7 ld')
   uicontrol('string','Save','position',[70,170,40,15],'tag','sv',...
       'callback','play7 sv','userdata',data)
   %%%controls for the zoom button
   uicontrol('style','toggle','position',[40,380,60,15],'string','ZOOM',...
       'tag','zoomOn','callback','play7 zoomToggle','value',0)
   %%%controls to select a region (to save a cropped movie/frame)
   uicontrol('style','text','position',[30,315,80,15],'string','REGION',...
       'tag','Region','userdata',[])
   uicontrol('style','toggle','position',[30,300,40,15],'string','Select',...
       'tag','selectR','callback','play7 selReg','value',0)
   uicontrol('string','Show','position',[70,300,40,15],'tag','showR',...
       'callback','play7 shReg')
   Ydim = size(M,1);
   Xdim = size(M,2);
   Xmid = floor(Xdim/2);
   uicontrol('string','leftIm','position',[30,285,40,15],'tag','leftImR',...
       'callback','play7 lImR','userdata',[1,1,Xmid-1,Ydim-1])
   uicontrol('string','rightIm','position',[70,285,40,15],'tag','rightImR',...
       'callback','play7 rImR','userdata',[Xmid+1,1,Xmid-1,Ydim-1])
   uicontrol('string','load','position',[30,270,30,15],'tag','ldR',...
       'callback','play7 ldReg')
   uicontrol('string','save','position',[60,270,30,15],'tag','sdR',...
       'callback','play7 svReg')
   uicontrol('string','erase','position',[90,270,30,15],'tag','erR',...
       'callback','play7 erReg')
   
   %%%controls for defining a mask
   uicontrol('style','text','position',[30,250,80,15],'string','MASK')
   uicontrol('string','Crea','position',[30,235,30,15],'tag','mask',...
       'callback','play7 crMask','userdata',zeros(size(M,1),size(M,2)),...
       'tooltipstring','Creates a mask')
   uicontrol('string','Load','position',[60,235,30,15],'tag','ldmsk',...
       'callback','play7 ldMask','tooltipstring','Loads a mask file')
   uicontrol('string','Qtf','position',[90,235,30,15],'tag','quantmsk',...
       'callback','play7 quantMask','tooltipstring','Quantif mask - background')
   set(gcf,'UserData',M,'keypressfcn','play7 key','doublebuffer','on',...
      'colormap',map)
   u = image(M(:,:,frame),'cdatamapping','scaled','tag','movi');
   set(gca,'clim',[low,high],'tag','moviaxis')
   %set(gca,'units','pixels')
   set(gca,'position',[0.13,0.15,0.9,0.75])
   h = title([stk,' Frame # = ',num2str(frame)],...
      'interpreter','none');
   set(h,'userdata',stk)
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
%minlow = get(findobj(children,'tag','scalelow'),'min');
%maxhigh = get(findobj(children,'tag','scalehigh'),'max');
hotPix = get(findobj(children,'tag','hotpix'),'value');
hPix = get(findobj(children,'tag','hotpix'),'userdata');
coldPix = get(findobj(children,'tag','coldpix'),'value');
cPix = get(findobj(children,'tag','coldpix'),'userdata');
%M = get(gcf,'userdata');
if hotPix
    maxhigh = hPix(2);
else
    maxhigh = hPix(1);
end
if coldPix
    minlow = cPix(2);
else
    minlow = cPix(1);
end
if high > maxhigh
    high = maxhigh;
end
if low < minlow
    low = minlow;
end
if high == minlow+1
   high = high +1;
end
if low == maxhigh-1
   low = low-1;
end

set(gca,'clim',[low,high])
set(findobj(children,'tag','scalelow'),'max',high-1,'min',minlow,...
   'sliderstep',[1/(high-1-minlow),25/(high-1-minlow)],...
   'value',low)
set(findobj(children,'tag','low_text'),'string',num2str(low));
set(findobj(children,'tag','scalehigh'),'min',low+1,'max',maxhigh,...
   'sliderstep',[1/(maxhigh-(low+1)),25/(maxhigh - (low+1))],...
   'value',high)
set(findobj(children,'tag','high_text'),'string',num2str(high));

function goto
M = get(gcf,'userdata');
children = get(gcf,'children');
frame = round(get(findobj(children,'tag','frame#'),'value'));
global stop
stop = 1;
data = get(findobj(children,'tag','sv'),'userdata');
events = data{frame};
delete(findobj(get(gca,'children'),'type','line'))
if ~isempty(events)
   line(events(:,1),events(:,2),'lineStyle','none','marker','o',...
      'markerEdgeColor','r','buttondownfcn','play7 pos')
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
if get(gcf,'currentcharacter') == 'c'
   if frame < size(M,3)
      frame = frame+1;
   end
end
if get(gcf,'currentcharacter') == 'v'
   if frame>1
      frame = frame-1;
   end
end
set(findobj(children,'tag','frame#'),'value',frame)
goto

function keepPlane
%The output is either a movie (a stk file) or a single image (a tif file)
M = get(gcf,'userdata');
children = get(gcf,'children');
keep = inputdlg({'Frames to keep'},'Keep frames');
if isempty(keep)
    return
end
keep = keep{1};
if ~isempty(str2num(keep))
    k_fr = str2num(keep);
else return
end
bounds = (k_fr>0) & (k_fr<=size(M,3));
k_fr = k_fr(find(bounds));
if isempty(k_fr),return,end
M = M(:,:,k_fr);
data = get(findobj(children,'tag','sv'),'userdata');
newdata = cell(1,size(M,3));
j=1;
for i=k_fr
    newdata{j} = data{i};
    j=j+1;
end
set(gcf,'userdata',M)
set(findobj(children,'tag','sv'),'userdata',newdata);
set(findobj(children,'tag','frame#'),'value',1)
delete(findobj(gcf,'tag','frame#'))
uicontrol('callback','play7 goto','string','frame#','style','slider',...
      'position',[50,15,90,15],'max',size(M,3),'min',1,'value',1,...
      'sliderstep',[1/(size(M,3)-1),10/(size(M,3)-1)],'tag','frame#');
goto
 
function removePlane
%removes frames, either the current frame, or a series of frames indicated
%by frame numbers separated by commas, or by :, i.e. 1:2:150 for all the 
%odd frames of a movie 150 frames long. 
%This is not a very efficient way to remove a large number of frames.
%Use keep planes instead (if available)
M = get(gcf,'userdata');
children = get(gcf,'children');
current_frame = round(get(findobj(children,'tag','frame#'),'value'));
remFrame = inputdlg({'Frame(s) to remove'},'Remove frames',1,{'current'});
if isempty(remFrame)
    return
end
remFrame = remFrame{1};
if isempty(remFrame)
    return
elseif strcmp(remFrame,'current')
    r_fr = current_frame;
elseif ~isempty(str2num(remFrame))
    r_fr = str2num(remFrame);
else return
end
data = get(findobj(children,'tag','sv'),'userdata');
removed = 0; %marks the number of frames already removed
for i = r_fr
    irm = i-removed;
    if (irm >= 1) && (irm <= size(M,3))
        M(:,:,irm) = [];
        data(irm) = [];
        removed = removed+1;
    end
end
set(gcf,'userdata',M)
set(findobj(children,'tag','frame#'),'value',1)
set(findobj(children,'tag','sv'),'userdata',data)
delete(findobj(gcf,'tag','frame#'))
uicontrol('callback','play7 goto','string','frame#','style','slider',...
      'position',[50,15,90,15],'max',size(M,3),'min',1,'value',1,...
      'sliderstep',[1/(size(M,3)-1),10/(size(M,3)-1)],'tag','frame#');
goto

function saveMovi
children = get(gcf,'children');
M = get(gcf,'userdata');
tit = get(gca,'title');
stk = get(tit,'userdata');
rect = get(findobj(children,'tag','Region'),'userdata');
if ~isempty(rect)
    button = questdlg('Save the movie on the selected region only?',...
    'Save movie on selected region','No');
    if strcmp(button,'Yes')
        bx = rect(1); by = rect(2); bw = rect(3); bh = rect(4);
        M = M(by:by+bh,bx:bx+bw,:);
    end
end
[stk,stkd] = uiputfile([stk(1:end-4),'-2',stk(end-3:end)],...
    'Name of the modified movie');
if ischar(stk) && ischar(stkd)
    stkwrite(M,stk,stkd)
end

function saveImage
M = get(gcf,'userdata');
children = get(gcf,'children');
rect = get(findobj(children,'tag','Region'),'userdata');
if ~isempty(rect)
    button = questdlg('Save the image on the selected region only?',...
    'Save image on selected region','No');
    if strcmp(button,'Yes')
        bx = rect(1); by = rect(2); bw = rect(3); bh = rect(4);
        M = M(by:by+bh,bx:bx+bw,:);
    end
end
current_frame = round(get(findobj(children,'tag','frame#'),'value'));
copy8bit = get(findobj(children,'tag','c8bit'),'value');
tifFrame = inputdlg({'Frame(s) to save as .tif file(s)'},...
    'Save Image',1,{'current'});
if isempty(tifFrame)
    return
end
tifFrame = tifFrame{1};
if isempty(tifFrame)
    return
elseif strcmp(tifFrame,'current')
    t_fr = current_frame;
elseif ~isempty(str2num(tifFrame))
    t_fr = str2num(tifFrame);
else return
end
%if size(t_fr,2)>1 return,end
if min(t_fr) < 1 || max(t_fr) > size(M,3)
    return,end
tit = get(gca,'title');
stk = get(tit,'userdata');
for i=t_fr
    imgM = M(:,:,i);
    if copy8bit
        limits = get(gca,'clim');
        imgM = double(imgM);
        imgM = 255.*(imgM-limits(1))./(limits(2)-limits(1));
        imgM = uint8(imgM);
    end
    [ftif,ptif] = uiputfile([stk(1:end-4),'fr',num2str(i),'.tif'],...
        'Image file name');
    if ischar(ftif)&&ischar(ptif)
        imwrite(imgM,[ptif,ftif],'tif','compression','none')
    end
end

function makeStripe
M = get(gcf,'userdata');
children = get(gcf,'children');
rect = get(findobj(children,'tag','Region'),'userdata');
if ~isempty(rect)
    button = questdlg('Make the stripe on the selected region only?',...
    'Make stripe on selected region','No');
    if strcmp(button,'Yes')
        bx = rect(1); by = rect(2); bw = rect(3); bh = rect(4);
        M = M(by:by+bh,bx:bx+bw,:);
    end
end
current_frame = round(get(findobj(children,'tag','frame#'),'value'));
copy8bit = get(findobj(children,'tag','c8bit'),'value');
params = inputdlg({'Frames to put on the stripe','orientation: horizontal=1, vertical=0','separation in pixels'},...
    'Make stripe',1,{'current','1','1'});
if isempty(params)
    return
end
frames = params{1};
if isempty(frames)
    return
elseif strcmp(frames,'current')
    t_fr = current_frame;
elseif ~isempty(str2num(frames))
    t_fr = str2num(frames);
else return
end
if min(t_fr) < 1 || max(t_fr) > size(M,3)
    return,end
numFrames = size(t_fr,2);

orient = params{2};
if isempty(orient)
    return
else orient = str2num(orient);
end
pixSep = params{3};
if isempty(pixSep)
    return
else pixSep = str2num(pixSep);
end
limits = get(gca,'clim');
hiPix = limits(2);
s1 = size(M,1);
s2 = size(M,2);
if orient %horizontal orientation
    stripe = zeros(s1,numFrames*(s2+pixSep)-pixSep);
    hiStripe = hiPix*ones(s1,pixSep);
    for i = 1:numFrames
        stripe(:,1+(s2+pixSep)*(i-1):s2+(s2+pixSep)*(i-1)) = M(:,:,t_fr(i));
        if i < numFrames
            stripe(:,s2*i+pixSep*(i-1)+1:(s2+pixSep)*i) = hiStripe;
        end
    end
elseif orient==0 %vertical orientation
    stripe = zeros(numFrames*(s1+pixSep)-pixSep,s2);
    hiStripe = hiPix*ones(pixSep,s2);
    for i = 1:numFrames
        stripe(1+(s1+pixSep)*(i-1):s1+(s1+pixSep)*(i-1),:) = M(:,:,t_fr(i));
        if i < numFrames
            stripe(s1*i+pixSep*(i-1)+1:(s1+pixSep)*i,:) = hiStripe;
        end
    end
else
    return
end
if copy8bit
    stripe = double(stripe);
    stripe = 255.*(stripe-limits(1))./(limits(2)-limits(1));
    stripe = uint8(stripe);
end
tit = get(gca,'title');
stk = get(tit,'userdata');
[ftif,ptif] = uiputfile([stk(1:end-4),'fr',num2str(t_fr(1)),'-',num2str(t_fr(end)),'.tif'],...
        'Image stripe file name');
if ischar(ftif)&&ischar(ptif)
    imwrite(stripe,[ptif,ftif],'tif','compression','none')
end

function selReg
children = get(gcf,'children');
selStatus = get(findobj(children,'tag','selectR'),'value');
region = get(findobj(children,'tag','Region'),'userdata');
if selStatus
    set(findobj(children,'tag','selectR'),'ForegroundColor','r')
    set(findobj(children,'tag','pick'),'value',0)
    set(findobj(children,'tag','zoomOn'),'value',0)
    %play7 pick
    play7 zoomToggle
    delete(findobj(children,'type','line','color','green'))
    [Xback,Yback,Back,rect] = imcrop;
    rect = round(rect);
    set(findobj(children,'tag','Region'),'UserData',rect);
    play7 shReg
end
set(findobj(children,'type','image'),'buttondownfcn','');
set(findobj(children,'tag','selectR'),'ForegroundColor','default','value',0)

function lImR %selects the left half of the image as a region
children = get(gcf,'children');
delete(findobj(children,'type','line','color','green'))
rect = get(findobj(children,'tag','leftImR'),'userdata');
set(findobj('tag','Region'),'UserData',rect);
play7 shReg

function rImR %selects the left half of the image as a region
children = get(gcf,'children');
delete(findobj(children,'type','line','color','green'))
rect = get(findobj(children,'tag','rightImR'),'userdata');
set(findobj('tag','Region'),'UserData',rect);
play7 shReg

function shReg
children = get(gcf,'children');
rect = get(findobj(children,'tag','Region'),'userdata');
if ~isempty(rect)
    bx = rect(1); by = rect(2); bw = rect(3); bh = rect(4);
    X = [bx,bx,bx+bw,bx+bw,bx];
    Y = [by,by+bh,by+bh,by,by];
    line('XData',X,'YData',Y,'color','g')
end

function svReg
children = get(gcf,'children');
rgn = get(findobj(children,'tag','Region'),'userdata');
stk = get(get(gca,'title'),'userdata');
[f,p] = uiputfile([stk(1:end-4),'_rgn.txt']...
      ,'Where to put the region file');
if ischar(f)&&ischar(p)
   dlmwrite([p,f],rgn,'\t')
end


function ldReg
children = get(gcf,'children');
stk = get(get(gca,'title'),'userdata');
[f,p] = uigetfile([stk(1:end-4),'_rgn.txt'],...
    'Choose the region text file');
if ischar(f)&&ischar(p)
    rgn = dlmread([p,f],'\t');
    if size(rgn)==[1 4]
       set(findobj(children,'tag','Region'),'UserData',rgn);
       delete(findobj(children,'type','line','color','green'))
       play7 shReg
    end
end

function erReg
children = get(gcf,'children');
set(findobj(children,'tag','Region'),'UserData',[]);
delete(findobj(children,'type','line','color','green'))

function zoomToggle
children = get(gcf,'children');
zoomStatus = get(findobj(children,'tag','zoomOn'),'value');
if zoomStatus
    set(findobj(children,'tag','zoomOn'),'ForegroundColor','r')
    set(findobj(children,'tag','pick'),'value',0)
    set(findobj(children,'tag','selectR'),'value',0)
    zoom on
    play7 pick
    %play7 selReg
else
    set(findobj(children,'tag','zoomOn'),'ForegroundColor','default')
    zoom off
end

function annoThr %Annotates the movie automatically on thresholded regions
%Ignores the first frame of the movie (maximum projection of the difference
%movie)
children = get(gcf,'children');
thresh = str2num(get(findobj(children,'tag','Thresh'),'string'));
if isempty(thresh),return,end
%This procedure will erase all annotate values entered before
%Put a question dialog box if necessary
%Set of parameters to define the thresholds for event detection
frbeg = 10; %number of frames to ignore at the beginning of the movie
frend = 10; %number of frames to ignore at the end of the movie
side = 7; %minimum number of pixels from the side of the image
distMin = 5; %minimum distance between objects on consecutive frames, 
             %to ignore events detected twice
negThresh = 6000; %threshold for "negative" values to reject events detected 
                  %because of movement. Put 0 or a very low value to make
                  %it inoperant
defaults = [thresh,frbeg,frend,side,distMin,negThresh];
prompt = {'Threshold for event detection (from the main window)',...
    'Number of frames to ignore at the beginning',...
    'Number of frames to ignore at the end of the movie',...
    'Minimum distance from the side of the image (in pixels)',...
    'Minimum distance between consecutive events to reject',...
    'Threshold below average to reject events detected with movement'};
[thresh,frbeg,frend,side,distMin,negThresh] = ...
    numinputdlg(prompt,'Parameters for exocytosis event detection on diff movie',1,defaults);
pause(1)
M = get(gcf,'userdata'); % the data file, or movie
dims = size(M);
data = cell(1,dims(3));
segM = M>thresh;
segMneg = M<negThresh;
for i=1+frbeg:dims(3)-frend
    lab = bwlabel(segM(:,:,i));
    prop = regionprops(lab,'basic');
    if ~isempty(prop)
        for j=1:size(prop,1)
            if prop(j).Area > 1
                XY = prop(j).Centroid;
                if (XY > 1+side)&(XY < [dims(2) dims(1)]-side) %#ok<AND2>
                   if i > 1
                       if ~isempty(data{i-1})
                           XYbef = data{i-1};
                           dBef = zeros(size(XYbef,1),1);
                           for u = 1:size(dBef,1)
            dBef(u) = sqrt((XY(1)-XYbef(u,1)).^2 + (XY(2)-XYbef(u,2)).^2);
                           end %there might be a better way than this loop...
                           test = dBef > distMin;
                       else
                           test = 1;
                       end
                       if test
                           rXY = round(XY);
    darkMoll = segMneg(rXY(2)-side+1:rXY(2)+side-1,rXY(1)-side+1:rXY(1)+side-1,i);
    nDark = sum(sum(darkMoll)); %number of dark pixels in the vicinity
                           if nDark<6
                               data{i}(end+1,1:2) = XY;
                           end
                       end
                   end
                end
            end
        end
    end
end
set(findobj(children,'tag','sv'),'userdata',data)
goto
        
function crMask
children = get(gcf,'children');
M = get(gcf,'userdata');
h_play = gcf;
%current_frame = round(get(findobj(children,'tag','frame#'),'value'));
%frMsk = M(:,:,current_frame);
frMsk = max(M,[],3);
stk = get(gcf,'name');
stk = stk(6:end);

mLow = min(min(frMsk));
mHigh = max(max(frMsk));
mskMap = gray(256);
mskMap(end,:) = [1 0 0];
h_mask = figure('name',['Mask ',stk]);
set(gcf,'userdata',frMsk,'colormap',mskMap);
image(frMsk,'cdatamapping','scaled','tag','maskImage')
uicontrol('position',[20,10,50,15],'style','text','string','Threshold')
uicontrol('position',[70,10,45,15],'style','text','tag','thresh_text',...
    'userdata',h_play)
uicontrol('position',[115,10,400,20],'style','slider',...
    'callback','play7 scaleMsk','tag','scaleth',...
    'min',mLow,'max',round(mHigh),'value',round(mHigh/4))
uicontrol('position',[10,50,90,20],'string','Create Mask',...
    'callback','play7 createMsk')
axis image
pixvalm
scaleMsk

function scaleMsk
children = get(gcf,'children');
threshold = round(get(findobj(children,'tag','scaleth'),'value'));
low = get(findobj(children,'tag','scaleth'),'min');
high = get(findobj(children,'tag','scaleth'),'max');
if threshold == low+1
    threshold = threshold+1;
end
if threshold == high-1
    threshold = threshold -1;
end
set(gca,'clim',[low,threshold])
set(findobj(children,'tag','thresh_text'),'string',num2str(threshold));
set(findobj(children,'tag','scaleth'),'value',threshold,...
    'sliderstep',[1/(high-low),10/(high-low)]);

function createMsk
stk = get(gcf,'name');
stk = stk(6:end);
children = get(gcf,'children');
threshold = get(findobj(children,'tag','scaleth'),'value');
h_play = get(findobj(children,'tag','thresh_text'),'userdata');
frMsk = get(gcf,'userdata'); 
C_mask = frMsk > threshold;
C_label = bwlabel(C_mask);
S = regionprops(C_label,'Area');
%%%Takes the N biggest regions (bigger than nPix/T) to create the mask
Nmax = 30; %Maximum number of subregions
% T = 1000; %minimum size of subregion (fraction of image), 524 for a 512*512 image
minArea = 2;
nPix = size(frMsk,1)*size(frMsk,2);
% minArea = round(nPix/T);
N = size([S.Area],2);% total number of regions
SR = cat(1,[S.Area],1:N)';
SR = sortrows(SR,1);
F_mask = frMsk < 0;
for i = 1:min(size(SR,1),Nmax)
    if SR(end-i+1,1) > minArea
        F_mask = F_mask | (C_label == SR(end-i+1,2));
    end
end
figure('name','mask','colormap',gray(4))
image(F_mask,'cdatamapping','scaled')
axis image

c = strfind(stk,'_');
if isempty(c)
    c = 5;
end
cellNum = num2str(stk(1:c));


[f,p] = uiputfile([cellNum,'mask.txt'],...
    'Where to put the mask file?');
if ischar(f) && ischar(p)
    dlmwrite([p,f],F_mask,'\t')
end
figure(h_play)
children = get(gcf,'children');
set(findobj(children,'tag','mask'),'userdata',F_mask);

function ldMask
children = get(gcf,'children');
oldMask = get(findobj(children,'tag','mask'),'userdata');
%stk = get(get(gca,'title'),'userdata');
[f,p] = uigetfile('*mask.txt','Choose the mask text file');
if ischar(f)&&ischar(p)
    mask = dlmread([p,f],'\t');
    if size(mask)== size(oldMask)
       set(findobj(children,'tag','mask'),'userdata',mask);
    else
       errordlg('Sizes of image and mask do not match')
    end
end

function quantMask
%Quantifies average fluorescence in mask - average fluorescence in
%background region for each frame
children = get(gcf,'children');
M = get(gcf,'userdata');
Mask = get(findobj(children,'tag','mask'),'userdata');
if ~max(max(Mask))
    errordlg('No mask has been selected')
    return
end
rect = get(findobj(children,'tag','Region'),'userdata');
if ~isempty(rect)
    bx = rect(1); by = rect(2); bw = rect(3); bh = rect(4);
    X = [bx,bx,bx+bw,bx+bw,bx];
    Y = [by,by+bh,by+bh,by,by];
    line('XData',X,'YData',Y,'color','g')
else
    errordlg('No background region selected')
    return
end

smsk = sum(sum(Mask)); %Size of mask, in pixels
fluo = zeros(1,size(M,3));
for i=1:size(M,3)
    cIm = double(M(:,:,i));
fluo(i) = sum(sum(cIm.*Mask))/smsk - mean(mean(cIm(by:by+bh,bx:bx+bw)));
end
h_play = gcf;
stk = get(gcf,'name');
stk = stk(6:end-4);
h_Curve = figure;
data = struct('name',stk,'mask',smsk,'bck',rect,'fluo',fluo);
uicontrol('string','Save quantif','position',[10,60,60,15],'tag','svQtf',...
    'callback','play7 svQuant', 'userdata',data)
plot(fluo)
ymax = max(get(gca,'ylim'));
ymin = min(get(gca,'ylim'));
if ymax > 0
    set(gca,'ylim',[0 ymax])
else
    set(gca,'ylim',[ymin 0])
end
xlabel('Frame #')
ylabel('average fluo')
title([stk,' Fluo in mask'])



function svQuant
children = get(gcf,'children');
data = get(findobj(children,'tag','svQtf'),'userdata');
disp(['fluorescence of the 1st frame: ', num2str(data.fluo(1))])
disp(['mean fluorescence: ', num2str(mean(data.fluo))])
disp('don''t forget to save background region!')
[f,p] = uiputfile([data.name,'_maskFluo.xlsx'],'File to save fluo data');
if ischar(f) && ischar(p)
    xlData = [data.mask;data.bck(3)*data.bck(4);mean(data.fluo);NaN;NaN;data.fluo'];
    xlAll = cell(size(xlData,1),2);
    xlAll{1,1} = 'MaskSize';
    xlAll{2,1} = 'BackSize';
    xlAll{3,1} = 'AvMaskFluo';
    xlAll{4,1} = 'file';
    xlAll{6,1} = 'Fluo-Bckgrnd';
    xlAll(:,2) = num2cell(xlData);
    xlAll{4,2} = f;
    warning off MATLAB:xlswrite:AddSheet
    xlswrite([p,f],xlAll, 'maskFluo')
end

function pick
children = get(gcf,'children');
if get(findobj(children,'tag','pick'),'value') == 1
   set(findobj(children,'tag','pick'),'ForegroundColor','r')
   set(findobj(children,'type','image'),'buttondownfcn',...
      'play7 pos');
   set(findobj(children,'tag','zoomOn'),'value',0)
   play7 zoomToggle
   %play7 selReg
else 
   set(findobj(children,'tag','pick'),'ForegroundColor','default')
   set(findobj(children,'type','image'),'buttondownfcn','');
end

function pos
M = get(gcf,'userdata');
xy = get(gca,'currentpoint');
xy = xy';
xy = xy(1:2);
children = get(gcf,'children');
frame = round(get(findobj(children,'tag','frame#'),'value'));
data = get(findobj(children,'tag','sv'),'userdata');

%to add an event, left-click
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

%to remove an event, right-click
if strcmp(get(gcf,'selectiontype'),'alt')
   if ~isempty(data{frame})
      A = abs(data{frame} - xy(ones(size(data{frame},1),1),:));    
      %A = abs(data{frame} - xy(ones(size(data{frame},1),1),:)); %old
      sA = sum(A,2);
      row = find(sA<4); %The right-click is less than 2 pixels from selection
      %a1 = A(:,1);
      %a2 = A(:,2);
      %row = find(a1&a2);
      if ~isempty(row)
         data{frame}(row,:)=[]; 
      end
   end
end
set(findobj(children,'tag','sv'),'userdata',data)
goto

function showAll
children = get(gcf,'children');
frame = round(get(findobj(children,'tag','frame#'),'value'));
data = get(findobj(children,'tag','sv'),'userdata');
for i=1:size(data,2)
    if ~isempty(data{i})
        line(data{i}(:,1),data{i}(:,2),'lineStyle','none','marker','+',...
            'markerEdgeColor','c', 'buttondownfcn','play7 pos')
    end
end
currEv = data{frame};
if ~isempty(currEv)
    line(currEv(:,1),currEv(:,2),'lineStyle','none','marker','o',...
      'markerEdgeColor','r','buttondownfcn','play7 pos')
end

% function rFrame
% children = get(gcf,'children');
% current_frame = round(get(findobj(children,'tag','frame#'),'value'));
% data = get(findobj(children,'tag','sv'),'userdata');
% tifFrame = inputdlg({'Frame at which all events will be removed'},...
%     'Remove from frame',1,{'current'});
% if isempty(tifFrame)
%     return
% end
% tifFrame = tifFrame{1};
% if isempty(tifFrame)
%     return
% elseif strcmp(tifFrame,'current')
%     t_fr = current_frame;
% elseif ~isempty(str2num(tifFrame))
%     t_fr = str2num(tifFrame);
% else return
% end
% data{t_fr} = [];
% set(findobj(children,'tag','sv'),'userdata',data)
% goto

function rRegion
children = get(gcf,'children');
data = get(findobj(children,'tag','sv'),'userdata');
rgn = get(findobj(children,'tag','Region'),'userdata');
current_frame = round(get(findobj(children,'tag','frame#'),'value'));
%button = questdlg('Remove events in the selected region?',...
%    'Remove events in rgn','No');
answer = inputdlg({'In region: 1, Outside region: -1, All image: 0','For which frame(s) (1:n,current,all)'},...
    'Remove events',1,{'1','current'});
if isempty(answer)
    return
end
if ~isempty(answer{1})
    inRegion = str2double(answer{1});
else
    inRegion = 0;
end
titFrame = answer{2};
if isempty(titFrame)
    return
elseif strcmp(titFrame,'current')
    t_fr = current_frame;
elseif strcmp(titFrame,'all')
    t_fr = 1:size(data,2);
elseif ~isempty(str2num(titFrame))
    t_fr = str2num(titFrame);
else return
end
if ~(inRegion == 0)
    if isempty(rgn)
        return
    end
    xMin = rgn(1);
    yMin = rgn(2); 
    xMax = xMin + rgn(3); 
    yMax = yMin + rgn(4);
    for i = t_fr
        if ~isempty(data{i})
            for j = size(data{i},1):-1:1
                x = data{i}(j,1);
                y = data{i}(j,2);
                if inRegion == 1
                    if (x>xMin&&y>yMin)&&(x<xMax&&y<yMax)
                        data{i}(j,:)=[];
                    end
                elseif inRegion == -1
                    if x<xMin||y<yMin||x>xMax||y>yMax
                        data{i}(j,:)=[];
                    end
                end
            end
        end
    end
else
    for i = t_fr
        data{t_fr} = [];
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
if ischar(f)&&ischar(p)
   dlmwrite([p,f],output,'\t')
end

function ld 
children = get(gcf,'children');
stk = get(get(gca,'title'),'userdata');
[f,p] = uigetfile('*.txt;*.trc','Choose the annotate.txt or .trc file');
if ischar(f)&&ischar(p)
   M = get(gcf,'userdata'); % the data file, or movie
   dims = size(M);
   data = cell(1,dims(3));
   ves = dlmread([p,f],'\t');
   if strfind(f,'.trc')
       lineXY = find(ves(:,1));
       ves(lineXY,3:4) = ves(lineXY,3:4)+1;
   end
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