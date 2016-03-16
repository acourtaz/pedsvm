% This Matlab file demomstrates the level set method in Li et al's paper
%    "Level Set Evolution Without Re-initialization: A New Variational Formulation"
%    in Proceedings of CVPR'05, vol. 1, pp. 430-436.
% Author: Chunming Li, all rights reserved.
% E-mail: li_chunming@hotmail.com
% URL:  http://vuiis.vanderbilt.edu/~licm/

clear all;
close all;
Img = imread('twoObj.bmp');  % The same cell image in the paper is used here
Img=double(Img(:,:,1));
sigma=1.5;    % scale parameter in Gaussian kernel for smoothing.
G=fspecial('gaussian',15,sigma);
Img_smooth=conv2(Img,G,'same');  % smooth image by Gaussiin convolution
[Ix,Iy]=gradient(Img_smooth);
f=Ix.^2+Iy.^2;
g=1./(1+f);  % edge indicator function.

epsilon=1.5; % the papramater in the definition of smoothed Dirac function

timestep=5;  % time step
mu=0.2/timestep;  % coefficient of the internal (penalizing) energy term P(\phi)
          % Note: the product timestep*mu must be less than 0.25 for stability!

lambda=5; % coefficient of the weighted length term L(\phi)
alf=3;  % coefficient of the weighted area term A(\phi);
        % Note: Choose smaller value of alf (\nu in the paper) if there are weak object boundaies, such as the cell image in demo 1.

[nrow, ncol]=size(Img);
figure;imagesc(Img, [0, 255]);colormap(gray);hold on;
text(10,10,'Left click to get points, right click to get end point');

% mouse click to specify initial contour/region
BW = roipoly;   % get a region R inside a polygon, BW is a binary image with 1 and 0 inside or outside the polygon;
c0=4; % the constant value used to define binary level set function;
initialLSF= c0*2*(0.5-BW); % initial level set function: -c0 inside R, c0 outside R;

% initialLSF = binaryInitial(con, nrow, ncol);

u=initialLSF;

[c,h] = contour(u,[0 0],'r');
u=initialLSF;
figure;imagesc(Img, [0, 255]);colormap(gray);hold on;
[c,h] = contour(u,[0 0],'r');                          
title('Initial contour');

% start level set evolution
for n=1:300
    u=EVOLUTION(u, g ,lambda, mu, alf, epsilon, timestep, 1);    
    if mod(n,20)==0
        pause(0.001);
        imagesc(Img, [0, 255]);colormap(gray);hold on;
        [c,h] = contour(u,[0 0],'r'); 
        iterNum=[num2str(n), ' iterations'];        
        title(iterNum);
        hold off;
    end
end
imagesc(Img, [0, 255]);colormap(gray);hold on;
[c,h] = contour(u,[0 0],'r'); 
totalIterNum=[num2str(n), ' iterations'];  
title(totalIterNum);
