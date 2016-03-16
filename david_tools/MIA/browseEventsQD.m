function browseEventsQD(action)
 
%Written by DP Adapted from browseEvents2
%This function shows 'ministacks' around events that can be selected
%or rejected.
%Left image shows the average of n (default 5) frames before the event at
%pH 7.4, to show the preexisting cluster
%Middle image shows the movie of the event (green channel, pH 5.5)
%Right image shows the movie of the associated protein (red channel)
%New for Version 3: Adds graphs for the 4 movies, made after avFluo4

if nargin == 0
   [stk,stkd] = uigetfile('*.stk','Choose the event stack (pH 5)');
   if ~stk,return,end
   M5 = stkread(stk,stkd);
   pause(0.1)
   [stk7,stkd7] = uigetfile('*.stk','Choose the cluster stack (pH 7)');
   if ~stk7,return,end
   M7 = stkread(stk7,stkd7);
   pause(0.1)
   [stkR5,stkdR5] = uigetfile('*.stk','Choose the red channel stack (pH5)');
   if ~stkR5,return,end
   MR5 = stkread(stkR5,stkdR5);
   pause(0.1)
   [stkR7,stkdR7] = uigetfile('*.stk','Choose the red channel stack (pH7)');
   pause(0.1)
   if ~stkR7,return,end
   MR7 = stkread(stkR7,stkdR7);
%If the movies do not have the same length, the program will cut the
%end of the longer one(s)
   movieLength = min([size(M5,3),size(M7,3),size(MR5,3),size(MR7,3)]);
   M7 = M7(:,:,1:movieLength);
   M5 = M5(:,:,1:movieLength);
   MR5 = MR5(:,:,1:movieLength);
   MR7 = MR7(:,:,1:movieLength);
   M = cat(1,M7,M5);
   clear M7 M5
   M = cat(1,M,MR5,MR7);
   clear MR5 MR7
   pause(0.1)
   [f,p] = uigetfile('*.txt;*.trc','File with matrix of events');
   if ~f,return,end
   sTRC = ~isempty(strfind(f,'.trc'));
   events = dlmread([p,f],'\t');
   
   [coFile,coDir] = uigetfile('*.txt','File with alignment coefficients');
   if ~coFile
       coeff = [0 1 0 0 0 0 0 0 0 0 0 1 0 0]';
   else coeff = dlmread([coDir,coFile],'\t');
   end  
   if ~(size(coeff)==[14 1]),return,end
   
%%% DEFAULT PARAMETERS FOR THE MINISTACKS %%%
   prompt = {'Size Ministack','Frames before event',...
       'Frames after start','Frames for average (high pH)'...
       'Circle radius','Annulus outer radius',...
'Lower limit L of the pixel values used for background  (0<= L < H <=1)',...
'Higher limit H of the pixel values used for background (0<= L < H <=1)'};
   [sizeMini before after av_high rCircle rAnn l_per h_per] = ...
	   numinputdlg(prompt,'Parameters for the ministacks',1,[25 0 1000 0 3 6 0.2 0.8]);
   param = [sizeMini before after av_high rCircle rAnn l_per h_per];
   
   map = gray(256);
   removed = [];
   lastEvent = events(end,1);
   comments = cell(lastEvent,1);
   scrsz = get(0,'ScreenSize');
   h_movies = figure('name','Browse events',...
          'position',[scrsz(3)-1150 scrsz(4)-500 1000 420]);
       
%controls for playing the movie
   uicontrol('style','text','position',[10,15,35,15],'string','Frame',...
       'tag','evFile','userdata',f)
  
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
   uicontrol('callback','browseEventsQD previousEvent','string','PREVIOUS',...
       'position',[20,300,70,15])
   uicontrol('callback','browseEventsQD nextEvent','string','NEXT',...
       'position',[20,285,70,15])
   uicontrol('callback','browseEventsQD nextEvent','string','NEXT',...
       'position',[100,45,70,40])
   uicontrol('style','text','string','#','position',[20,270,10,15],...
       'tag','coeff','userdata',coeff)
   uicontrol('string','Go','callback','browseEventsQD gotoEvent',...
       'position',[70,270,20,15],'tag','CurvesEv','userdata',[])
   
