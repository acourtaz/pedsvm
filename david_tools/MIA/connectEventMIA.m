function connectEventMIA

[f,p] = uigetfile('*.txt;*.trc','File with matrix of events');
if ~f,return,end
events = dlmread([p,f],'\t');
[stk,stkd] = uigetfile('*.stk','MIA stack of tracked structures (CCPs)');
if ~stk,return,end
CCPs = stkread(stk,stkd);
[coFile,coDir] = uigetfile('*.txt','File with alignment coefficients');
if ~coFile
    %warndlg('No alignment correction will be performed','Warning')
    coeff = [0 1 0 0 0 0 0 0 0 0 0 1 0 0]';
else coeff = dlmread([coDir,coFile],'\t');
end
output = [];
SE = strel('square',3);
CCPs = imdilate(CCPs,SE);


for i=1:(size(events,1)-3)
    if events(i,1) == 0
        val = zeros(1,6);
        val(1) = events(i+1,1);
        frame = round(events(i+1,2));
        val(2) = frame;
        xEvent = round(events(i+1,3))+1;
        yEvent = round(events(i+1,4))+1;
        color = CCPs(yEvent,xEvent,frame);
        if color > 0
            val(3) = color;
            j=1;p=1;
            while (i+j < size(events,1)) & (events(i+j+1,1) > 0)
                xEvent = round(events(i+j+1,3))+1;
                yEvent = round(events(i+j+1,4))+1;
                if CCPs(yEvent,xEvent,frame+j)==color
                    p=p+1;
                end
                j=j+1;
            end
            val(4)=j;
            fraction = p/j;
            val(5)=fraction;
        end
        output = cat(1,output,val);
        if color > 0
            a = [events(i+1,1) fraction];
        else
            a = [events(i+1,1) 0];
        end
        a %just to have a marker while the program is running
    end
end

[fle,p] = uiputfile([f(1:end-4),'_ccp.txt']...
      ,'Where to put the file with connected events');
  
if ischar(fle)&ischar(p)
   dlmwrite([p,fle],output,'\t')
end