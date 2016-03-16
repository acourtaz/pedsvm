function browseFT1c(action)

%Written by DP last update 06/02/2012
%This function shows 'ministacks' around events that can be selected
%or rejected.
%Left image shows the average of n (default 5) frames before the event
%which will be used for background subtraction
%Middle image shows the movie of the event (green channel)
%Right image shows the movie of the associated protein (red channel)

if nargin == 0
   [stk,stkd] = uigetfile('*.stk','Choose the event stack (pH 5)');
   if ~stk,return,end
   M = stkread(stk,stkd);
%%%Used in browseEvents2 and up   
   
   pause(0.5)
   [f,p] = uigetfile('*.txt;*.trc','File with matrix of events');
   if ~f,return,end
   sTRC = ~isempty(strfind(f,'.trc'));
   events = dlmread([p,f],'\t');
   
  
%%% DEFAULT PARAMETERS FOR THE MINISTACKS %%%
   prompt = {'Size Ministack','Frames before event',...
       'Frames after start','Frames for average (before event)',...
       'Threshold for segmentation','Minimum pixels for object',...
       'Circle radius for mask'};
   [sizeMini before after av_high thresh pixT rCircle] = ...
numinputdlg(prompt,'Parameters for the ministacks',1,[25 10 30 5 5 4 2.2]);
   param = [sizeMini before after av_high thresh pixT rCircle];
   
   map = gray(256);
   removed = [];
   lastEvent = events(end,1);
   comments = cell(lastEvent,1);
   scrsz = get(0,'ScreenSize');
   h_movies = figure('name','Browse events',...
          'position',[scrsz(3)-1020 scrsz(4)-400 1000 350]);
       
%controls for playing the movie
   uicontrol('style','text','position',[10,15,35,15],'string','Frame')
  
%controls for the scales that do not change with each ministack
   uicontrol('style','text','position',[170,15,30,15],'tag','low_textAv')
   uicontrol('style','text','position',[170,30,30,15],'tag','high_textAv')
   uicontrol('style','text','position',[125,30,45,15],'string','Average')
   
   uicontrol('style','text','position',[450,15,30,15],'tag','low_textGr')
   uicontrol('style','text','position',[450,30,30,15],'tag','high_textGr')
   uicontrol('style','text','position',[405,30,45,15],'string','Green')
   
   uicontrol('style','text','position',[730,15,30,15],'tag','low_textRe')
   uicontrol('style','text','position',[730,30,30,15],'tag','high_textRe')
   uicontrol('style','text','position',[685,30,45,15],'string','Red')

   
   
% controls to browse ministacks
   uicontrol('style','text','position',[20,315,70,15],'string','EVENTS',...
       'tag','param','userdata',param)
   uicontrol('callback','browseFT1c previousEvent','string','PREVIOUS',...
       'position',[20,300,70,15])
   uicontrol('callback','browseFT1c nextEvent','string','NEXT',...
       'position',[20,285,70,15])
   uicontrol('style','text','string','#','position',[20,270,10,15],...
       'tag','coeff')
   
   uicontrol('string','Go','callback','browseFT1c gotoEvent',...
       'position',[70,270,20,15],'tag','CurvesEv','userdata',[])
   
% controls for showing the tracked object coordinates
   uicontrol('style','checkbox','string','Track','value',1,...
       'position',[20,255,70,15],'userdata',events,'tag','trackEvents',...
       'callback','browseFT1c track')
   
% controls to tag and remove ministacks
   uicontrol('style','text','position',[20,230,70,15],...
       'string','removed file')
   uicontrol('callback','browseFT1c loadRemoved','string','Load',...
       'position',[20,215,70,15],...
       'TooltipString',' Loads a removed event file ')
   uicontrol('callback','browseFT1c saveRemoved','string','Save',...
       'position',[20,200,70,15],...
       'TooltipString',' Saves the removed event file ')   
   uicontrol('style','checkbox','callback','browseFT1c removeEvent',...
       'string','Remove','value',0,...
       'position',[20,185,70,15],'userdata',removed,'tag','removedEvent')
   handle_rem = uibuttongroup('units','pixels','position',[25,125,60,60],...
       'tag','removeCause');
   uicontrol('style','radio','string','cluster','position',[0,45,60,15],...
       'parent',handle_rem,'tag','rcluster','enable','off')
   uicontrol('style','radio','string','S/N','position',[0,30,60,15],...
       'parent',handle_rem,'tag','rSN','enable','off')
   uicontrol('style','radio','string','track','position',[0,15,60,15],...
       'parent',handle_rem,'tag','rtrack','enable','off')
   uicontrol('style','radio','string','other','position',[0,0,60,15],...
       'parent',handle_rem,'tag','rother','enable','off')
   set(handle_rem,'SelectionChangeFcn','browseFT1c removeEvent')
   
% controls to write comments
   uicontrol('style','text','position',[10,104,50,15],'string','comments')
   uicontrol('tag','commentEvent','callback','browseFT1c addComment',...
       'string','Add','position',[65,105,25,15],'userdata',comments)
   uicontrol('style','edit','tag','comment','position',[5,88,100,17],...
      'horizontalalignment','left')
   uicontrol('callback','browseFT1c loadComments','string','Load',...
       'position',[20,73,35,15])
   uicontrol('callback','browseFT1c saveComments','string','Save',...
       'position',[55,73,35,15])
   