% controls for showing the tracked object coordinates
   uicontrol('style','checkbox','string','Track','value',1,...
       'position',[20,255,70,15],'userdata',events,'tag','trackEvents',...
       'callback','browseEventsQD track')
   
% controls to tag and remove ministacks
   uicontrol('style','text','position',[20,230,70,15],...
       'string','removed file')
   uicontrol('callback','browseEventsQD loadRemoved','string','Load',...
       'position',[20,215,70,15],...
       'TooltipString',' Loads a removed event file ')
   uicontrol('callback','browseEventsQD saveRemoved','string','Save',...
       'position',[20,200,70,15],...
       'TooltipString',' Saves the removed event file ')   
   uicontrol('style','checkbox','callback','browseEventsQD removeEvent',...
       'string','Remove','value',0,...
       'position',[20,185,70,15],'userdata',removed,'tag','removedEvent')
   handle_rem = uibuttongroup('position',[0,0,10,10],'tag','removeCause');
   uicontrol('style','radio','string','cluster','position',[25,170,60,15],...
       'parent',handle_rem,'tag','rcluster','enable','off')
   uicontrol('style','radio','string','S/N','position',[25,155,60,15],...
       'parent',handle_rem,'tag','rSN','enable','off')
   uicontrol('style','radio','string','track','position',[25,140,60,15],...
       'parent',handle_rem,'tag','rtrack','enable','off')
   uicontrol('style','radio','string','other','position',[25,125,60,15],...
       'parent',handle_rem,'tag','rother','enable','off')
   set(handle_rem,'SelectionChangeFcn','browseEventsQD removeEvent')
   
% controls to write comments
   uicontrol('style','text','position',[10,104,50,15],'string','comments')
   uicontrol('tag','commentEvent','callback','browseEventsQD addComment',...
       'string','Add','position',[65,105,25,15],'userdata',comments)
   uicontrol('style','edit','tag','comment','position',[5,88,100,17],...
      'horizontalalignment','left')
   uicontrol('callback','browseEventsQD loadComments','string','Load',...
       'position',[20,73,35,15])
   uicontrol('callback','browseEventsQD saveComments','string','Save',...
       'position',[55,73,35,15])
   
% misc. controls   
   Fluo = cell(1,4);
   uicontrol('callback','browseEventsQD writeExcel','string','WriteXLS',...
       'position',[20,55,70,15],'tag','Fluo','userdata',Fluo,...
       'tooltipstring',' Write failed/passed events in summary excel file')
   uicontrol('callback','browseEventsQD removeTRC','string','RemoveTRC',...
       'position',[20,40,70,15],'tag','TRC','userdata',sTRC,...
       'tooltipstring',' Removes tagged events from trc file permanently')
%%%
   
   set(gcf,'UserData',M,'keypressfcn',@keyBrowse,'doublebuffer','on',...
      'colormap',map,'tag',[stkd,stk])
      %'closerequestfcn','browseEventsQD saveRemovedandClose')
   if events(1,1) == 0
       firstEvent = events(2,1);
   else
       firstEvent = events(1,1);
   end
   ministack(firstEvent)
   mzoom on
   %pixvalm
   scale
   goto
else
    eval(action)
end

function ministack(numEv)
children = get(gcf,'children');
M = get(gcf,'userdata');
width = size(M,1)./4; % 3 in browseEvents2
M7 = M(1:width,:,:);
M5 = M(width+1:2*width,:,:);
MR5 = M(2*width+1:3*width,:,:);
MR7 = M(3*width+1:end,:,:);
events = get(findobj(children,'tag','trackEvents'),'userdata');
param = get(findobj(children,'tag','param'),'userdata');
coeff = get(findobj(children,'tag','coeff'),'userdata');
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
xGreen = round(events(start,4))+sTRC;
yGreen = round(events(start,3))+sTRC;
x_miniGreen = max(1,xGreen-a);
y_miniGreen = max(1,yGreen-a);
x_maxiGreen = min(size(M5,1),xGreen+a);
y_maxiGreen = min(size(M5,2),yGreen+a);
t_mini = max(frame-param(2),1); %event will start at frame param(2)+1 = 21 or less
t_maxi = min(frame+param(3),size(M5,3));
MiniG5 = M5(x_miniGreen:x_maxiGreen,y_miniGreen:y_maxiGreen,t_mini:t_maxi);
MiniG7 = M7(x_miniGreen:x_maxiGreen,y_miniGreen:y_maxiGreen,t_mini:t_maxi);
MiniAv = M7(x_miniGreen:x_maxiGreen,y_miniGreen:y_maxiGreen,frame);
%MiniAv = sum(MiniAv,3)./param(4);
    %needs to add zeros
