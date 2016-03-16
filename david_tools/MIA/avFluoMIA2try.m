function avFluoMIA

%Written by DP 6/9/05%

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
output = [];

rCircle = 3;
rAnnulus = 6;
length = 20; %maximum length of tracked vesicle%
before = 10; %number of frames measured before vesicle appearance%

[x,y] = meshgrid(1:size(movi,2),1:size(movi,1));

for i=1:(size(events,1)-3)
    if events(i,1) == 0
        frame = round(events(i+1,2));
        val = zeros(1,length+before+4);
        val(1) = events(i+1,1);
%calculates avFluo before the event ; centered on first frame of event%
        u = min([frame-1,before]);
        x0 = interPolx(events(i+1,3),events(i+1,4),coeff);
        y0 = interPoly(events(i+1,3),events(i+1,4),coeff);
        distance = sqrt((x-x0).^2 + (y-y0).^2);
        circle = distance<rCircle;
        circle = circle(:,:,ones(1,u+1));
        annulus = (distance>=rCircle)&(distance<rAnnulus);
        annulus = annulus(:,:,ones(1,u+1));
        im = double(movi(:,:,frame-u:frame));
        values = sum(sum(im.*circle))/sum(sum(circle(:,:,1)))...
            - sum(sum(im.*annulus))/sum(sum(annulus(:,:,1)));
        val([before+5-u:before+5]) = squeeze(values)';
        j=1; 
%calculates avFluo for the event after the first frame - tracked %
        while (i+j < size(events,1)) & (events(i+j+1,1) > 0) & (j < length)
            x0 = interPolx(events(i+j+1,3),events(i+j+1,4),coeff);
            y0 = interPoly(events(i+j+1,3),events(i+j+1,4),coeff);
            distance = sqrt((x-x0).^2 + (y-y0).^2);
            circle = distance<rCircle;
            annulus = (distance>=rCircle)&(distance<rAnnulus);
            im = double(movi(:,:,frame+j));
            val(before+5+j) = sum(sum(im.*circle))/sum(sum(circle)) -...
                sum(sum(im.*annulus))/sum(sum(annulus));
            j=j+1;
        end
        if (j<length) & (frame+j < size(movi,3))
            v = min([frame+length,size(movi,3)]);
            v = v - frame; %The maximal length of measures
            x0 = interPolx(events(i+j,3),events(i+j,4),coeff);
            y0 = interPoly(events(i+j,3),events(i+j,4),coeff);
            distance = sqrt((x-x0).^2 + (y-y0).^2);
            circle = distance<rCircle;
            circle = circle(:,:,ones(1,v-j));
            annulus = (distance>=rCircle)&(distance<rAnnulus);
            annulus = annulus(:,:,ones(1,v-j));
            im = double(movi(:,:,frame+j:frame+v-1));
            values = sum(sum(im.*circle))/sum(sum(circle(:,:,1)))...
                - sum(sum(im.*annulus))/sum(sum(annulus(:,:,1)));
            val([before+j+5:before+v+4]) = squeeze(values)';
        end  
        val(3)=j;
        output = cat(1,output,val);
        a = [events(i+1,1) j];
        a %just to have a marker while the program is running
    end
end

averageEv = mean(output);
averagePlot = averageEv(5:size(averageEv,2));
frameNumb = -before:length-1;
figure
plot(frameNumb,averagePlot,'-og')
[fle,p] = uiputfile([f(1:end-4),'_av.txt']...
      ,'Where to put the average fluorescence file');
  
if ischar(fle)&ischar(p)
   dlmwrite([p,fle],output,'\t')
end


%Third order polynomials for interpolation

function u = interPolx(x,y,c)
u = c(1) + c(2).*x + c(3).*x.^2 + c(4).*x.^3 +...
   c(5).*y + c(6).*y.^2 + c(7).*y.^3;

function v = interPoly(x,y,c)
v = c(8) + c(9).*x + c(10).*x.^2 + c(11).*x.^3 +...
   c(12).*y + c(13).*y.^2 + c(14).*y.^3;
