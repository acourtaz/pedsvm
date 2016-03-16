function eventFrequency(varargin)

%Determines the event cumulative and overall frequency 
%from .trc and .txt files

if nargin == 0
    [f,p] = uigetfile('*.txt;*.trc','File with matrix of events');
    if ~f,return,end
    events = dlmread([p,f],'\t');
    prompt = {'Number of frames','Frame interval (in s)',...
        'Frames discarded at the beginning','Frames discarded at the end'};
    [Nfr F_inter frbef fraft] = ...
        numinputdlg(prompt,'Parameters for frequency',1,[200 4 10 10]);
    param = [Nfr F_inter frbef fraft];
elseif nargin ==1
    events = dlmread(varargin{1},'\t');
    param = [200 4 10 10];
elseif nargin == 5
    f = varargin{1};
    events = dlmread(f,'\t');
    param = cell2mat(varargin(2:5));
end

%if strcmp(f(end-3:end),'.txt')
%end

%Recreates an array of events with frame start only, like in annotate.txt files
if strcmp(f(end-3:end),'.trc')
    firstEvent = round(events(2,1));
    lastEvent = round(events(end,1));
    evFr = [];
    for i=firstEvent:lastEvent
        eventTrack = (events(:,1)==i);
        [u,start] = max(eventTrack);
        if u
            evFr = [evFr;events(start,1:2)];
        end
    end
elseif strcmp(f(end-3:end),'.txt')
    evFr = events(:,1:2);
end
TF = param(2)/60; %interval of image acquisition, per minute
totalTime = (param(1)-param(3)-param(4))*TF;
frequency_min = size(evFr,1)/totalTime

figure('name',['Freq ',f])
plot(evFr(:,2).*TF,1:size(evFr,1))
text(totalTime/10,size(evFr,1)*0.8,[num2str(frequency_min),' events/min'])
xlabel('time (min)')
ylabel('# events')

%Makes histogram of frequency per minute
figure('name',['Histo freq per min ',f])
hist((evFr(:,2)-param(3)).*TF,0:floor((param(1)-param(3))*TF))
xlabel('time (min)')
ylabel('events/min')

