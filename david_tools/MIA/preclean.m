function preclean

%written by DP - 18/02/2014
%Adds potential events (beginning of cleanup5) to MIA trc file

%screens events generated by MIA according to various criteria (see code)
%and generates a .trc file with the events passing the screen
%generates also a summary excel file where all the parameters and results
%are written

%This function works with the two types of trc files: with or without 
%the '0' lines. It will write the '0' lines if they were present.

[f,p] = uigetfile('*.txt;*.trc','File with matrix of events (e.g. MIA.trc file');
if ~f,return,end
events = dlmread([p,f],'\t');
fk = strfind(f,'_');
cellNum = f(1:fk(1)-1); %the number of the cell analysed
[stk,stkd] = uigetfile('*.stk','Stack of events (TfR5)');
if ~stk,return,end
[stkMIA,stkdMIA] = ...
    uigetfile('*.stk','Stack of clusters (TfR7, MIA objects)');
if ~stkMIA
    warndlg('no screen for pre-existing cluster will be performed')
    clusters = [];
else
    clusters = stkread(stkMIA,stkdMIA);
end
movi = stkread(stk,stkd);
moviLength = size(movi,3);
output = zeros(size(events));

rCircle = 3; %Radius of the circle for fluorescence quantification, in pixels
rAnn = 6; %radius of the Annulus
Edge = 7; %Minimal distance from the edge of the image
sigNoise = 5; %Signal/Noise ratio estimated on TfR5 movie
slopeMax = 1; %Maximum slope for fluorescence increase
thClst = 0.2; %Threshold for pre-existing cluster (0<T<=1) taken on TfR7 MIA movie
minFrame = 5; % Minimal number of frames before the event
%It has to be bigger than 5 
%(the number of frames used to estimate local background)
maxFrame = 5; %Minimal number of frames after start of event
fMIA = 3; %Fold increase in the 'integrated intensity' (column 6 in the .trc file)
%Can detect potential events if quenching is not absolute (TfR-pHuji)
defaults = [rCircle,rAnn,Edge,sigNoise,slopeMax,thClst,minFrame,maxFrame,fMIA];
prompt = {'Circle radius','Annulus outer radius',...
    'Minimal distance from the edge of the image',...
    'Signal/Noise ratio',...
    'Maximum slope for fluorescence increase',...
    'Threshold for pre-existing cluster (0<T<=1)',...
    'Minimal number of frames before event (>5)',...
    'Minimal number of frames after start of event',...
    'Fold increase in intensity of MIA object'};
[rCircle,rAnn,Edge,sigNoise,slopeMax,thClst,minFrame,maxFrame,fMIA] = ...
numinputdlg(prompt,'Parameters for removing non qualified events',1,defaults);
pause(1)
params = [rCircle,rAnn,Edge,sigNoise,slopeMax,thClst,minFrame,maxFrame,fMIA];
[x,y] = meshgrid(1:2*rAnn+1);

if events(1,1) == 0 %obsolete, when trc files had 0 lines
    firstEvent = round(events(2,1));
else
    firstEvent = round(events(1,1));
end
lastEvent = round(events(end,1));

%Added to cleanup5: looks for potential events corresponding to a fold
%increase of integrated intensity larger than fMIA (default 3)
%It can account for the incomplete quenching of TfR-pHuji 
%or TfR-SEP by trypan purple

events(:,5) = events(:,1); %Keeps the original event numbers from MIA 
%in column 5 (areas, unused) before renaming the events with the added ones
ev1 = events(1:end-1,[1 6]);
ev2 = events(2:end,[1 6]);
ratio = (ev1(:,1)-ev2(:,1)+1).*(ev2(:,2)./ev1(:,2));

added = [];
nfLE = size(num2str(lastEvent),2); % number of figures of last event
%e.g. if lastEvent = 2543, it has 4 figures (254, 3 figures)
% a figure = un chiffre
nad = []; % numbers of added events
newStart = find(ratio > fMIA)';
for i = newStart %If newStart is empty, no error
    evNum = events(i+1,1);
    isEv = (events(:,1) == evNum);
    evLength = sum(isEv(i+1:end));
    if evLength >= 3
        new = events(i+1:i+evLength,:);
        new(:,5) = new(:,1); %Keeps the original event number from MIA
        oEv = num2str(evNum);
        aEv = 10^(1+nfLE-size(oEv,2));
        addEv = [num2str(aEv),oEv];
        oEv = addEv(3:end); %eg 0012 if evNum = 12 & lastEvent has 4 figures
        new(:,1) = str2double(addEv);
        if ~isempty(added)
            while max(added(:,1)==new(1,1))
                aEv = str2double(addEv(1:end-nfLE));
                aEv = aEv+10;
                addEv = [num2str(aEv),oEv];
                new(:,1) = str2double(addEv);
            end
        end
        nad = [nad,new(1,1)];
        added = [added;new];
    end
end
count2 = zeros(9,1); % To count the number of events added, then rejected with the screen
if ~isempty(newStart)
    events = cat(1,events,added);
    count2(1) = size(nad,2); % number of added events
end

[f1,p1] = uiputfile([f(1:end-4),'preCln',f(end-3:end)],'file with first frame of events');
if ischar(f1)&&ischar(p1)
   dlmwrite([p1,f1],events,'\t')
end