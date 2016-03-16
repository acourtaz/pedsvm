function R = rainbow(m)

%Rainbow(m) is a m-by-3 matrix containing a colormap defined by D.Perrais
%reproducing the pseudocolor look-up table used in Metamorph.
%It uses the function usercolormap.m that interpolates colormap between
%set values (see comments in this function)

if nargin < 1
    m = 256;
end
color1 = [0 0 0]; %black
color2 = [0.25 0.04 0.5];
color3 = [0.5 0 1];
color4 = [0.5 0.5 1];
color5 = [0 1 1]; %cyan
color6 = [0 0.5 0.75];
color7 = [0 0.6 0.5];
color8 = [0.25 0.7 0.375];
color9 = [0.5 0.8 0.25];
color10 = [0.75 0.9 0.125];
color11 = [1 1 0]; %yellow
color12 = [1 0.75 0];
color13 = [1 0.5 0];
color14 = [1 0.25 0];
color15 = [1 0 0]; %red
color16 = [1 0.5 0.5];
color17 = [1 1 1]; %white

R = usercolormap(color1,color2,color3,color4,color5,color6,color7,...
    color8,color9,color10,color11,color12,color13,color14,color15,...
    color16,color17);