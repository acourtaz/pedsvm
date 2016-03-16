function play4(action)

if nargin == 0
   [stk,stkd] = uigetfile('*.stk','Choose a Stack');
   if ~stk,return,end
   frame = 1;
   M = stkread(stk,stkd);
   figure('name',['Play ',stk])
   map = gray(256);
   %%%controls for playing the movie
   uicontrol('string','Stop','callback','play4 goto','position',[10,30,45,15])
   uicontrol('callback','play4 fullforward','string',...
      'Play -->','position',[100,30,45,15])
   uicontrol('callback','play4 fullbackward','string',...
      '<-- Play','position',[55,30,45,15])
   uicontrol('callback','play4 goto','string','frame#','style','slider',...
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
   uicontrol('style','slider','callback','play4 scale',...
      'min',low,'max',high-3,'value',low,...
      'position',[240,15,120,15],'tag','scalelow')
   uicontrol('style','text','position',[210,15,30,15],'tag','low_text')
   uicontrol('style','text','position',[175,15,35,15],'string','Low')
   uicontrol('style','slider','callback','play4 scale',...
      'min',low+3,'max',high,'value',high,...
      'position',[240,30,120,15],'tag','scalehigh')
   uicontrol('style','text','position',[210,30,30,15],'tag','high_text')
   uicontrol('style','text','position',[175,30,35,15],'string','High')
   uicontrol('style','checkbox','position',[370,15,60,15],...
       'string','HotPix','value',0,'tag','hotpix',...
       'callback','play4 scale','userdata',[high,hPix])
   uicontrol('style','checkbox','position',[370,30,60,15],...
       'string','ColdPix','value',0,'tag','coldpix',...
       'callback','play4 scale','userdata',[low,cPix])
   %%%controls for removing planes
   uicontrol('string','Keep planes','position',[30,150,80,15],...
       'callback','play4 keepPlane')
   uicontrol('string','Remove plane','position',[30,135,80,15],...
       'callback','play4 removePlane')
   uicontrol('string','Save Movie','position',[30,110,80,15],...
       'callback','play4 saveMovi')
   uicontrol('string','Save 1 image','position',[30,95,80,15],...
       'callback','play4 saveImage')
   uicontrol('style','checkbox','position',[40,80,70,15],...
       'string','8bit copy','value',0,'tag','c8bit')
   uicontrol('string','Make Stripe','position',[30,65,80,15],...
       'callback','play4 makeStripe')
   %%%controls for threshold annotation (automatic annotation)
   uicontrol('style','text','position',[30,360,30,15],'string','Thresh')
   uicontrol('style','edit','position',[60,360,40,15],'string','8400',...
       'tag','Thresh')
   uicontrol('string','Ann > Thresh','position',[30,345,70,15],...
       'tag','AnnTh','callback','play4 annoThr')
   %%%controls for annotating movie
   data = cell(1,size(M,3));
   uicontrol('style','text','position',[30,210,80,15],'string','ANNOTATE')
   uicontrol('style','toggle','position',[30,195,30,15],'string','Pick',...
       'tag','pick','callback','play4 pick','value',0)
   uicontrol('string','Show All','position',[60,195,50,15],...
       'callback','play4 showAll')
   uicontrol('string','Load','position',[30,180,40,15],'tag','ld',...
       'callback','play4 ld')
   uicontrol('string','Save','position',[70,180,40,15],'tag','sv',...
       'callback','play4 sv','userdata',data)
   %%%controls for the zoom button
   uicontrol('style','toggle','position',[40,240,60,15],'string','ZOOM',...
       'tag','zoomOn','callback','play4 zoomToggle','value',0)
   %%%controls to select a region (to save a cropped movie/frame)
   uicontrol('style','text','position',[30,315,80,15],'string','REGION',...
       'tag','Region','userdata',[])
   uicontrol('style','toggle','position',[30,300,40,15],'string','Select',...
       'tag','selectR','callback','play4 selReg','value',0)
   uicontrol('string','Show','position',[70,300,40,15],'tag','showR',...
       'callback','play4 shReg')
   Ydim = size(M,1);
   Xdim = size(M,2);
   Xmid = floor(Xdim/2);
   uicontrol('string','leftIm','position',[30,285,40,15],'tag','leftImR',...
       'callback','play4 lImR','userdata',[1,1,Xmid-1,Ydim-1])
   uicontrol('string','rightIm','position',[70,285,40,15],'tag','rightImR',...
       'callback','play4 rImR','userdata',[Xmid+1,1,Xmid-1,Ydim-1])
   uicontrol('string','load','position',[30,270,30,15],'tag','ldR',...
       'callback','play4 ldReg')
   uicontrol('string','save','position',[60,270,30,15],'tag','sdR',...
       'callback','play4 svReg')
   uicontrol('string','erase','position',[90,270,30,15],'tag','erR',...
       'callback','play4 erReg')
   set(gcf,'UserData',M,'keypressfcn','play4 key','doublebuffer','on',...
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
      'markerEdgeColor','r','buttondownfcn','play4 pos')
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
uicontrol('callback','play4 goto','string','frame#','style','slider',...
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
uicontrol('callback','play4 goto','string','frame#','style','slider',...
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
    %play4 pick
    play4 zoomToggle
    delete(findobj(children,'type','line','color','green'))
    [Xback,Yback,Back,rect] = imcrop;
    rect = round(rect);
    set(findobj('tag','Region'),'UserData',rect);
    play4 shReg
end
set(findobj(children,'type','image'),'buttondownfcn','');
set(findobj(children,'tag','selectR'),'ForegroundColor','default','value',0)

function lImR %selects the left half of the image as a region
children = get(gcf,'children');
delete(findobj(children,'type','line','color','green'))
rect = get(findobj(children,'tag','leftImR'),'userdata');
set(findobj('tag','Region'),'UserData',rect);
play4 shReg

function rImR %selects the left half of the image as a region
children = get(gcf,'children');
delete(findobj(children,'type','line','color','green'))
rect = get(findobj(children,'tag','rightImR'),'userdata');
set(findobj('tag','Region'),'UserData',rect);
play4 shReg

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
       play4 shReg
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
    play4 pick
    %play4 selReg
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
M = get(gcf,'userdata'); % the data file, or movie
dims = size(M);
data = cell(1,dims(3));
segM = M>thresh;
for i=2:dims(3)
    lab = bwlabel(segM(:,:,i));
    prop = regionprops(lab,'basic');
    if ~isempty(prop)
        for j=1:size(prop,1)
            if prop(j).Area > 1
                data{i}(end+1,1:2) = round(prop(j).Centroid);
            end
        end
    end
end
set(findobj(children,'tag','sv'),'userdata',data)
goto
        

function pick
children = get(gcf,'children');
if get(findobj(children,'tag','pick'),'value') == 1
   set(findobj(children,'tag','pick'),'ForegroundColor','r')
   set(findobj(children,'type','image'),'buttondownfcn',...
      'play4 pos');
   set(findobj(children,'tag','zoomOn'),'value',0)
   play4 zoomToggle
   %play4 selReg
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
            'markerEdgeColor','c','buttondownfcn','play4 pos')
    end
end
currEv = data{frame};
if ~isempty(currEv)
    line(currEv(:,1),currEv(:,2),'lineStyle','none','marker','o',...
      'markerEdgeColor','r','buttondownfcn','play4 pos')
end

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
[f,p] = uigetfile([stk(1:end-4),'_annotate.txt'],...
    'Choose the textfile with the Information to Load');
if ischar(f)&&ischar(p)
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