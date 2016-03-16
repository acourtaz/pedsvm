

function TestTransform(action)
global isLeft

if nargin == 0
 
    [f2,p2] = uigetfile('*.tif','Dual image (of beads)');
    if ~f2,return,end
    img = imread([p2,f2]);
    
    [f,p] = uigetfile('*.txt','File with alignment coefficients');
    if ~f
        coeff = [0 1 0 0 0 0 0 0 0 0 0 1 0 0]';
    else coeff = load([p,f]);
    end

    height = size(img,1);
    width = floor(size(img,2)/2);
    [X,Y] = meshgrid(1:width,1:height);
    Xp = interPolx(X,Y,coeff);
    Yp = interPoly(X,Y,coeff);
    M = transformMatrix(Xp,Yp,height,width);

    button = questdlg('Is the Green channel on the left side of the image?');

    isLeft = strcmp(button,'Yes');
            
    imgG = double(img(:,1+width*(~isLeft):width*(1+~isLeft)));
    imgR = double(img(:,1+width*(isLeft):width*(1+isLeft)));
    
    
    newR = reshape(M*imgR(:),height,width);

    figure
    set(gcf,'doublebuffer','on')

    
%Level controls for the left (green) image
    uicontrol('style','slider','callback','TestTransform scale',...
        'min',min(min(imgG)),'max',max(max(imgG)),...
        'value',max(max(imgG)),...
        'userdata',imgG,...    
        'position',[100,10,160,15],'tag','scaleLeft')

    uicontrol('style','text','position',[70,10,30,15],...
        'tag','leftText')

    uicontrol('style','text','position',[15,10,55,15],...
        'string','Green ')

%Level controls for the right (red) image
    uicontrol('style','slider','callback','TestTransform scale',...
        'min',min(min(imgR)),'max',max(max(imgR)),...
        'value',max(max(imgR)),'userdata',newR,...
        'position',[370,10,160,15],'tag','scaleRight')

    uicontrol('style','text','position',[340,10,30,15],...
        'tag','rightText')

    uicontrol('style','text','position',[285,10,55,15],...
        'string','Red ')

    image(imgR,'tag','image')
    axis image
    scale %provides a scaling for the superimposition red-green
    zoom on
else
    eval(action)
    
end

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
   

%Third order polynomial functions for interpolation

function Xpoly = interPolx(X,Y,coeff)
Xpoly = coeff(1) + coeff(2).*X + coeff(3).*X.^2 + coeff(4).*X.^3 +...
   coeff(5).*Y + coeff(6).*Y.^2 + coeff(7).*Y.^3;

function Ypoly = interPoly(X,Y,coeff)
Ypoly = coeff(8) + coeff(9).*X + coeff(10).*X.^2 + coeff(11).*X.^3 +...
   coeff(12).*Y + coeff(13).*Y.^2 + coeff(14).*Y.^3;


function transMtx = transformMatrix(X,Y,nRows,nCols)

X = X(:);
Y = Y(:);

nPixels = nRows*nCols;
rX = floor(X);
rY = floor(Y);
dX = X-rX;
dY = Y-rY;

rX(rX<1) = 1;
rY(rY<1) = 1;
rX(rX>nCols-1) = nCols-1;
rY(rY>nRows-1) = nRows-1;

i = [1:nPixels,1:nPixels,1:nPixels,1:nPixels]';

j = [(rX-1)*nRows+rY;(rX-1)*nRows+rY+1;...
      rX*nRows+rY;rX*nRows+rY+1];

s = [(1-dX).*(1-dY);(1-dX).*dY;...
      dX.*(1-dY);dX.*dY];

transMtx = sparse(i,j,s,nPixels,nPixels,nPixels*4);
