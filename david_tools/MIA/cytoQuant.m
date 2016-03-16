function cytoQuant

% written by Mo 16/10/2013
% takes a maskFluo file and writes a new sheet with pHred2/pHred1 
% values for each couple of images (2 different excitations, same time)

[f,p] = uigetfile('*.xls;*.xlsx','File with fluo measurements');
    if ~f,return,end
[data,txt] = xlsread([p,f],'maskFluo');
data = data(6:end);

% Normalise the even images over the previous image 
%(ex: pHred2/pHred1 or cytoSEP/cyto-mCherry ...) 

quant = [];
for i = 1:2:size(data)
    quant = cat(1,quant,data(i+1)/data(i));
end


c = strfind(f,'_');
if isempty(c)
    c = 5;
end
cellNum = num2str(f(1:c-1));

% find the treatment applied (basal, ppH, calibration...) from file name

treatment = txt{4,2};
treatment = treatment(c+1:end-14);

% Define time vector according to frame numbers entered by user

defaults = [1,12,30]; % 1st frame, last frame and delay between two aquisitions
prompt = {'first frame','last frame','step (in s)'};
[first,last,step] = numinputdlg(prompt,'Aquisition parameters',1,defaults);
step = step/60; % to put the interval in minutes
time = [first:2:last];
time = (((time-1)/2)*step)';

% write data in a new sheet of maskFluo

toWrite = {NaN,'time (min)','val/norm';treatment,NaN,NaN};
if size(time)~= size(quant)
    disp('mismatch between aquisition parameters and number of images taken')
    return
else
    toWrite(2:size(time)+1,2)=num2cell(time);
    toWrite(2:size(quant)+1,3)=num2cell(quant);
end

warning off MATLAB:xlswrite:AddSheet
xlswrite([p,f],toWrite,'cytoQuant');



