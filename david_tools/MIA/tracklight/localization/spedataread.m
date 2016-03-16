function [data,parameter] = spedataread (filename)
% function [data parameter] = spedataread (filename)
% read data files of type WinView and returns size
% in base of userdataread.m
% data: datamatrix
%       parameter ... [sx,sy,nx,ny,np]
%       param:
%              sx ... Imagesize in x- direction
%              sy ... -----"-----  y- direction
%              nx ... Number of subimages in x- direction
%              ny ... Number of subimages in y- direction
%              np ... Number of subimages for different polarizations
% for trackdiffusion.m 
% MR jan 06
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Open file for reading
fi = fopen(filename,'r','ieee-le');
if fi<3
	error('File not found or readerror.');
	return  
end
pID_WinView = 2996;
fseek(fi,pID_WinView,-1);
WinID = fread(fi,1,'int32')';

%some pointers
HeaderSz = 4100;
pXdim    = 42;
pDType	= 108;
ptitle   = 200;
pcomment = ptitle+80;
pYdim    = 656;
pNfram   = 1446;
pNumROI	= 1510;
DataType = {'single' 'int32' 'int16' 'uint16'};

% read file - header
fseek(fi,pXdim,-1);
Xdim = fread(fi,1,'uint16');
fseek(fi,pYdim,-1);
Ydim = fread(fi,1,'uint16');
fseek(fi,pNfram,-1);
NFram = fread(fi,1,'int32');
fseek(fi,pNumROI,-1);
NumROI = max([1,fread(fi,1,'int16')]);
parameter=[Xdim,Ydim*NFram,1,NFram,NumROI];

% Reading the datamatrix
fseek(fi,pDType,-1);
nDataType = fread(fi,1,'int16');
sDataType = char(DataType(nDataType+1));
fseek(fi,HeaderSz,-1);
data = fread(fi,[Xdim,Ydim*NFram],sDataType)';

fclose(fi);% end of file
   

