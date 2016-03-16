function colocNMDP(action)

%Written by DP last update 21/06/07
%This program computes various ways to visualize and quantify
%colocalization between two fluorescent images.
%First it displays the two images and the merged image (red,green).
%Then it computes the areas where there is a signal, and calculates the
%nMDP and Icorr according to Jaskolski et al. 2005, and also (in the
%future) Pearson's rank and other means of quantification.

if nargin == 0
    [fileG,pthG] = uigetfile('*.tif','Choose the green image');
    if ~fileG,return,end
    imG = imread([pthG,fileG]);
    
    
    [fileR,pthR] = uigetfile('*.tif','Choose the red image');
    if ~fileR,return,end
    imR = imread([pthR,fileR]);
%crops the images if they are of different size (it shouldn't happen, but
%it would prevent the procedure from making an error.
    sizeIm = min([size(imG);size(imR)]);
    imG = imG(1:sizeIm(1),1:sizeIm(2));
    imR = imR(1:sizeIm(1),1:sizeIm(2));
    scr = get(0,'screensize');
    map = gray(256);
    figure('name','Colocalisation',...
        'position',[scr(3)-800,scr(4)-360,800,360])
    %set(gcf,'doublebuffer','on')
    set(gcf,'colormap',map,'name',['Colocalisation  ',fileG,'  ',fileR])
    
    subplot('position',[0.05,0.1,0.3,0.9])
    image(imG,'cdatamapping','scaled','tag','imGr')
    axis image
    axis off
    title('green image')
    set(gca,'tag','axisGr')
    highG = double(max(max(imG)));
    lowG = double(min(min(imG)));
    
    subplot('position',[0.35,0.1,0.3,0.9])
    image(imR,'cdatamapping','scaled','tag','imRe')
    axis image
    axis off
    title('red image')
    set(gca,'tag','axisRe')
    highR = double(max(max(imR)));
    lowR = double(min(min(imR)));
    
    subplot('position',[0.65,0.1,0.3,0.9])
    image(imG,'cdatamapping','direct','tag','imMerge')
    axis image
    axis off
    title('merged')
    set(gca,'tag','axisMerge') %useful?
    
    uicontrol('style','slider','callback','colocNMDP scaleGreen',...
        'position',[100,10,100,15],'tag','scalelowG',...
        'min',lowG,'max',highG-3,'value',lowG)
    uicontrol('style','text','position',[70,10,30,15],'tag','lowG_text')
    uicontrol('style','text','position',[35,10,35,15],'string','Low')
    
    uicontrol('position',[100,25,100,15],'tag','scalehighG',...
        'style','slider','callback','colocNMDP scaleGreen',...
        'min',lowG+3,'max',highG,'value',highG)
    uicontrol('style','text','position',[70,25,30,15],'tag','highG_text')
    uicontrol('style','text','position',[35,25,35,15],'string','High')
    
    uicontrol('position',[350,10,100,15],'tag','scalelowR',...
        'style','slider','callback','colocNMDP scaleRed',...
        'min',lowR,'max',highR-3,'value',lowR)
    uicontrol('style','text','position',[320,10,30,15],'tag','lowR_text')
    uicontrol('style','text','position',[285,10,35,15],'string','Low')
    
    uicontrol('position',[350,25,100,15],'tag','scalehighR',...
        'style','slider','callback','colocNMDP scaleRed',...
        'min',lowR+3,'max',highR,'value',highR) 
    uicontrol('style','text','position',[320,25,30,15],'tag','highR_text')
    uicontrol('style','text','position',[285,25,35,15],'string','High')
    
    uicontrol('position',[480,50,110,20],'string','Select Background',...
        'callback','colocNMDP selectOn','style','togglebutton',...
        'min',0,'max',1,'value',0,'tag','selBack')
    uicontrol('position',[480,30,110,20],'string','Select ROI',...
        'callback','colocNMDP selectROI','style','togglebutton',...
        'min',0','max',1,'value',0,'tag','selROI')
    uicontrol('position',[480,10,70,15],'style','text','string','threshold')
    uicontrol('position',[550,10,40,15],'style','edit','string','6',...
        'tag','thresh')
    uicontrol('position',[600,30,110,20],'string','Outline Signal',...
        'callback','colocNMDP Outline','tag','outline')
    uicontrol('position',[600,10,110,20],'string','Calculate nMDP',...
        'callback','colocNMDP nMDP','tag','nMDP')
    
        
    scaleGreen
    scaleRed
    pixvalm
else
    eval(action)
end
    
function scaleGreen
children = get(gcf,'children');
low = ceil(get(findobj(children,'tag','scalelowG'),'value'));
high = floor(get(findobj(children,'tag','scalehighG'),'value'));
minlow = get(findobj(children,'tag','scalelowG'),'min');
maxhigh = get(findobj(children,'tag','scalehighG'),'max');
if high == minlow+1
   high = high +1;
end
if low == maxhigh-1
   low = low-1;
end
set(findobj(children,'tag','axisGr'),'clim',[low,high])
set(findobj(children,'tag','scalelowG'),'max',high-1,'value',low,...
   'sliderstep',[1/(high-1-minlow),25/(high-1-minlow)])
set(findobj(children,'tag','lowG_text'),'string',num2str(low));
set(findobj(children,'tag','scalehighG'),'min',low+1,'value',high,...
   'sliderstep',[1/(maxhigh-(low+1)),25/(maxhigh - (low+1))])
set(findobj(children,'tag','highG_text'),'string',num2str(high));
scaleMerge

function scaleRed
children = get(gcf,'children');
low = ceil(get(findobj(children,'tag','scalelowR'),'value'));
high = floor(get(findobj(children,'tag','scalehighR'),'value'));
minlow = get(findobj(children,'tag','scalelowR'),'min');
maxhigh = get(findobj(children,'tag','scalehighR'),'max');
if high == minlow+1
   high = high +1;
end
if low == maxhigh-1
   low = low-1;
end
set(findobj(children,'tag','axisRe'),'clim',[low,high])
set(findobj(children,'tag','scalelowR'),'max',high-1,'value',low,...
   'sliderstep',[1/(high-1-minlow),25/(high-1-minlow)])
set(findobj(children,'tag','lowR_text'),'string',num2str(low));
set(findobj(children,'tag','scalehighR'),'min',low+1,'value',high,...
   'sliderstep',[1/(maxhigh-(low+1)),25/(maxhigh - (low+1))])
set(findobj(children,'tag','highR_text'),'string',num2str(high));
scaleMerge

function scaleMerge
children = get(gcf,'children');
mergeHandle = findobj(children,'tag','imMerge');
imG = double(get(findobj(children,'tag','imGr'),'cdata'));
imR = double(get(findobj(children,'tag','imRe'),'cdata'));
lowG = get(findobj(children,'tag','scalelowG'),'value');
highG = get(findobj(children,'tag','scalehighG'),'value');
lowR = get(findobj(children,'tag','scalelowR'),'value');
highR = get(findobj(children,'tag','scalehighR'),'value');
green = (imG-lowG)/(highG-lowG);
green(green<0) = 0;
green(green>1) = 1;
red = (imR-lowR)/(highR-lowR);
red(red<0) = 0;
red(red>1) = 1;
blue = zeros(size(green));

rgb = cat(3,red,green,blue);
set(mergeHandle,'cdata',rgb)

function selectOn
children = get(gcf,'children');
selectStatus = get(findobj(children,'tag','selBack'),'value');
if selectStatus == 0
    return
else
    %zoom off
    %set(findobj(children,'tag','selROI'),'value',0);
    delete(findobj(children,'type','line','color','g'))
    [Xback,Yback,Back,rect] = imcrop;
    rect = round(rect);
    bx = rect(1); by = rect(2); bw = rect(3); bh = rect(4);
    X = [bx,bx,bx+bw,bx+bw,bx];
    Y = [by,by+bh,by+bh,by,by];
    line('XData',X,'YData',Y,'color','g')
    set(findobj(children,'tag','selBack'),'UserData',rect);
    %set(findobj(children,'tag','selBack'),'value',0);
    %set(gcf,'windowButtonDownFcn','');
end

function selectROI
children = get(gcf,'children');
selectStatus = get(findobj(children,'tag','selBack'),'value');
if selectStatus == 0
    return
else
    %zoom off
    %set(findobj(children,'tag','selBack'),'value',0);
    delete(findobj(children,'type','line','color','r'))
    [ROI,x,y] = roipoly;
    line('Xdata',x,'Ydata',y,'color','r')
    set(findobj(children,'tag','selROI'),'Userdata',ROI);
    %set(findobj(children,'tag','selROI'),'value',0);
end

function Outline
children = get(gcf,'children');
rect = get(findobj(children,'tag','selBack'),'Userdata');
threshold = get(findobj(children,'tag','thresh'),'string');
threshold = str2num(threshold);
ROI = get(findobj(children,'tag','selROI'),'Userdata');
if isempty(rect)
    errordlg('No background region is selected')
elseif isempty(threshold)
    errordlg('Choose a threshold between 2 and 30')
elseif (threshold<2) | (threshold>30)
    errordlg('Choose a threshold between 2 and 30')
else
    imG = get(findobj(children,'tag','imGr'),'cdata');
    if isempty(ROI)
        warndlg('Colocalisation analysis will be performed on whole images')
        ROI = ones(size(imG));
    end
    bx = rect(1); by = rect(2); bw = rect(3); bh = rect(4);
    se90 = strel('line',2, 90);
    se0 = strel('line', 2, 0);
    
    [Gr_back,Gr_Tback] = edge(imG(by:by+bh,bx:bx+bw),'Sobel');
    %mimage(Gr_back)
    %Gr_Tback
    EdgeGr = edge(imG,'Sobel',threshold*Gr_Tback); %detect edges
    EdgeGr = (EdgeGr & ROI);
    EdgeGr = imdilate(EdgeGr,[se90 se0]); %dilate lines
    FillGr = imfill(EdgeGr,'holes');
    FillGr = imerode(FillGr,[se90 se0]);
    %mimage(FillGr)
    
    imR = get(findobj(children,'tag','imRe'),'cdata');
    [Re_back,Re_Tback] = edge(imR(by:by+bh,bx:bx+bw),'Sobel');
    EdgeRe = edge(imR,'Sobel',threshold*Re_Tback);
    EdgeRe = (EdgeRe & ROI);
    EdgeRe = imdilate(EdgeRe,[se90 se0]); %dilate lines
    FillRe = EdgeRe; %FillRe = imfill(EdgeRe,'holes'); 
    %mimage(FillRe)
    
    Inter = (FillGr & FillRe); %map of Re&Gr pixels
    Mask = (FillGr | FillRe); %map of Re|Gr pixels
    GrOnly = (FillGr & ~FillRe);
    ReOnly = (FillRe & ~FillGr);
    figure
    bubulle = cat(3,FillRe,FillGr,zeros(size(FillGr)));
    image(bubulle,'cdatamapping','direct')
    %mimage(2*Inter-Mask)
    interPix = sum(sum(Inter));
    maskPix = sum(sum(Mask));
    GrOnlyPix = sum(sum(GrOnly));
    ReOnlyPix = sum(sum(ReOnly));
    titles = {'Green','Red','Green&Red','Total','Green notRed','Red notGreen'}
    data = [sum(sum(FillGr)),sum(sum(FillRe)),interPix,maskPix,GrOnlyPix,ReOnlyPix]
    overlap = interPix/maskPix;   %gives the fraction of overlapping pixels
    set(findobj(children,'tag','outline'),'userdata',Mask);
    %needs to add a picture of outlined channels
    
    %nMDP calculation
    
end

function nMDP
children = get(gcf,'children');
imG = double(get(findobj(children,'tag','imGr'),'cdata'));
imR = double(get(findobj(children,'tag','imRe'),'cdata'));
mask = get(findobj(children,'tag','outline'),'userdata');
if isempty(mask)
    errordlg('You need to outline the signal first')
else
    imGmask = imG.*mask;
    imRmask = imR.*mask;
    [i,j,u] = find(imGmask);
    mean_imG = mean2(u);
    [i,j,v] = find(imRmask);
    mean_imR = mean2(v);
    dev_imG = imGmask-mean_imG;
    dev_imR = imRmask-mean_imR;
    PEM = (dev_imG.*dev_imR)./(max(dev_imG(:))*max(dev_imR(:)));
    %mimage(PEM)
    ImPEM = PEM.*mask;
    figure
    imshow(medfilt2(ImPEM,[3 3]))
    colormap mapcorr
    title('nMDP Image');
    CLim =[-0.5, 0.5]; 
    set(gca,'CLim',CLim);
    colorbar;
    
    [i,j,p] = find(ImPEM);
    p_neg = (p<0);
    a_neg = sum(sum(p_neg))
    p_pos = (p>0);
    a_pos = sum(sum(p_pos))
    Icorr = a_pos/(a_pos+a_neg)
end
    