function miniStacksMIA

%Written by DP 6/09/05 - updated 4/02/06%
%The image is centered on the start of the event ; it is not tracked%

[f,p] = uigetfile('*.txt;*.trc','File with matrix of events');
if ~f,return,end
events = dlmread([p,f],'\t');
[stk,stkd] = uigetfile('*.stk','Choose a Stack');
if ~stk,return,end
movi = stkread(stk,stkd);
[coFile,coDir] = uigetfile('*.txt','File with alignment coefficients');
if ~coFile
    %warndlg('No alignment correction will be performed','Warning')
    coeff = [0 1 0 0 0 0 0 0 0 0 0 1 0 0]';
else coeff = dlmread([coDir,coFile],'\t');
end

prompt = {'Size Ministack','Frames before event',...
   'Frames after start','Event numbers (separated by commas)'};
answer = ...
    inputdlg(prompt,'Parameters for the ministacks',1,{'25','20','20',''});
sizeStack = str2num(answer{1}); %must be an odd number
before = str2num(answer{2});
after = str2num(answer{3});
eventNums = str2num(answer{4});

if isempty(eventNums)
    lastEvent = round(events(end,1));
    counter = 1:lastEvent;
else
    counter = eventNums;
end
for i=counter
    eventTrack = (events(:,1)==i);
    [u,start] = max(eventTrack);
    if u
        frame = round(events(start,2));
        xa = round(interPoly(events(start,3),events(start,4),coeff))+1;
        ya = round(interPolx(events(start,3),events(start,4),coeff))+1;
        a = floor(sizeStack/2); % 12 if sizeStack=25 %
        x_mini = max(1,xa-a);
        y_mini = max(1,ya-a);
        x_maxi = min(size(movi,1),xa+a);
        y_maxi = min(size(movi,2),ya+a);
        t_mini = max(frame-before,1); %event will start at frame 21 or less%
        t_maxi = min(frame+after,size(movi,3));
        Mini = movi(x_mini:x_maxi,y_mini:y_maxi,t_mini:t_maxi);
        %needs to add zeros%
        if xa-a < 1
            comp = zeros(1-xa+a,size(Mini,2),size(Mini,3));
            Mini = cat(1,comp,Mini);
        end
        if xa+a > size(movi,1)
            comp = zeros(xa+a-size(movi,1),size(Mini,2),size(Mini,3));
            Mini = cat(1,Mini,comp);
        end
        if ya-a < 1
            comp = zeros(size(Mini,1),1-ya+a,size(Mini,3));
            Mini = cat(2,comp,Mini);
        end
        if ya+a >size(movi,2)
            comp = zeros(size(Mini,1),ya+a-size(movi,2),size(Mini,3));
            Mini = cat(2,Mini,comp);
        end
        stkwrite(Mini,[stk(1:end-4),'_',num2str(i),'.stk'],stkd);
    end
end
        
%Third order polynomials for interpolation

function u = interPolx(x,y,c)
u = c(1) + c(2).*x + c(3).*x.^2 + c(4).*x.^3 +...
   c(5).*y + c(6).*y.^2 + c(7).*y.^3;

function v = interPoly(x,y,c)
v = c(8) + c(9).*x + c(10).*x.^2 + c(11).*x.^3 +...
   c(12).*y + c(13).*y.^2 + c(14).*y.^3;