function out = CCP(radius,depth,relat_hight)

chi = (2.*radius.*relat_hight)./depth;

out = (1-exp(-chi))./chi;