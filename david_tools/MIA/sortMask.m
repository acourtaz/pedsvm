function sortMask(action)

%Cuts mask into several regions

if nargin == 0
    [fm,pm,fim] = uigetfile('*.txt;*.tif','Mask file');
    if ~fm,return,end
    isTxt = strfind(fm(end-4:end), 'txt');
    isTif = strfind(fm(end-4:end), 'tif');
    if isTxt
        mask = dlmread([pm,fm],'\t');
    elseif isTif
        mask = imread([pm,fm]);
    end
    if max(max(mask)) > 10000
        mask = double(mask > 64000);
    else
        mask = double(mask > 0);
    end
    
%elseif nargin == 2
%    events = dlmread(varargin{1},'\t');
%    fm = varagin{2};
%    mask = dlmread(varargin{2},'\t');
h = figure('name',fm);
set(h,'colormap',gray(4))
image(mask,'cdatamapping','scaled')
axis image

    uicontrol('string','Create ROI','position',[15,300,70,15],...
        'callback','sortMask createROI','userdata',[],'tag','createROI')
    uicontrol('string','Load ROI','position',[15,280,70,15],...
        'callback','sortMask loadROI')
    uicontrol('string','Save ROI','position',[15,260,70,15],...
        'callback','sortMask saveROI','tag','mask','userdata',mask)
    uicontrol('string','Sort Mask','position',[15,220,70,15],...
        'callback','sortMask sortNOW','tag','sortNOW','userdata',fm)

else
    eval(action)
end
end


%[ROI,x,y] = roipoly;
%line('Xdata',x,'Ydata',y,'color','g')



% for i = 1:size(events,1)
%     xi = round(events(i,3));
%     yi = round(events(i,4));
%     if ROI(yi,xi) == 1 && mask(yi,xi) == 1
%         ev1 = cat(1,ev1,events(i,:));
%     elseif ROI(yi,xi) == 0 && mask(yi,xi) == 1
%         ev2 = cat(1,ev2,events(i,:));
%     else
%         ev3 = cat(1,ev3,events(i,:));
%     end
% end

function createROI
children = get(gcf,'children');
delete(findobj(children,'type','line','color','g'))

[ROI,x,y] = roipoly;
line('Xdata',x,'Ydata',y,'color','g')
ROIxy = {ROI,x,y};
set(findobj(children,'tag','createROI'),'userdata',ROIxy)
end

function loadROI
children = get(gcf,'children');
mask = get(findobj(children,'tag','mask'),'userdata');
[fxy,pxy] = uigetfile('*.txt','ROI polygon file');
polyXY = dlmread([pxy,fxy],'\t');
x = polyXY(:,1);
y = polyXY(:,2);
ROI = poly2mask(x,y,size(mask,1),size(mask,2));
delete(findobj(children,'type','line','color','g'))
line('Xdata',x,'Ydata',y,'color','g')
ROIxy = {ROI,x,y};
set(findobj(children,'tag','createROI'),'userdata',ROIxy)
end

function saveROI
children = get(gcf,'children');
ROIxy = get(findobj(children,'tag','createROI'),'userdata');
fm = get(findobj(children,'tag','sortNOW'),'userdata');
c = strfind(fm,'_'); 
if ~isempty(c)
    c = c(1)-1;
else
    c = size(fm,2)-9;
end
x = ROIxy{2};
y = ROIxy{3};
polyXY = cat(2,x,y);
[fs,ps] = uiputfile('*.txt','ROI polygon',[fm(1:c),'_poly.txt']);
if ischar(fs)&&ischar(ps)
   dlmwrite([ps,fs],polyXY,'\t')
end
end

function sortNOW
children = get(gcf,'children');
ROIxy = get(findobj(children,'tag','createROI'),'userdata');
mask = get(findobj(children,'tag','mask'),'userdata');
isCheck = 0; 
if isempty(ROIxy)
    m = size(mask);
    [ROI,x,y] = roipoly(ones(m),[1,1,m(2),m(2)],[1, m(1), m(1),1]); 
    ROIxy = {ROI,x,y};
    line('Xdata',x,'Ydata',y,'color','g')
    isCheck = 1; 
end
fm = get(findobj(children,'tag','sortNOW'),'userdata');
mask = get(findobj(children,'tag','mask'),'userdata');
ROI = ROIxy{1};

ROImask = ROI.*mask;
%ROImask = (ROImask == 1);
[fr,pr] = uiputfile([fm(1:end-4),'_ROI',fm(end-3:end)],'mask within ROI');
if ischar(fr)&&ischar(pr)
    if strfind(fm(end-4:end), 'txt')
        dlmwrite([pr,fr],ROImask,'\t')
    elseif strfind(fm(end-4:end), 'tif')
        imwrite(ROImask,[pr,fr])
    end
end

nROImask = mask-ROImask;
%nROImask = (nROImask == 1);
[fnr,pnr] = uiputfile([fm(1:end-4),'_nROI',fm(end-3:end)],'mask outside of ROI'); 
if ischar(fnr)&&ischar(pnr)
    if strfind(fm(end-4:end), 'txt')
        dlmwrite([pnr,fnr],nROImask,'\t')
    elseif strfind(fm(end-4:end), 'tif')
        imwrite(nROImask,[pnr,fnr])
    end
end
end

 



