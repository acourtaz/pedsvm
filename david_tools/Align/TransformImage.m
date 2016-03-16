function transformImage(varargin)

%Transforms the right part of an image acquired with DualView 
%to match the left image part
%TransformImage('filename.tif','coeff.txt')
%TransformImage('filename.tif')
%TransformImage
%
%Transforms the image in filename.tif with the third order polynomial 
%fuction using the coefficients in coeff.txt

if nargin == 0
    [f2,p2] = uigetfile('*.tif','Image to transform (align)');
    if ~f2,return,end
    img = imread([p2,f2]);
    
    [f,p] = uigetfile('*.txt','File with alignment coefficients');
    if ~f
        coeff = [0 1 0 0 0 0 0 0 0 0 0 1 0 0]';
    else coeff = load([p,f]);
    end
elseif nargin == 1
    img = imread(varargin{1});
    [f,p] = uigetfile('*.txt','File with alignment coefficients');
    if ~f
        coeff = [0 1 0 0 0 0 0 0 0 0 0 1 0 0]';
    else coeff = load([p,f]);
    end
elseif nargin == 2
    img = imread(varargin{1});
    coeff = load(varargin{2});
end

    height = size(img,1);
    width = size(img,2);
    imgD = double(img);
    [X,Y] = meshgrid(1:width,1:height);
    Xp = interPolx(X,Y,coeff);
    Yp = interPoly(X,Y,coeff);
    M = transformMatrix(Xp,Yp,height,width);
    sprImg = reshape(M*imgD(:),height,width);
    newImg = uint16(sprImg);

    [fo,po] = uiputfile('*.tif','Transformed image file');
    if ~fo,return,end
    imwrite(newImg,[po,fo],'tif','compression','none')


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