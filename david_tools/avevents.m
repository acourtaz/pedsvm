function AvEvents

[fle,pth] = uigetfile('*.txt','Event Coordinates (from Annotate)');
if ~fle,return,end

events = load([pth,fle]);

[stk,stkd] = uigetfile('*.stk','Choose a Stack');
if ~stk,return,end

movi = stkread(stk,stkd);

rCircle = 3;
rAnnulus = 8;
numberFrame = 2;
output = [];

for i=1:size(events,1);
    [x,y] = meshgrid(1:size(movi,2),1:size(movi,1));
    distance = sqrt((x-events(i,1)).^2 + (y-events(i,2)).^2);
    circle = distance<rCircle;
    annulus = (distance>=rCircle)&(distance<rAnnulus);
    avCircle = 0; avAnnulus = 0;
    for j=1:numberFrame;
        im = double(movi(:,:,events(i,3)+j-1));
        avCircle = avCircle + sum(sum(im.*circle))/sum(sum(circle));
        avAnnulus = avAnnulus + sum(sum(im.*annulus))/sum(sum(annulus));
    end
    avCircle = avCircle/numberFrame;
    avAnnulus = avAnnulus/numberFrame;
    output = [output;avCircle,avAnnulus];
end

[f,p] = uiputfile([stk(1:end-4),'_avfluo.txt']...
      ,'Where to put the textfile with average fluorescence');
  
if ischar(f)&ischar(p)
   dlmwrite([p,f],output,'\t')
end
