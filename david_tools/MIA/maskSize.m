function maskSize(varargin)

% gives the size of a cell mask in µm2

if nargin == 0
    [f,p] = uigetfile('*.txt','Mask file');
    if ~f,return,end
    mask = dlmread([p,f],'\t');
elseif nargin ==1
    mask = dlmread(varargin);
end

c = findstr(f,'_');
if isempty(c)
     cellNum = f(1:5);
else cellNum = f(1:c(1));
end

pmSize = sum(sum(mask)); % size of the mask in pixels

dlg_title = 'Pixel properties';
prompt = {'Pixel size','Unit (µm2 or nm)'};
default = {'150', 'nm'};
lines = 1;
pixPpt = inputdlg(prompt,dlg_title,lines,default);

pixSize = str2num(pixPpt{1});
pixUnit = pixPpt{2};

if ~(strcmp(pixUnit,'nm')||strcmp(pixUnit,'µm2'))
    disp('Invalid unit');
    return
elseif strcmp(pixUnit,'nm')
    pixSize = (pixSize*pixSize)*10.^-6;    % sets pixel size in µm2
end

mSize = pmSize*pixSize;

[fsize,p] = uiputfile([cellNum,'maskSize.txt'],'Save Mask size');
if ischar(fsize) && ischar(p)
    dlmwrite([p,fsize],mSize)
end

end
