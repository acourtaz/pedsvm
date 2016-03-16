function coloc3color(action)

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
    [fileB,pthB] = uigetfile('*.tif','Choose the blue image');
    if ~fileB,return,end
    imB = imread([pthB,fileB]);
%crops the images if they are of different size (it shouldn't happen, but
%it would prevent the procedure from making an error.
    sizeIm = min([size(imG);size(imR);size(imB)]);
    imG = imG(1:sizeIm(1),1:sizeIm(2));
    imR = imR(1:sizeIm(1),1:sizeIm(2));
    imG = imG(1:sizeIm(1),1:sizeIm(2));
    scr = get(0,'screensize');
    map = gray(256);
    figure('name','Colocalisation',...
        'position',[scr(3)-800,scr(4)-800,800,800])
    %set(gcf,'doublebuffer','on')
    set(gcf,'colormap',map,'name',...
        ['Colocalisation  ',fileG,'  ',fileR,'  ',fileB])
    
    subplot('position',[0.05,0.55,0.3,0.45])
    image(imG,'cdatamapping','scaled','tag','imGr')
    axis image
    axis off
    title('green image')
    set(gca,'tag','axisGr')
    highG = double(max(max(imG)));
    lowG = double(min(min(imG)));
    
    subplot('position',[0.35,0.55,0.3,0.45])
    image(imR,'cdatamapping','scaled','tag','imRe')
    axis image
    axis off
    title('red image')
    set(gca,'tag','axisRe')
    highR = double(max(max(imR)));
    lowR = double(min(min(imR)));
    
    subplot('position',[0.65,0.55,0.3,0.45])
    image(imB,'cdatamapping','scaled','tag','imBl')
    axis image
    axis off
    title('blue image')
    set(gca,'tag','axisBl')
    highB = double(max(max(imB)));
    lowB = double(min(min(imB)));
    
    subplot('position',[0.05,0,0.3,0.45])
    image(imG,'cdatamapping','direct','tag','imMerge')
    axis image
    axis off
    title('merged')
    set(gca,'tag','axisMerge') %useful?
    
    uicontrol('style','slider','tag','scalelowG',...
        'position',[100,420,100,15],'callback','coloc3color scaleGreen',...
        'min',lowG,'max',highG-3,'value',lowG)
    uicontrol('style','text','position',[70,420,30,15],'tag','lowG_text')
    uicontrol('style','text','position',[35,420,35,15],'string','Low')
    
    uicontrol('position',[100,435,100,15],'tag','scalehighG',...
        'style','slider','callback','coloc3color scaleGreen',...
        'min',lowG+3,'max',highG,'value',highG)
    uicontrol('style','text','position',[70,435,30,15],'tag','highG_text')
    uicontrol('style','text','position',[35,435,35,15],'string','High')
    
    uicontrol('position',[350,420,100,15],'tag','scalelowR',...
        'style','slider','callback','coloc3color scaleRed',...
        'min',lowR,'max',highR-3,'value',lowR)
    uicontrol('style','text','position',[320,420,30,15],'tag','lowR_text')
    uicontrol('style','text','position',[285,420,35,15],'string','Low')
    
    uicontrol('position',[350,435,100,15],'tag','scalehighR',...
        'style','slider','callback','coloc3color scaleRed',...
        'min',lowR+3,'max',highR,'value',highR) 
    uicontrol('style','text','position',[320,435,30,15],'tag','highR_text')
    uicontrol('style','text','position',[285,435,35,15],'string','High')
    
    uicontrol('position',[600,420,100,15],'tag','scalelowB',...
        'style','slider','callback','coloc3color scaleBlue',...
        'min',lowB,'max',highB-3,'value',lowB)
    uicontrol('style','text','position',[570,420,30,15],'tag','lowB_text')
    uicontrol('style','text','position',[535,420,35,15],'string','Low')
    
    uicontrol('position',[600,435,100,15],'tag','scalehighB',...
        'style','slider','callback','coloc3color scaleBlue',...
        'min',lowB+3,'max',highB,'value',highB) 
    uicontrol('style','text','position',[570,435,30,15],'tag','highB_text')
    uicontrol('style','text','position',[535,435,35,15],'string','High')
    
    uicontrol('position',[480,50,110,20],'string','Select Background',...
        'callback','coloc3color selectOn','style','togglebutton',...
        'min',0,'max',1,'value',0,'tag','selBack')
    uicontrol('position',[480,30,110,20],'string','Select ROI',...
        'callback','coloc3color selectROI','style','togglebutton',...
        'min',0','max',1,'value',0,'tag','selROI')
    uicontrol('position',[480,10,70,15],'style','text','string','threshold')
    uicontrol('position',[550,10,40,15],'style','edit','string','6',...
        'tag','thresh')
    uicontrol('position',[600,30,110,20],'string','Outline Signal',...
        'callback','coloc3color Outline','tag','outline')
    uicontrol('position',[600,10,110,20],'string','Calculate nMDP',...
        'callback','coloc3color nMDP','tag','nMDP')
    
        
    scaleGreen
    scaleRed
    scaleBlue
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

function scaleBlue
children = get(gcf,'children');
low = ceil(get(findobj(children,'tag','scalelowB'),'value'));
high = floor(get(findobj(children,'tag','scalehighB'),'value'));
minlow = get(findobj(children,'tag','scalelowB'),'min');
maxhigh = get(findobj(children,'tag','scalehighB'),'max');
if high == minlow+1
   high = high +1;
end
if low == maxhigh-1
   low = low-1;
end
set(findobj(children,'tag','axisBl'),'clim',[low,high])
set(findobj(children,'tag','scalelowB'),'max',high-1,'value',low,...
   'sliderstep',[1/(high-1-minlow),25/(high-1-minlow)])
set(findobj(children,'tag','lowB_text'),'string',num2str(low));
set(findobj(children,'tag','scalehighB'),'min',low+1,'value',high,...
   'sliderstep',[1/(maxhigh-(low+1)),25/(maxhigh - (low+1))])
set(findobj(children,'tag','highB_text'),'string',num2str(high));
scaleMerge

function scaleMerge
children = get(gcf,'children');
mergeHandle = findobj(children,'tag','imMerge');
imG = double(get(findobj(children,'tag','imGr'),'cdata'));
imR = double(get(findobj(children,'tag','imRe'),'cdata'));
imB = double(get(findobj(children,'tag','imBl'),'cdata'));
lowG = get(findobj(children,'tag','scalelowG'),'value');
highG = get(findobj(children,'tag','scalehighG'),'value');
lowR = get(findobj(children,'tag','scalelowR'),'value');
highR = get(findobj(children,'tag','scalehighR'),'value');
lowB = get(findobj(children,'tag','scalelowB'),'value');
highB = get(findobj(children,'tag','scalehighB'),'value');
green = (imG-lowG)/(highG-lowG);
green(green<0) = 0;
green(green>1) = 1;
red = (imR-lowR)/(highR-lowR);
red(red<0) = 0;
red(red>1) = 1;
blue = (imB-lowB)/(highB-lowB);
blue(blue<0) = 0;
blue(blue>1) = 1;

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
elseif (threshold<2) || (threshold>30)
    errordlg('Choose a threshold between 2 and 30')
else
    imG = get(findobj(children,'tag','imGr'),'cdata');
    if isempty(ROI)
        warndlg('Colocalisation analysis will be performed on whole images')
        ROI = ones(size(imG));
    end
    surfROI = sum(sum(ROI));
    bx = rect(1); by = rect(2); bw = rect(3); bh = rect(4);
    se90 = strel('line',2, 90);
    se0 = strel('line', 2, 0);
    
    [Gr_back,Gr_Tback] = edge(imG(by:by+bh,bx:bx+bw),'Sobel');
    %mimage(Gr_back)
    %Gr_Tback
    EdgeGr = edge(imG,'Sobel',threshold*Gr_Tback); %detect edges
    EdgeGr = (EdgeGr & ROI);
    EdgeGr = imdilate(EdgeGr,[se90 se0]); %dilate lines
    FillGr = EdgeGr; %FillGr = imfill(EdgeGr,'holes');
    %mimage(FillGr)
    
    imR = get(findobj(children,'tag','imRe'),'cdata');
    [Re_back,Re_Tback] = edge(imR(by:by+bh,bx:bx+bw),'Sobel');
    EdgeRe = edge(imR,'Sobel',threshold*Re_Tback);
    EdgeRe = (EdgeRe & ROI);
    EdgeRe = imdilate(EdgeRe,[se90 se0]); %dilate lines
    FillRe = EdgeRe; %FillRe = imfill(EdgeRe,'holes'); 
    %mimage(FillRe)
    
    imB = get(findobj(children,'tag','imBl'),'cdata');
    [Bl_back,Bl_Tback] = edge(imB(by:by+bh,bx:bx+bw),'Sobel');
    EdgeBl = edge(imB,'Sobel',threshold*Bl_Tback);
    EdgeBl = (EdgeBl & ROI);
    EdgeBl = imdilate(EdgeBl,[se90 se0]); %dilate lines
    FillBl = EdgeBl; %FillBl = imfill(EdgeBl,'holes'); 
    
    Inter = (FillGr & FillRe & FillBl); %map of Re&Gr&Bl pixels
    Mask = (FillGr | FillRe | FillBl); %map of Re|Gr|Bl pixels
    GrOnly = (FillGr & ~FillRe & ~FillBl);
    ReOnly = (FillRe & ~FillGr & ~FillBl);
    BlOnly = (FillBl & ~FillGr & ~FillRe);
    noGr = (FillRe & FillBl & ~FillGr);
    noRe = (FillGr & FillBl & ~FillRe);
    noBl = (FillGr & FillRe & ~FillBl);
    F_Gr = sum(sum(double(imG).*FillGr)); %total fluo on the pixels
    F_Re = sum(sum(double(imR).*FillRe));
    F_Bl = sum(sum(double(imB).*FillBl));
    
    figure
    bubulle = cat(3,FillRe,FillGr,FillBl);
    image(bubulle,'cdatamapping','direct')
    axis image
    %mimage(2*Inter-Mask)
    interPix = sum(sum(Inter));
    maskPix = sum(sum(Mask));
    GrOnlyPix = sum(sum(GrOnly));
    ReOnlyPix = sum(sum(ReOnly));
    BlOnlyPix = sum(sum(BlOnly));
    noGrPix = sum(sum(noGr));
    noRePix = sum(sum(noRe));
    noBlPix = sum(sum(noBl));
    title1 = {'Green','Red','Blue','Green&Red&Blue','Total','surf ROI'}
    data1 = [sum(sum(FillGr)),sum(sum(FillRe)),sum(sum(FillBl)),interPix,maskPix,surfROI]
    dataFluo = [F_Gr,F_Re,F_Bl]
    title2 = {'Green only','Red only','Blue only','not Green','not Red','not Blue'}
    data2 = [GrOnlyPix,ReOnlyPix,BlOnlyPix,noGrPix,noRePix,noBlPix]
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
    