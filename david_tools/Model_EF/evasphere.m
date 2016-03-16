function out = evasphere(radius,dist,depth)

ratio = radius./depth;
out = 4.*pi.*(exp(-(radius+dist)./depth)).*(depth.^3).*...
   (ratio.*cosh(ratio)-sinh(ratio));
