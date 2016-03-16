function out = CCPalpha(radius,depth,alpha)

chi = (radius.*(2.*(1-cos(alpha))).^0.5)./depth;

out = (1-exp(-chi))./chi;