if xGreen-a < 1
    comp = zeros(1-xGreen+a,size(MiniG5,2),size(MiniG5,3));
    compAv = comp(:,:,1);
    MiniG5 = cat(1,comp,MiniG5);
    MiniG7 = cat(1,comp,MiniG7);
    MiniAv = cat(1,compAv,MiniAv);
end
if xGreen+a > size(M5,1)
    comp = zeros(xGreen+a-size(M5,1),size(MiniG5,2),size(MiniG5,3));
    compAv = comp(:,:,1);
    MiniG5 = cat(1,MiniG5,comp);
    MiniG7 = cat(1,MiniG7,comp);
    MiniAv = cat(1,MiniAv,compAv);
end
if yGreen-a < 1
    comp = zeros(size(MiniG5,1),1-yGreen+a,size(MiniG5,3));
    compAv = comp(:,:,1);
    MiniG5 = cat(2,comp,MiniG5);
    MiniG7 = cat(2,comp,MiniG7);
    MiniAv = cat(2,compAv,MiniAv);
end
if yGreen+a > size(M5,2)
    comp = zeros(size(MiniG5,1),yGreen+a-size(M5,2),size(MiniG5,3));
    compAv = comp(:,:,1);
    MiniG5 = cat(2,MiniG5,comp);
    MiniG7 = cat(2,MiniG7,comp);
    MiniAv = cat(2,MiniAv,compAv);
end

xRed = round(interPoly(events(start,3),events(start,4),coeff))+sTRC;
yRed = round(interPolx(events(start,3),events(start,4),coeff))+sTRC;
x_miniRed = max(1,xRed-a);
y_miniRed = max(1,yRed-a);
x_maxiRed = min(size(MR5,1),xRed+a);
y_maxiRed = min(size(MR5,2),yRed+a);
MiniR5 = MR5(x_miniRed:x_maxiRed,y_miniRed:y_maxiRed,t_mini:t_maxi);
MiniR7 = MR7(x_miniRed:x_maxiRed,y_miniRed:y_maxiRed,t_mini:t_maxi);
if xRed-a < 1
    comp = zeros(1-xRed+a,size(MiniR5,2),size(MiniR5,3));
    MiniR5 = cat(1,comp,MiniR5);
    MiniR7 = cat(1,comp,MiniR7);
end
if xRed+a > size(MR5,1)
    comp = zeros(xRed+a-size(MR5,1),size(MiniR5,2),size(MiniR5,3));
    MiniR5 = cat(1,MiniR5,comp);
    MiniR7 = cat(1,MiniR7,comp);
end
if yRed-a < 1
    comp = zeros(size(MiniR5,1),1-yRed+a,size(MiniR5,3));
    MiniR5 = cat(2,comp,MiniR5);
    MiniR7 = cat(2,comp,MiniR7);
end
if yRed+a > size(MR5,2)
    comp = zeros(size(MiniR5,1),yRed+a-size(MR5,2),size(MiniR5,3));
    MiniR5 = cat(2,MiniR5,comp);
    MiniR7 = cat(2,MiniR7,comp);
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
delete(findobj(gcf,'tag','scalelowRe'))
delete(findobj(gcf,'tag','scalehighRe'))

delete(findobj(gcf,'tag','frame#')) 
delete(findobj(gcf,'tag','EvNumber'))
lowAv = double(min(min(MiniAv(:,:))));
highAv = double(max(max(MiniAv(:,:))));
lowGr = double(min(min(min(MiniG5(:,:,:)))));
highGr = double(max(max(max(MiniG5(:,:,:)))));
lowRe = double(min(min(min(MiniR5(:,:,:)))));
highRe = double(max(max(max(MiniR5(:,:,:)))));

