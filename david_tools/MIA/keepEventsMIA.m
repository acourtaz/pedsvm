function keepEventsMIA

%Written by DP 7/9/05%
%Generates a MIA objects movie with all the events kept after screening
%(with cleanup and browseEvents for example)

[f,p] = uigetfile('*.txt;*.trc','File with matrix of events');
if ~f,return,end
events = dlmread([p,f],'\t');
[stk,stkd] = uigetfile('*.stk','Choose a Stack (color tagged MIA)');
if ~stk,return,end
movi = stkread(stk,stkd);

xMax = size(movi,1);
yMax = size(movi,2);
[x,y] = meshgrid(1:xMax,1:yMax);
keepEvents = zeros(size(movi));

for i=1:size(events,1)-3
    if events(i,1) == 0
        color = round(events(i,2));
        frame = round(events(i+1,2));
        j=0;
        while (i+j < size(events,1)) & (events(i+j+1,1) > 0)
            fj = frame+j;
            keepEvents(:,:,fj) = keepEvents(:,:,fj) + ...
                (movi(:,:,fj)==color).*color;
            j=j+1;
        end
    end
end

[fle,pth] = uiputfile([stk(1:end-4),'_keep.stk'],...
    'Where to put the new MIA stk file');
if ischar(fle)
    stkwrite(uint16(keepEvents),fle,pth);
end