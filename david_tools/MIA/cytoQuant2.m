function cytoQuant2

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

defaults = [12,40,12,12,12,12,12,12,12,12,12,12,30]; 
prompt = {'baseline','ppH','HBS(1)','MBS','HBS(2)','cal 7.5(1)',...
    'cal 7.25','cal 7','cal 6.75','cal 6.5','cal 6.25','cal 7.5(2)',...
    'delay (in s)'};
[base,ppH,HBS1,MBS,HBS2,cal1,cal2,cal3,cal4,cal5,cal6,cal7,delay] = ...
    numinputdlg(prompt,'Aquisition paradigm (in fr)',1,defaults);
treatFr=[base,ppH,HBS1,MBS,HBS2,cal1,cal2,cal3,cal4,cal5,cal6,cal7];
delay = delay/60; % to put the interval in minutes
if sum(treatFr) ~= size(data)
    disp('wrong number of frames')
    return
end


treatTiming = prompt(1);
j=1;
for i = 1:sum(treatFr)/2
    if i == size(treatTiming,2)+(treatFr(j)/2)
        treatTiming(i) = prompt(j+1);
        j=j+1;
    end
end
treatTiming=treatTiming';

end
% for i = 1:sum(treatFr)/2
%     if i == treatFr(j)/2
%         treatTiming(sum(treatFr(1:j)/2)+1) = prompt(j+1);
%         j=j+1;
%     end
% end
% end


%defaults = [12,40,12,12,12,12,12,12,12,12,12,12,30]; 

%[base,ppH,HBS1,MBS,HBS2,cal1,cal2,cal3,cal4,cal5,cal6,cal7]
%base+ppH+HBS1+MBS+HBS2+cal1+cal2+cal3+cal4+cal5+cal6+cal7

% treatments = {'baseline','ppH','HBS(1)','MBS','HBS(2)','cal 7.5(1)',...
%     'cal 7.25','cal 7','cal 6.75','cal 6.5','cal 6.25','cal 7.5(2)'}


% treatment = txt{4,2};
% treatment = treatment(c+1:end-14);
% 
% time = [first:2:size(data)];
% time = (((time-1)/2)*delay)';
% % 
% % Define time vector according to frame numbers entered by user
% 
% defaults = [1,12,30]; % 1st frame, last frame and delay between two aquisitions
% prompt = {'first frame','last frame','step (in s)'};
% [first,last,step] = numinputdlg(prompt,'Aquisition parameters',1,defaults);
% step = step/60; % to put the interval in minutes
% time = [first:2:last];
% time = (((time-1)/2)*step)';
% 
% % write data in a new sheet of maskFluo
% 
% toWrite = {NaN,'time (min)','val/norm';treatment,NaN,NaN};
% if size(time)~= size(quant)
%     disp('mismatch between aquisition parameters and number of images taken')
%     return
% else
%     toWrite(2:size(time)+1,2)=num2cell(time);
%     toWrite(2:size(quant)+1,3)=num2cell(quant);
% end
% 
% warning off MATLAB:xlswrite:AddSheet
% xlswrite([p,f],toWrite,'cytoQuant');



