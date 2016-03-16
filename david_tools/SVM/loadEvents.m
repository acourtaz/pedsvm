
function [datas, eventsID, events, stk] = loadEvents()
   
   [stk,stkd] = uigetfile('*.stk','Choose the event stack (pH 5)');
   if ~stk,return,end
   M5 = stkread(stk,stkd);
   pause(0.1)
   [stk7,stkd7] = uigetfile('*.stk','Choose the cluster stack (pH 7)');
   if ~stk7,return,end
   M7 = stkread(stk7,stkd7);
   pause(0.1)
  
   %If the movies do not have the same length, the program will cut the
   %end of the longer one(s)
   movieLength = min([size(M5,3),size(M7,3)]);
   M7 = M7(:,:,1:movieLength);
   M5 = M5(:,:,1:movieLength);
   [f,p] = uigetfile('*.trc','File with cleaned matrix of events');
   if ~f,return,end
   sTRC = ~isempty(strfind(f,'.trc'));
   events = dlmread([p,f],'\t');
     
   %%% DEFAULT PARAMETERS FOR THE MINISTACKS %%%
   prompt = {'Size Ministack','Frames before event',...
       'Frames after start','Frames for average (high pH)'...
       'Circle radius','Annulus outer radius',...
       'Lower limit L of the pixel values used for background  (0<= L < H <=1)',...
       'Higher limit H of the pixel values used for background (0<= L < H <=1)'};
   [sizeMini before after av_high rCircle rAnn l_per h_per] = ...
   numinputdlg(prompt,'Parameters for the ministacks',1,[25 20 20 5 3 6 0.2 0.8]);
   param = [sizeMini before after av_high rCircle rAnn l_per h_per];
   
       
      
%%%
   
   
   eventsID = unique(events(:,1));
   
  
 
   h = waitbar(0,'Loading datas...');
   cpt = 0;
   datas = ministack(M5,M7, events,param,sTRC, eventsID(1));
   
   
   for numEv = eventsID(2:end)'
   cpt=cpt+1;
   mini = ministack(M5,M7,events,param,sTRC, numEv);
   if size(mini,2) > size(datas,2)
       mini = mini(:,1:size(datas,2));
   end
   datas = cat(1, datas, mini);
   waitbar(cpt/size(eventsID, 1), h);
   end
   close(h);
   
   
 
end


function [mini] = ministack (M5, M7, events, param, sTRC, numEv)
eventTrack = events(:,1)==numEv;
[isAnEvent, start] = max(eventTrack);

%calculate the ministacks for the event
frame = round(events(start,2));
a = floor(param(1)/2);
xGreen = round(events(start,4))+sTRC;
yGreen = round(events(start,3))+sTRC;
x_miniGreen = max(1,xGreen-a);
y_miniGreen = max(1,yGreen-a);
x_maxiGreen = min(size(M5,1), xGreen+a);
y_maxiGreen = min(size(M5,2), yGreen+a);
t_mini = max(frame-param(2),1);
t_maxi = min(frame+param(3), size(M5,3));
MiniG5 = M5(x_miniGreen:x_maxiGreen,y_miniGreen:y_maxiGreen,t_mini:t_maxi);
MiniG7 = M7(x_miniGreen:x_maxiGreen,y_miniGreen:y_maxiGreen,t_mini:t_maxi);

if xGreen-a < 1
    comp = zeros(1-xGreen+a,size(MiniG5,2),size(MiniG5,3));
    MiniG5 = cat(1,comp,MiniG5);
    MiniG7 = cat(1,comp,MiniG7);
end
if xGreen+a > size(M5,1)
    comp = zeros(xGreen+a-size(M5,1),size(MiniG5,2),size(MiniG5,3));
    MiniG5 = cat(1,MiniG5,comp);
    MiniG7 = cat(1,MiniG7,comp);
end
if yGreen-a < 1
    comp = zeros(size(MiniG5,1),1-yGreen+a,size(MiniG5,3));
    MiniG5 = cat(2,comp,MiniG5);
    MiniG7 = cat(2,comp,MiniG7);
end
if yGreen+a > size(M5,2)
    comp = zeros(size(MiniG5,1),yGreen+a-size(M5,2),size(MiniG5,3));
    MiniG5 = cat(2,MiniG5,comp);
    MiniG7 = cat(2,MiniG7,comp);
end

MiniG5 = reshape(MiniG5,[],1);
MiniG7 = reshape(MiniG7,[],1);
mini = cat(1, MiniG5, MiniG7)';

end