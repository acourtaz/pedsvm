function maskTiff(action)

if nargin == 0
    
    [fileG,pthG] = uigetfile('*.tif','Choose the reference image');
     if ~fileG,return,end
    maxIm = imread([pthG,fileG]);


%shows the image of the maximum projection and uses it as input for
%background

    low = min(min(maxIm));
    high = max(max(maxIm));


    map = gray(256);
    map(end,:) = [1 0 0];
    figure('name',fileG)
    set(gcf,'UserData',maxIm,'colormap',map,'tag',fileG);
    image(maxIm,'cdatamapping','scaled','tag','maximage')
    %set(gca,'tag','axisMax')
    uicontrol('position',[20,10,50,15],'style','text','string','Threshold')
    uicontrol('position',[70,10,45,15],'style','text','tag','thresh_text')
    uicontrol('position',[115,10,400,20],'style','slider',...
        'callback','maskTiff scale','tag','scaleth',...
        'min',low,'max',round(high/2),'value',round(high/4))
    uicontrol('position',[10,120,110,20],'string','Select Background',...
        'callback','maskTiff selectOn','style','togglebutton',...
        'min',0,'max',1,'value',0,'tag','selToggle')
    uicontrol('position',[10,50,90,20],'string','Create Mask',...
        'callback','maskTiff mask');
    %%%controls to select a region (to save a cropped movie/frame)
   uicontrol('style','text','position',[30,315,80,15],'string','REGION',...
       'tag','Region','userdata',[])
   uicontrol('string','Show','position',[70,300,40,15],'tag','showR',...
       'callback','maskTiff shReg')
   Ydim = size(maxIm,1);
   Xdim = size(maxIm,2);
   Xmid = floor(Xdim/2);
   uicontrol('string','leftIm','position',[30,285,40,15],'tag','leftImR',...
       'callback','maskTiff lImR','userdata',[1,1,Xmid-1,Ydim-1])
   uicontrol('string','rightIm','position',[70,285,40,15],'tag','rightImR',...
       'callback','maskTiff rImR','userdata',[Xmid+1,1,Xmid-1,Ydim-1])
   uicontrol('string','Save image','position',[30,95,80,15],...
       'callback','maskTiff saveImage')
   uicontrol('string','load','position',[30,270,30,15],'tag','ldR',...
       'callback','maskTiff ldReg')
   uicontrol('string','save','position',[60,270,30,15],'tag','sdR',...
       'callback','maskTiff svReg')
   uicontrol('string','erase','position',[90,270,30,15],'tag','erR',...
       'callback','maskTiff erReg')
        
   h = title(fileG, 'interpreter','none');
   set(h,'userdata',fileG)
   
   
    mzoom on
    axis image
    pixvalm
    scale
else
    eval(action)
end

function scale
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


function selectOn
children = get(gcf,'children');
selectStatus = get(findobj(children,'tag','selToggle'),'value');
region = get(findobj(children,'tag','Region'),'userdata');
if selectStatus == 0
    mzoom on
    pixvalm
else
    mzoom off
    delete(findobj(get(gca,'children'),'type','line'))
    [Xback,Yback,Back,rect] = imcrop;
    rect = round(rect);
    bx = rect(1); by = rect(2); bw = rect(3); bh = rect(4);
    X = [bx,bx,bx+bw,bx+bw,bx];
    Y = [by,by+bh,by+bh,by,by];
    line('XData',X,'YData',Y,'color','g')
    set(findobj('tag','Region'),'UserData',rect);
end


function shReg
children = get(gcf,'children');
rect = get(findobj(children,'tag','Region'),'userdata');
if ~isempty(rect)
    bx = rect(1); by = rect(2); bw = rect(3); bh = rect(4);
    X = [bx,bx,bx+bw,bx+bw,bx];
    Y = [by,by+bh,by+bh,by,by];
    line('XData',X,'YData',Y,'color','g')
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
       play6 shReg
    end
end


function erReg
children = get(gcf,'children');
set(findobj(children,'tag','Region'),'UserData',[]);
delete(findobj(children,'type','line','color','green'))


function svReg
children = get(gcf,'children');
rgn = get(findobj(children,'tag','Region'),'userdata');
stk = get(get(gca,'title'),'userdata');
[f,p] = uiputfile([stk(1:end-4),'_rgn.txt']...
      ,'Where to put the region file');
if ischar(f)&&ischar(p)
   dlmwrite([p,f],rgn,'\t')
end



function lImR %selects the left half of the image as a region
children = get(gcf,'children');
delete(findobj(children,'type','line','color','green'))
rect = get(findobj(children,'tag','leftImR'),'userdata');
set(findobj('tag','Region'),'UserData',rect);
maskTiff shReg


function rImR %selects the left half of the image as a region
children = get(gcf,'children');
delete(findobj(children,'type','line','color','green'))
rect = get(findobj(children,'tag','rightImR'),'userdata');
set(findobj('tag','Region'),'UserData',rect);
maskTiff shReg


function saveImage
M = get(gcf,'userdata');
children = get(gcf,'children');
rect = get(findobj(children,'tag','Region'),'userdata');
stk = get(get(gca,'title'),'userdata');
if ~isempty(rect)
    button = questdlg('Save the image on the selected region only?',...
    'Save image on selected region','No');
    if strcmp(button,'Yes')
        bx = rect(1); by = rect(2); bw = rect(3); bh = rect(4);
        M = M(by:by+bh,bx:bx+bw,:);
    end
end

    [ftif,ptif] = uiputfile([stk(1:end-4),'.tif'],...
        'Image file name');
    if ischar(ftif)&&ischar(ptif)
        imwrite(M,[ptif,ftif],'tif','compression','none')
    end



function mask

children = get(gcf,'children');
threshold = get(findobj(children,'tag','scaleth'),'value');
maxIm = get(gcf,'userdata');

stk = get(gcf,'tag');
    
%makes the mask to calculate average fluorescence and std
C_mask = maxIm > threshold;
%C_mask = imfill(C_mask,'holes');
C_label = bwlabel(C_mask);
S = regionprops(C_label,'Area');
%%%Takes the N biggest regions (bigger than nPix/T) to create the mask
N = 10; %Maximum number of subregions
T = 500; %minimum size of subregion (fraction of image), 524 for a 512*512 image
nPix = size(maxIm,1)*size(maxIm,2);
minArea = round(nPix/T);
SR = cat(1,[S.Area],1:size([S.Area],2))';
SR = sortrows(SR,1);
F_mask = zeros(size(maxIm));
for i = 1:N
    if SR(end-i+1,1) > minArea
        F_mask = F_mask | (C_label == SR(end-i+1,2));
    end
end

figure('name','mask','colormap',gray(4))
image(F_mask,'cdatamapping','scaled')
axis image


[f,p] = uiputfile([stk(1:end-4),'_mask.txt'],...
    'Where to put the mask file?');
if ischar(f)&&ischar(p)
    dlmwrite([p,f],F_mask,'\t')
end

