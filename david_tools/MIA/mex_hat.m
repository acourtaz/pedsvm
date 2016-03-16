function area = mex_hat(sizeIm,circleHat,annHat,xh,yh)

[x,y] = meshgrid(1:sizeIm,1:sizeIm);
distance = sqrt((x-xh).^2 + (y-yh).^2);
circle = distance < circleHat;
annulus = distance >=circleHat & distance < annHat;
hat = circle -annulus;
area = [sum(sum(circle)) sum(sum(annulus))];
%mimage(hat)