uicontrol('style','slider',...
      'callback','browseEventsQD scaleAv',...
      'min',lowAv,'max',highAv-3,...
      'value',lowAv,...
      'position',[200,15,150,15],'tag','scalelowAv')
uicontrol('style','slider',...
      'callback','browseEventsQD scaleAv',...
      'min',lowAv+3,'max',highAv,...
      'value',highAv,...
      'position',[200,30,150,15],'tag','scalehighAv')
uicontrol('style','slider',...
      'callback','browseEventsQD scaleGr',...
      'min',lowGr,'max',highGr-3,...
      'value',lowGr,...
      'position',[480,15,150,15],'tag','scalelowGr')
uicontrol('style','slider',...
      'callback','browseEventsQD scaleGr',...
      'min',lowGr+3,'max',highGr,...
      'value',highGr,...
      'position',[480,30,150,15],'tag','scalehighGr')
uicontrol('style','slider',...
      'callback','browseEventsQD scaleRe',...
      'min',lowRe,'max',highRe-3,...
      'value',lowRe,...
      'position',[760,15,150,15],'tag','scalelowRe')
uicontrol('style','slider',...
      'callback','browseEventsQD scaleRe',...
      'min',lowRe+3,'max',highRe,...
      'value',highRe,...
      'position',[760,30,150,15],'tag','scalehighRe')

uicontrol('callback','browseEventsQD goto','tag','frame#',...
      'style','slider',...
      'position',[45,15,80,15],...
      'max',size(MiniG5,3),...
      'min',1,...
      'value',1,...
      'sliderstep',[1/(size(MiniG5,3)-1),10/(size(MiniG5,3)-1)])
uicontrol('style','edit','tag','EvNumber','string',num2str(numEv),...
      'position',[30,270,40,15],'userdata',numEv)

%draws the average cluster (pH7) image
subplot(1,3,1,'replace')
image(MiniAv(:,:),'cdatamapping','scaled','tag','moviAv')
set(gca,'clim',[lowAv,highAv],'tag','axisAv','userdata',MiniAv)
axis image
browseEventsQD scaleAv