% misc. controls  
   Fluo = cell(1,1);
   uicontrol('callback','browseFT1c writeExcel','string','WriteXLS',...
       'position',[20,55,70,15],'tag','Fluo','userdata',Fluo,...
       'tooltipstring',' Write failed/passed events in summary excel file')
   uicontrol('callback','browseFT1c removeTRC','string','RemoveTRC',...
       'position',[20,40,70,15],'tag','TRC','userdata',sTRC,...
       'tooltipstring',' Removes tagged events from trc file permanently')
%%%
   
   set(gcf,'UserData',M,'keypressfcn',@keyBrowse,'doublebuffer','on',...
      'colormap',map,'tag',[stkd,stk])
      %'closerequestfcn','browseFT1c saveRemovedandClose')
   if events(1,1) == 0
       firstEvent = events(2,1);
   else
       firstEvent = events(1,1);
   end
   ministack(firstEvent)
   mzoom on
   %pixvalm
   scale
   %goto
else
    eval(action)
end

function ministack(numEv)
children = get(gcf,'children');
M = get(gcf,'userdata');
%width = size(M,1)./2; %3; in browseEvents2
%M5 = M(width+1:2*width,:,:);
%M5 = M(1:width,:,:);
%Mred = M(width+1:end,:,:);
events = get(findobj(children,'tag','trackEvents'),'userdata');
param = get(findobj(children,'tag','param'),'userdata');
%coeff = get(findobj(children,'tag','coeff'),'userdata');
sTRC = get(findobj(children,'tag','TRC'),'userdata');
h_cEv = get(findobj(children,'tag','CurvesEv'),'userdata');
Fluo = get(findobj(children,'tag','Fluo'),'userdata');
firstEvent = events(2,1);
lastEvent = events(end,1);
eventTrack = events(:,1)==numEv;
[isAnEvent,start] = max(eventTrack);

%calculates the ministacks for the event
frame = round(events(start,2));
a = floor(param(1)/2);  % 12 if sizeStack=param(1)=25 
xGreen = round(events(start,4)) + sTRC;
yGreen = round(events(start,3)) + sTRC;
x_miniGreen = max(1,xGreen-a);
y_miniGreen = max(1,yGreen-a);
x_maxiGreen = min(size(M,1),xGreen+a);
y_maxiGreen = min(size(M,2),yGreen+a);
t_mini = max(frame-param(2),1); %event will start at frame param(2)+1 = 21 or less
t_maxi = min(frame+param(3),size(M,3));
MiniGr = M(x_miniGreen:x_maxiGreen,y_miniGreen:y_maxiGreen,t_mini:t_maxi);
%replace by M5 to avoid problems???
MiniBck = M(x_miniGreen:x_maxiGreen,y_miniGreen:y_maxiGreen,frame-param(4):frame-1);
MiniBck = double(MiniBck);
MiniAv = sum(MiniBck,3)./param(4);
MiniAv2 = MiniAv(:,:,ones(1,size(MiniBck,3)));
MiniBck = MiniBck-MiniAv2;
MiniStd = std(MiniBck(:)); %%%%used for the tubule segmentation line 402
    %needs to add zeros
if xGreen-a < 1
    comp = zeros(1-xGreen+a,size(MiniGr,2),size(MiniGr,3));
    compAv = comp(:,:,1);
    MiniGr = cat(1,comp,MiniGr);
    MiniAv = cat(1,compAv,MiniAv);
end
if xGreen+a > size(M,1)
    comp = zeros(xGreen+a-size(M,1),size(MiniGr,2),size(MiniGr,3));
    compAv = comp(:,:,1);
    MiniGr = cat(1,MiniGr,comp);
    MiniAv = cat(1,MiniAv,compAv);
end
if yGreen-a < 1
    comp = zeros(size(MiniGr,1),1-yGreen+a,size(MiniGr,3));
    compAv = comp(:,:,1);
    MiniGr = cat(2,comp,MiniGr);
    MiniAv = cat(2,compAv,MiniAv);
end
if yGreen+a > size(M,2)
    comp = zeros(size(MiniGr,1),yGreen+a-size(M,2),size(MiniGr,3));
    compAv = comp(:,:,1);
    MiniGr = cat(2,MiniGr,comp);
    MiniAv = cat(2,MiniAv,compAv);
end

%checks for removed status
removedBox = findobj(gcf,'tag','removedEvent');
removed = get(removedBox,'userdata');
if ~isempty(removed)
    tag = max(removed(:,1)==numEv);
    if tag>0
        set(removedBox,'value',1)
    else
        set(removedBox,'value',0)
    end
else
    set(removedBox,'value',0)
end
rr = get(removedBox,'value');
if rr
    set(findobj(children,'tag','rcluster'),'enable','on')
    set(findobj(children,'tag','rSN'),'enable','on')
    set(findobj(children,'tag','rtrack'),'enable','on')
    set(findobj(children,'tag','rother'),'enable','on')
else
    set(findobj(children,'tag','rcluster'),'enable','off')
    set(findobj(children,'tag','rSN'),'enable','off')
    set(findobj(children,'tag','rtrack'),'enable','off')
    set(findobj(children,'tag','rother'),'enable','off')
end

