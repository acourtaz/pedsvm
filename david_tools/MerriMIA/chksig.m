function [chk] = chksig(mini,ta);

dim = 25;
frbef = 3;                                          % number of frames prior to ta to test
fraft = 2;                                          % number of frames after ta to test

[circ,ann,circpix,annpix] = roi(dim);

tmpmini = mini(:,:,ta - frbef:ta + fraft);          % extract a substack centered on the alignment frame

for a = 1:size(tmpmini,3);                          % extract the fluorescence data
    im = tmpmini(:,1:dim,a);
    roifl = sum(sum(circ.*im))/circpix;
    annfl = sum(sum(ann.*im))/annpix;
    fl(a) = roifl - annfl;
end

sigbef = fl(frbef);                                 % find strength of signal (needs updating - should ...
sigaft = fl(frbef + 1);                             % ... measure signal:noise ratio?)

fl = fl';                                           % need fl data in a vector to calc regression
flaft = fl(frbef + 1:frbef + fraft + 1);            % calc least squares linear regression for the ...
X = [ones(fraft + 1,1) (1:1:fraft + 1)'];           % three data points following scission
a = X\flaft;
slope = a(2);                                       % ... the slope

if sigaft > 1.75*sigbef & slope < 20;               % check signal and slope
    chk = 1;
else
    chk = 0;
end

function [circ,ann,circpix,annpix] = roi(dim);
circ = zeros(dim,dim);
midx = (0.5*(size(circ,1))) + 0.5;
midy = (0.5*(size(circ,2))) + 0.5;
x = 1;
y = 1;
for y = 1:25;
    for x = 1:25;
        dist = (((y - midy)^2 + (x - midx)^2) ^ 0.5);
        if dist <= 6.5;
            circ(y,x) = 1;
        end
    x = x + 1;
    end
    y = y + 1;
end
circpix = sum(sum(circ));
sizecircpix = size(circpix);

ann = zeros(dim,dim);
midx = (0.5*(size(ann,1))) + 0.5;
midy = (0.5*(size(ann,2))) + 0.5;
x = 1;
y = 1;
for y = 1:25;
    for x = 1:25;
        dist = (((y - midy)^2 + (x - midx)^2) ^ 0.5);
        if  6 <= dist & dist <= 12;
            ann(y,x) = 1;
        end
    x = x + 1;
    end
    y = y + 1;
end
annpix = sum(sum(ann));
sizeannpix = size(annpix);