%draws the green ministack image
subplot(1,3,2,'replace')
image(MiniG5(:,:,1),'cdatamapping','scaled','tag','moviGr')
set(gca,'clim',[lowGr,highGr],'tag','axisGr','userdata',MiniG5)
cellNum = get(gcf,'tag');
c = strfind(cellNum,'\');
c = c(end)+1;
h = title(['Cell ',cellNum(c:c+3),'  Event ',num2str(numEv),'  Frame # = ',num2str(-param(2))],...
    'interpreter','none');
set(h,'userdata',['Cell ',cellNum(c:c+3),'  Event ',num2str(numEv)])
axis image
pixvalm
browseEventsQD scaleGr

%draws the red ministack image
subplot(1,3,3,'replace')
image(MiniR5(:,:,1),'cdatamapping','scaled','tag','moviRe')
set(gca,'clim',[lowRe,highRe],'tag','axisRe','userdata',MiniR5)
axis image
browseEventsQD scaleRe
goto

h_movies = gcf;
curves = 1;
if curves
    rCircle = param(5);
    rAnn = param(6);
    lowpercent = param(7);
    highpercent = param(8);
    l_t0 = min(frame,param(2)+1);
    sGr = size(MiniG5);
    center = round((param(1)+1)/2);
    [x,y] = meshgrid(1:sGr(1));
    nTrack = sum(eventTrack);
    pp = param(2)-l_t0+4;
    
%file for fluorescent quantification
    val = zeros(4,param(2)+param(3)+4); %valG5 = val(1,:);valG7 = val(2,:);
    val(:,1) = numEv;
    val(:,2) = nTrack;

    %val = cat(2,valG5,valG7,valR5,valR7);
    distance = zeros(sGr);
    distanceR = zeros(sGr);
    l_x0 = events(start,3) - yGreen + center+sTRC;
    r_x = interPolx(events(start:start+nTrack-1,3),events(start:start+nTrack-1,4),coeff);
    r_y = interPoly(events(start:start+nTrack-1,3),events(start:start+nTrack-1,4),coeff);
    r_x0 = r_x(1) - yRed + center+sTRC;
    r_y0 = r_y(1) - xRed + center+sTRC;
    l_y0 = events(start,4) - xGreen + center+sTRC;
    l_x0 = l_x0(:,ones(1,l_t0));
    l_y0 = l_y0(:,ones(1,l_t0));
    r_x0 = r_x0(:,ones(1,l_t0));
    r_y0 = r_y0(:,ones(1,l_t0));
    for lf = 1:min(param(3),nTrack-1)
        l_x0 = [l_x0,events(start+lf,3) - yGreen + center+sTRC];
        l_y0 = [l_y0,events(start+lf,4) - xGreen + center+sTRC];
        r_x0 = [r_x0,r_x(1+lf) - yRed + center+sTRC];
        r_y0 = [r_y0,r_y(1+lf) - xRed + center+sTRC];
    end
    while lf < param(3)
        l_x0 = [l_x0,events(start+nTrack-1,3) - yGreen + center+sTRC];
        l_y0 = [l_y0,events(start+nTrack-1,4) - xGreen + center+sTRC];
        r_x0 = [r_x0,r_x(nTrack) - yRed + center+sTRC];
        r_y0 = [r_y0,r_y(nTrack) - xRed + center+sTRC];
        lf = lf+1;
    end
    for mu = 1:size(l_x0,2)
        distance(:,:,mu) = sqrt((x - l_x0(mu)).^2 + (y - l_y0(mu)).^2);
        distanceR(:,:,mu) = sqrt((x - r_x0(mu)).^2 + (y - r_y0(mu)).^2);
    end
    distance = cat(4,distance,distance,distanceR,distanceR);        
    circle = distance < rCircle;
    annulus = (distance>=rCircle)&(distance<rAnn);
    %nPixC = squeeze(round(sum(sum(circle,1))))';
    nPix = squeeze(round(sum(sum(annulus,1))))';
    nLoPix = round(nPix*lowpercent);
    nHiPix = round(nPix*highpercent);
    miniPix = param(1)^2;
    Movi = cat(4,MiniG5,MiniG7,MiniR5,MiniR7);
    momo = min(size(circle,3),size(Movi,3));
    circle = circle(:,:,1:momo,:);
    annulus = annulus(:,:,1:momo,:);
    for ch = 1:4  %The 4 channels: G5,G7,R5,R7
        sigl = double(Movi(:,:,:,ch)).*circle(:,:,:,ch);
        back = double(Movi(:,:,:,ch)).*annulus(:,:,:,ch);
        sortback = sort(reshape(back,miniPix,sGr(3)));
        background = ones(1,sGr(3));
        for k = 1:sGr(3)
            background(k) = ...
sum(sortback(miniPix-nPix(ch,k)+nLoPix(ch,k)+1:miniPix-nPix(ch,k)+nHiPix(ch,k),k))./(nHiPix(ch,k)-nLoPix(ch,k));
        end
        values = sum(sum(sigl))./sum(sum(circle(:,:,:,ch)));
        val(ch,pp+1:pp+sGr(3)) = squeeze(values)' - background;
    end
    
%makes the figures
    if isempty(h_cEv)
        scrsz = get(0,'ScreenSize');
        h_cEv = figure('name',['Curves event ',num2str(numEv)],...
            'position',[scrsz(3)-1150 scrsz(4)-1000 1000 400]);
        figure(h_movies)
        set(findobj(children,'tag','CurvesEv'),'userdata',h_cEv);
        figure(h_cEv)
    else
        scrsz = get(0,'ScreenSize');
        figure(h_cEv)
        %set(gcf,'position',[scrsz(3)-1020 scrsz(4)-1000 1000 500])
        set(gcf,'name',['Curves event ',num2str(numEv)]);
    end
    
    subplot(2,2,1:2)
    
    p4 = param(4);
    af = min(sGr(3)-l_t0,10);
    
    maxG5 = double(max(max(max(MiniG5(:,:,l_t0-p4:l_t0+af)))));
    minG5 = double(min(min(min(MiniG5(:,:,l_t0-p4:l_t0+af)))));
    im_G5 = double(MiniG5(:,:,l_t0-p4:l_t0+af)-minG5)./(maxG5-minG5);
    im_G5 = reshape(im_G5,[sGr(1) sGr(2)*(p4+af+1)]);
    maxG7 = double(max(max(max(MiniG7(:,:,l_t0-p4:l_t0+af)))));
    minG7 = double(min(min(min(MiniG7(:,:,l_t0-p4:l_t0+af)))));
    im_G7 = double(MiniG7(:,:,l_t0-p4:l_t0+af)-minG7)./(maxG7-minG7);
    im_G7 = reshape(im_G7,[sGr(1) sGr(2)*(p4+af+1)]);
    
    maxR5 = double(max(max(max(MiniR5(:,:,l_t0-p4:l_t0+af)))));
    minR5 = double(min(min(min(MiniR5(:,:,l_t0-p4:l_t0+af)))));
    im_R5 = double(MiniR5(:,:,l_t0-p4:l_t0+af)-minR5)./(maxR5-minR5);
    im_R5 = reshape(im_R5,[sGr(1) sGr(2)*(p4+af+1)]);
    maxR7 = double(max(max(max(MiniR7(:,:,l_t0-p4:l_t0+af)))));
    minR7 = double(min(min(min(MiniR7(:,:,l_t0-p4:l_t0+af)))));
    im_R7 = double(MiniR7(:,:,l_t0-p4:l_t0+af)-minR7)./(maxR7-minR7);
    im_R7 = reshape(im_R7,[sGr(1) sGr(2)*(p4+af+1)]);
    
    im_Tot = cat(1,im_G7,im_G5,im_R7,im_R5);
    
    image(im_Tot,'cdatamapping','scaled')
    axis image
    axis off
    colormap gray(256)
    
%curves for green and red channels    
    subplot(2,2,3)
    valG5 = val(1,pp+1:pp+sGr(3));
    nT = min(nTrack-1,param(3));
    plot(valG5,'g') %pp = param(2)-l_t0+4;
    hold on
    plot(l_t0-p4:l_t0+nT,valG5(l_t0-p4:l_t0+nT),'og','markerfacecolor','g');
    plot(l_t0-p4:l_t0+af,valG5(l_t0-p4:l_t0+af),'og')
    valG7 = val(2,pp+1:pp+sGr(3));
    plot(valG7,'color',[0 0.6 0])
    line([l_t0 l_t0],ylim)
    hold off
    
    subplot(2,2,4)
    valR5 = val(3,pp+1:pp+sGr(3));
    plot(valR5,'r') %pp = param(2)-l_t0+4;
    hold on
    plot(l_t0-p4:l_t0+nT,valR5(l_t0-p4:l_t0+nT),'or','markerfacecolor','r');
    plot(l_t0-p4:l_t0+af,valR5(l_t0-p4:l_t0+af),'or')
    valR7 = val(4,pp+1:pp+sGr(3));
    plot(valR7,'color',[0.6 0 0])
    line([l_t0 l_t0],ylim)
    hold off
    
%Updates the Fluo quantification matrix
    if isempty(Fluo{1})
        for ch = 1:4
            Fluo{ch} = val(ch,:);
        end
    else
        eventTrack = Fluo{1}(:,1)==numEv;
        [isThere,z] = max(eventTrack); 
        if isThere
            for ch = 1:4
                Fluo{ch}(z,:) = val(ch,:);
            end
        else
            for ch = 1:4
                Fluo{ch} = [Fluo{ch};val(ch,:)];
                Fluo{ch} = sortrows(Fluo{ch});
            end
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

function scaleRe
children = get(gcf,'children');
low = ceil(get(findobj(children,'tag','scalelowRe'),'value'));
high = floor(get(findobj(children,'tag','scalehighRe'),'value'));
minlow = get(findobj(children,'tag','scalelowRe'),'min');
maxhigh = get(findobj(children,'tag','scalehighRe'),'max');
if high == minlow+1
   high = high +1;
end
if low == maxhigh-1
   low = low-1;
end

set(findobj(children,'tag','axisRe'),'clim',[low,high])
set(findobj(children,'tag','scalelowRe'),'max',high-1,...
   'sliderstep',[1/(high-1-minlow),25/(high-1-minlow)],...
   'value',low)
set(findobj(children,'tag','low_textRe'),'string',num2str(low));
set(findobj(children,'tag','scalehighRe'),'min',low+1,...
   'sliderstep',[1/(maxhigh-(low+1)),25/(maxhigh - (low+1))],...
   'value',high)
set(findobj(children,'tag','high_textRe'),'string',num2str(high));

function goto
children = get(gcf,'children');
MiniG5 = get(findobj(children,'tag','axisGr'),'userdata');
MiniR5 = get(findobj(children,'tag','axisRe'),'userdata');
frame = round(get(findobj(children,'tag','frame#'),'value'));
param = get(findobj(children,'tag','param'),'userdata');
global stop
stop = 1;
imgGr = MiniG5(:,:,frame);
imgRe = MiniR5(:,:,frame);
set(findobj(children,'tag','moviGr'),'cdata',imgGr)
set(findobj(children,'tag','moviRe'),'cdata',imgRe)
tit = get(findobj(children,'tag','axisGr'),'title');
stk = get(tit,'userdata');
axes(findobj(children,'tag','axisGr'))
title([stk,' Frame # = ',num2str(frame-param(2)-1)]);
delete(findobj(get(findobj(children,'tag','axisGr'),'children'),...
    'type','line'))
delete(findobj(get(findobj(children,'tag','axisRe'),'children'),...
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
    browseEventsQD nextEvent
end
if evnt.Character == 'p'
    browseEventsQD previousEvent
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
    delete(findobj(get(findobj(children,'tag','axisRe'),'children'),...
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
d = strfind(cellName,'_');
if isempty(d)
    d = strfind(cellName,'.');
    d = d(end)-1;
else
    d = d(1)-1;
end
children = get(gcf,'children');
removed = get(findobj(children,'tag','removedEvent'),'userdata');
[fle,pth] = uiputfile([cellName(c:d),'_rem.txt'],...
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
d = strfind(cellName,'_');
if isempty(d)
    d = strfind(cellName,'.');
    d = d(end)-1;
else
    d = d(1)-1;
end
[fle,pth] = uiputfile([cellName(c:d),'_com.mat'],...
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
    c = max(c)+1;
    s = strfind(cellName,'_');
    s = max(s)-1;
    if ~isempty(s)
        cellNumber = cellName(c:s);
    else
        cellNumber = cellName(c:c+3);
    end
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
pause(0.1)
    [f,p] = uiputfile([cellNumber,' browsed.xlsx'],...
        'Name of the excel summary data file');
    if ischar(f) && ischar(p)
        warning off MATLAB:xlswrite:AddSheet
        sheet = [cellNumber,' browse summary'];
        xlswrite([p,f],tableBr,sheet)
        
        sheet0 = [cellNumber,' summary'];
        cts = ...
{'events removed';'rem /cluster';'rem /signal';'rem /track';'rem /other'};
        if ~isempty(removed)
            sumRemoved = sum(removed,1);
            sumRem = [sRem;sumRemoved(5+2*TRC:8+2*TRC)'];
            cts = cat(2,cts,cell(5,1),num2cell(sumRem));
        end
        xlswrite([p,f],cts,sheet0,'H5')
        xlswrite([p,f],{'passed by user:','',size(passed,1)},sheet0,'H12')
        
        Fluo = get(findobj(children,'tag','Fluo'),'userdata');
    %%%Removes measures from removed events
        if ~isempty(removed) 
            for i = 1:size(removed,1)
                isRemoved = Fluo{1}(:,1)==removed(i,1);
                [u,z] = max(isRemoved);
                if u
                    for ch = 1:4
                        Fluo{ch}(z,:) = [];
                    end
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
        
        cn = cellNumber;
        sLabs = {[cn,' TfR5'],[cn,' TfR7'],[cn,' red5'],[cn,' red7']};
        [t,desc] = xlsfinfo([p,f]);
        if max(strcmp(sLabs{1},desc))
%i.e. if the Fluo spreadsheets already exist from another browse session
            oFluo = cell(1,4);
            for ch = 1:4
                %output{2,2,ch} = ['essai',num2str(ch)];
                oFluo{ch} = xlsread([p,f],sLabs{ch});
                oFluo{ch} = oFluo{ch}(8:end,:);
            end
%Removes 'old' Fluo corresponding to events quantified in the current session
            rr=[];
            for i = 1:size(oFluo{1},1)
                if max(Fluo{1}(:,1)==oFluo{1}(i,1))
                    rr = cat(1,rr,i);
                end
            end
            for ch = 1:4
                for j=rr
                    oFluo{ch}(j,:) = [];
                end
            end
            for ch = 1:4
                Fluo{ch} = sortrows(cat(1,Fluo{ch},oFluo{ch}));
            end
        end
    else
        return
    end
    
%%% Draws a figure of the graphs
    figure('name',cellNumber)
    colors = [0 1 0;0 0.6 0;1 0 0;0.6 0 0];
    for ch = 1:4
        average = mean(Fluo{ch});
        stdEv = std(Fluo{ch});
        datathere = Fluo{ch}~=0;
        datathere = datathere(:,4:end);
        stdPlot = stdEv(4:size(stdEv,2));
        averagePlot = average(4:size(average,2));
        semPlot = stdPlot./sqrt(sum(datathere,1));
        frameNumb = -param(2):param(3);

        grandAverage = zeros(5,size(Fluo{ch},2));
        grandAverage(1,4:end) = frameNumb;
        grandAverage(2,4:end) = averagePlot;
        grandAverage(3,4:end) = semPlot;
        grandAverage(4,4:end) = sum(datathere,1);

        Fluo{ch} = cat(1,grandAverage,Fluo{ch});
        
        subplot(2,2,ch)
        co = colors(ch,:);
        errorbar(frameNumb,averagePlot,semPlot,'-o','color',co,...
            'markerfacecolor',co)
        xlabel('Frame #')
        ylabel('average fluo')
        line([0 0],ylim)
    end    
    [ffluo,pfluo] = uiputfile([cellNumber,' fluo.fig'],'Save fluo data');
    if ischar(ffluo)&& ischar(pfluo)
        saveas(gcf,[pfluo,ffluo])
    end

           
 %instructions to remove 0s and putting names in the excel file
    
    output = cell(size(Fluo{1},1),size(Fluo{1},2),4);
    for ch = 1:4
        output(:,:,ch) = num2cell(Fluo{ch});
        hightCell = size(output,1);
        widthCell = size(output,2);
        output(5,:,ch) = {''};
        output(:,3,ch) = {''};
        output(1:4,1:2,ch) = {''};
        output(1:4,3,ch) = {'frame';'average';'sem';'N'};
        output(5,1:2,ch) = {'event#','track'};
    end
    
    fff = get(findobj(children,'tag','evFile'),'userdata');
    parcell = cell(4,widthCell);
    parcell{1,1} = ['Fluorescence quantification: circle - annulus for ',cellName(c:end)];
    parcell(1,4:8) = {'event file:',fff,'','',date};
    parcell(2,1:8) = {'miniSize','fr_bef','fr_aft','fr_av','rCircle','rAnn','lowPerc','highPerc'};
    paramC = num2cell(param);
    parcell(3,1:8) = paramC;
    parcell = cat(3,parcell,parcell,parcell,parcell);
    output = cat(1,parcell,output);
   
    for ch = 1:4
        xlswrite([p,f],output(:,:,ch),sLabs{ch})
    end  
end
  
%%%%%%%%%%%%%%%%

            

function removeTRC
button = ...
  questdlg('Do you really want to remove tagged events from the trc file?',...
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
    d = strfind(cellName,'-');
    d = d(end)+1;
    [fle,p] = uiputfile([cellName(c:d),'_clnR.trc']...
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
[fle,pth] = uiputfile([cellName(c+1:a),'_rem.txt'],...
'Where to put the file showing removed events');
if ischar(fle)&&ischar(pth)
   dlmwrite([pth,fle],removed,'\t')
end
delete(gcf)