%checks for comments
comments = get(findobj(children,'tag','commentEvent'),'userdata');
set(findobj(children,'tag','comment'),'string',comments{numEv})

% sets the controls for the ministack
delete(findobj(gcf,'tag','scalelowAv'))
delete(findobj(gcf,'tag','scalehighAv'))
delete(findobj(gcf,'tag','scalelowGr'))
delete(findobj(gcf,'tag','scalehighGr'))
%delete(findobj(gcf,'tag','scalelowRe'))
%delete(findobj(gcf,'tag','scalehighRe'))

delete(findobj(gcf,'tag','frame#')) 
delete(findobj(gcf,'tag','EvNumber'))
lowAv = double(min(min(MiniAv(:,:))));
highAv = double(max(max(MiniAv(:,:))));
lowGr = double(min(min(min(MiniGr(:,:,:)))));
highGr = double(max(max(max(MiniGr(:,:,:)))));
%lowRe = double(min(min(min(MiniRe(:,:,:)))));
%highRe = double(max(max(max(MiniRe(:,:,:)))));

uicontrol('style','slider',...
      'callback','browseFT1c scaleAv',...
      'min',lowAv,'max',highAv-3,...
      'value',lowAv,...
      'position',[200,15,150,15],'tag','scalelowAv')
uicontrol('style','slider',...
      'callback','browseFT1c scaleAv',...
      'min',lowAv+3,'max',highAv,...
      'value',highAv,...
      'position',[200,30,150,15],'tag','scalehighAv')
uicontrol('style','slider',...
      'callback','browseFT1c scaleGr',...
      'min',lowGr,'max',highGr-3,...
      'value',lowGr,...
      'position',[480,15,150,15],'tag','scalelowGr')
uicontrol('style','slider',...
      'callback','browseFT1c scaleGr',...
      'min',lowGr+3,'max',highGr,...
      'value',highGr,...
      'position',[480,30,150,15],'tag','scalehighGr')

uicontrol('callback','browseFT1c goto','tag','frame#',...
      'style','slider',...
      'position',[45,15,80,15],...
      'max',size(MiniGr,3),...
      'min',1,...
      'value',1,...
      'sliderstep',[1/(size(MiniGr,3)-1),10/(size(MiniGr,3)-1)])
uicontrol('style','edit','tag','EvNumber','string',num2str(numEv),...
      'position',[30,270,40,15],'userdata',numEv)

%draws the average cluster (pH7) image
subplot(1,3,1,'replace')
image(MiniAv(:,:),'cdatamapping','scaled','tag','moviAv')
set(gca,'clim',[lowAv,highAv],'tag','axisAv','userdata',MiniAv)
axis image
browseFT1c scaleAv

