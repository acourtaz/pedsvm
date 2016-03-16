function testbeadimage

[f2,p2] = uigetfile('*.tif','Bead Image');
if ~f2,return,end

img = imread([p2,f2]);
sizeX = floor(size(img,2)/2);
imgL = double(img(:,1:sizeX));
imgR = double(img(:,sizeX+1:end));


figure
set(gcf,'doublebuffer','on')

%Level controls for the left (red) image
uicontrol('style','slider','callback','testbeadimage scale',...
   'min',1,'max',2^16,'value',max(max(imgL)),...
   'userdata',imgL,...    
   'position',[80,10,180,15],'tag','scaleLeft')

uicontrol('style','text','position',[50,10,30,15],...
   'tag','leftText')

uicontrol('style','text','position',[15,10,35,15],...
   'string','Left')

%Level controls for the right (green) image
uicontrol('style','slider','callback','testbeadimage scale',...
   'min',1,'max',2^16,'value',max(max(imgR)),...
   'userdata',imgR,...
   'position',[350,10,180,15],'tag','scaleRight')

uicontrol('style','text','position',[320,10,30,15],...
   'tag','rightText')

uicontrol('style','text','position',[285,10,35,15],...
   'string','Right')

image(imgR,'tag','image')
axis image 
scale %provides a scaling for the superimposition red-green
zoom on

function scale
global isLeft
children = get(gcf,'children');
scaleLeft = findobj(children,'tag','scaleLeft');
scaleRight = findobj(children,'tag','scaleRight');
leftText = findobj(children,'tag','leftText');
rightText = findobj(children,'tag','rightText');
img = findobj(children,'tag','image');

newR = get(scaleRight,'userdata');
imgG = get(scaleLeft,'userdata');
right = get(scaleRight,'value');
left = get(scaleLeft,'value');
set(leftText,'string',int2str(left))
set(rightText,'string',int2str(right))

red = imgG/left;
red(red>1) = 1;
green = newR/right;
green(green>1) = 1;
blue = zeros(size(red));

if isLeft
    rgb = cat(3,red,green,blue);
else
    rgb = cat(3,green,red,blue);
end
set(img,'cdata',rgb)