%draws the green ministack image
subplot(1,3,2,'replace')
image(MiniGr(:,:,1),'cdatamapping','scaled','tag','moviGr')
set(gca,'clim',[lowGr,highGr],'tag','axisGr','userdata',MiniGr)
cellNum = get(gcf,'tag');
c = strfind(cellNum,'\');
c = c(end)+1;
h = title(['Cell ',cellNum(c:c+4),'  Event ',num2str(numEv),'  Frame # = ',num2str(-param(2))],...
    'interpreter','none');
set(h,'userdata',['Cell ',cellNum(c:c+4),'  Event ',num2str(numEv)])
axis image
pixvalm
browseFT1c scaleGr

goto
h_movies = gcf;
curves = 1;
if curves

    thresh = param(5); %Threshold (multiples of background SD) to segment image
    pixThresh = param(6); %Minimal number of pixels for detectable object
    rCircle = param(7); %radius (in pixels) of circle used to quantify fluo as minimum
    
    l_t0 = min(frame,param(2)+1);
    sGr = size(MiniGr);
    
%file for fluorescent quantification
    val = zeros(1,param(2)+param(3)+9);
    val(1) = numEv;
    
%background subtraction
    MiniGb = double(MiniGr);
    back_Gr = MiniAv(:,:,ones(1,size(MiniGb,3)));
    MiniGb = MiniGb - back_Gr;
    
 
    [x,y] = meshgrid(1:size(MiniGb,2),1:size(MiniGb,1));
    center = round((param(1)+1)/2);
    x0 = events(start,3) + sTRC;
    ix0 = floor(x0);
    dx0 = x0-ix0;
    l_x0 = center+dx0; %local x coordinate
    y0 = events(start,4) + sTRC;
    iy0 = floor(y0);
    dy0 = y0-iy0;
    l_y0 = center+dy0; %local y coordinate
    distance = sqrt((x-l_x0).^2 + (y-l_y0).^2);
    mask = distance<rCircle;
    mask = mask(:,:,ones(1,size(MiniGb,3)));
    
%shapes the mask with tubule thresholding (from fluoTubules)
    tubTh = 1;
    if tubTh
        evThr = MiniStd*thresh;
        %%%Filtering of movie, gaussian filter (default params)
        hgauss = fspecial('gaussian');
        MiniGf = MiniGb;
        for k=1:size(MiniGb,3)
            MiniGf(:,:,k) = imfilter(MiniGb(:,:,k),hgauss);
        end
        segMiniG = MiniGf>evThr; %segmented movie of tubule

        si = l_t0; %token for frames in segmented tubules
        %tub = 1; 1 if there is a tubule, 0 if a point like structure
%%%%Calculations for start frame 
        labMin = bwlabel(segMiniG(:,:,si),4); %4-connected objects
        prop = regionprops(labMin,'Area');
        if ~isempty(prop) %To clean up the segmented area
            for j = 1:size(prop,1)
                if prop(j).Area < pixThresh %default: 5, line 369
                    labMin(find(labMin==j))=0;
                end
            end
        end
        prop = regionprops(labMin,'All');
%if computing all tubules parameters, like in fluoTubules.m, use:
%       prop = regionprops(labMin,'all');
        if isempty(prop)
            tub = 0;
            val(3) = pixThresh - 1;
            val(4:6) = 0;
        else
            tub = 1;
            Ntub = size(prop,1);
            distub = zeros(1,Ntub);
            for j = 1:Ntub
                XY = prop(j).Centroid;
                distub(j) = sqrt((XY(1)-l_x0)^2+(XY(2)-l_y0)^2);
            end
            [dtub,itub] = min(distub);
            if dtub < 5 %tubule does not move more than 5 pixels
                l_tub = labMin==itub;
                l_tub = l_tub(:,:,ones(1,l_t0));
                mask(:,:,1:l_t0) = l_tub|mask(:,:,1:l_t0);
%Mask is the same for all frames before event
                %val(2) tubule persistence, in frames
                
                l_x0 = prop(itub).Centroid(1); %Need to put back right coordinates!!!
                l_y0 = prop(itub).Centroid(2);
                val(3) = prop(itub).Area;
                val(4) = prop(itub).Eccentricity;
                val(5) = prop(itub).MajorAxisLength;
                val(6) = prop(itub).Orientation;
            end
        end
        trXY = [l_x0 l_y0]; % tracking local coordinates
%%%Calculations for tracked frames
        si = si+1;
        while tub && (si < size(MiniGb,3))
        labMin = bwlabel(segMiniG(:,:,si),4); %4-connected objects
        prop = regionprops(labMin,'Area');
        if ~isempty(prop) %To clean up the segmented area
            for j = 1:size(prop,1)
                if prop(j).Area < pixThresh %default: 5
                    labMin(find(labMin==j))=0;
                end
            end
        end
        prop = regionprops(labMin,'Centroid');
        if isempty(prop)
            tub = 0;
        else
            tub = 1;
            Ntub = size(prop,1);
            distub = zeros(1,Ntub);
            for j = 1:Ntub
                XY = prop(j).Centroid;
                distub(j) = sqrt((XY(1)-trXY(end,1))^2+(XY(2)-trXY(end,2))^2);
            end
            [dtub,itub] = min(distub);
            if dtub < 5 %tubule does not move more than 5 pixels
                trXY = [trXY;prop(itub).Centroid(1) prop(itub).Centroid(2)];
                distance = sqrt((x-trXY(end,1)).^2 + (y-trXY(end,2)).^2);
                mask(:,:,si) = distance<rCircle;
                mask(:,:,si) = labMin==itub|mask(:,:,si);
  %Need to put back right (not local) coordinates!!!
                si=si+1;
            else
                tub = 0;
            end
        end
        end
        for k = si:size(MiniGb,3)
            mask(:,:,k) = mask(:,:,si-1);
        end
        val(2) = si-l_t0; %tubule persistence, in frames
        valR(2) = val(2);
    end
    
    
    %makes the figures
    if isempty(h_cEv)
        scrsz = get(0,'ScreenSize');
        h_cEv = figure('name',['Curves event ',num2str(numEv)],...
            'position',[scrsz(3)-1020 scrsz(4)-910 1000 425]);
        figure(h_movies)
        set(findobj(children,'tag','CurvesEv'),'userdata',h_cEv);
        figure(h_cEv)
    else
        figure(h_cEv)
        set(gcf,'name',['Curves event ',num2str(numEv)]);
    end
    
    subplot(2,2,1:2)
    
    p4 = param(4);
    af = min(size(MiniGb,3)-l_t0,10);
    maxGb = max(max(max(MiniGb(:,:,l_t0-p4:l_t0+af))));
    minGb = min(min(min(MiniGb(:,:,l_t0-p4:l_t0+af))));
    im_Gr = (MiniGb(:,:,l_t0-p4:l_t0+af)-minGb)./(maxGb-minGb);
    im_Gr = reshape(im_Gr,[sGr(1) sGr(2)*(p4+af+1)]);
    
  
    im_mask = ...
reshape(mask(:,:,l_t0-p4:l_t0+af),[sGr(1) sGr(2)*(p4+af+1)]);
    
    im_seg = ...
reshape(segMiniG(:,:,l_t0-p4:l_t0+af),[sGr(1) sGr(2)*(p4+af+1)]);

    im_Tot = cat(1,im_Gr,im_mask,im_seg);
    
    image(im_Tot,'cdatamapping','scaled')
    axis image
    axis off
    colormap gray(256)
    
%curves for green and red channels    
    subplot(2,2,3)
    ampG = squeeze(sum(sum(MiniGb.*mask)));
    plot(ampG,'g')
    hold on
    plot(l_t0-p4:si-1,ampG(l_t0-p4:si-1),'og','markerfacecolor','g')
    plot(l_t0-p4:l_t0+af,ampG(l_t0-p4:l_t0+af),'og')
    line([l_t0 l_t0],ylim)
    hold off
    
            
%Updates the Fluo quantification matrix
    val(param(2)-l_t0+10:param(2)-l_t0+9+size(mask,3)) = ampG;
    if isempty(Fluo{1})
        Fluo{1} = val;
    else
%checks if fluo has already been computed for this event
        eventTrack = Fluo{1}(:,1)==numEv;
        [isThere,z] = max(eventTrack);
        if isThere
            Fluo{1}(z,:) = val;
        else
            Fluo{1} = [Fluo{1};val];
            Fluo{1} = sortrows(Fluo{1});
        end
    end
    figure(h_movies)
    children = get(gcf,'children');
    set(findobj(children,'tag','Fluo'),'userdata',Fluo)
end


%Third order polynomials for interpolation

function u = interPolx(x,y,c)
u = c(1) + c(2).*x + c(3).*x.^2 + c(4).*x.^3 +...
   c(5).*y + c(6).*y.^2 + c(7).*y.^3;

function v = interPoly(x,y,c)
v = c(8) + c(9).*x + c(10).*x.^2 + c(11).*x.^3 +...
   c(12).*y + c(13).*y.^2 + c(14).*y.^3;

function scaleAv
children = get(gcf,'children');
low = ceil(get(findobj(children,'tag','scalelowAv'),'value'));
high = floor(get(findobj(children,'tag','scalehighAv'),'value'));
minlow = get(findobj(children,'tag','scalelowAv'),'min');
maxhigh = get(findobj(children,'tag','scalehighAv'),'max');
if high == minlow+1
   high = high +1;
end
if low == maxhigh-1
   low = low-1;
end

set(findobj(children,'tag','axisAv'),'clim',[low,high])
set(findobj(children,'tag','scalelowAv'),'max',high-1,...
   'sliderstep',[1/(high-1-minlow),25/(high-1-minlow)],...
   'value',low)
set(findobj(children,'tag','low_textAv'),'string',num2str(low));
set(findobj(children,'tag','scalehighAv'),'min',low+1,...
   'sliderstep',[1/(maxhigh-(low+1)),25/(maxhigh - (low+1))],...
   'value',high)
set(findobj(children,'tag','high_textAv'),'string',num2str(high));

function scaleGr
children = get(gcf,'children');
low = ceil(get(findobj(children,'tag','scalelowGr'),'value'));
high = floor(get(findobj(children,'tag','scalehighGr'),'value'));
minlow = get(findobj(children,'tag','scalelowGr'),'min');
maxhigh = get(findobj(children,'tag','scalehighGr'),'max');
if high == minlow+1
   high = high +1;
end
if low == maxhigh-1
   low = low-1;
end

set(findobj(children,'tag','axisGr'),'clim',[low,high])
set(findobj(children,'tag','scalelowGr'),'max',high-1,...
   'sliderstep',[1/(high-1-minlow),25/(high-1-minlow)],...
   'value',low)
set(findobj(children,'tag','low_textGr'),'string',num2str(low));
set(findobj(children,'tag','scalehighGr'),'min',low+1,...
   'sliderstep',[1/(maxhigh-(low+1)),25/(maxhigh - (low+1))],...
   'value',high)
set(findobj(children,'tag','high_textGr'),'string',num2str(high));

function goto
children = get(gcf,'children');
MiniGr = get(findobj(children,'tag','axisGr'),'userdata');
MiniRe = get(findobj(children,'tag','axisRe'),'userdata');
frame = round(get(findobj(children,'tag','frame#'),'value'));
param = get(findobj(children,'tag','param'),'userdata');
global stop
stop = 1;
imgGr = MiniGr(:,:,frame);
set(findobj(children,'tag','moviGr'),'cdata',imgGr)
tit = get(findobj(children,'tag','axisGr'),'title');
stk = get(tit,'userdata');
axes(findobj(children,'tag','axisGr'))
title([stk,' Frame # = ',num2str(frame-param(2)-1)]);
delete(findobj(get(findobj(children,'tag','axisGr'),'children'),...
    'type','line'))
trackBox = findobj(children,'tag','trackEvents');
trackStatus = get(trackBox,'value');
if trackStatus
    drawtrack
end

function keyBrowse(src,evnt)
%children = get(gcf,'children');
%Mini = get(findobj(children,'tag','axisGr'),'userdata');
%frame = round(get(findobj(children,'tag','frame#'),'value'));
%global stop
%stop = 1;
if evnt.Character == 'v'
    children = get(gcf,'children');
    Mini = get(findobj(children,'tag','axisGr'),'userdata');
    frame = round(get(findobj(children,'tag','frame#'),'value'));
   if frame < size(Mini,3)
      frame = frame+1;
      drawnow
      set(findobj(children,'tag','frame#'),'value',frame)
   end
end
if evnt.Character == 'c'
    children = get(gcf,'children');
    Mini = get(findobj(children,'tag','axisGr'),'userdata');
    frame = round(get(findobj(children,'tag','frame#'),'value'));
    if frame>1
      frame = frame-1;
      drawnow
      set(findobj(children,'tag','frame#'),'value',frame)
   end
end
%set(findobj(children,'tag','frame#'),'value',frame)
if evnt.Character == 'n'
    browseFT1c nextEvent
end
if evnt.Character == 'p'
    browseFT1c previousEvent
end
%if get(gcf,'currentcharacter') == 'r'
%    removeEvent
%end
goto

function previousEvent
addComment
children = get(gcf,'children');
M = get(gcf,'userdata');
events = get(findobj(children,'tag','trackEvents'),'userdata');
numEv = get(findobj(children,'tag','EvNumber'),'userdata');
if events(1,1) == 0
    firstEvent = round(events(2,1));
else
    firstEvent = round(events(1,1));
end
isAnEvent = false;
if numEv < firstEvent
    numEv = firstEvent;
end
while ~isAnEvent && (numEv > firstEvent)
    numEv = numEv-1;
    eventTrack = events(:,1)==numEv;
    isAnEvent = max(eventTrack);
end
ministack(numEv)

function nextEvent
addComment
children = get(gcf,'children');
M = get(gcf,'userdata');
events = get(findobj(children,'tag','trackEvents'),'userdata');
numEv = get(findobj(children,'tag','EvNumber'),'userdata');
lastEvent = round(events(end,1));
isAnEvent = false;
if numEv > lastEvent
    numEv = lastEvent;
end
while ~isAnEvent && (numEv < lastEvent)
    numEv = numEv+1;
    eventTrack = events(:,1)==numEv;
    isAnEvent = max(eventTrack);
end
ministack(numEv)

function gotoEvent
addComment
children = get(gcf,'children');
M = get(gcf,'userdata');
events = get(findobj(children,'tag','trackEvents'),'userdata');
numEv = str2num(get(findobj(children,'tag','EvNumber'),'string'));
if isempty(numEv),return,end
if events(1,1) == 0
    firstEvent = round(events(2,1));
else
    firstEvent = round(events(1,1));
end
lastEvent = round(events(end,1));
if numEv < firstEvent
    numEv = firstEvent;
end
if numEv >= lastEvent
    numEv = lastEvent;
end
if firstEvent < numEv && numEv < lastEvent
    eventTrack = events(:,1)==numEv;
    isAnEvent = max(eventTrack);
    while ~isAnEvent && (numEv < lastEvent)
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
    delete(findobj(get(findobj(children,'tag','axisGr'),'children'),...
        'type','line'))
end

function drawtrack
children = get(gcf,'children');
param = get(findobj(children,'tag','param'),'userdata');
frame = round(get(findobj(children,'tag','frame#'),'value'));
events = get(findobj(children,'tag','trackEvents'),'userdata');
numEv = get(findobj(children,'tag','EvNumber'),'userdata');
eventTrack = events(:,1)==numEv;
[isAnEvent,startEvent] = max(eventTrack);
if events(startEvent,2) <= param(2)
    absFrame = round(startEvent+frame-events(startEvent,2));
else
    absFrame = round(startEvent+frame-param(2)-1);
end
if absFrame <= size(eventTrack,1) && absFrame > 0
if isAnEvent && eventTrack(absFrame)
    center = round((param(1)+1)/2); %normally 13 for a 25x25 ministack
    % local coordinates of the tracked object center
    objectX = events(absFrame,3)-round(events(startEvent,3)) + center;
    objectY = events(absFrame,4)-round(events(startEvent,4)) + center;
    %axes(get(findobj(children,'tag','axisGr')))
    %line('xdata',objectX,'ydata',objectY,'linestyle','none',...
    %    'marker','+','markerEdgeColor','green')
    %axes(get(findobj(children,'tag','axisRe')))
    line('xdata',objectX,'ydata',objectY,'linestyle','none',...
        'marker','+','markerEdgeColor','red')
end
end

function removeEvent
children = get(gcf,'children');
removedBox = findobj(children,'tag','removedEvent');
removedStatus = get(removedBox,'value');
removed = get(removedBox,'userdata');
numEv = get(findobj(children,'tag','EvNumber'),'userdata');
if ~isempty(removed)
    tag = removed(:,1)==numEv;
    [c,i] = max(tag);
end
if removedStatus
    rc = get(findobj(children,'tag','rcluster'),'value');
    rs = get(findobj(children,'tag','rSN'),'value');
    rt = get(findobj(children,'tag','rtrack'),'value');
    ro = get(findobj(children,'tag','rother'),'value');
    numLine = [numEv rc rs rt ro];
    if isempty(removed)
        removed = numLine;
    else
        if c>0
            removed(i,:) = numLine;
        else
            removed = cat(1,removed,numLine);
            removed = sortrows(removed);
        end
    end
    set(findobj(children,'tag','rcluster'),'enable','on')
    set(findobj(children,'tag','rSN'),'enable','on')
    set(findobj(children,'tag','rtrack'),'enable','on')
    set(findobj(children,'tag','rother'),'enable','on')
else
    if ~isempty(removed) && c>0
        removed(i,:) = [];
    end
    set(findobj(children,'tag','rcluster'),'enable','off')
    set(findobj(children,'tag','rSN'),'enable','off')
    set(findobj(children,'tag','rtrack'),'enable','off')
    set(findobj(children,'tag','rother'),'enable','off')
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
    numEv = get(findobj(children,'tag','EvNumber'),'userdata');
    tag = max(removed==numEv);
    if tag>0
        set(removedBox,'value',1)
    else
        set(removedBox,'value',0)
    end
end
loadComments
goto

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
if ischar(fle)&&ischar(pth)
   dlmwrite([pth,fle],removed,'\t')
end
saveComments
goto

function addComment
children = get(gcf,'children');
comments = get(findobj(children,'tag','commentEvent'),'userdata');
evComment = get(findobj(children,'tag','comment'),'string');
numEv = get(findobj(children,'tag','EvNumber'),'userdata');
comments{numEv} = evComment;
set(findobj(children,'tag','commentEvent'),'userdata',comments)

function loadComments
button = questdlg('Do you want to load a comments file?',...
    'Load comments','No');
if strcmp(button,'Yes')
    [f,p] = uigetfile('*.mat','File with comments on events');
    if ~f,return,end
    load([p,f],'comments')
    children = get(gcf,'children');
    set(findobj(children,'tag','commentEvent'),'userdata',comments) %#ok<USENS>
    numEv = get(findobj(children,'tag','EvNumber'),'userdata');
    set(findobj(children,'tag','comment'),'string',comments{numEv})
end

function saveComments
children = get(gcf,'children');
comments = get(findobj(children,'tag','commentEvent'),'userdata');
cellName = get(gcf,'tag');
c = strfind(cellName,'\');
c = c(end)+1;
d = strfind(cellName,'.');
d = d(end)-1;
[fle,pth] = uiputfile([cellName(c:d),'_comments.mat'],...
'Where to put the comments file');
if ischar(fle)&&ischar(pth)
   save([pth,fle],'comments')
end

function writeExcel
%makes a passed events matrix with comments and 
%completes the removed events matrix (with comments also)
button = ...
    questdlg('Do you really want to write an excel file of passed/removed events?',...
    'Write excel file','No');
if strcmp(button,'Yes')
    children = get(gcf,'children');
    events = get(findobj(children,'tag','trackEvents'),'userdata');
    param = get(findobj(children,'tag','param'),'userdata');
    if size(events,2) == 6
        TRC = 1;  %If the 'events' file is of .trc type (from MIA)
    elseif size(events,2) == 4
        TRC = 0;  %If the 'events' file is of .txt type (from play4, annotate)
    end
    if events(1,1)==0
        firstEvent = round(events(2,1));
    else
        firstEvent = round(events(1,1));
    end
    lastEvent = round(events(end,1));
    passed = zeros(lastEvent,4+3*TRC); %4 for annotate, 7 for TRC
    pa = 1; %token for the passed events matrix
    removed = get(findobj(children,'tag','removedEvent'),'userdata');
    if isempty(removed)
        butt2 = ...
            questdlg('The removed matrix is empty. Do you want to proceed?',...
            'Removed matrix empty','No');
        if strcmp(butt2,'No')
            return
        elseif strcmp(butt2,'Yes')
            for i=firstEvent:lastEvent
                eventTrack = (events(:,1)==i);
                [isEvent,start] = max(eventTrack);
                if isEvent
                    if TRC
                        passed(pa,1:6) = events(start,:);
                        passed(pa,7) = sum(eventTrack);
                    else
                        passed(pa,1:4) = events(start,:);
                    end
                    pa = pa+1;
                end
            end
        end
    else
    sRem = size(removed,1);
    removed = cat(2,removed(:,1),zeros(sRem,3+2*TRC),removed(:,2:5));
    for i=firstEvent:lastEvent
        eventTrack = (events(:,1)==i);
        removedTrack = (removed(:,1)==i);
        [isEvent,start] = max(eventTrack);
        [isRemoved,k] = max(removedTrack);
        if isEvent && isRemoved
            removed(k,2:4+2*TRC) = events(start,2:4+2*TRC);
        elseif isEvent && ~isRemoved
            if TRC
                passed(pa,1:6) = events(start,:);
                passed(pa,7) = sum(eventTrack);
            else
                passed(pa,1:4) = events(start,:);
            end
            pa = pa+1;
        end
    end
    end
    passed = passed(1:pa-1,:);
    comments = get(findobj(children,'tag','commentEvent'),'userdata');
    passedComments = cell(0);
    for i = passed(:,1)
        passedComments = cat(1,passedComments,comments(i));
    end
    
    removedComments = cell(0);
    if ~isempty(removed)
        for i = removed(:,1)
            removedComments = cat(1,removedComments,comments(i));
        end
    end
    cellName = get(gcf,'tag');
    c = strfind(cellName,'\');
    c = c(end)+1;
    cellNumber = cellName(c:c+4);
    tableHeight = max(size(passed,1),size(removed,1))+2;
    tableBr = cell(tableHeight,21);
    tableBr{1,1} = 'passed events';
    tableBr{1,11} = 'removed events';
    if TRC
    tableBr(2,1:8) = {'event id','frame','x','y','surf','totPixVal','persist','comments'};
    else
    tableBr(2,1:6) = {'event id','frame','x','y','persist','comments'};
    end
    tableBr(3:size(passed,1)+2,1:size(passed,2)) = num2cell(passed);
    tableBr(3:size(passedComments,1)+2,6+2*TRC) = passedComments;
    if isempty(removed)
        tableBr{2,11} = 'NO EVENTS REMOVED BY USER';
    else
        if TRC
            tableBr(2,11:16) = {'event id','frame','x','y','surf','totPixVal'};
        else
            tableBr(2,11:14) = {'event id','frame','x','y'};
        end
        tableBr(2,15+2*TRC:19+2*TRC) = {'cluster','S/N','track','other','comments'};
        tableBr(3:size(removed,1)+2,11:size(removed,2)+10) = num2cell(removed);
        tableBr(3:size(removedComments)+2,19+2*TRC) = removedComments;
    end
    
%%% Writes fluo data
    
    Fluo = get(findobj(children,'tag','Fluo'),'userdata');
    %%%Removes measures from removed events
    if ~isempty(removed)
        for i = 1:size(removed,1)
            isRemoved = Fluo{1}(:,1)==removed(i,1);
            [u,z] = max(isRemoved);
            if u
                Fluo{1}(z,:) = [];
            end
        end
    end
    if size(Fluo{1},1) < size(passed,1)
        butt3 = ...
questdlg('Not all events have been checked and quantified. Write fluo spreadsheets anyway?',...
        'Write fluo spreadsheets','No');
        if strcmp(butt3,'No')
            return
        end
    end
    
%%%Average+sem
    averageEv = mean(Fluo{1});
    stdEv = std(Fluo{1});
    datathere = Fluo{1}~=0;
    datathere = datathere(:,9:end);
    stdPlot = stdEv(9:size(stdEv,2));
    averagePlot = averageEv(9:size(averageEv,2));
    semPlot = stdPlot./sqrt(sum(datathere,1));
    frameNumb = -param(2):param(3);

    grandAverage = zeros(5,size(Fluo{1},2));
    grandAverage(1,9:end) = frameNumb;
    grandAverage(2,9:end) = averagePlot;
    grandAverage(3,9:end) = semPlot;
    grandAverage(4,9:end) = sum(datathere,1);

    Fluo{1} = cat(1,grandAverage,Fluo{1});

    
    %%%Figure for green channel
    figure('name',[cellNumber,'_Gr']) %%%changed?
    errorbar(frameNumb,averagePlot,semPlot,'-og','markerfacecolor','g')
    line([0 0],ylim)
    xlabel('Frame #')
    ylabel('average fluo')
    title(['cell #  ',cellNumber])
    pause(0.05)

    
%instructions to remove 0s and putting names in the excel file

    output = num2cell(Fluo{1});
    hightCell = size(output,1);
    widthCell = size(output,2);
    output(5,:) = {''};
    output(:,7:8) = {''};
    output(1:4,1:7) = {''};
    output(1:4,8) = {'frame';'average';'sem';'N'};
    output(5,1:6) = {'event#','track','area','eccent','length','orient'};

    parcell = cell(4,widthCell);
    parcell{1,1} = ['Fluorescence quantification: total fluo with mask for ',cellName(c:end)];
    parcell(1,4:7) = {'event file:',cellName(c:end),'',date};
    parcell(2,1:7) = {'miniSize','fr_bef','fr_aft','fr_av','threshold','nPixels','rCircle'};
    paramC = num2cell(param);
    parcell(3,1:7) = paramC;
    output = cat(1,parcell,output);

        [f,p] = uiputfile([cellNumber,'_data.xls'],...
        'Name of the excel summary data file');
    if ischar(f) && ischar(p)
        warning off MATLAB:xlswrite:AddSheet
        sheet = [cellNumber,' browse summary'];
        xlswrite([p,f],tableBr,sheet)
        
        sheet0 = [cellNumber,' summary'];
        cts = ...
{'events removed';'rem /cluster';'rem /signal';'rem /track';'rem /other'};
        if ~isempty(removed)
            if size(removed,1) == 1
                sumRemoved = removed;
            else
                sumRemoved = sum(removed);
            end
            sumRem = [sRem;sumRemoved(5+2*TRC:8+2*TRC)'];
            cts = cat(2,cts,cell(5,1),num2cell(sumRem));
        end
        xlswrite([p,f],cts,sheet0,'H5')
        xlswrite([p,f],{'passed by user:','',size(passed,1)},sheet0,'H12')
        sheetG = [cellNumber,' green'];
        xlswrite([p,f],output,sheetG)
    else
        return
    end
end
        

function removeTRC
button = ...
  questdlg('Do you really want to remove tagged events from the trc/txt file?',...
  'Remove from trc file','No');
if strcmp(button,'Yes')
    children = get(gcf,'children');
    remEvents = get(findobj(children,'tag','removedEvent'),'userdata');
    events = get(findobj(children,'tag','trackEvents'),'userdata');
    trackRemoved = ismember(events(:,1),remEvents(:,1));
    numEv = get(findobj(children,'tag','EvNumber'),'userdata');
    if events(1,1) == 0
        t2 = trackRemoved(2:end);
        t2 = cat(1,t2,0);
        trackRemoved = trackRemoved + t2 > 0;
    end
    
    i = find(~trackRemoved);
    newEvents = events(i,:);
    cellName = get(gcf,'tag');
    c = strfind(cellName,'\');
    c = c(end)+1;
    d = strfind(cellName,'.');
    d = d(end)-1;
    [fle,p] = uiputfile([cellName(c:d),'_bws.txt']...
        ,'Where to put the cleaned up event file');
    if ischar(fle)&&ischar(p)
        dlmwrite([p,fle],newEvents,'\t')
    else
        return
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
end

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
if ischar(fle)&&ischar(pth)
   dlmwrite([pth,fle],removed,'\t')
end
delete(gcf)